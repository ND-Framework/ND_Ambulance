BodyBonesDamage = lib.table.deepclone(Data.boneSettings)
local randomDeathAnim = Data.deathAnims[math.random(1, #Data.deathAnims)]
local bodyAttached = false
local bleeding = 0
local downAnim
local deathState
local lastSync
local bleedOutTimer

local function getInjuredBoneData(bones)
    local data = {}
    for bone, info in pairs(bones) do
        if info.severity > 0 then
            if not data[bone] then
                data[bone] = info
            else
                local limb = data[bone]
                limb.suffocating = info.suffocating
                limb.fracture = info.fracture
                limb.burn = info.burn
                limb.bleeding = info.bleeding
                limb.severity = info.severity
            end
        end
    end
    return data
end

local function setDead(ped)
    SetEntityHealth(ped, 100)
    CreateThread(function()
        while DoesEntityExist(ped) and GetEntityHealth(ped) == 100 do
            SetPedDiesWhenInjured(ped, false)
            -- FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetEveryoneIgnorePlayer(ped, true)
            SetPedCanBeTargetted(ped, false)
            SetEntityCanBeDamaged(ped, false)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdollFromPlayerImpact(ped, false)
            Wait(10)
        end
    end)
end

local function setDeathState(newState)
    local ped = PlayerPedId()
    if cache.vehicle then
        newState = "vehicle"
    end
    if newState == "dead" and downAnim then
        StopAnimTask(ped, downAnim[1], downAnim[2], 1.0)
        downAnim = nil
    end
    deathState = newState

    local state = Player(cache.serverId).state
    state:set("isDead", deathState, true)
    state:set("injuries", getInjuredBoneData(BodyBonesDamage), true)
    LocalPlayer.state.dead = true

    local anim = randomDeathAnim[deathState]
    local dict, clip = anim[1], anim[2]
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, clip, 8.0, 8.0, -1, 1, 0, false, false, false)
    setDead(ped)
    return {dict, clip}
end

local function hurtWalk()
    for _, info in pairs(BodyBonesDamage) do        
        if info.causeLimp and info.severity > 1.0 then
            lib.requestAnimSet("move_m@injured")
            SetPedMovementClipset(cache.ped, "move_m@injured", 1)
            SetPlayerSprint(cache.playerId, false)
            SetPedMoveRateOverride(cache.ped, 0.95)
            return true
        end
    end
    if GetPedMovementClipset(cache.ped) == `move_m@injured` then
        SetPedMoveRateOverride(cache.ped, 1.0)
        ResetPedMovementClipset(cache.ped, 0)
    end
end

local function updateBodyDamage()
    if not lastSync or (GetGameTimer()-lastSync) < 5000 then return end
    lastSync = GetGameTimer()
    local state = Player(cache.serverId).state
    state:set("injuries", getInjuredBoneData(BodyBonesDamage), true)
end

function GetTotalDamageType(body, damageType)
    if not body then return 0 end

    local value = 0
    for _, info in pairs(body) do        
        if info[damageType] then
            value += info[damageType]
        end
    end
    return value
end

CreateThread(function()
    local notifyInfo = {
        id = "playerBleeding",
        icon = "droplet",
        iconColor = "#eb4034",
        duration = 4000,
        position = "bottom-right"
    }
    while true do
        Wait(3000)
        if bleeding > 0 then
            local bleed = math.floor(bleeding/2)
            if bleed > 0 and (GetEntityHealth(cache.ped)-100) > bleed and not deathState then
                ApplyDamageToPed(cache.ped, bleed)
                notifyInfo.title = "You're bleeding!"
                NDCore.notify(notifyInfo)
            elseif bleed > 0 and not deathState then
                bleedOutTimer = GetCloudTimeAsInt()
                setDeathState("down")
                notifyInfo.title = "You're need help!"
                NDCore.notify(notifyInfo)
            elseif bleed > 0 and deathState == "down" and bleedOutTimer and bleedOutTimer-GetCloudTimeAsInt() > 120 then
                setDeathState("dead")
                notifyInfo.title = "You bled out!"
                NDCore.notify(notifyInfo)
            end
        end
    end
end)

exports("getLastDamagingWeapon", function(ped)
    for weapon, info in pairs(Data.weapons) do
        if HasPedBeenDamagedByWeapon(ped, weapon, 0) then
            ClearEntityLastDamageEntity(ped)
            return info
        end
    end
end)

exports("getBodyDamage", function()
    return BodyBonesDamage
end)

exports("resetBodyDamage", function()
    BodyBonesDamage = lib.table.deepclone(Data.boneSettings)
    bleeding = 0
    deathState = nil
    downAnim = nil
    local state = Player(cache.serverId).state
    state:set("injuries", nil, true)
end)

exports("updateBodyDamage", function(bone, damageWeapon)
    local boneName = Data.boneParts[bone]
    if not boneName then return end
    local boneInfo = BodyBonesDamage[boneName]
    local updateDamageOn = {"fracture", "burn", "bleeding", "suffocating"}
    for i=1, #updateDamageOn do
        local item = updateDamageOn[i]
        if damageWeapon[item] then
            if not boneInfo[item] then
                boneInfo[item] = 0
            end
            boneInfo[item] += damageWeapon.severity
            boneInfo.severity += damageWeapon.severity
        end
    end
    
    if not boneInfo.injury then
        boneInfo.injury = {}
    end
    if not lib.table.contains(boneInfo.injury, damageWeapon.injury) then
        boneInfo.injury[#boneInfo.injury+1] = damageWeapon.injury
    end

    bleeding = GetTotalDamageType(BodyBonesDamage, "bleeding")
    hurtWalk()
    updateBodyDamage()
end)

RegisterNetEvent("ND:playerEliminated", function(info)
    Wait(2000)
    NDCore.revivePlayer(false, true)
    downAnim = setDeathState("down")
end)

RegisterNetEvent("ND:characterLoaded", function(player)
    randomDeathAnim = Data.deathAnims[math.random(1, #Data.deathAnims)]
    SetPlayerHealthRechargeMultiplier(cache.playerId, 0.0)
    if player.metadata.dead then
        NDCore.revivePlayer(false, true)
        downAnim = setDeathState("down")
    end
end)

RegisterNetEvent("onResourceStart", function(name)
    if GetCurrentResourceName() ~= name then return end
    SetPlayerHealthRechargeMultiplier(cache.playerId, 0.0)
end)

lib.onCache("ped", function()
    SetPlayerHealthRechargeMultiplier(cache.playerId, 0.0)
end)

AddStateBagChangeHandler("injuries", nil, function(bagName, key, value, reserved, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 or replicated then return end

    local src = GetPlayerServerId(ply)
    if src ~= cache.serverId or not value then return end

    for bone, limb in pairs(BodyBonesDamage) do
        local updatedLimb = value[bone]
        if updatedLimb then
            limb.suffocating = updatedLimb.suffocating
            limb.fracture = updatedLimb.fracture
            limb.burn = updatedLimb.burn
            limb.bleeding = updatedLimb.bleeding
            limb.severity = updatedLimb.severity
        end
    end
    bleeding = GetTotalDamageType(BodyBonesDamage, "bleeding")
    hurtWalk()
end)

RegisterNetEvent("ND_Ambulance:syncDragBody", function(draggingPlayer, leave)
    local draggingPed = GetPlayerPed(GetPlayerFromServerId(draggingPlayer))
    if not draggingPed or not DoesEntityExist(draggingPed) then return end
    lib.requestAnimDict("combat@drag_ped@")
    
    if leave then
        TaskPlayAnim(cache.ped, "combat@drag_ped@", "injured_putdown_ped", 2.0, 2.0, 5700, 1, 0, false, false, false)
        Wait(5000)
        DetachEntity(draggingPed, true, true)
        downAnim = setDeathState(deathState or "down")
        return
    end

    AttachEntityToEntity(cache.ped, draggingPed, GetPedBoneIndex(cache.ped, `SKEL_Pelvis`), 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 2, false)
    TaskPlayAnim(cache.ped, "combat@drag_ped@", "injured_pickup_back_ped", 2.0, 2.0, -1, 1, 0, false, false, false)
    Wait(5700)
    TaskPlayAnim(cache.ped, "combat@drag_ped@", "injured_drag_ped", 2.0, 2.0, -1, 1, 0, false, false, false)
    bodyAttached = true
end)

RegisterCommand("check", function(source, args, rawCommand)
    CheckPlayerInjuries(cache.serverId)
end, false)

exports.ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:checkInjuries",
        icon = "fa-solid fa-hand-holding-heart",
        label = "Check injuries",
        distance = 2.0,
        canInteract = function(entity, distance, coords, name)
            return not bodyAttached and GetEntityHealth(entity) <= 101
        end,
        onSelect = function(data)
            local target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            CheckPlayerInjuries(target)
        end
    },
    {
        name = "ND_Ambulance:dragBody",
        icon = "fa-solid fa-hand-holding-heart",
        label = "Drag body",
        distance = 2.0,
        canInteract = function(entity, distance, coords, name)
            return not bodyAttached and GetEntityHealth(entity) <= 101
        end,
        onSelect = function(data)
            local target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            bodyAttached = lib.callback.await("ND_Ambulance:syncDragBody", false, target)
            if not bodyAttached then return end

            lib.requestAnimDict("combat@drag_ped@")
            TaskPlayAnim(cache.ped, "combat@drag_ped@", "injured_pickup_back_plyr", 2.0, 2.0, 5700, 1, 0, false, false, false)
            Wait(5700)
            TaskPlayAnim(cache.ped, "combat@drag_ped@", "injured_drag_plyr", 2.0, 2.0, -1, 1, 0, false, false, false)

            CreateThread(function()
                while bodyAttached do
                    Wait(0)
                    if IsControlJustPressed(0, 73) then
                        TriggerServerEvent("ND_Ambulance:syncDragBody", target)
                        TaskPlayAnim(cache.ped, "combat@drag_ped@", "injured_putdown_plyr", 2.0, 2.0, 5500, 1, 0, false, false, false)
                        SetTimeout(5500, function()
                            bodyAttached = false
                        end)
                        break
                    -- elseif IsControlPressed(0, 30) then
                    --     SetEntityHeading(cache.ped, GetEntityHeading(cache.ped)+0.5)
                    -- elseif IsControlPressed(0, 34) then
                    --     SetEntityHeading(cache.ped, GetEntityHeading(cache.ped)-0.5)
                    end
                end
            end)
        end
    }
})

-- make bleeding cause health to go down very slow, make items to heal wounds. And more.

local downAnim
local randomDeathAnim = Data.deathAnims[math.random(1, #Data.deathAnims)]
local bodyBonesDamage = lib.table.deepclone(Data.boneSettings)

local function setDeathState(state)
    if state == "down" and ddownAnim then
        StopAnimTask(cache.ped, downAnim[1], ddownAnim[2], 1.0)
    end
    local dict, clip = randomDeathAnim[state][1], randomDeathAnim[state][2]
    lib.requestAnimDict(dict)
    TaskPlayAnim(cache.ped, dict, clip, 1.0, 8.0, -1, 1, 0, true, true, true)
    return {dict, clip}
end

exports("getLastDamagingWeapon", function(ped)
    for weapon, info in pairs(Data.weapons) do
        if HasPedBeenDamagedByWeapon(ped, weapon, 0) then
            ClearEntityLastDamageEntity(ped)
            return info
        end
    end
end)

exports("getBodyDamage", function()
    return bodyBonesDamage
end)

exports("resetBodyDamage", function()
    bodyBonesDamage = lib.table.deepclone(Data.boneSettings)
end)

exports("updateBodyDamage", function(bone, damageWeapon)
    local boneName = Data.boneParts[bone]
    if not boneName then return end
    local boneInfo = bodyBonesDamage[boneName]
    local updateDamageOn = {"fracture", "burn", "bleeding"}
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
    if boneInfo.causeLimp and boneInfo.severity > 1.0 then
        lib.requestAnimSet("move_m@injured")
        SetPedMovementClipset(cache.ped, "move_m@injured", 1)
        SetPlayerSprint(cache.playerId, false)
        SetPedMoveRateOverride(cache.ped, 0.95)
    end
end)

RegisterNetEvent("ND:characterLoaded", function()
    SetPlayerHealthRechargeMultiplier(cache.playerId, 0.0)
    randomDeathAnim = Data.deathAnims[math.random(1, #Data.deathAnims)]
end)

RegisterNetEvent("ND:playerEliminated", function(info)
    Wait(2000)
    NDCore.revivePlayer()
    SetPedDiesWhenInjured(cache.ped, false)
    SetEntityHealth(cache.ped, 100)
    SetPlayerInvincible(cache.playerId, true)
    downAnim = setDeathState("down")
end)

-- make bleeding cause health to go down very slow, make items to heal wounds. And more.
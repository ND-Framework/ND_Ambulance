local data_animations = require("data.animations")
local randomDeathAnim = nil
local downAnim = nil
local deathState = nil

local function getRandomDeathAnim()
    return data_animations[math.random(1, #data_animations)]
end

local function setDead(ped, dict, clip, newDeathState)
    deathState = newDeathState
    SetEntityHealth(ped, 100)

    CreateThread(function()
        print("loop started", newDeathState)
        while LocalPlayer.state.dead and deathState == newDeathState do
            local ped = cache.ped

            if not IsEntityPlayingAnim(ped, dict, clip, 3) then
                TaskPlayAnim(ped, dict, clip, 2.0, 8.0, -1, 1, 0, false, false, false)
            end

            if deathState == "eliminated" then
                SetPedDiesWhenInjured(ped, false)
                SetEntityInvincible(ped, true)
                SetEntityCanBeDamaged(ped, false)
            end

            SetEveryoneIgnorePlayer(ped, true)
            SetPedCanBeTargetted(ped, false)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdollFromPlayerImpact(ped, false)
            Wait(0)
        end
        print("loop stopped", newDeathState)
    end)
end

function GetInjuredBoneData(bones)
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

local function setDeathState(newState)
    local ped = PlayerPedId()

    if LocalPlayer.state.dead and deathState == "knocked" then
        LocalPlayer.state.dead = false
        newState = "eliminated"
    end

    if cache.vehicle then
        newState = "vehicle"
    end

    local state = Player(cache.serverId).state
    state:set("isDead", newState, true)
    state:set("injuries", GetInjuredBoneData(BodyBonesDamage), true)
    LocalPlayer.state.dead = true

    downAnim = downAnim or getRandomDeathAnim()
    local anim = downAnim[newState]
    local dict, clip = anim[1], anim[2]
    lib.requestAnimDict(dict)
    setDead(ped, dict, clip, newState)
end

local function updatePreviousPlayerDeath(player)
    SetPlayerHealthRechargeMultiplier(cache.playerId, 0.0)

    if not player or not player.metadata.dead then return end
    NDCore.revivePlayer(false, true)
    setDeathState("knocked")
end

RegisterNetEvent("ND:playerEliminated", function(info)
    Wait(2000)
    NDCore.revivePlayer(false, true)
    setDeathState("knocked")
end)

RegisterNetEvent("ND:characterLoaded", function(player)
    Wait(4000)
    updatePreviousPlayerDeath(player)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if cache.resource ~= resourceName then return end
    Wait(1000)
    local player = NDCore.getPlayer()
    updatePreviousPlayerDeath(player)
end)

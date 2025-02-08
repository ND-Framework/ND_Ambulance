-- taken from ND_Core under GPL-3.0 License: https://github.com/ND-Framework/ND_Core/blob/main/client/peds.lua
local alreadyEliminated = false

local function PlayerEliminated(deathCause, killerServerId, killerClientId)
    if alreadyEliminated then return end
    alreadyEliminated = true
    local info = {
        deathCause = deathCause,
        killerServerId = killerServerId,
        killerClientId = killerClientId,
        damagedBones = getBodyDamage() or {}
    }
    TriggerEvent("ND_Ambulance:playerEliminated", info)
    TriggerServerEvent("ND_Ambulance:playerEliminated", info)
    Wait(1000)
    alreadyEliminated = false
end

AddEventHandler("gameEventTriggered", function(name, args)
	if name ~= "CEventNetworkEntityDamage" then return end

	local victim = args[1]
	if not IsPedAPlayer(victim) or NetworkGetPlayerIndexFromPed(victim) ~= cache.playerId then return end

    local hit, bone = GetPedLastDamageBone(victim)
    if hit then
        local damageWeapon = getLastDamagingWeapon(victim)
        updateBodyDamage(bone, damageWeapon)
    end
    
    if not IsPedDeadOrDying(victim, true) or GetEntityHealth(victim) > 100 then return end

    local killerEntity, deathCause = GetPedSourceOfDeath(cache.ped), GetPedCauseOfDeath(cache.ped)
    local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
    if killerEntity ~= cache.ped and killerClientId and NetworkIsPlayerActive(killerClientId) then
        return PlayerEliminated(deathCause, GetPlayerServerId(killerClientId), killerClientId)
    end
    PlayerEliminated(deathCause)
end)

local firstSpawn = true
if GetResourceState("spawnmanager"):find("start") then
    exports.spawnmanager:setAutoSpawnCallback(function()
        if not firstSpawn then return end
        firstSpawn = false
        exports.spawnmanager:spawnPlayer()
        exports.spawnmanager:setAutoSpawn(false)
    end)
end

RegisterNetEvent("ND_Ambulance:revivePlayer", function()
    if source == "" then return end
    local oldPed = cache.ped
    local veh = GetVehiclePedIsIn(oldPed)
    local seat = cache.seat
    local coords = GetEntityCoords(oldPed)
    local armor = GetPedArmour(oldPed)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(oldPed), true, true, false)

    local ped = PlayerPedId()
    if oldPed ~= ped then
        DeleteEntity(oldPed)
        ClearAreaOfPeds(coords.x, coords.y, coords.z, 0.2, false)
    end

    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)
    SetEveryoneIgnorePlayer(ped, false)
    SetPedCanBeTargetted(ped, true)
    SetEntityCanBeDamaged(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, true)
    ClearPedTasksImmediately(ped)
    SetPedArmour(ped, armor)

    if veh and veh ~= 0 then
        SetPedIntoVehicle(ped, veh, seat)
    end
end)

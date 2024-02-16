local stretcherModels = require("data.stretchers")
local ambulanceModels = require("data.vehicles")
local ox_target = exports.ox_target

local function stopMovingStretcher(playerState, entity)
    LocalPlayer.state.blockHandsUp = false
    playerState:set("movingStretcher", nil, true)
    lib.disableControls:Remove(73, 22, 21, 23, 24, 25, 257, 36)

    local ped = cache.ped
    DetachEntity(entity)
    if IsEntityPlayingAnim(ped, "anim@move_m@prisoner_cuffed", "idle", 3) then
        StopAnimTask(ped, "anim@move_m@prisoner_cuffed", "idle", 2.0)
    end
end

local function startMoveStretcher(ped, entity, playerState)
    LocalPlayer.state.blockHandsUp = true
    lib.requestAnimDict("anim@move_m@prisoner_cuffed")
    lib.disableControls:Add(73, 22, 21, 23, 24, 25, 257, 36)

    CreateThread(function()
        while playerState.movingStretcher do
            Wait(0)
            lib.disableControls()

            if IsDisabledControlJustPressed(0, 73) or not DoesEntityExist(ped) then
                break
            end

            if not IsEntityPlayingAnim(ped, "anim@move_m@prisoner_cuffed", "idle", 3) then
                TaskPlayAnim(ped, "anim@move_m@prisoner_cuffed", "idle", 1.0, 1.0, -1, 49, 0, false, false, false)
            end
        end
        stopMovingStretcher(playerState, entity)
    end)

    Wait(500)
    if NetworkGetEntityOwner(entity) ~= cache.playerId then return end
    AttachEntityToEntity(
        entity, ped, GetPedBoneIndex(ped, `SKEL_Spine_Root`),
        0.0, 1.5, -1.0,
        0.0, 0.0, 90.0,
        true, true, false,
        true, 1, true
    )
end

local function getTargetAmbulanceModels()
    local models = {}
    for model, _ in pairs(ambulanceModels) do
        models[#models+1] = model
    end
    return models
end

local function getTargetStretcherModels()
    local models = {}
    for i=1, #stretcherModels do
        local model = stretcherModels[i]
        table.insert(models, model)
        table.insert(models, "lowered"..model)
    end
    return models
end

local function isModelRaised(entity)
    local model = GetEntityModel(entity)
    for i=1, #stretcherModels do
        if GetHashKey(stretcherModels[i]) == model then
            return true
        end
    end
end

-- get closest stretcher to coord.
local function getClosestStretcher(coords)
    for i=1, #stretcherModels do
        local model = stretcherModels[i]
        local stretcher = GetClosestObjectOfType(coords.x, coords.y, coords.z, 4.0, GetHashKey("lowered"..model), false, false, false)
        if DoesEntityExist(stretcher) then
            return stretcher
        end
    end
end

local function isTargetDead(ped)
    local player = NetworkGetPlayerIndexFromPed(ped)
    local serverId = GetPlayerServerId(player)
    local state = Player(serverId).state
    return state.isDead
end

local function placePedOnStretcher(ped, coords)
    local stretcher = getClosestStretcher(coords)
    local player = NetworkGetPlayerIndexFromPed(ped)
    local serverId = GetPlayerServerId(player)
    local stretcherNetId = ObjToNet(stretcher)
    TriggerServerEvent("ND_Ambulance:placePedOnStretcher", serverId, stretcherNetId)
end

local function getAmbulanceModelConfig(model)
    return ambulanceModels[model]
end

local function isDoorsOpen(entity, doors)
    for i=1, #doors do
        local door = doors[i]
        if GetVehicleDoorAngleRatio(entity, door) == 0 and not IsVehicleDoorDamaged(entity, door) then
            return
        end
    end
    return true
end

local function canInteractWithAmulance(entity, coords)
    local config = getAmbulanceModelConfig(GetEntityModel(entity))
    local offset = config.interact
    offset = GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z)
    return #(offset-coords) < 1.0 and isDoorsOpen(entity, config.doors)
end

ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:pickupStretcher",
        icon = "fa-solid fa-download",
        label = "Place on stretcher",
        distance = 4.0,
        canInteract = function(entity, distance, coords, name, bone)
            return isTargetDead(entity) and getClosestStretcher(coords)
        end,
        onSelect = function(data)
            if not data then return end
            placePedOnStretcher(data.entity, data.coords)
        end
    },
})

ox_target:addModel(getTargetStretcherModels(), {
    {
        name = "ND_Ambulance:pickupStretcher",
        icon = "fa-solid fa-hand",
        label = "Move stretcher",
        distance = 3.0,
        canInteract = function(entity)
            return isModelRaised(entity)
        end,
        onSelect = function(data)
            if not data then return end
            local entity = data.entity
            local playerState = Player(cache.serverId).state
            playerState:set("movingStretcher", NetworkGetNetworkIdFromEntity(entity), true)
            startMoveStretcher(cache.ped, entity, playerState)
        end
    },
    {
        name = "ND_Ambulance:raisedStretcher",
        icon = "fa-solid fa-arrow-up",
        label = "Raise stretcher",
        distance = 3.0,
        canInteract = function(entity)
            return not isModelRaised(entity)
        end,
        onSelect = function(data)
            if not data then return end
            TriggerServerEvent("ND_Ambulance:changeStretcher", false, NetworkGetNetworkIdFromEntity(data.entity))
        end
    },
    {
        name = "ND_Ambulance:lowerStretcher",
        icon = "fa-solid fa-arrow-down",
        label = "Lower stretcher",
        distance = 3.0,
        canInteract = function(entity)
            return isModelRaised(entity)
        end,
        onSelect = function(data)
            if not data then return end
            TriggerServerEvent("ND_Ambulance:changeStretcher", true, NetworkGetNetworkIdFromEntity(data.entity))
        end
    },
    {
        name = "ND_Ambulance:removeFromStretcher",
        icon = "fa-solid fa-hand",
        label = "Remove from stretcher",
        distance = 3.0,
        canInteract = function(entity)
            local state = Entity(entity).state
            return state.ambulanceStretcherPlayer
        end,
        onSelect = function(data)
            if not data then return end
            TriggerServerEvent("ND_Ambulance:removePlayerFromStretcher", NetworkGetNetworkIdFromEntity(data.entity))
        end
    },
})

ox_target:addModel(getTargetAmbulanceModels(), {
    {
        name = "ND_Ambulance:attachStretcher",
        icon = "fa-solid fa-truck-medical",
        label = "Attach stretcher",
        distance = 3.0,
        canInteract = function(entity, distance, coords, name, bone)
            return canInteractWithAmulance(entity, coords) and not Entity(entity).state.hasStretcher and Player(cache.serverId).state.movingStretcher
        end,
        onSelect = function(data)
            if not data then return end
            TriggerServerEvent("ND_Ambulance:attachStretcher", NetworkGetNetworkIdFromEntity(data.entity))
        end
    },
    {
        name = "ND_Ambulance:detachStretcher",
        icon = "fa-solid fa-truck-medical",
        label = "Detach stretcher",
        distance = 3.0,
        canInteract = function(entity, distance, coords, name, bone)
            return canInteractWithAmulance(entity, coords) and Entity(entity).state.hasStretcher and not Player(cache.serverId).state.movingStretcher
        end,
        onSelect = function(data)
            if not data then return end
            TriggerServerEvent("ND_Ambulance:detachStretcher", NetworkGetNetworkIdFromEntity(data.entity))
        end
    }
})

local function getEntityFromNetId(netId)
    local time = GetCloudTimeAsInt()
    while not NetworkDoesNetworkIdExist(netId) and GetCloudTimeAsInt()-time < 5 do Wait(0) end

    time = GetCloudTimeAsInt()
    local entity = NetworkGetEntityFromNetworkId(netId)
    while not DoesEntityExist(entity) and GetCloudTimeAsInt()-time < 5 do Wait(0) end
    return entity
end

AddStateBagChangeHandler("hasStretcher", nil, function(bagName, key, value, reserved, replicated)
    if not value then return end

    local veh = GetEntityFromStateBagName(bagName)
    local stretcher = getEntityFromNetId(value)
    if not DoesEntityExist(veh) and not DoesEntityExist(stretcher) or NetworkGetEntityOwner(veh) ~= cache.playerId then return end

    while not NetworkHasControlOfEntity(stretcher) do
        NetworkRequestControlOfEntity(stretcher)
        Wait(100)
    end

    local config = getAmbulanceModelConfig(GetEntityModel(veh))
    local offset = config.position

    AttachEntityToEntity(
        stretcher, veh, nil,
        offset.x, offset.y, offset.z,
        0.0, 0.0, 90.0,
        true, true, false,
        true, 1, true
    )
end)

AddStateBagChangeHandler("movingStretcher", nil, function(bagName, key, value, reserved, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 then return end

    if not value then
        local playerState = Player(GetPlayerServerId(ply)).state
        local entity = getEntityFromNetId(playerState.movingStretcher)
        if not DoesEntityExist(entity) then return end

        local veh = lib.getClosestVehicle(GetEntityCoords(entity), 5.0, true)
        if not DoesEntityExist(veh) then return end
        return SetEntityNoCollisionEntity(veh, entity, false)
    end

    local ped = GetPlayerPed(ply)
    local entity = getEntityFromNetId(value)
    if not DoesEntityExist(ped) or not DoesEntityExist(entity) then return end

    if ply == cache.playerId then
        startMoveStretcher(cache.ped, entity, Player(cache.serverId).state)
    end

    if NetworkGetEntityOwner(entity) ~= cache.playerId then return end

    AttachEntityToEntity(
        entity, ped, GetPedBoneIndex(ped, `SKEL_Spine_Root`),
        0.0, 1.5, -1.0,
        0.0, 0.0, 90.0,
        true, true, false,
        true, 1, true
    )
end)

AddStateBagChangeHandler("ambulanceStretcherPlayer", nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if not DoesEntityExist(entity) then return end

    local oldValue = Entity(entity).state.ambulanceStretcherPlayer
    if not value and oldValue == cache.serverId then
        LocalPlayer.state.onStretcher = false
        DetachEntity(cache.ped)
        Wait(100)
        local offset = GetOffsetFromEntityInWorldCoords(entity, 0.0, -1.3, 0.0)
        return SetEntityCoords(cache.ped, offset.x, offset.y, offset.z)
    end

    if cache.serverId ~= value then return end
    LocalPlayer.state.onStretcher = true

    local height = isModelRaised(entity) and 2.11 or 1.49
    AttachEntityToEntity(
        cache.ped, entity, nil,
        0.2, 0.0, height,
        0.0, 0.0, 88.0,
        true, true, false,
        true, 1, true
    )
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    local playerState = Player(cache.serverId).state
    playerState:set("movingStretcher", nil, true)
end)

DisableIdleCamera(true)

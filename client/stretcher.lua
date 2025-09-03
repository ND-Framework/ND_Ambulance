local stretcherModels = require("data.stretchers")
local ambulanceModels = require("data.vehicles")
local ox_target = exports.ox_target

local function isObjectStretcher(hash)
    for i=1, #stretcherModels do
        local stretcher = stretcherModels[i]
        if GetHashKey(stretcher) == hash or GetHashKey("lower"..stretcher) == hash then
            return true
        end
    end
end

function GetNearestStretcher(coords)
    local objects = lib.getNearbyObjects(coords, 4.0)
    for i=1, #objects do
        local obj = objects[i]
        if isObjectStretcher(GetEntityModel(obj.object)) then
            return obj.object
        end
    end
end

local function isModelRaised(entity)
    local model = GetEntityModel(entity)
    for i=1, #stretcherModels do
        if GetHashKey(stretcherModels[i]) == model then
            return true
        end
    end
end

function AttachPlayerToStretcher(entity)
    local height = isModelRaised(entity) and 2.11 or 1.49
    AttachEntityToEntity(
        cache.ped, entity, nil,
        0.2, 0.0, height,
        0.0, 0.0, 88.0,
        true, true, false,
        true, 1, true
    )
end

local function stopMovingStretcher(playerState, entity)
    BlockActions(false)
    playerState:set("movingStretcher", nil, true)
    lib.disableControls:Remove(73, 22, 21, 23, 24, 25, 257, 36)

    local ped = cache.ped
    DetachEntity(entity)
    PlaceObjectOnGroundProperly(entity)

    if IsEntityPlayingAnim(ped, "anim@move_m@prisoner_cuffed", "idle", 3) then
        StopAnimTask(ped, "anim@move_m@prisoner_cuffed", "idle", 2.0)
    end
end

local function startMoveStretcher(ped, entity, playerState)
    BlockActions(true)
    exports.ox_target:disableTargeting(false) -- disable so player can put stretcher in ambulance.
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
    if not doors then return true end

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
    if not config then return false end

    local offset = config.interact
    offset = GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z)
    return #(offset-coords) < 1.0 and isDoorsOpen(entity, config.doors)
end

ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:pickupStretcher",
        icon = "fa-solid fa-download",
        label = locale("amb_place_on_stretcher"),
        distance = 1.5,
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
        label = locale("amb_move_stretcher"),
        distance = 3.0,
        canInteract = function(entity)
            local localPlayerState = LocalPlayer.state
            if localPlayerState.isDead or localPlayerState.dead or localPlayerState.knockedout then return false end
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
        label = locale("amb_raise_stretcher"),
        distance = 3.0,
        canInteract = function(entity)
            local localPlayerState = LocalPlayer.state
            if localPlayerState.isDead or localPlayerState.dead or localPlayerState.knockedout then return false end
            return not isModelRaised(entity)
        end,
        onSelect = function(data)
            if not data then return end
            lib.callback("ND_Ambulance:changeStretcher", nil, function(netId)
                if not NetworkDoesEntityExistWithNetworkId(netId) then return end
                PlaceObjectOnGroundProperly(NetToObj(netId))
            end, NetworkGetNetworkIdFromEntity(data.entity), false)
        end
    },
    {
        name = "ND_Ambulance:lowerStretcher",
        icon = "fa-solid fa-arrow-down",
        label = locale("amb_lower_stretcher"),
        distance = 3.0,
        canInteract = function(entity)
            local localPlayerState = LocalPlayer.state
            if localPlayerState.isDead or localPlayerState.dead or localPlayerState.knockedout then return false end
            return isModelRaised(entity)
        end,
        onSelect = function(data)
            if not data then return end
            lib.callback("ND_Ambulance:changeStretcher", nil, function(netId)
                if not NetworkDoesEntityExistWithNetworkId(netId) then return end
                PlaceObjectOnGroundProperly(NetToObj(netId))
            end, NetworkGetNetworkIdFromEntity(data.entity), true)
        end
    },
    {
        name = "ND_Ambulance:removeFromStretcher",
        icon = "fa-solid fa-hand",
        label = locale("amb_remove_from_stretcher"),
        distance = 3.0,
        canInteract = function(entity)
            local localPlayerState = LocalPlayer.state
            if localPlayerState.isDead or localPlayerState.dead or localPlayerState.knockedout then return false end
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
        label = locale("amb_attach_stretcher"),
        distance = 3.0,
        canInteract = function(entity, distance, coords, name, bone)
            local localPlayerState = LocalPlayer.state
            if localPlayerState.isDead or localPlayerState.dead or localPlayerState.knockedout then return false end
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
        label = locale("amb_detach_stretcher"),
        distance = 3.0,
        canInteract = function(entity, distance, coords, name, bone)
            local localPlayerState = LocalPlayer.state
            if localPlayerState.isDead or localPlayerState.dead or localPlayerState.knockedout then return false end
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
        0.0, 0.0, offset.w,
        true, true, false,
        true, 1, true
    )
end)

AddStateBagChangeHandler("movingStretcher", nil, function(bagName, key, value, reserved, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 then return end
    
    if not value then
        local playerState = Player(GetPlayerServerId(ply)).state
        if not playerState.movingStretcher then return end

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
        BlockActions(false)
        DetachEntity(cache.ped)
        Wait(100)
        local offset = GetOffsetFromEntityInWorldCoords(entity, 0.0, -1.3, 0.0)
        return SetEntityCoords(cache.ped, offset.x, offset.y, offset.z)
    end

    if cache.serverId ~= value then return end
    BlockActions(true)
    LocalPlayer.state.onStretcher = true

    AttachPlayerToStretcher(entity)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    local playerState = Player(cache.serverId).state
    playerState:set("movingStretcher", nil, true)
end)

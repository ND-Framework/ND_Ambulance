local stretcherModels = require("data.stretchers")
local jobs = require("data.jobs")

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end

    local props = GetAllObjects()
    for i=1, #props do
        local prop = props[i]
        local model = GetEntityModel(prop)
        for i=1, #stretcherModels do
            local stretcher = stretcherModels[i]
            if GetHashKey(stretcher) == model or GetHashKey("lowered"..stretcher) == model then
                DeleteEntity(prop)
            end
        end
    end
end)

local function checkHasGroup(groups)
    for i=1, #jobs do
        if groups[jobs[i]] then
            return true
        end
    end
end

local function isModelStretcher(model, regular)
    for i=1, #stretcherModels do
        local hash = GetHashKey(regular and stretcherModels[i] or "lowered"..stretcherModels[i])
        if hash == model then
            return i
        end
    end
end

local function getEntityFromNetId(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local time = os.time()
    while not DoesEntityExist(entity) and os.time()-time < 5 do Wait(100) end
    return entity
end

local function getEntityCoordOffset(entity, offsetX, offsetY, offsetZ)
    local heading = GetEntityHeading(entity)
    local x = offsetX * math.cos(math.rad(heading)) - offsetY * math.sin(math.rad(heading))
    local y = offsetX * math.sin(math.rad(heading)) + offsetY * math.cos(math.rad(heading))
    local z = offsetZ
    local entityCoords = GetEntityCoords(entity)
    return vector3(entityCoords.x + x, entityCoords.y + y, entityCoords.z + z), heading
end

lib.callback.register("ND_Ambulance:changeStretcher", function(source, netId, lower)
    local entity = getEntityFromNetId(netId)
    if not DoesEntityExist(entity) then return end

    local model = GetEntityModel(entity)
    local stretcher = isModelStretcher(model, lower)
    if not stretcher then return end

    local attachedPlayer = Entity(entity).state.ambulanceStretcherPlayer
    local hash = GetHashKey(lower and "lowered"..stretcherModels[stretcher] or stretcherModels[stretcher])
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local prop = CreateObject(hash, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(prop, heading)
    DeleteEntity(entity)
    
    local time = os.time()
    while not DoesEntityExist(prop) and os.time()-time < 5 do Wait(0) end

    if attachedPlayer then
        local state = Entity(prop).state
        state:set("ambulanceStretcherPlayer", attachedPlayer, true)
    end

    return NetworkGetNetworkIdFromEntity(prop)
end)

RegisterNetEvent("ND_Ambulance:placePedOnStretcher", function(targetPlayer, stretcherNetId)
    local src = source
    local entity = getEntityFromNetId(stretcherNetId)
    if not DoesEntityExist(entity) then return end

    local stretcherCoords = GetEntityCoords(entity)
    local targetPed = GetPlayerPed(targetPlayer)
    local targetCoords = GetEntityCoords(targetPed)

    if #(targetCoords-stretcherCoords) > 10 then return end
    local state = Entity(entity).state
    state:set("ambulanceStretcherPlayer", targetPlayer, true)
end)

RegisterNetEvent("ND_Ambulance:removePlayerFromStretcher", function(stretcherNetId)
    local src = source
    local entity = getEntityFromNetId(stretcherNetId)
    if not DoesEntityExist(entity) then return end

    local stretcherCoords = GetEntityCoords(entity)
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords-stretcherCoords) > 5 then return end
    local state = Entity(entity).state
    state:set("ambulanceStretcherPlayer", false, true)
end)

RegisterNetEvent("ND_Ambulance:attachStretcher", function(ambulanceNetId)
    local src = source
    local ambulance = getEntityFromNetId(ambulanceNetId)
    if not DoesEntityExist(ambulance) then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local ambulanceCoords = GetEntityCoords(ambulance)
    if #(pedCoords-ambulanceCoords) > 10 then return end

    local ambulanceState = Entity(ambulance).state
    local playerState = Player(src).state
    local stretcherNetId = playerState.movingStretcher
    if not stretcherNetId or ambulanceState.hasStretcher then return end
    
    local entity = getEntityFromNetId(stretcherNetId)
    if not DoesEntityExist(entity) then return end

    local model = GetEntityModel(entity)
    local stretcher = isModelStretcher(model, true)
    if not stretcher then return end

    local attachedPlayer = Entity(entity).state.ambulanceStretcherPlayer
    local hash = GetHashKey("lowered"..stretcherModels[stretcher])
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local prop = CreateObject(hash, coords.x, coords.y, coords.z-5.0, true, true, false)
    SetEntityHeading(prop, heading)
    DeleteEntity(entity)
    playerState:set("movingStretcher", nil, true)
    
    local time = os.time()
    while not DoesEntityExist(prop) and os.time()-time < 5 do Wait(0) end

    if attachedPlayer then
        local state = Entity(prop).state
        state:set("ambulanceStretcherPlayer", attachedPlayer, true)
        Wait(10)
    end

    ambulanceState:set("hasStretcher", NetworkGetNetworkIdFromEntity(prop), true)
end)

RegisterNetEvent("ND_Ambulance:detachStretcher", function(ambulanceNetId)
    local src = source
    local ambulance = getEntityFromNetId(ambulanceNetId)
    if not DoesEntityExist(ambulance) then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local ambulanceCoords = GetEntityCoords(ambulance)
    if #(pedCoords-ambulanceCoords) > 10 then return end

    local playerState = Player(src).state
    if playerState.movingStretcher then return end

    local ambulanceState = Entity(ambulance).state
    local stretcherNetId = ambulanceState.hasStretcher
    if not stretcherNetId then return end
    
    local entity = getEntityFromNetId(stretcherNetId)
    if not DoesEntityExist(entity) then return end

    local model = GetEntityModel(entity)
    local stretcher = isModelStretcher(model, false)
    if not stretcher then return end

    local attachedPlayer = Entity(entity).state.ambulanceStretcherPlayer
    local hash = GetHashKey(stretcherModels[stretcher])
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local prop = CreateObject(hash, coords.x, coords.y, coords.z-5.0, true, true, false)
    SetEntityHeading(prop, heading)
    DeleteEntity(entity)
    ambulanceState:set("hasStretcher", nil, true)
    
    local time = os.time()
    while not DoesEntityExist(prop) and os.time()-time < 5 do Wait(0) end
    
    playerState:set("movingStretcher", NetworkGetNetworkIdFromEntity(prop), true)

    if attachedPlayer then
        local state = Entity(prop).state
        state:set("ambulanceStretcherPlayer", attachedPlayer, true)
    end
end)

exports("createStretcher", function(event, item, inventory, slot, data)
    if event ~= "usedItem" then return end

    local ped = GetPlayerPed(inventory.id)
    local coords, heading = getEntityCoordOffset(ped, 0.0, 1.5, -1.0)
    local prop = CreateObject(`fernocot`, coords.x, coords.y, coords.z, true, true, false)

    SetEntityHeading(prop, heading+90)
end)

RegisterCommand("stretcher", function(source, args, rawCommand)
    local player = Bridge.getPlayer(source)
    if not player or checkHasGroup(player.groups) then return end

    local pedCoords = GetEntityCoords(GetPlayerPed(source))
    local objects = GetAllObjects()

    for i=1, #objects do
        local object = objects[i]
        local model = GetEntityModel(object)
        if (isModelStretcher(model, false) or isModelStretcher(model, true)) and #(pedCoords-GetEntityCoords(object)) < 2.5 then
            DeleteEntity(object)
            return exports.ox_inventory:AddItem(source, "stretcher", 1)
        end
    end
end, false)

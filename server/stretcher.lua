local stretcherModels = require("data.stretchers")
local props = {}

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    for i=1, #props do
        local prop = props[i]
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
end)

RegisterCommand("teststret", function(source, args, rawCommand)
    local hash = `fernocot`
    local coords = vec3(1364.11, 3161.52, 39.41)
    local prop = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, true, true, false)
    props[#props+1] = prop
end, false)


local function isModelStretcher(model, lower)
    for i=1, #stretcherModels do
        local hash = GetHashKey(lower and stretcherModels[i] or "lowered"..stretcherModels[i])
        if hash == model then
            return i
        end
    end
end

RegisterNetEvent("ND_Ambulance:changeStretcher", function(lower, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local time = os.time()
    while not DoesEntityExist(entity) and os.time()-time < 5 do Wait(100) end

    if not DoesEntityExist(entity) then return end

    local model = GetEntityModel(entity)
    local stretcher = isModelStretcher(model, lower)
    if not stretcher then return end

    local hash = GetHashKey(lower and "lowered"..stretcherModels[stretcher] or stretcherModels[stretcher])
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local prop = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, true, true, false)
    props[#props+1] = prop
    SetEntityHeading(prop, heading)

    while not DoesEntityExist(prop) do Wait(0) end
    DeleteEntity(entity)
end)

local stretcherModels = require("data.stretchers")
local ox_target = exports.ox_target

local function stopMovingStretcher(playerState, entity)
    playerState:set("movingStretcher", nil, true)
    lib.disableControls:Remove(73, 22, 21, 23, 24, 25, 257, 36)

    local ped = cache.ped
    DetachEntity(entity)
    if IsEntityPlayingAnim(ped, "anim@move_m@prisoner_cuffed", "idle", 3) then
        StopAnimTask(ped, "anim@move_m@prisoner_cuffed", "idle", 2.0)
    end
end

local function startMoveStretcher(ped, entity)
    local playerState = Player(cache.serverId).state
    playerState:set("movingStretcher", NetworkGetNetworkIdFromEntity(entity), true)
    
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
end

local function getTargetModels()
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

ox_target:addModel(getTargetModels(), {
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
            startMoveStretcher(cache.ped, data.entity)
        end
    },
    {
        name = "ND_Ambulance:raisedStretcher",
        icon = "fa-solid fa-arrow-up",
        label = "Raise stretcher",
        distance = 2.0,
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
        distance = 2.0,
        canInteract = function(entity)
            return isModelRaised(entity)
        end,
        onSelect = function(data)
            if not data then return end
            TriggerServerEvent("ND_Ambulance:changeStretcher", true, NetworkGetNetworkIdFromEntity(data.entity))
        end
    }
})

AddStateBagChangeHandler("movingStretcher", nil, function(bagName, key, value, reserved, replicated)
    if not value then return end

    local ply = GetPlayerFromStateBagName(bagName)
    local ped = GetPlayerPed(ply)
    local entity = NetToObj(value)
    if ply == 0 or not DoesEntityExist(ped) or not DoesEntityExist(entity) or NetworkGetEntityOwner(entity) ~= cache.playerId then return end

    AttachEntityToEntity(
        entity, ped, GetPedBoneIndex(ped, `SKEL_Spine_Root`),
        0.0, 1.5, -1.0,
        0.0, 0.0, 90.0,
        true, true, false,
        true, 1, true
    )
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    local playerState = Player(cache.serverId).state
    playerState:set("movingStretcher", nil, true)
end)


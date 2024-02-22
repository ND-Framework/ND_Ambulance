local bagEntities = {}
local bagInventories = {}
local medBagItemsWeight = 0
local defaultMedbagWeight = 0
local medBagItems = require("data.medbag")

for item, data in pairs(exports.ox_inventory:Items()) do
    if item == medbag then
        defaultMedbagWeight = data.weight
    end
    for i=1, #medBagItems do
        local medBagItem = medBagItems[i]
        if medBagItem[1] == item then
            medBagItemsWeight += data.weight*medBagItem[2]
        end
    end
end

local function getWeightFromInventory(inv)
    local weight = 0
    local items = exports.ox_inventory:GetInventoryItems(inv)
    for _, item in pairs(items) do
        weight += item.weight
    end
    return weight
end

lib.callback.register("ND_Ambulance:bagStatus", function(source, enable)
    local prop = bagEntities[source]
    if not enable then
        if prop and DoesEntityExist(prop.entity) then
            DeleteEntity(prop.entity)
        end
        bagEntities[source] = nil
        return
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local entity = CreateObject(`xm_prop_x17_bag_med_01a`, coords.x, coords.y, coords.z-3.0, true, false, false)
    
    local time = os.time()
    while not DoesEntityExist(entity) and os.time()-time < 5 do Wait(0) end

    local netId = NetworkGetNetworkIdFromEntity(entity)
    bagEntities[source] = {
        entity = entity,
        netId = netId
    }

    local bag = exports.ox_inventory:Search(source, 1, "medbag")
    for _, v in pairs(bag) do
        bag = v
        break
    end

    local stashWeight
    if bag.metadata.stashId and exports.ox_inventory:GetInventory(bag.metadata.stashId) then
        stashWeight = getWeightFromInventory(bag.metadata.stashId)
    end

    bag.metadata.weight = (stashWeight or medBagItemsWeight) + (defaultMedbagWeight or 0)
    exports.ox_inventory:SetMetadata(source, bag.slot, bag.metadata)

    return netId
end)

RegisterNetEvent("ND_Ambulance:pickupBag", function(netId)
    local src = source
    local prop = NetworkGetEntityFromNetworkId(netId)
    if prop and DoesEntityExist(prop) and GetEntityModel(prop) == `xm_prop_x17_bag_med_01a` then
        DeleteEntity(prop)
        for _, v in pairs(bagInventories) do
            if v.netId == netId then
                exports.ox_inventory:AddItem(src, "medbag", 1, {stashId = v.stashId})
                break
            end
        end
    end
end)

local function usingBag(inventory, slot, netId)
    local metadata
    for i=1, #inventory.items do
        local item = inventory.items[i]
        if item and item.slot == slot then
            metadata = item.metadata
            break
        end
    end

    local stashId = metadata and metadata.stashId
    if not bagInventories[stashId] then
        stashId = exports.ox_inventory:CreateTemporaryStash({
            label = "Trauma bag",
            slots = 10,
            maxWeight = 7000,
            items = medBagItems
        })
    end

    bagInventories[stashId] = {
        netId = netId,
        stashId = stashId
    }

    local entity = NetworkGetEntityFromNetworkId(netId)
    local time = os.time()
    while not DoesEntityExist and os.time()-time < 5 do Wait(0) end
    
    local state = Entity(entity).state
    state.stashId = stashId
end

exports("useBag", function(event, item, inventory, slot, data)
    if event == "usingItem" then
        local bagInfo = bagEntities[inventory.id]
        local netId = bagInfo and bagInfo.netId
        if not netId then return false end

        bagEntities[inventory.id] = nil
        SetTimeout(500, function()
            usingBag(inventory, slot, netId)
        end)
    end
end)

RegisterNetEvent("onResourceStop", function(name)
    if cache.resource ~= name then return end
    for _, prop in pairs(bagEntities) do
        if prop and DoesEntityExist(prop.entity) then
            DeleteEntity(prop.entity)
        end
    end
end)

exports.ox_inventory:registerHook("swapItems", function(payload)
    if payload.toType ~= "player" or payload.fromInventory == payload.toInventory then return end
    return exports.ox_inventory:GetItemCount(payload.toInventory, "medbag") == 0
end, {
    itemFilter = {
        medbag = true
    }
})

UseNearbyItems = {}
InjuredPlayers = {}

function GetNearestPlayer(src)
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    for _, player in ipairs(GetPlayers()) do
        local target = tonumber(player)
        local targetPed = GetPlayerPed(target)
        local targetCoords = GetEntityCoords(targetPed)
        if #(pedCoords - targetCoords) <= 2.0 and target ~= src then
            return target, targetPed, targetCoords
        end
    end
end

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

RegisterNetEvent("ND:playerEliminated", function(info)
    local src = source
    if not info.damagedBones then return end
    InjuredPlayers[src] = getInjuredBoneData(info.damagedBones)
end)

RegisterNetEvent("ND_Ambulance:updateInfo", function(info)
    local src = source
    if not info then return end
    InjuredPlayers[src] = getInjuredBoneData(info)
end)

lib.callback.register("ND_Ambulance:getInfo", function(source, target)
    print("Check injuries:", json.encode(InjuredPlayers[target], {indent = true}))
    return InjuredPlayers[target]
end)

RegisterNetEvent("ND_Ambulance:useOnNearby", function(item, slot)
    local src = source
    local func = UseNearbyItems[item]
    if not func then return end

    local success, info, target = func(src)
    if target then
        local player = NDCore.getPlayer(target)
        player.notify(info)
    end

    if not success then return end
    exports.ox_inventory:RemoveItem(src, item, 1, nil, slot)
end)

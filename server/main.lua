local injuredPlayers = {}

local function getInjuredBoneData(bones)
    local data = {}
    for bone, info in pairs(bones) do
        if info.severity > 0 then
            data[bone] = info
        end
    end
    return data
end

RegisterNetEvent("ND:playerEliminated", function(info)
    local src = source
    injuredPlayers[src] = {}
    for k, v in pairs(info.damagedBones) do
        print(k, json.encode(getInjuredBoneData(v)))
    end
end)

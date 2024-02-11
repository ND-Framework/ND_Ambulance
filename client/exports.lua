local data_weapons = require("data.weapons")
local data_bone_settings = require("data.bone_settings")
local data_bones = require("data.bones")
local bleeding = 0
BodyBonesDamage = lib.table.deepclone(data_bone_settings)

local function hurtWalk()
    for _, info in pairs(BodyBonesDamage) do        
        if info.causeLimp and info.severity > 1.0 then
            lib.requestAnimSet("move_m@injured")
            SetPedMovementClipset(cache.ped, "move_m@injured", 1)
            SetPlayerSprint(cache.playerId, false)
            SetPedMoveRateOverride(cache.ped, 0.95)
            return true
        end
    end
    if GetPedMovementClipset(cache.ped) == `move_m@injured` then
        SetPedMoveRateOverride(cache.ped, 1.0)
        ResetPedMovementClipset(cache.ped, 0)
    end
end

local function updateBodyDamage()
    if not lastSync or (GetGameTimer()-lastSync) < 5000 then return end
    lastSync = GetGameTimer()
    local state = Player(cache.serverId).state
    state:set("injuries", GetInjuredBoneData(BodyBonesDamage), true)
end

function GetTotalDamageType(body, damageType)
    if not body then return 0 end

    local value = 0
    for _, info in pairs(body) do        
        if info[damageType] then
            value += info[damageType]
        end
    end
    return value
end

exports("getLastDamagingWeapon", function(ped)
    for weapon, info in pairs(data_weapons) do
        if HasPedBeenDamagedByWeapon(ped, weapon, 0) then
            ClearEntityLastDamageEntity(ped)
            return info
        end
    end
end)

exports("getBodyDamage", function()
    return BodyBonesDamage
end)

exports("resetBodyDamage", function()
    BodyBonesDamage = lib.table.deepclone(data_bone_settings)
    bleeding = 0
    local state = Player(cache.serverId).state
    state:set("injuries", nil, true)
end)

exports("updateBodyDamage", function(bone, damageWeapon)
    local boneName = data_bones[bone]
    if not boneName then return end
    local boneInfo = BodyBonesDamage[boneName]
    local updateDamageOn = {"fracture", "burn", "bleeding", "suffocating"}
    for i=1, #updateDamageOn do
        local item = updateDamageOn[i]
        if damageWeapon[item] then
            if not boneInfo[item] then
                boneInfo[item] = 0
            end
            boneInfo[item] += damageWeapon.severity
            boneInfo.severity += damageWeapon.severity
        end
    end
    
    if not boneInfo.injury then
        boneInfo.injury = {}
    end
    if not lib.table.contains(boneInfo.injury, damageWeapon.injury) then
        boneInfo.injury[#boneInfo.injury+1] = damageWeapon.injury
    end

    bleeding = GetTotalDamageType(BodyBonesDamage, "bleeding")
    hurtWalk()
    updateBodyDamage()
end)

-- taken from ND_Core under GPL-3.0 License: https://github.com/ND-Framework/ND_Core/blob/main/client/peds.lua
local pedsFunctions = {}
local target = GetResourceState("ox_target") == "started"
local ox_target = target and exports.ox_target
local locations = {}
local clothingComponents = {
    face = 0,
    mask = 1,
    hair = 2,
    torso = 3,
    leg = 4,
    bag = 5,
    shoes = 6,
    accessory = 7,
    undershirt = 8,
    kevlar = 9,
    badge = 10,
    torso2 = 11
}
local clothingProps = {
    hat = 0,
    glasses = 1,
    ears = 2,
    watch = 6,
    bracelets = 7
}

local function configPed(ped)
    SetPedCanBeTargetted(ped, false)
    SetEntityCanBeDamaged(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedResetFlag(ped, 249, true)
    SetPedConfigFlag(ped, 185, true)
    SetPedConfigFlag(ped, 108, true)
    SetPedConfigFlag(ped, 208, true)
    SetPedCanRagdoll(ped, false)
end

local function setClothing(ped, clothing)
    if not clothing then return end
    for component, clothingInfo in pairs(clothing) do
        if clothingComponents[component] then
            SetPedComponentVariation(ped, clothingComponents[component], clothingInfo.drawable, clothingInfo.texture, 0)
        elseif clothingProps[component] then
            SetPedPropIndex(ped, clothingProps[component], clothingInfo.drawable, clothingInfo.texture, true)
        end
    end
end

function pedsFunctions.createAiPed(info)
    local ped
    local model = type(info.model) == "string" and GetHashKey(info.model) or info.model
    local anim = info.anim
    local clothing = info.clothing
    local coords = info.coords
    local options = info.options
    local point = lib.points.new({
        coords = vec3(coords.x, coords.y, coords.z),
        distance = info.distance or 25.0
    })
    
    local id = #locations+1
    locations[id] = {
        point = point,
        options = options
    }

    function point:onEnter()
        local found, ground = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
        lib.requestModel(model)
        ped = CreatePed(4, model, coords.x, coords.y, found and ground or coords.z, coords.w or coords.h or info.heading, false, false)

        local time = GetCloudTimeAsInt()
        while not DoesEntityExist(ped) and time-GetCloudTimeAsInt() < 5 do
            Wait(100)
        end

        configPed(ped)
        setClothing(ped, clothing)
        locations[id].ped = ped

        if anim and anim.dict and anim.clip then
            lib.requestAnimDict(anim.dict)
            TaskPlayAnim(ped, anim.dict, anim.clip, 2.0, 8.0, -1, 1, 0, 0, 0, 0)
        end

        if target and options then
            Wait(500)
            ox_target:addLocalEntity({ped}, options)
        end
    end

    function point:onExit()
        if ped and DoesEntityExist(ped) then
            if target and options then
                ox_target:removeLocalEntity({ped})
            end
            Wait(500)
            DeleteEntity(ped)
        end
    end

    return id
end

function pedsFunctions.removeAiPed(id)
    local info = locations[id]
    if not info then return end

    local ped = info.ped
    info.point:remove()
    locations[id] = nil

    if ped and DoesEntityExist(ped) then
        if info.options then
            ox_target:removeLocalEntity({ped})
        end
        DeleteEntity(ped)
    end
end

AddEventHandler("onResourceStop", function(name)
    if name ~= lib.resource then return end
    for i, _ in ipairs(locations) do
        pedsFunctions.removeAiPed(i)
    end
end)

RegisterCommand("getclothing-drugs", function(source, args, rawCommand)
    local info = ""
    for k, v in pairs(clothingComponents) do
        info = ("%s\n%s = { drawable = %s, texture = %s },"):format(info, k, GetPedDrawableVariation(cache.ped, v), GetPedTextureVariation(cache.ped, v))
    end
    for k, v in pairs(clothingProps) do
        info = ("%s\n%s = { drawable = %s, texture = %s },"):format(info, k, GetPedPropIndex(cache.ped, v), GetPedPropTextureIndex(cache.ped, v))
    end
    lib.setClipboard(info)
end, false)

return pedsFunctions
local prop = nil

local options = {
    {
        name = "ND_Ambulance:defib:pickup",
        icon = "fa-solid fa-briefcase",
        label = "Pick up",
        distance = 1.5,
        onSelect = function(data)
            lib.requestAnimDict("anim@mp_snowball")
            TaskPlayAnim(cache.ped, "anim@mp_snowball", "pickup_snowball", 2.0, 8.0, 1000, 32, 0, false, false, false)
            Wait(500)
            TriggerServerEvent("ND_Ambulance:pickupDefib")
        end
    }
}

local function enableDefib(enable)
    local count = exports.ox_inventory:GetItemCount("defib")
    if count > 1 and enable or count > 1 and not enable then return end

    if prop and DoesEntityExist(prop) then
        DeleteEntity(prop)
        prop = nil
        return
    end
    
    if not enable then return end
    local coords = GetEntityCoords(cache.ped)
    lib.requestModel(`lifepak15`)
    prop = CreateObject(`lifepak15`, coords.x, coords.y, coords.z, true, false, false)
    while not DoesEntityExist(prop) do Wait(0) end

    AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 0x49D9), 0.4, -0.02, -0.0, 45.0, -85.0, -18.29, true, true, false, true, 2, true)
end

AddEventHandler("onResourceStart", function(resourceName)
    if cache.resource ~= resourceName or exports.ox_inventory:GetItemCount("defib") == 0 then return end
    enableDefib(true)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName or exports.ox_inventory:GetItemCount("defib") == 0 then return end
    enableDefib(false)
end)

exports("useDefib", function(data, slot)
    if not prop or not DoesEntityExist(prop) then return end

    lib.requestAnimDict("anim@heists@money_grab@briefcase")
    TaskPlayAnim(cache.ped, "anim@heists@money_grab@briefcase", "put_down_case", 2.0, 8.0, 2000, 32, 0, false, false, false)
    
    Wait(800)

    DetachEntity(prop)
    local coords = GetEntityCoords(prop)
    local found, ground = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    SetEntityCoords(prop, coords.x, coords.y, found and ground or coords.z-0.2)
    SetEntityRotation(prop, 0.0, 0.0, 0.0, 2)
    SetEntityHeading(prop, GetEntityHeading(cache.ped)-110)
    prop = nil
    exports.ox_inventory:useItem(data)
end)

exports("hasDefib", enableDefib)

exports.ox_target:addModel(`lifepak15`, options)

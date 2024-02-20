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

exports.ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:checkVital",
        icon = "fa-solid fa-heart-pulse",
        label = "Vital Signs",
        distance = 1.5,
        canInteract = function(entity, distance, coords, name, bone)
            local prop = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0, `lifepak15`, false, false, false)
            if not prop or not DoesEntityExist(prop) then return end

            local player = NetworkGetPlayerIndexFromPed(entity)
            local serverId = GetPlayerServerId(player)
            local state = Player(serverId).state
            return state.isDead or state.knockedout
        end,
        onSelect = function(data)
            local player = NetworkGetPlayerIndexFromPed(data.entity)
            local serverId = GetPlayerServerId(player)
            local state = Player(serverId).state
            local deathState = state.isDead
            if state.knockedout then
                NDCore.notify({
                    title = "Vital signs",
                    description = "Patient unconscious. Vital signs stable. Appears to have been knocked out.",
                    type = "inform",
                    icon = "heart-pulse",
                    duration = 8000
                })
            elseif deathState == "knocked" then
                NDCore.notify({
                    title = "Vital signs",
                    description = "Patient unconscious. Vital signs stable. Appears to have sustained significant injuries.",
                    type = "inform",
                    icon = "heart-pulse",
                    duration = 8000
                })
            elseif deathState == "eliminated" then
                local timeSinceDeath = state.timeSinceDeath
                if GetCloudTimeAsInt()-timeSinceDeath < 30 then
                    NDCore.notify({
                        title = "Vital signs",
                        description = "No pulse detected. Initiating life-saving measures & transport to medical facility recommended.",
                        type = "inform",
                        icon = "heart-pulse",
                        duration = 8000
                    })
                else
                    NDCore.notify({
                        title = "Vital signs",
                        description = "No pulse detected. Patient deceased. Life-saving measures ineffective.",
                        type = "inform",
                        icon = "heart-pulse",
                        duration = 8000
                    })
                end
            end
        end
    },
    {
        name = "ND_Ambulance:startDefib",
        icon = "fa-solid fa-heart-pulse",
        label = "Use defibrillator",
        distance = 1.5,
        canInteract = function(entity, distance, coords, name, bone)
            local prop = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0, `lifepak15`, false, false, false)
            if not prop or not DoesEntityExist(prop) then return end

            local player = NetworkGetPlayerIndexFromPed(entity)
            local serverId = GetPlayerServerId(player)
            return Player(serverId).state.isDead == "eliminated"
        end,
        onSelect = function(data)
            local player = NetworkGetPlayerIndexFromPed(data.entity)
            local serverId = GetPlayerServerId(player)
            local state = Player(serverId).state
            local timeSinceDeath = state.timeSinceDeath or 0

            if not lib.progressBar({
                duration = 3000,
                label = "Ready?",
                useWhileDead = false,
                canCancel = true,
                disable = { car = true }
            }) then return end

            if not lib.skillCheck("medium") then
                return NDCore.notify({
                    title = "Defibrillator: unsuccessful",
                    type = "error",
                    icon = "heart-pulse",
                    duration = 7000
                })
            end

            if not lib.progressCircle({
                duration = 3000,
                position = "bottom",
                useWhileDead = false,
                disable = { car = true }
            }) then return end

            
            if GetCloudTimeAsInt()-timeSinceDeath > 30 or math.random(1, 10) == 1 then
                return NDCore.notify({
                    title = "Defibrillator: unsuccessful",
                    type = "error",
                    icon = "heart-pulse",
                    duration = 7000
                })
            end

            NDCore.notify({
                title = "Defibrillator: successful",
                type = "success",
                icon = "heart-pulse",
                duration = 7000
            })

            TriggerServerEvent("ND_Ambulance:successDefib", serverId)
        end
    }
})

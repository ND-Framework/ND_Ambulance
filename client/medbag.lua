local bagProp = {}

local bagOptions = {
    {
        name = "ND_Ambulance:medbag:pickup",
        icon = "fa-solid fa-briefcase",
        label = "Pick up",
        distance = 1.5,
        onSelect = function(data)
            if not Entity(data.entity).state.stashId then return end

            lib.requestAnimDict("anim@mp_snowball")
            TaskPlayAnim(cache.ped, "anim@mp_snowball", "pickup_snowball", 2.0, 8.0, 1000, 32, 0, false, false, false)

            Wait(500)
            TriggerServerEvent("ND_Ambulance:pickupBag", ObjToNet(data.entity))
        end
    },
    {
        name = "ND_Ambulance:medbag:open",
        icon = "fa-solid fa-notes-medical",
        label = "Open",
        distance = 1.5,
        onSelect = function(data)
            local state = Entity(data.entity).state
            local stash = state.stashId
            if not stash or not exports.ox_inventory:openInventory("stash", stash) then return end

            lib.requestAnimDict("amb@medic@standing@tendtodead@idle_a")
            TaskPlayAnim(cache.ped, "amb@medic@standing@tendtodead@idle_a", "idle_b", 2.0, 8.0, -1, 15, 0, false, false, false)
            while LocalPlayer.state.invOpen do Wait(300) end

            lib.requestAnimDict("amb@medic@standing@tendtodead@exit")
            StopAnimTask(cache.ped, "amb@medic@standing@tendtodead@idle_a", "idle_b", 8.0)
            TaskPlayAnim(cache.ped, "amb@medic@standing@tendtodead@exit", "exit", 2.0, 8.0, 2500, 15, 0, false, false, false)
        end
    }
}

local function resetWalk()
    if GetPedMovementClipset(cache.ped) ~= `clipset@move@trash_fast_turn` then return end
    SetPedMoveRateOverride(cache.ped, 1.0)
    ResetPedMovementClipset(cache.ped, 0)
end

local function enableBag(enable)
    local count = exports.ox_inventory:GetItemCount("medbag")
    if count > 1 and enable or count > 1 and not enable then return end
    
    local netId = lib.callback.await("ND_Ambulance:bagStatus", false, enable)
    if not enable or not netId then return
        resetWalk()
    end
    
    local obj = NetToObj(netId)
    if not obj or not DoesEntityExist(obj) then
        return resetWalk()
    end
    
    AttachEntityToEntity(obj, cache.ped, GetPedBoneIndex(cache.ped, 0xDEAD), 0.38, -0.1, -0.02, -86.87, -85.0, -18.29, true, true, false, true, 2, true)
    bagProp.entity = obj
    bagProp.netId = netId

    lib.requestAnimSet("clipset@move@trash_fast_turn")
    SetPedMovementClipset(cache.ped, "clipset@move@trash_fast_turn", 0.1)
    SetPlayerSprint(cache.playerId, false)
    SetPedMoveRateOverride(cache.ped, 0.95)
    
    CreateThread(function()
        lib.requestAnimDict("anim@heists@narcotics@trash")
        
        while bagProp.entity and DoesEntityExist(bagProp.entity) do
            Wait(100)
            local moving = IsPedWalking(cache.ped) or IsPedSprinting(cache.ped) or IsPedRunning(cache.ped)
            if not moving and not IsEntityPlayingAnim(cache.ped, "anim@heists@narcotics@trash", "idle", 3)then
                TaskPlayAnim(cache.ped, "anim@heists@narcotics@trash", "idle", 1.0, 1.0, -1, 49, 0, false, false, false)
            elseif moving and IsEntityPlayingAnim(cache.ped, "anim@heists@narcotics@trash", "idle", 3) then
                StopAnimTask(cache.ped, "anim@heists@narcotics@trash", "idle", 2.0)
            end
        end
        StopAnimTask(cache.ped, "anim@heists@narcotics@trash", "idle", 2.0)
    end)
end

AddEventHandler("onResourceStart", function(name)
    if cache.resource ~= name or exports.ox_inventory:GetItemCount("medbag") == 0 then return end
    enableBag(true)
end)

AddEventHandler("onResourceStop", function(name)
    if cache.resource ~= name or exports.ox_inventory:GetItemCount("medbag") == 0 then return end
    resetWalk()
end)

exports("useBag", function(data)
    if not bagProp.entity or not DoesEntityExist(bagProp.entity) then return end

    local entity = bagProp.entity
    bagProp = {}
    Wait(100)

    lib.requestAnimDict("anim@heists@money_grab@briefcase")
    TaskPlayAnim(cache.ped, "anim@heists@money_grab@briefcase", "put_down_case", 2.0, 8.0, 2000, 32, 0, false, false, false)
    
    Wait(800)
    DetachEntity(entity)
    exports.ox_inventory:useItem(data)
    resetWalk()
end)

exports("bag", enableBag)

exports.ox_target:addModel(`xm_prop_x17_bag_med_01a`, bagOptions)

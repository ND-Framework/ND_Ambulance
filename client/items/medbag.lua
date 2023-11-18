local bagOptionsAdded = false
local bagProp = {}
local bagStashes = {}
local bagOptions = {
    {
        name = "ND_Ambulance:medbag:pickup",
        icon = "fa-solid fa-briefcase",
        label = "Pick up",
        distance = 1.5,
        onSelect = function(data)
            local netId = ObjToNet(data.entity)
            if not bagStashes[netId] then return end

            lib.requestAnimDict("anim@mp_snowball")
            TaskPlayAnim(cache.ped, "anim@mp_snowball", "pickup_snowball", 2.0, 8.0, 1000, 32, 0, false, false, false)

            Wait(500)
            TriggerServerEvent("ND_Ambulance:pickupBag", netId)
        end
    },
    {
        name = "ND_Ambulance:medbag:open",
        icon = "fa-solid fa-notes-medical",
        label = "Open",
        distance = 1.5,
        onSelect = function(data)
            local netId = ObjToNet(data.entity)
            local stash = bagStashes[netId]
            if not stash then return end
            local canOpen = exports.ox_inventory:openInventory("stash", stash)
            if not canOpen then return end

            lib.requestAnimDict("amb@medic@standing@tendtodead@idle_a")
            TaskPlayAnim(cache.ped, "amb@medic@standing@tendtodead@idle_a", "idle_b", 2.0, 8.0, -1, 15, 0, false, false, false)
            while LocalPlayer.state.invOpen do Wait(300) end

            lib.requestAnimDict("amb@medic@standing@tendtodead@exit")
            StopAnimTask(cache.ped, "amb@medic@standing@tendtodead@idle_a", "idle_b", 8.0)
            TaskPlayAnim(cache.ped, "amb@medic@standing@tendtodead@exit", "exit", 2.0, 8.0, 2500, 15, 0, false, false, false)

            -- ClearPedTasks(cache.ped) -- test exit anim.
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
    if count > 1 and enable then
        return
    elseif count > 1 and not enable then
        return
    end
    
    local netId = lib.callback.await("ND_Ambulance:bagStatus", false, enable)
    if not enable or not netId then return
        resetWalk()
    end
    
    local obj = NetToObj(netId)
    if not obj or not DoesEntityExist(obj) then
        return resetWalk()
    end
    
    AttachEntityToEntity(obj, cache.ped, GetPedBoneIndex(cache.ped, 0xDEAD), 0.4, -0.1, -0.03, -49.87, -85.0, -18.29, true, true, false, true, 2, true)
    bagProp.entity = obj
    bagProp.netId = netId

    lib.requestAnimSet("clipset@move@trash_fast_turn")
    SetPedMovementClipset(cache.ped, "clipset@move@trash_fast_turn", 1)
    SetPlayerSprint(cache.playerId, false)
    SetPedMoveRateOverride(cache.ped, 0.95)
end

AddEventHandler("onResourceStart", function(name)
    if cache.resource ~= name then return end
    if exports.ox_inventory:GetItemCount("medbag") == 0 then return end
    enableBag(true)
end)

exports("bag", enableBag)

exports("useBag", function(data)
    if not bagProp.entity or not DoesEntityExist(bagProp.entity) then return end

    lib.requestAnimDict("anim@heists@money_grab@briefcase")
    TaskPlayAnim(cache.ped, "anim@heists@money_grab@briefcase", "put_down_case", 2.0, 8.0, 2000, 32, 0, false, false, false)
    
    Wait(800)
    DetachEntity(bagProp.entity)
    exports.ox_inventory:useItem(data)
    bagProp = {}
    resetWalk()
end)

RegisterNetEvent("ND_Ambulance:syncBagOptions", function(netId, stash)
    bagStashes[netId] = stash
    if bagOptionsAdded then return end
    bagOptionsAdded = true
    exports.ox_target:addModel({`xm_prop_x17_bag_med_01a`}, bagOptions)
end)

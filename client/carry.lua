local function cancelCarry(ped, state)
    state:set("ambulanceCarry", nil, true)
    state:set("handsUp", nil, true)
    ClearPedSecondaryTask(ped)
    DetachEntity(ped, true, false)
end

local function isDead(state, ped)
    return state.isDead or state.dead or state.knockedout or IsPedFatallyInjured(ped)
end

local function startCarry(dict, anim, flag, carryingState, carriedState, carryingPed, carriedPed)
    BlockActions(true, true, true)

    local carry = true
    CreateThread(function()
        while carry do
            if IsControlJustPressed(0, 73) then
                carry = false
            end
            Wait(0)
        end
    end)
    CreateThread(function()
        local ped = cache.ped
        local playerState = Player(cache.serverId).state
        lib.requestAnimDict(dict)

        while carry and carryingState.ambulanceCarry and carriedState.ambulanceCarry and DoesEntityExist(carryingPed) and DoesEntityExist(carriedPed) and not isDead(carryingState, carryingPed) do
            if not IsEntityPlayingAnim(ped, dict, anim, 3) then
                TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
            end
            Wait(500)
        end

        BlockActions(false)
        carry = false
        if playerState.ambulanceCarry then
            cancelCarry(cache.ped, playerState)
        end
    end)
end

function carryNearbyPlayer()
    local playerState = Player(cache.serverId).state
    if playerState.ambulanceCarry == true or playerState.onStretcher or playerState.handsUp or playerState.isCuffed then
        return
    elseif playerState.ambulanceCarry then
        return cancelCarry(cache.ped, playerState)
    end

    local coords = GetEntityCoords(cache.ped)
    local targetPlayer = lib.getClosestPlayer(coords, 3.0, false)
    if not targetPlayer then return end

    local targetSrc = GetPlayerServerId(targetPlayer)
    if targetSrc == -1 then return end

    local targetPed = GetPlayerPed(targetPlayer)
    local targetState = Player(targetSrc).state
    if isDead(playerState, cache.ped) or targetState.ambulanceCarry or targetState.onStretcher or not (targetState.handsUp or targetState.isCuffed or isDead(targetState, targetPed)) then return end

    playerState:set("ambulanceCarry", targetSrc, true)
    Wait(500)
    startCarry("missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 49, playerState, targetState, cache.ped, targetPed)
end

AddStateBagChangeHandler("ambulanceCarry", nil, function(bagName, key, value, _, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 or not value or value == true then return end

    local carriedPlayerSrc = value
    if carriedPlayerSrc ~= cache.serverId then return end

    local carryingPed = GetPlayerPed(ply)
    if not DoesEntityExist(carryingPed) then return end

    local pedCoords = GetEntityCoords(cache.ped)
    local carryingCoords = GetEntityCoords(carryingPed)
    if #(pedCoords-carryingCoords) > 3.0 then return end

    local playerState = Player(carriedPlayerSrc).state
    if playerState.ambulanceCarry then return end

    playerState:set("ambulanceCarry", true, true)
    startCarry("nm", "firemans_carry", 33, Player(GetPlayerServerId(ply)).state, playerState, carryingPed, cache.ped)
    AttachEntityToEntity(
        cache.ped, carryingPed, 0,
        0.27, 0.15, 0.63,
        0.5, 0.5, 180,
        false, false, false,
        false, 2, false
    )
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    cancelCarry(cache.ped, Player(cache.serverId).state)
end)

RegisterCommand("carry", function(source, args, rawCommand)
    carryNearbyPlayer()
end, false)

exports.ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:carryNearby",
        icon = "fa-solid fa-hand-holding",
        label = locale("carry"),
        distance = 1.5,
        canInteract = function(entity, distance, coords, name, bone)
            local player = NetworkGetPlayerIndexFromPed(entity)
            local serverId = GetPlayerServerId(player)
            return Player(serverId).state.isDead
        end,
        onSelect = function(data)
            carryNearbyPlayer()
        end
    },
    {
        name = "ND_Ambulance:searchPlayer",
        icon = "fa-solid fa-magnifying-glass",
        label = locale("loot"),
        distance = 1.5,
        canInteract = function(entity)
            local player = NetworkGetPlayerIndexFromPed(entity)
            local serverId = GetPlayerServerId(player)
            local state = Player(serverId).state
            return state.isDead or state.knockedout
        end,
        onSelect = function(data)
            local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            if not targetPlayer then return end
            exports.ox_inventory:openInventory("player", targetPlayer)
        end
    }
})

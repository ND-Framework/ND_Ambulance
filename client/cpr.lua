local enabled = false

local function setEntityToEntityHeading(ped, targetPed)
    local pedCoords = GetEntityCoords(ped)
    local targetPos = GetEntityCoords(targetPed)
    SetEntityHeading(ped, GetHeadingFromVector_2d(targetPos.x-pedCoords.x, targetPos.y-pedCoords.y)+25.0)
end

local function startCpr(data)
    enabled = true
    lib.requestAnimDict("mini@cpr@char_a@cpr_str")

    local coords = GetOffsetFromEntityInWorldCoords(data.entity, 0.7, -0.4, 0.0)
    local found, ground = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    SetEntityCoords(cache.ped, coords.x, coords.y, found and ground or coords.z)
    setEntityToEntityHeading(cache.ped, data.entity)
    BlockActions(true)

    local targetPlayerSrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    TriggerServerEvent("ND_Ambulance:startCpr", targetPlayerSrc)

    CreateThread(function()
        while enabled do
            Wait(0)
            if IsDisabledControlJustPressed(0, 73) then
                enabled = false
            end
        end
    end)
    
    CreateThread(function()
        while enabled do
            Wait(500)
            if not DoesEntityExist(cache.ped) or not DoesEntityExist(data.entity) or #(GetEntityCoords(cache.ped)-GetEntityCoords(data.entity)) > 5 or LocalPlayer.state.dead then
                enabled = false
            end
            if not IsEntityPlayingAnim("mini@cpr@char_a@cpr_str", "cpr_pumpchest", 3) then
                TaskPlayAnim(cache.ped, "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, 1.0, -1, 9, 0, false, false, false)
            end
        end

        TriggerServerEvent("ND_Ambulance:stopCpr", targetPlayerSrc)
        lib.requestAnimDict("mini@cpr@char_a@cpr_def")
        TaskPlayAnim(cache.ped, "mini@cpr@char_a@cpr_def", "cpr_success", 8.0, 1.0, -1, 2, 0, false, false, false)
        BlockActions(false)
    end)
end

local function canPermformCpr(state)
    local localPlayerState = LocalPlayer.state
    if localPlayerState.isDead or localPlayerState.dead or localPlayerState.knockedout then return false end

    local cprData = state.cprData or {}
    return not cprData.ongoing and state.isDead == "eliminated"
end

exports.ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:cprPlayer",
        icon = "fa-solid fa-lungs",
        label = locale("perform_cpr"),
        distance = 1.5,
        canInteract = function(entity, distance, coords, name, bone)
            local player = NetworkGetPlayerIndexFromPed(entity)
            local serverId = GetPlayerServerId(player)
            return not enabled and canPermformCpr(Player(serverId).state)
        end,
        onSelect = startCpr
    },
})

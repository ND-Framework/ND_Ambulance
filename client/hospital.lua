local data_death = require("data.death")
local data_stretchers = require("data.stretchers")

local function treatPatient(data)
    local state = Player(cache.serverId).state
    local carry = state.ambulanceCarry

    if carry and type(carry) == "number" then
        local targetState = Player(carry).state
        if not state.isDead then
            return NDCore.notify("This person is not severly injured!")
        end 
        TriggerServerEvent("ND_Ambulance:treatPatient", carry)
    elseif state.movingStretcher then
        local stretcher = GetNearestStretcher(data.coords)
        if not stretcher or not DoesEntityExist(stretcher) then
            return NDCore.notify("No patient found nearby!")
        end

        local stretcherState = Entity(stretcher).state
        if not stretcherState.ambulanceStretcherPlayer then
            return NDCore.notify("No patient found nearby!")
        end

        TriggerServerEvent("ND_Ambulance:treatPatient", stretcherState.ambulanceStretcherPlayer, state.movingStretcher)
    else
        NDCore.notify("No patient found nearby!")
    end
end

local function getClosestReviveLocation(coords)
    local closestLoc = nil
    local closestDist = nil
    for i=1, #data_death.hospitalRespawns do
        local location = data_death.hospitalRespawns[i]
        local dist = #(coords-location.xyz)
        if not closestLoc or not closestDist or dist < closestDist then
            closestLoc = location
            closestDist = dist
        end
    end
    return closestLoc
end

RegisterNetEvent("ND_Ambulance:respawnHospital", function()
    if source == "" then return end
    local coords = getClosestReviveLocation(GetEntityCoords(cache.ped))
    DoScreenFadeOut(500)
    Wait(500)
    Teleport(cache.ped, coords, false)
    Wait(100)
    DoScreenFadeIn(500)
end)

for i=1, #data_death.hospitalPeds do
    NDCore.createAiPed({
        model = `s_m_m_doctor_01`,
        coords = data_death.hospitalPeds[i],
        blip = {
            sprite = 61,
            scale = 0.8,
            color = 43,
            label = "Hospital",
        },
        anim = {
            dict = "anim@amb@casino@valet_scenario@pose_d@",
            clip = "base_a_m_y_vinewood_01"
        },
        options = {
            {
                name = "ND_Ambulance:hospitalPed",
                icon = "fa-solid fa-notes-medical",
                label = "Get treated",
                distance = 2.0,
                onSelect = function(data)
                    TriggerServerEvent("ND_Ambulance:treatSelf")
                end
            },
            {
                name = "ND_Ambulance:hospitalPed",
                icon = "fa-solid fa-user-nurse",
                label = "Treat patient",
                distance = 2.0,
                canInteract = function(entity, distance, coords, name, bone)
                    local state = Player(cache.serverId).state
                    return state.movingStretcher or state.ambulanceCarry
                end,
                onSelect = treatPatient
            }
        }
    })
end

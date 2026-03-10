local data_death = require("data.death")
local data_stretchers = require("data.stretchers")
local createdPeds = {}

local lastPedIndex = nil

local function treatPatient(data)
    local state = Player(cache.serverId).state
    local carry = state.ambulanceCarry

    if carry and type(carry) == "number" then
        local targetState = Player(carry).state
        if not targetState.isDead then
            return Bridge.notify({
                title = locale("no_treatment_needed"),
                type = "error"
            })
        end 
        TriggerServerEvent("ND_Ambulance:treatPatient", carry, nil, lastPedIndex)
        carryNearbyPlayer()
    elseif state.movingStretcher then
        local stretcher = GetNearestStretcher(data.coords)
        if not stretcher or not DoesEntityExist(stretcher) then
            return Bridge.notify({
                title = locale("no_patient_nearby"),
                type = "error"
            })
        end

        local stretcherState = Entity(stretcher).state
        if not stretcherState.ambulanceStretcherPlayer then
            return Bridge.notify({
                title = locale("no_patient_nearby"),
                type = "error"
            })
        end

        TriggerServerEvent("ND_Ambulance:treatPatient", stretcherState.ambulanceStretcherPlayer, state.movingStretcher, lastPedIndex)
    else
        return Bridge.notify({
            title = locale("no_patient_nearby"),
            type = "error"
        })
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
    SetTimeout(2000, function()
        if IsScreenFadedIn() then
            DoScreenFadeIn(500)
        end
    end)
end)

for i=1, #data_death.hospitalPeds do
    local hospitalInfo = data_death.hospitalPeds[i]
    local pedIndex = i
    createdPeds[#createdPeds+1] = Bridge.createAiPed({
        model = `s_m_m_doctor_01`,
        coords = hospitalInfo.coords,
        blip = hospitalInfo.blip and {
            sprite = 61,
            scale = 0.8,
            color = 43,
            label = locale("hospital"),
        },
        anim = {
            dict = "anim@amb@casino@valet_scenario@pose_d@",
            clip = "base_a_m_y_vinewood_01"
        },
        options = {
            {
                name = "ND_Ambulance:hospitalPed",
                icon = "fa-solid fa-notes-medical",
                label = locale("get_treated"),
                distance = 2.0,
                onSelect = function(data)
                    TriggerServerEvent("ND_Ambulance:treatSelf", pedIndex)
                end
            },
            {
                name = "ND_Ambulance:hospitalPed",
                icon = "fa-solid fa-user-nurse",
                label = locale("treat_patient"),
                distance = 2.0,
                canInteract = function(entity, distance, coords, name, bone)
                    local state = Player(cache.serverId).state
                    return state.movingStretcher or state.ambulanceCarry
                end,
                onSelect = function(data)
                    lastPedIndex = pedIndex
                    treatPatient(data)
                end
            }
        }
    })
end

AddEventHandler("onResourceStop", function(resource)
    if cache.resource ~= resource then return end
    for i=1, #createdPeds do
        Bridge.removeAiPed(createdPeds[i])
    end
end)

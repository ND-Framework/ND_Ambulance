local bridge = {}
local QBCore = exports["qb-core"]:GetCoreObject()
local peds = lib.load("client.modules.peds")

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    TriggerEvent("ND_Ambulance:playerLoaded")
end)

function bridge.getDeathModule()
    lib.load("client.modules.death")
end

function bridge.hasJobs(jobs)
    local player = QBCore.Functions.GetPlayerData()
    return lib.table.contains(jobs, player.job.name)
end

function bridge.notify(data)
    if data.type == "inform" then
        data.type = "info"
    end

    QBCore.Functions.Notify({
        text = data.description,
        caption = data.title
    }, data.type, data.duration)
end

function bridge.createAiPed(info)
    return peds.createAiPed(info)
end

function bridge.removeAiPed(id)
    peds.removeAiPed(id)
end

function bridge.isDead()
    local player = QBCore.Functions.GetPlayerData()
    return player.metadata["isdead"]
end

function bridge.sinceDeath()
    local player = QBCore.Functions.GetPlayerData()
    return player.metadata["deathTimeStamp"]
end

return bridge
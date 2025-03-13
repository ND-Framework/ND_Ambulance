local bridge = {}
local ESX = exports["es_extended"]:getSharedObject()
local peds = lib.load("client.modules.peds")

function bridge.getDeathModule()
    lib.load("client.modules.death")
end

function bridge.hasJobs(jobs)
    local player = ESX.GetPlayerData()
    return lib.table.contains(jobs, player.job.name)
end

function bridge.notify(data)
    if data.type == "inform" then
        data.type = "info"
    end

    ESX.ShowNotification(data.description or data.title, data.type or "info", data.duration or 5000)
end

function bridge.createAiPed(info)
    peds.createAiPed(info)
end

function bridge.isDead()
    local player = ESX.GetPlayerData()
    return player.metadata["isDead"]
end

return bridge
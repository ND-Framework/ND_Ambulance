local bridge = {}
local QBCore = exports["qb-core"]:GetCoreObject()
local peds = lib.load("client.modules.peds")

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
    peds.createAiPed(info)
end

function bridge.isDead()
    local player = QBCore.Functions.GetPlayerData()
    return player.metadata["isdead"]
end

return bridge
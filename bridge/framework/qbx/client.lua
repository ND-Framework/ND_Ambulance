local bridge = {}
local qbx_core = exports.qbx_core
local peds = lib.load("client.modules.peds")
require("@qbx_core/modules/playerdata")

function bridge.getDeathModule()
    lib.load("client.modules.death")
end

function bridge.hasJobs(jobs)
    return lib.table.contains(jobs, QBX.PlayerData.job.name)
end

function bridge.notify(data)
    qbx_core:Notify(data.description, data.type, data.duration, data.title, data.position, data.style, data.icon, data.color)
end

function bridge.createAiPed(info)
    peds.createAiPed(info)
end

function bridge.isDead()
    return QBX.PlayerData?.metadata?.isdead
end

return bridge
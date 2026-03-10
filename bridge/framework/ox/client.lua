local bridge = {}
local Ox = require "@ox_core.lib.init"
local peds = lib.load("client.modules.peds")

AddEventHandler("ox:playerLoaded", function(playerId, isNew)
    TriggerEvent("ND_Ambulance:playerLoaded")
end)

function bridge.getDeathModule()
    lib.load("client.modules.death")
end

function bridge.hasJobs(jobs)
    for i=1, #jobs do
        local job = jobs[i]
        if player.getGroup(job) then
            return true
        end
    end
end

function bridge.notify(data)
    lib.notify(data)
end

function bridge.createAiPed(info)
    return peds.createAiPed(info)
end

function bridge.removeAiPed(id)
    peds.removeAiPed(id)
end

function bridge.isDead()
    return LocalPlayer.state.isDead
end

return bridge
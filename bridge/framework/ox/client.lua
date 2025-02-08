local bridge = {}
local Ox = require "@ox_core.lib.init"
local peds = lib.load("client.modules.peds")

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
    peds.createAiPed(info)
end

function bridge.isDead()
    return LocalPlayer.state.isDead
end

return bridge
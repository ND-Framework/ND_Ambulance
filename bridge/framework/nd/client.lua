local bridge = {}
local NDCore = require "@ND_Core.init"

local player = NDCore.getPlayer()

AddEventHandler("onResourceStart", function(resourceName)
    if cache.resource ~= resourceName then return end
    player = NDCore.getPlayer()
end)

RegisterNetEvent("ND:characterLoaded", function(character)
    player = character
end)

RegisterNetEvent("ND:updateCharacter", function(character)
    player = character
end)

function bridge.hasJobs(jobs)
    return player and lib.table.contains(jobs, player.job))
end

function bridge.notify(data)
    NDCore.notify(data)
end

function bridge.createAiPed(info)
    NDCore.createAiPed(info)
end

function bridge.isDead()
    return player and player.metadata.dead
end

return bridge
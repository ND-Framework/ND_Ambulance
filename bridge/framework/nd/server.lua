local bridge = {}
local NDCore = require "@ND_Core.init"

function bridge.getPlayer(src)
    return NDCore.getPlayer(src)
end

function bridge.notify(src, data)
    local player = NDCore.getPlayer(src)
    if not player then return end
    player.notify(data)
end

function bridge.hasMoney(src, amount)
    local player = NDCore.getPlayer(src)
    if not player then return end

    if player.bank >= amount or player.cash >= amount then
        return true
    end
end

function bridge.deductMoney(src, amount)
    local player = NDCore.getPlayer(src)
    if not player then return end

    if player.bank >= amount then
        player.deductMoney("bank", amount, locale("hospital_bill"))
    elseif player.cash >= amount then
        player.deductMoney("cash", amount, locale("hospital_bill"))
    end
end

local function checkHasGroup(jobs, groups)
    for i=1, #jobs do
        local group = groups[jobs[i]]
        if group?.metadata?.duty then
            return true
        end
    end
end

function bridge.getAmbulanceCount(jobs)
    local count = 0
    local players = NDCore.getPlayers()
    for id, player in pairs(players) do
        if checkHasGroup(jobs, player.groups) then
            count += 1
        end
    end
    return count
end

function bridge.hasJobs(src, groups)
    local player = NDCore:getPlayer(src)
    if not player then return end

    for i=1, #groups do
        if player.groups[groups[i]] then
            return true
        end
    end
end

function bridge.revivePlayer(src)
    local player = NDCore.getPlayer(src)
    if not player then return end
    player.revive()
end

return bridge
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
        player.deductMoney("bank", amount, "Hospital bill")
    elseif player.cash >= amount then
        player.deductMoney("cash", amount, "Hospital bill")
    end
end

function bridge.revivePlayer(src)
    local player = NDCore.getPlayer(src)
    if not player then return end
    player.revive()
end

return bridge
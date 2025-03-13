local bridge = {}
local QBCore = exports["qb-core"]:GetCoreObject()

function bridge.setDeadMetadata(src)
    local player = QBCore.Functions.GetPlayer(src)
    player.Functions.SetMetaData("isdead", true)
end

function bridge.getPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

function bridge.notify(src, data)
    if data.type == "inform" then
        data.type = "info"
    end

    local player = QBCore.Functions.GetPlayer(src)
    if player then
        player.Functions.Notify(data.title, data.type, data.duration)
    end
end

function bridge.hasMoney(src, amount)
    local player = QBCore.Functions.GetPlayer(src)
    local bank = player.Functions.GetMoney(src, "bank")
    local cash = player.Functions.GetMoney(src, "cash")

    if bank >= amount or cash >= amount then
        return true
    end
end

function bridge.deductMoney(src, amount)
    local player = QBCore.Functions.GetPlayer(src)
    local bank = player.Functions.GetMoney(src, "bank")
    local cash = player.Functions.GetMoney(src, "cash")

    if bank >= amount then
        player.Functions.RemoveMoney("bank", amount, "Hospital bill")
    elseif cash >= amount then
        player.Functions.RemoveMoney("cash", amount, "Hospital bill")
    end
end

function bridge.revivePlayer(src)
    TriggerClientEvent("ND_Ambulance:revivePlayer", src)
    local player = QBCore.Functions.GetPlayer(src)
    player.Functions.SetMetaData("isdead", false)
end

lib.addCommand("revive", {
    help = "Admin command, revive a player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(src, args, raw)
    bridge.revivePlayer(src)
end)

return bridge
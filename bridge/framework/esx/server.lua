local bridge = {}
local ESX = exports["es_extended"]:getSharedObject()

function bridge.setDeadMetadata(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.setMeta("isDead", true)
end

function bridge.getPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function bridge.notify(src, data)
    if data.type == "inform" then
        data.type = "info"
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.showNotification(data.description or data.title, data.type or "info", data.duration or 5000)
end

function bridge.hasMoney(src, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    local bank = xPlayer.getAccount("bank").money
    local cash = xPlayer.getAccount("money").money

    if bank >= amount or cash >= amount then
        return true
    end
end

function bridge.deductMoney(src, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    local bank = xPlayer.getAccount("bank").money
    local cash = xPlayer.getAccount("money").money

    if bank >= amount then
        xPlayer.removeAccountMoney("bank", amount, "Hospital bill")
    elseif cash >= amount then
        xPlayer.removeAccountMoney("money", amount, "Hospital bill")
    end
end

function bridge.revivePlayer(src)
    TriggerClientEvent("ND_Ambulance:revivePlayer", src)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.setMeta("isDead", false)
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
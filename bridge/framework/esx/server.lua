local bridge = {}
local ESX = exports["es_extended"]:getSharedObject()

function bridge.setDeadMetadata(src, info)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.setMeta("isDead", true)
    xPlayer.setMeta("deathTimeStamp", info.timestamp)
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
        xPlayer.removeAccountMoney("bank", amount, locale("hospital_bill"))
    elseif cash >= amount then
        xPlayer.removeAccountMoney("money", amount, locale("hospital_bill"))
    end
end

function bridge.getAmbulanceCount(jobs)
    local count = 0
    local groupedPlayers = ESX.ExtendedPlayers("job", jobs)
    for group, players in pairs(groupedPlayers) do
        for i, xPlayer in ipairs(players) do
            if xPlayer.job.name == group then
                count += 1
            end
        end
    end
    return count
end

function bridge.hasJobs(src, groups)
    if not groups then return end

    local player = ESX.GetPlayerFromId(src)
    local job = player.getJob().name

    for i=1, #groups do
        if job == groups[i] then
            return true
        end
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
    bridge.revivePlayer(args.target)
end)

return bridge
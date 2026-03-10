local bridge = {}
local QBCore = exports["qb-core"]:GetCoreObject()

function bridge.setDeadMetadata(src, info)
    local player = QBCore.Functions.GetPlayer(src)
    player.Functions.SetMetaData("isdead", true)
    player.Functions.SetMetaData("deathTimeStamp", info.timestamp)
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
        player.Functions.RemoveMoney("bank", amount, locale("hospital_bill"))
    elseif cash >= amount then
        player.Functions.RemoveMoney("cash", amount, locale("hospital_bill"))
    end
end

function bridge.getAmbulanceCount(jobs)
    local count = 0
    local players = QBCore.Functions.GetPlayers()
    for _, player in pairs(players) do
        if lib.table.contains(jobs, player.PlayerData.job.name) then
            count += 1
        end
    end
    return count
end

function bridge.hasJobs(src, groups)
    if not groups then return end

    local player = QBCore.Functions.GetPlayer(src)
    local job = player.PlayerData.job.name

    for i=1, #groups do
        if job == groups[i] then
            return true
        end
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
    bridge.revivePlayer(args.target)
end)

return bridge
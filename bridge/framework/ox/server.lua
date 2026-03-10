local bridge = {}
local Ox = require "@ox_core.lib.init"

function bridge.setDeadMetadata(src)
    Player(src).state:set("isDead", true)
end

function bridge.getPlayer(src)
    return true
end

function bridge.notify(src, data)
    TriggerClientEvent("ox_lib:notify", src, data)
end

function bridge.hasMoney(src, amount)
    local player = Ox.GetPlayer(src)
    local account = player.getAccount()
    return account.balance >= amount
end

function bridge.deductMoney(src, amount)
    local player = Ox.GetPlayer(src)
    local account = player.getAccount()

    account.removeBalance({
        amount = account,
        message = locale("hospital_bill"),
        overdraw = true
    })
end

function bridge.revivePlayer(src)
    TriggerClientEvent("ND_Ambulance:revivePlayer", src)
    Player(src).state:set("isDead", false)
end

function bridge.getAmbulanceCount(jobs)
    local players = Ox.GetPlayers({
        groups = jobs
    })
    return #players
end

function bridge.hasJobs(src, groups)
    local player = Ox.GetPlayer(src)
    local playerGroups = player.getGroups()
    for i=1, #groups do
        if playerGroups[groups[i]] then
            return true
        end
    end
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
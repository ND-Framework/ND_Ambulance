local bridge = {}
local qbx_core = exports.qbx_core

function bridge.setDeadMetadata(src)
    qbx_core:SetMetadata(src, "isDead", true)
end

function bridge.getPlayer(src)
    return qbx_core:GetPlayer(src)
end

function bridge.notify(src, data)
    qbx_core:Notify(src, data.description, data.type, data.duration, data.title, data.position, data.style, data.icon, data.color)
end

function bridge.hasMoney(src, amount)
    local bank = qbx_core:GetMoney(src, "bank")
    local cash = qbx_core:GetMoney(src, "cash")

    if bank >= amount or cash >= amount then
        return true
    end
end

function bridge.deductMoney(src, amount)
    local bank = qbx_core:GetMoney(src, "bank")
    local cash = qbx_core:GetMoney(src, "cash")

    if bank >= amount then
        qbx_core:RemoveMoney(src, "bank", amount, "Hospital bill")
    elseif cash >= amount then
        qbx_core:RemoveMoney(src, "cash", amount, "Hospital bill")
    end
end

function bridge.revivePlayer(src)
    TriggerClientEvent("ND_Ambulance:revivePlayer", src)
    qbx_core:SetMetadata(src, "isDead", false)
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
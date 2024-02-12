local data_respawn = require("data.respawn")

RegisterNetEvent("ND_Ambulance:respawnPlayer", function()
    local src = source
    local state = Player(src).state
    local time = os.time()
    if not state or time-state.timeSinceDeath < data_respawn.timer then return end

    local player = NDCore.getPlayer(src)
    if not player then return end
    player.revive()

    if not data_respawn.dropInventory then return end
    exports.ox_inventory:CreateDropFromPlayer(src)
end)

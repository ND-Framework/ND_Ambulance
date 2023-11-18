RegisterNetEvent("ND_Ambulance:useMedkit", function()
    local maxHealth = GetEntityMaxHealth(cache.ped)
    local health = GetEntityHealth(cache.ped)

    local time = GetGameTimer()
    while health < maxHealth do
        SetEntityHealth(cache.ped, health+1)
        health = GetEntityHealth(cache.ped)
        Wait(250)
        if (GetGameTimer()-time) > 25000 then return end
    end
    SetEntityHealth(cache.ped, maxHealth)
end)

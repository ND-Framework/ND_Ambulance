local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb and limb.usedGauze and limb.bleeding and limb.severity and limb.severity > 0 then
            if limb.bleeding > 0 and limb.bleeding < 1.0 then
                if limb.severity then
                    limb.severity -= limb.bleeding
                end
                limb.bleeding = nil
            elseif limb.bleeding > 0 then
                limb.bleeding -= 1.0
                limb.severity -= 1.0
            end
            limb.usedBandage = true
            return limb.label
        end
    end
end

local function use(target)
    if not target then
        return false, {
            title = "Error",
            description = "No player found.",
            type = "error"
        }
    end
    
    local state = Player(target).state
    local injuries = state.injuries

    if not injuries then
        return false, {
            title = "Error",
            description = "No injuries found.",
            type = "error"
        }
    end

    local limbName = check(injuries)
    if not limbName then
        return false, {
            title = "Error",
            description = "You need to use gauze before bandage.",
            type = "error"
        }
    end

    return injuries, {
        title = "Success",
        description = ("Used bandage to hold together gauze on %s."):format(limbName),
        type = "success"
    }
end

function UseNearbyItems.bandage2(src)
    local target = GetNearestPlayer(src)
    local result, info = use(target)
    if result then
        local state = Player(target).state
        state:set("injuries", result, true)
    end
    return result, info, target
end

exports("bandage2", function(event, item, inventory, slot, data)
    if event == "usingItem" then
        local result, info = use(inventory.id)
        if not result then            
            local player = NDCore.getPlayer(inventory.id)
            player.notify(info)
        end
        return result
    end
    
    if event == "usedItem" then        
        local result, info = use(inventory.id)
        if result then
            local state = Player(inventory.id).state
            state:set("injuries", result, true)
        end
        local player = NDCore.getPlayer(inventory.id)
        player.notify(info)
    end
end)

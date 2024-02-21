local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb and limb.burn and limb.severity and limb.severity > 0 then
            if limb.burn > 0 and limb.burn < 1.0 then
                if limb.severity then
                    limb.severity -= limb.burn
                end
                limb.burn = nil
            elseif limb.burn > 0 then
                limb.burn -= 1.0
                limb.severity -= 1.0
            end
            return limb.label
        end
    end
end

function Treatment.burndressing(target)
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
            description = "No injuries found that can use a burn dressing.",
            type = "error"
        }
    end

    return injuries, {
        title = "Success",
        description = ("Used burn dressing on %s."):format(limbName),
        type = "success"
    }
end

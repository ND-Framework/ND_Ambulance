local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb.canUseTourniquet and not limb.usedTourniquet and limb.severity and limb.bleeding and limb.bleeding > 0 then
            limb.bleeding = limb.bleeding/2
            limb.severity -= limb.bleeding
            limb.usedTourniquet = true
            return limb.label
        end
    end
end

function Treatment.tourniquet(target)
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
            description = "No injuries found that can use a tourniquet.",
            type = "error"
        }
    end

    return injuries, {
        title = "Success",
        description = ("Used tourniquet to slow down bleeding on %s."):format(limbName),
        type = "success"
    }
end

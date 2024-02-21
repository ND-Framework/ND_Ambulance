local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb and limb.bleeding and limb.severity and limb.severity > 0 then
            if limb.bleeding > 0 and limb.bleeding < 1.0 then
                if limb.severity then
                    limb.severity -= limb.bleeding
                end
                limb.bleeding = nil
            elseif limb.bleeding > 0 then
                limb.bleeding -= 1.0
                limb.severity -= 1.0
            end
            return limb.label
        end
    end
end

function Treatment.gauze(target)
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
            description = "No wounds found.",
            type = "error"
        }
    end

    return injuries, {
        title = "Success",
        description = ("Used gauze on wounds on %s."):format(limbName),
        type = "success"
    }
end

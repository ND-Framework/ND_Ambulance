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
            title = locale("gauze_error_title"),
            description = locale("gauze_error_no_player"),
            type = "error"
        }
    end

    local state = Player(target).state
    local injuries = state.injuries
    if not injuries then
        return false, {
            title = locale("gauze_error_title"),
            description = locale("gauze_error_no_injuries"),
            type = "error"
        }
    end

    local limbName = check(injuries)
    if not limbName then
        return false, {
            title = locale("gauze_error_title"),
            description = locale("gauze_error_no_wounds"),
            type = "error"
        }
    end

    return injuries, {
        title = locale("gauze_success_title"),
        description = locale("gauze_success_used", limbName),
        type = "success"
    }
end

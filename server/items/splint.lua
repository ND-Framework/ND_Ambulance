local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb.fracture and limb.severity > 0 then
            limb.severity -= limb.fracture
            limb.fracture = nil
            return limb.label
        end
    end
end

function Treatment.splint(target)
    local state = Player(target).state
    local injuries = state.injuries
    if not injuries then
        return false, {
            title = locale("splint_error_title"),
            description = locale("splint_error_no_injuries"),
            type = "error"
        }
    end

    local limbName = check(injuries)
    if not limbName then
        return false, {
            title = locale("splint_error_title"),
            description = locale("splint_error_no_fracture"),
            type = "error"
        }
    end

    return injuries, {
        title = locale("splint_success_title"),
        description = locale("splint_success_used", limbName),
        type = "success"
    }
end

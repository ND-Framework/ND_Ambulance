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
            title = locale("burndressing_error_title"),
            description = locale("burndressing_error_no_injuries"),
            type = "error"
        }
    end

    local limbName = check(injuries)
    if not limbName then
        return false, {
            title = locale("burndressing_error_title"),
            description = locale("burndressing_error_no_burnable"),
            type = "error"
        }
    end

    return injuries, {
        title = locale("burndressing_success_title"),
        description = locale("burndressing_success_used", limbName),
        type = "success"
    }
end

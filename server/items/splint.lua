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
            title = "Error",
            description = "No injuries found.",
            type = "error"
        }
    end

    local limbName = check(injuries)
    if not limbName then
        return false, {
            title = "Error",
            description = "No injuries found that can use a splint.",
            type = "error"
        }
    end

    return injuries, {
        title = "Success",
        description = ("Used splint on %s."):format(limbName),
        type = "success"
    }
end

local damageStrings = {"Fractures: %s", "Burns: %s", "Bleeding: %s", "Suffocation: %s"}
local damageTypes = {"fracture", "burn", "bleeding", "suffocating"}
local help = {"Treatment: splint", "Treatment: dressing", "Treatment: gauze, bandages or tourniquet", "Treatment: cpr"}

local function getDamageText(damage)
    if not damage then return end
    if damage > 0 and damage < 1 then
        return "minor"
    elseif damage >= 1 and damage <= 3 then
        return "major"
    elseif damage > 3 then
        return "extreme"
    end
end

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function getBodypartDamage(part)
    local values = {}
    local damageTypes = {"fracture", "burn", "bleeding", "suffocating"}
    for i=1, 4 do
        local text = part and getDamageText(part[damageTypes[i]])
        if text then
            values[#values+1] = damageStrings[i]:format(text)
        end
    end
    return values
end

function CheckPlayerInjuries(player)
    local info = lib.callback.await("ND_Ambulance:getInfo", nil, player)
    if not info then
        lib.registerMenu({
            id = "ND_Ambulance:checkInjuries",
            title = "Check injuries",
            position = "top-right",
            options = {{label = "No injuries"}}
        })
        lib.showMenu("ND_Ambulance:checkInjuries")
        return
    end

    local options = {}
    for i=1, 4 do
        local totalDamage = GetTotalDamageType(info, damageTypes[i])
        local text = getDamageText(totalDamage)
        if text then
            options[#options+1] = {
                label = damageStrings[i]:format(text),
                description = help[i]
            }
        end
    end

    for _, k in pairs(sortedKeys(info)) do
        local bodyPart = info[k]
        local label = bodyPart.label
        local damage = getDamageText(bodyPart.severity)
        local injury = table.concat(bodyPart.injury, ", ")
        print("test", bodyPart, label, damage, injury)
        if damage and injury and injury ~= "" then
            options[#options+1] = {
                label = ("%s: %s injury"):format(label, damage),
                values = getBodypartDamage(bodyPart),
                description = ("Injury: %s"):format(injury)
            }
        end
    end

    if #options == 0 then
        lib.registerMenu({
            id = "ND_Ambulance:checkInjuries",
            title = "Check injuries",
            position = "top-right",
            options = {{label = "No injuries"}}
        })
        lib.showMenu("ND_Ambulance:checkInjuries")
        return
    end

    lib.registerMenu({
        id = "ND_Ambulance:checkInjuries",
        title = "Check injuries",
        position = "top-right",
        options = options
    })
    lib.showMenu("ND_Ambulance:checkInjuries")
end

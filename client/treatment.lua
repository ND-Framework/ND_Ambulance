local damageStrings = {"Fractures: %s", "Burns: %s", "Bleeding: %s", "Suffocation: %s"}
local damageTypes = {"fracture", "burn", "bleeding", "suffocating"}
local help = {"Treatment: splint", "Treatment: burn dressing", "Treatment: gauze or tourniquet", "Treatment: cpr"}
local injuryTreatment = {"fracture", "burn", "bleeding", "suffocating"}
local jobs = lib.load("data.jobs")

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

local function tableLength(t)
    local count = 0
    for _, _ in pairs(t) do
        count += 1
    end
    return count
end

function CheckPlayerInjuries(targetSrc)
    local state = Player(targetSrc).state
    local info = state.injuries

    if not info or tableLength(info) == 0 then
        lib.registerMenu({
            id = "ND_Ambulance:checkInjuries",
            title = "Check injuries",
            position = "top-right",
            options = {{label = "No injuries"}}
        })
        return lib.showMenu("ND_Ambulance:checkInjuries")
    end

    local options = {}
    for i=1, 4 do
        local totalDamage = GetTotalDamageType(info, damageTypes[i])
        local text = getDamageText(totalDamage)
        if text then
            options[#options+1] = {
                label = damageStrings[i]:format(text),
                description = help[i],
                args = injuryTreatment[i]
            }
        end
    end

    for _, part in pairs(sortedKeys(info)) do
        local bodyPart = info[part]
        local label = bodyPart.label
        local damage = getDamageText(bodyPart.severity)
        local injury = table.concat(bodyPart.injury, ", ")
        
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
        return lib.showMenu("ND_Ambulance:checkInjuries")
    end

    lib.registerMenu({
        id = "ND_Ambulance:checkInjuries",
        title = "Check injuries",
        position = "top-right",
        options = options
    }, function(selected, scrollIndex, args)
        if not args or type(args) ~= "string" then return end
        TriggerServerEvent("ND_Ambulance:useOnNearby", targetSrc, args)
    end)
    lib.showMenu("ND_Ambulance:checkInjuries")
end

RegisterCommand("injuries", function(source, args, rawCommand)
    CheckPlayerInjuries(cache.serverId)
end, false)

exports.ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:checkInjuries",
        icon = "fa-solid fa-notes-medical",
        label = "Check injuries",
        distance = 1.5,
        canInteract = function(entity, distance, coords, name, bone)
            local targetPlayer = NetworkGetPlayerIndexFromPed(entity)
            local serverId = GetPlayerServerId(targetPlayer)
            return Player(serverId).state.isDead or Bridge.hasJobs(jobs)
        end,
        onSelect = function(data)
            local targetPlayer = NetworkGetPlayerIndexFromPed(data.entity)
            CheckPlayerInjuries(GetPlayerServerId(targetPlayer))
        end
    },
})

local damageStrings = {locale("fractures"), locale("burns"), locale("bleeding"), locale("suffocation")}
local damageTypes = {locale("fracture"), locale("burn"), locale("damage_bleeding"), locale("suffocating")}
local help = {locale("treatment_splint"), locale("treatment_burn_dressing"), locale("treatment_gauze_or_tourniquet"), locale("treatment_cpr")}
local injuryTreatment = {locale("fracture"), locale("burn"), locale("bleeding"), locale("suffocating")}
local jobs = lib.load("data.jobs")

local function getDamageText(damage)
    if not damage then return end
    if damage > 0 and damage < 1 then
        return locale("damage_severity_minor")
    elseif damage >= 1 and damage <= 3 then
        return locale("damage_severity_major")
    elseif damage > 3 then
        return locale("damage_severity_extreme")
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
            values[#values+1] = ("%s: %s"):format(damageStrings[i], text)
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
            title = locale("check_injuries"),
            position = "top-right",
            options = {{label = locale("no_injuries")}}
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
                label = locale("injury_label", label, damage),
                values = getBodypartDamage(bodyPart),
                description = locale("injury_description", injury)
            }
        end
    end

    if #options == 0 then
        lib.registerMenu({
            id = "ND_Ambulance:checkInjuries",
            title = locale("check_injuries"),
            position = "top-right",
            options = {{label = locale("no_injuries")}}
        })
        return lib.showMenu("ND_Ambulance:checkInjuries")
    end

    lib.registerMenu({
        id = "ND_Ambulance:checkInjuries",
        title = locale("check_injuries"),
        position = "top-right",
        options = options
    }, function(selected, scrollIndex, args)
        if not args or type(args) ~= "string" then return end
        TriggerServerEvent("ND_Ambulance:useOnNearby", targetSrc, args)
    end)
    lib.showMenu("ND_Ambulance:checkInjuries")
end

RegisterCommand(locale("check_injuries_self_command"), function(source, args, rawCommand)
    CheckPlayerInjuries(cache.serverId)
end, false)

exports.ox_target:addGlobalPlayer({
    {
        name = "ND_Ambulance:checkInjuries",
        icon = "fa-solid fa-notes-medical",
        label = locale("check_injuries"),
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

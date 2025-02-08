local bridgeResources = {
    { "ND_Core", "nd" },
    { "qbx_core", "qbx" },
    { "ox_core", "ox" }
    -- { "es_extended", "esx" },
    -- { "qb-core", "qb" }
}

local targetResources = {
    "ox_target",
    "qb-target"
}

local function getBridge()
    for i=1, #bridgeResources do
        local info = bridgeResources[i]
        if GetResourceState(info[1]):find("start") then
            lib.print.info(("Found active framework: ^6%s"):format(info[1]))
            return ("bridge.framework.%s.%s"):format(info[2], lib.context)
        end
    end

    lib.print.info("No matching framework found, defaulting to ^6standalone mode.")
    return ("bridge.framework.standalone.%s"):format(lib.context)
end

local function getBridgeTarget()
    for i=1, #targetResources do
        local target = targetResources[i]
        if GetResourceState(target):find("start") then
            lib.print.info(("Found interaction resource: ^6%s"):format(target))
            return ("bridge.target.%s"):format(target)
        end
    end

    lib.print.info("No matching target resource found, defaulting to ^6standalone mode.")
    return "bridge.target.standalone"
end

Bridge = lib.load(getBridge())

-- if lib.context == "client" then
--     Target = lib.load(getBridgeTarget())
-- end
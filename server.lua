-- CC SCRIPTS / HUD - ESX VERSION
local ESX = exports['es_extended']:getSharedObject()

local ResetStress = false

---------------------------------------------------------
-- ESX COMMANDS
---------------------------------------------------------

ESX.RegisterCommand('cash', 'user', function(xPlayer, args, showError)
    local cash = 0

    for _, acc in ipairs(xPlayer.getAccounts()) do
        if acc.name == 'money' or acc.name == 'cash' then
            cash = acc.money
        end
    end

    TriggerClientEvent('hud:client:ShowAccounts', xPlayer.source, 'cash', cash)
end, false, {help = Lang:t('info.check_cash_balance')})

ESX.RegisterCommand('bank', 'user', function(xPlayer, args, showError)
    local bank = 0

    for _, acc in ipairs(xPlayer.getAccounts()) do
        if acc.name == 'bank' then
            bank = acc.money
        end
    end

    TriggerClientEvent('hud:client:ShowAccounts', xPlayer.source, 'bank', bank)
end, false, {help = Lang:t('info.check_bank_balance')})

ESX.RegisterCommand('dev', 'admin', function(xPlayer, args, showError)
    TriggerClientEvent("qb-admin:client:ToggleDevmode", xPlayer.source)
end, true, {help = Lang:t('info.toggle_dev_mode')})

---------------------------------------------------------
-- STRESS SYSTEM (ESX VERSION)
---------------------------------------------------------

local function isPolice(xPlayer)
    return xPlayer.job and (
        xPlayer.job.name == 'police' or
        xPlayer.job.name == 'sheriff' or
        xPlayer.job.name == 'trooper'
    )
end

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if Config.DisablePoliceStress and isPolice(xPlayer) then return end

    local current = xPlayer.getMeta('stress') or 0
    local newStress = ResetStress and 0 or (current + amount)

    if newStress < 0 then newStress = 0 end
    if newStress > 100 then newStress = 100 end

    xPlayer.setMeta('stress', newStress)

    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local current = xPlayer.getMeta('stress') or 0
    local newStress = ResetStress and 0 or (current - amount)

    if newStress < 0 then newStress = 0 end
    if newStress > 100 then newStress = 100 end

    xPlayer.setMeta('stress', newStress)

    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('esx:showNotification', src, Lang:t("notify.stress_removed"))
end)

---------------------------------------------------------
-- SAVE UI CONFIG
---------------------------------------------------------

RegisterNetEvent('hud:server:saveUIData', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- PERMISSION CHECK
    if xPlayer.getGroup() ~= 'admin' and not IsPlayerAceAllowed(src, 'command') then
        print(('[HUD] Player %s attempted to save UI config without permission'):format(src))
        return
    end

    local uiConfigData = {}
    uiConfigData.icons = {}

    local path = GetResourcePath(GetCurrentResourceName())
    path = path:gsub('//', '/') .. '/uiconfig.lua'
    local file = io.open(path, 'w+')

    if not file then
        print("[HUD] ERROR: Cannot save UI config at " .. path)
        return
    end

    file:write("UIConfig = {}\n")

    -------------------------------------------------
    -- ICONS
    -------------------------------------------------
    file:write("\nUIConfig.icons = {}\n")

    local iconKeys = {}
    for k in pairs(data.icons) do table.insert(iconKeys, k) end
    table.sort(iconKeys)

    for _, iconName in ipairs(iconKeys) do
        uiConfigData.icons[iconName] = {}

        file:write("\nUIConfig.icons['" .. iconName .. "'] = {")

        local innerKeys = {}
        for k in pairs(data.icons[iconName]) do table.insert(innerKeys, k) end
        table.sort(innerKeys)

        for _, key in ipairs(innerKeys) do
            local v = data.icons[iconName][key]
            uiConfigData.icons[iconName][key] = v

            if type(v) == "string" then
                file:write(("\n    %s = '%s',"):format(key, v))
            else
                file:write(("\n    %s = %s,"):format(key, v))
            end
        end

        file:write("\n}\n")
    end

    -------------------------------------------------
    -- LAYOUT
    -------------------------------------------------
    file:write("\nUIConfig.layout = {")
    for k, v in pairs(data.layout) do
        if type(v) == "string" then
            file:write(("\n    %s = '%s',"):format(k, v))
        else
            file:write(("\n    %s = %s,"):format(k, v))
        end
    end
    file:write("\n}\n")

    uiConfigData.layout = data.layout

    -------------------------------------------------
    -- COLORS
    -------------------------------------------------
    file:write("\nUIConfig.colors = {}\n")
    uiConfigData.colors = {}

    local colorKeys = {}
    for k in pairs(data.colors) do table.insert(colorKeys, k) end
    table.sort(colorKeys)

    for _, colorName in ipairs(colorKeys) do
        uiConfigData.colors[colorName] = {}
        uiConfigData.colors[colorName].colorEffects = {}

        file:write("\nUIConfig.colors['" .. colorName .. "'] = {")
        file:write("\n    colorEffects = {")

        for i, effect in ipairs(data.colors[colorName].colorEffects) do
            uiConfigData.colors[colorName].colorEffects[i] = effect

            file:write("\n        [" .. i .. "] = {")

            local effectKeys = {}
            for k in pairs(effect) do table.insert(effectKeys, k) end
            table.sort(effectKeys)

            for _, key in ipairs(effectKeys) do
                local v = effect[key]
                if type(v) == "string" then
                    file:write(("\n            %s = '%s',"):format(key, v))
                else
                    file:write(("\n            %s = %s,"):format(key, v))
                end
            end

            file:write("\n        },")
        end

        file:write("\n    },")
        file:write("\n}\n")
    end

    file:close()

    UIConfig = uiConfigData

    TriggerClientEvent('hud:client:UpdateUISettings', -1, uiConfigData)
end)

---------------------------------------------------------
-- ESX CALLBACKS
---------------------------------------------------------

ESX.RegisterServerCallback('hud:server:getMenu', function(source, cb)
    cb(Config.Menu)
end)

ESX.RegisterServerCallback('hud:server:getRank', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    if xPlayer.getGroup() == 'admin' or IsPlayerAceAllowed(source, "command") then
        cb(true)
    else
        cb(false)
    end
end)

-- ESX Compatible Locale System (QBCore-like)

local Translations = {
    notify = {
        ["hud_settings_loaded"] = "HUD Settings Loaded!",
        ["hud_restart"] = "HUD Is Restarting!",
        ["hud_start"] = "HUD Is Now Started!",
        ["hud_command_info"] = "This command resets your current HUD settings!",
        ["load_square_map"] = "Square Map Loading...",
        ["loaded_square_map"] = "Square Map Has Loaded!",
        ["load_circle_map"] = "Circle Map Loading...",
        ["loaded_circle_map"] = "Circle Map Has Loaded!",
        ["cinematic_on"] = "Cinematic Mode On!",
        ["cinematic_off"] = "Cinematic Mode Off!",
        ["engine_on"] = "Engine Started!",
        ["engine_off"] = "Engine Shut Down!",
        ["low_fuel"] = "Fuel Level Low!",
        ["access_denied"] = "You Are Not Authorized!",
        ["stress_gain"] = "Feeling More Stressed!",
        ["stress_removed"] = "Feeling More Relaxed!"
    },
    info = {
        ["toggle_engine"] = "Toggle Engine",
        ["open_menu"] = "Open Menu",
        ["check_cash_balance"] = "Check Cash Balance",
        ["check_bank_balance"] = "Check Bank Balance",
        ["toggle_dev_mode"] = "Enable/Disable Developer Mode",
    }
}

-------------------------------------------------
-- QBCore-Compatible Locale Wrapper for ESX
-------------------------------------------------

Locale = {}

function Locale:new(data)
    local o = {}
    o.phrases = data.phrases or {}
    o.warnOnMissing = data.warnOnMissing or false
    setmetatable(o, self)
    self.__index = self
    return o
end

function Locale:t(path)
    local current = self.phrases
    for part in string.gmatch(path, "[^.]+") do
        current = current[part]
        if current == nil then
            if self.warnOnMissing then
                print("^1[cc-hud] Missing translation: " .. path .. "^7")
            end
            return path
        end
    end
    return current
end

-------------------------------------------------
-- Expose Lang identifier (like in QBCore)
-------------------------------------------------
Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

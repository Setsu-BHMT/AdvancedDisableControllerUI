-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

-- Note to addon authors: these are safe to call from your code, but make sure you add ADCUI as an optional dependency

if not ADCUI.isDefined then return end


-- call the original IsInGamepadPreferredMode function
local originalIsInGamepadPreferredMode = IsInGamepadPreferredMode
function ADCUI:originalIsInGamepadPreferredMode()
  return originalIsInGamepadPreferredMode()
end

-- enable or disable override of IsInGamepadPreferredMode
local function myIsInGamepadPreferredMode()
  --DEBUG: find out who called us
  --d(debug.traceback())

  local isInGamepadMode = ADCUI:originalIsInGamepadPreferredMode()

  if ADCUI:shouldUseGamepadUI() then
    return isInGamepadMode
  else
    return isInGamepadMode and ADCUI.vars.isLockpicking
  end
end
function ADCUI:setGamepadPreferredModeOverrideState(state)
  if state then
    _G["IsInGamepadPreferredMode"] = myIsInGamepadPreferredMode
  else
    _G["IsInGamepadPreferredMode"] = originalIsInGamepadPreferredMode
  end
end

-- switch the gamepad enabled state twice, because some UI elements grab the state before we can properly do an update
function ADCUI:cycleGamepadPreferredMode()
  if ADCUI:originalIsInGamepadPreferredMode() then
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "false")
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "true")
  else
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "true")
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "false")
  end
end

-- get settings for either character or account wide
function ADCUI:getSettings()
  if not ADCUI.savedVariablesAccountWide and not ADCUI.savedVariables then
    return nil  -- this will cause us to default to override in the very early stages of ui loading
  else
    return ADCUI.savedVariablesAccountWide.useAccountWideSettings and ADCUI.savedVariablesAccountWide or ADCUI.savedVariables
  end
end
local function getSettingHelper(settingName)
  local settings = ADCUI:getSettings()

  return settings and settings[settingName]
end

-- return whether default gamepad UI should be used
function ADCUI:shouldUseGamepadUI()
  return getSettingHelper("useControllerUI")
end

-- return whether gamepad buttons should be used
function ADCUI:shouldUseGamepadButtons()
  return getSettingHelper("useGamepadButtons")
end

-- return whether gamepad action bar should be used
function ADCUI:shouldUseGamepadActionBar()
  return getSettingHelper("useGamepadActionBar")
end

-- set the reticle fonts
function ADCUI:setReticleFont(reticleFont, contextFont, isGamepad)
  local style = {
      font = contextFont,
      keybindButtonStyle = ZO_ShallowTableCopy(KEYBIND_STRIP_STANDARD_STYLE),
    }
    
  if isGamepad then
    style.keybindButtonStyle = ZO_ShallowTableCopy(KEYBIND_STRIP_GAMEPAD_STYLE)
  end
  
  style.keybindButtonStyle.nameFont = reticleFont
  
  RETICLE:ApplyPlatformStyle(style)
end

-- set the stealth icon fonts
function ADCUI:setStealthIconFont(fontName)
  local style = { font = fontName }
  
  RETICLE.stealthIcon:ApplyPlatformStyle(style)
  LOCK_PICK.stealthIcon:ApplyPlatformStyle(style)
end
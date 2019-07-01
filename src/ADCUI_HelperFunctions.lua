-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


-- switch the gamepad enabled state twice, because some UI elements grab the state before we can properly do an update
function ADCUI:cycleGamepadPreferredMode()
  if self.vars.isGamepadEnabled then
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "false")
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "true")
  else
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "true")
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "false")
  end
end

-- switch whether to use gamepad UI
-- input is optional, default is change to opposite state
function toggleControllerUI()
  ADCUI:toggleControllerUI()  -- for backward compatability if any other addon calls this
end
function ADCUI:toggleControllerUI(state)
  local settings = ADCUI:getSettings()
  
  if (state == settings.useControllerUI) then
    return -- requested state is the same as current state, so do nothing
  end

	settings.useControllerUI = not settings.useControllerUI
  
  if settings.useControllerUI then
    _G["IsInGamepadPreferredMode"] = self.vars.originalIsInGamepadPreferredMode  -- this is important, because some UI elements initialize before we get notified of game mode changes
  elseif self.vars.isGamepadKeysInitialized then
    -- if gamepad settings is not initialized then we let the game mode change event handler deal with overriding and initialization
    _G["IsInGamepadPreferredMode"] = myIsInGamepadPreferredMode
  end
  
  self:cycleGamepadPreferredMode()
end

-- return whether default gamepad UI should be used
function ADCUI:shouldUseGamepadUI()
  local settings = ADCUI:getSettings()

  return settings and settings.useControllerUI
end

-- call the original IsInGamepadPreferredMode function
function ADCUI:originalIsInGamepadPreferredMode()
  return self.vars.originalIsInGamepadPreferredMode()
end

-- get settings for either character or account wide
function ADCUI:getSettings()
  return ADCUI.savedVariablesAccountWide.useAccountWideSettings and ADCUI.savedVariablesAccountWide or ADCUI.savedVariables
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
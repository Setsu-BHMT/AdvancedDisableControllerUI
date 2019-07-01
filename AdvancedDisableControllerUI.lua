-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

-- CHANGELOG:
--    account wide settings
--    lockpick menu move B to right
--    adjust font size for reticle, context, stealth
--    adjust stack all for launder

-- TODO: 
--    world map zooming...etc [worldmap.lua]
--    restore gamepad action bar
--    configurable override of gamepad buttons

-- BUGS:
--    sprint is now a toggle
--    [Dolgubon's lazy writ crafter] auto open container not working ... loop consistantly

if not ADCUI.isDefined then return end

	
-- [Global Overrides]

-- override for the IsInGamepadPreferredMode, it's how this addon implements its main function
-- do the override later to allow default UI elements to load the gamepad icons/settings we want.
-- this has to be global!
function myIsInGamepadPreferredMode()
  --DEBUG: find out who called us
  --d(debug.traceback())

  -- don't do anything if we don't actually use the gamepad
  if not ADCUI.vars.isGamepadEnabled then
    return false
  end

  -- enable gamepad mode while lockpicking
  if ADCUI.vars.isLockpicking then
    return true
  end
  
  -- unless user set useControllerUI we return false to force keyboard mode
  return ADCUI:shouldUseGamepadUI()
end


-- [Private Functions]

-- Initialize preferences
local function initializePrefs()
  ADCUI.savedVariablesAccountWide = ZO_SavedVars:NewAccountWide("AdvancedDisableControllerUI_SavedPrefs", 1, nil, ADCUI.default)
  ADCUI.savedVariables = ZO_SavedVars:NewCharacterIdSettings("AdvancedDisableControllerUI_SavedPrefs", 1, nil, ADCUI.default)
end

-- update panel
local function loadMenuPanel()
  LoadLAM2Panel() -- load Menu Settings
  EVENT_MANAGER:UnregisterForEvent("AdvancedDisableControllerUI_Player", EVENT_PLAYER_ACTIVATED) -- unregist event handler
end

-- disable and then re-enable gamepad mode, used to adjust timing of overriding IsInGamepadPreferredMode
local function initializeGamepadOverride()
  ADCUI:getGamepadIcons()
  ADCUI:cycleGamepadPreferredMode()
end

-- OnLoad
local function onLoad(event, addon)  
  if(addon ~= ADCUI.const.ADDON_NAME) then
    return
  end
  
  initializePrefs()
  onUpdateCompass()
    
  -- if we load in gamepad mode, we can grab the gamepad settings
  if ADCUI.vars.isGamepadEnabled then
    ADCUI:getGamepadIcons()
    
    -- override IsInGamepadPreferredMode and cycle only if we're overriding the UI
    if not ADCUI:shouldUseGamepadUI() then
      _G["IsInGamepadPreferredMode"] = myIsInGamepadPreferredMode
      ADCUI:cycleGamepadPreferredMode()
    end
  end
  
  ZO_CompassFrame:SetHandler("OnUpdate", frameUpdate)
  
  EVENT_MANAGER:RegisterForEvent("AdvancedDisableControllerUI_Player", EVENT_PLAYER_ACTIVATED, loadMenuPanel)  
  EVENT_MANAGER:UnregisterForEvent("AdvancedDisableControllerUI_OnLoad", EVENT_ADD_ON_LOADED) 
end

-- Update variables
local function onUpdateVars()

--d("onUpdateVars")
  
  local anchor, point, rTo, rPoint, offsetx, offsety = ZO_CompassFrame:GetAnchor()
  local settings = ADCUI:getSettings()
    
  if((offsetx ~= settings.anchorOffsetX and offsetx ~= ADCUI.default.anchorOffsetX)
      or 
     (offsety ~= settings.anchorOffsetY and offsety ~= ADCUI.default.anchorOffsetY)) then
    
    settings.anchorOffsetX = offsetx
    settings.anchorOffsetY = offsety
    settings.point = point
  
    if(rPoint ~= nil) then
      settings.point = rPoint
    end
  end  
end  

-- handle the gamepad mode change event
-- we use this to handle overrides and cleanup
local function onGamepadModeChanged(eventCode, gamepadPreferred)
  ADCUI.vars.isGamepadEnabled = gamepadPreferred
  
  KEYBIND_STRIP:ClearKeybindGroupStateStack() -- this call is important! If the user changed modes mid-scene such as quest journal or bank, the strip stack would be left in an inconsistent state eventually leading to LUA errors

  -- switch settings for each mode
  if gamepadPreferred and not ADCUI:shouldUseGamepadUI() then
    if not ADCUI.vars.isGamepadKeysInitialized then
      -- we have not yet cached the gamepad icons yet, so do that do override and cycle so that everything loads correctly
      -- this is only done once, on the first enabling of gamepad mode if we loaded in keyboard mode
      ADCUI:getGamepadIcons()
      _G["IsInGamepadPreferredMode"] = myIsInGamepadPreferredMode
      ADCUI:cycleGamepadPreferredMode()
      return
    end
  
    ADCUI:setGamepadIcons()
    ADCUI:setGamepadUISettings()
    
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.DEFAULT_CLICK, "Gamepad UI override enabled")
  else
    ADCUI:setKeyboardUISettings()
  end
end


-- [Register Event Handlers]

EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_ADD_ON_LOADED, onLoad)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GLOBAL_MOUSE_UP, onUpdateVars)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GLOBAL_MOUSE_DOWN, onUpdateVars)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, onGamepadModeChanged)

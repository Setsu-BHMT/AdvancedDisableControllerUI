-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


-- [Dialogs]

-- override ZO_Dialogs_ShowDialog to force gamepad buttons
-- we do this by reverting our override function back to the original during dialog creation, then switching back after the call
-- this seems to keep the keyboard dialog and just switch out the buttons to the gamepad ones
local originalZOShowDialog = _G["ZO_Dialogs_ShowDialog"]
local function myShowDialog(name, data, textParams, isGamepad)
  if not ADCUI:shouldUseGamepadButtons() then
    return originalZOShowDialog(name, data, textParams, isGamepad)
  end
  
  ADCUI:setGamepadPreferredModeOverrideState(false)
  local dialog = originalZOShowDialog(name, data, textParams, isGamepad)
  ADCUI:setGamepadPreferredModeOverrideState(true)

  return dialog
end
_G["ZO_Dialogs_ShowDialog"] = myShowDialog


-- [Quickslot Radial Manager]

-- override QuickslotSlotRadialManager:StartInteraction() to force gamepad buttons
-- except when using the gamepad UI this should always return the keyboard version
local function myQuickslotSlotRadialManager_StartInteraction(self)
  self.gamepad = ADCUI:shouldUseGamepadUI()

  if self.gamepad then
    QUICKSLOT_RADIAL_GAMEPAD:StartInteraction()
  else
    QUICKSLOT_RADIAL_KEYBOARD:StartInteraction()
  end
end
QUICKSLOT_RADIAL_MANAGER["StartInteraction"] = myQuickslotSlotRadialManager_StartInteraction


-- [Stall All Button Mapping]

-- hook button group add to adjust controls for the store scene
-- we have to do this for store and inventory scenes because their classes don't expose the descriptor structures globally

-- adjust stack all to be compatable with gamepad controls or revert them back to keyboard
local function setStackAllKeybind(keybindButtonGroupDescriptor)
  for _, keybindButtonDescriptor in ipairs(keybindButtonGroupDescriptor) do
    if ADCUI:originalIsInGamepadPreferredMode() then -- set override
      if not keybindButtonDescriptor.modByADCUI and (keybindButtonDescriptor.keybind == "UI_SHORTCUT_STACK_ALL") then
        keybindButtonDescriptor.keybind = "UI_SHORTCUT_LEFT_STICK"
        keybindButtonDescriptor.modByADCUI = true
      end
    else                                -- revert override
      if (keybindButtonDescriptor.keybind == "UI_SHORTCUT_LEFT_STICK") then
        keybindButtonDescriptor.keybind = "UI_SHORTCUT_STACK_ALL"
        keybindButtonDescriptor.modByADCUI = false
      end
    end
  end
end

local function onAddOrUpdateKeybindButtonGroup(self, keybindButtonGroupDescriptor, stateIndex)
  local settings = ADCUI:getSettings()  -- this is important, if you call ADCUI:shouldUseGamepadButtons you get NOT BOUND in keyboard mode
  if not keybindButtonGroupDescriptor or not settings or not settings.useGamepadButtons then
    return
  end

  local sceneName = SCENE_MANAGER:GetCurrentSceneName()
  if not sceneName or (sceneName ~= "store") and (sceneName ~= "inventory") and (sceneName ~= "fence_keyboard") then
    return
  end

  setStackAllKeybind(keybindButtonGroupDescriptor)
end

ZO_PreHook(KEYBIND_STRIP, "AddKeybindButtonGroup", onAddOrUpdateKeybindButtonGroup)
ZO_PreHook(KEYBIND_STRIP, "UpdateKeybindButtonGroup", onAddOrUpdateKeybindButtonGroup)


-- [Player Attribute Bars]

local originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged = PLAYER_ATTRIBUTE_BARS["OnGamepadPreferredModeChanged"]
local function myZO_PlayerAttributeBars_OnGamepadPreferredModeChanged(self)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged(self)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false, "myZO_PlayerAttributeBars_OnGamepadPreferredModeChanged")
  originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged(self)
  ADCUI:setGamepadPreferredModeOverrideState(true, "myZO_PlayerAttributeBars_OnGamepadPreferredModeChanged")
end


-- [Action Bar]

-- override ZO_PlatformStyle but only for calls from ActionButton
local originalZO_PlatformStyle_Apply = ZO_PlatformStyle["Apply"]
local function myZO_PlatformStyle_Apply(self)
  if not self.keyboardStyle or (self.keyboardStyle.showWeaponSwapButton == nil) or not ADCUI:originalIsInGamepadPreferredMode() then
    return originalZO_PlatformStyle_Apply(self)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false, "myZO_PlatformStyle_Apply")
  self.applyFunction(self.gamepadStyle)
  ADCUI:setGamepadPreferredModeOverrideState(true, "myZO_PlatformStyle_Apply")
end

-- override ZO_GetPlatformTemplate but only for calls from ActionButton
local originalZO_GetPlatformTemplate = _G["ZO_GetPlatformTemplate"]
local function myZO_GetPlatformTemplate(baseTemplate)
  if not ADCUI:originalIsInGamepadPreferredMode() or 
     (baseTemplate ~= "ZO_ActionButton") and (baseTemplate ~= "ZO_UltimateActionButton") then
    return originalZO_GetPlatformTemplate(baseTemplate)
  else
    return baseTemplate .. "_Gamepad_Template"
  end
end

-- we need this so that the ultimate button loads with fill animations and button icons
-- luckily this is only called once and some other call will re-enable the override
local originalZO_WeaponsSwap_SetPermanentlyHidden = _G["ZO_WeaponSwap_SetPermanentlyHidden"]
local function myZO_WeaponsSwap_SetPermanentlyHidden(self, hidden)
  if not ADCUI.vars.isHudOrHudUIShowing then
    return originalZO_WeaponsSwap_SetPermanentlyHidden(self, hidden)
  end
  ADCUI:setGamepadPreferredModeOverrideState(false, "myZO_WeaponsSwap_SetPermanentlyHidden")
  originalZO_WeaponsSwap_SetPermanentlyHidden(self, hidden)
end


-- called when ability button is pressed
local originalActionButton_ResetVisualState = ActionButton["ResetVisualState"]
local function myActionButton_ResetVisualState(self)
  if not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_ResetVisualState(self)
  end
  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_ResetVisualState")
  originalActionButton_ResetVisualState(self)
  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- if ran removes ultimate LB/RB and action bounce
end

--first thing that gets called when a button is created
local originalActionButton_HandleSlotChanged = ActionButton["HandleSlotChanged"]
local function myActionButton_HandleSlotChanged(self)
  if not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_HandleSlotChanged(self)
  end
  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_HandleSlotChanged")
  originalActionButton_HandleSlotChanged(self)
  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- let this leak, so ultimate button animation plays correctly
end

-- called when a slot is being removed
local originalActionButton_Clear = ActionButton["Clear"]
local function myActionButton_Clear(self)
  if not ADCUI:originalIsInGamepadPreferredMode() or not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_Clear(self)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_Clear")
  originalActionButton_Clear(self)
  ADCUI:setGamepadPreferredModeOverrideState(true, "myActionButton_Clear")
end

local originalActionButton_UpdateState = ActionButton["UpdateState"]  --DEBUG
local function myActionButton_UpdateState(self)
  originalActionButton_UpdateState(self)  -- if ran fixes easy travel error but removes ultimate fill bar, LB/RB, action button bounce
  ADCUI:setGamepadPreferredModeOverrideState(true, "myActionButton_UpdateState")
end
ActionButton["UpdateState"] = myActionButton_UpdateState

local originalActionButton_SetCooldownIconAnchors = ActionButton["SetCooldownIconAnchors"]
local function myActionButton_SetCooldownIconAnchors(self, inCooldown)
  if not ADCUI:originalIsInGamepadPreferredMode() or not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_SetCooldownIconAnchors(self, inCooldown)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_SetCooldownIconAnchors")
  originalActionButton_SetCooldownIconAnchors(self, inCooldown)
  ADCUI:setGamepadPreferredModeOverrideState(true, "myActionButton_SetCooldownIconAnchors")    -- need this so that after switching quickslot we end in override state
end

-- runs continuously during cooldown such as after using a collectible item
-- maintains our override during the cooldown period
local originalActionButton_RefreshCooldown = ActionButton["RefreshCooldown"]
local function myActionButton_RefreshCooldown(self)
  if not ADCUI:originalIsInGamepadPreferredMode() or not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_RefreshCooldown(self)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_RefreshCooldown")
  originalActionButton_RefreshCooldown(self)
  ADCUI:setGamepadPreferredModeOverrideState(true, "myActionButton_RefreshCooldown")
end

-- last call after action is used
local originalActionButton_UpdateCooldown = ActionButton["UpdateCooldown"]
local function myActionButton_UpdateCooldown(self, options)
  if not ADCUI:originalIsInGamepadPreferredMode() or not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_UpdateCooldown(self, options)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_UpdateCooldown")
  originalActionButton_UpdateCooldown(self, options)
  --ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_UpdateCooldown") -- maybe? need this so that ultimate squeeze animation and highlight work after reloadui
  if (self.slot.slotNum == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1) then
    self.button:SetHidden(true)
  end
end

-- last call after button load/initializes/gamepad change
local originalActionButton_ApplyStyle = ActionButton["ApplyStyle"]  
local function myActionButton_ApplyStyle(self, template)
  if not ADCUI:originalIsInGamepadPreferredMode() or not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_ApplyStyle(self, template)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_ApplyStyle")
  originalActionButton_ApplyStyle(self, template)
  ADCUI:setGamepadPreferredModeOverrideState(true, "myActionButton_ApplyStyle")
end

local originalActionButton_SetupFlipAnimation = ActionButton["SetupFlipAnimation"]
local function myActionButton_SetupFlipAnimation(self, OnStopHandlerFirst, OnStopHandlerLast)
  if not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_SetupFlipAnimation(self, OnStopHandlerFirst, OnStopHandlerLast)
  end
  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_SetupFlipAnimation")
  originalActionButton_SetupFlipAnimation(self, OnStopHandlerFirst, OnStopHandlerLast)
  ADCUI:setGamepadPreferredModeOverrideState(true, "myActionButton_SetupFlipAnimation")  -- try this and see if it's necessary to fix a leak override
end

local originalActionButton_SetupBounceAnimation = ActionButton["SetupBounceAnimation"]
local function myActionButton_SetupBounceAnimation(self)
  if not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_SetupBounceAnimation(self)
  end
  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_SetupBounceAnimation")
  originalActionButton_SetupBounceAnimation(self)
  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- if set then the ultimate animation setup will be in the wrong mode
end

local originalActionButton_PlayAbilityUsedBounce = ActionButton["PlayAbilityUsedBounce"]
local function myActionButton_PlayAbilityUsedBounce(self, offset)
  if not ADCUI.vars.isHudOrHudUIShowing then
    return originalActionButton_PlayAbilityUsedBounce(self, offset)
  end
  ADCUI:setGamepadPreferredModeOverrideState(false, "myActionButton_PlayAbilityUsedBounce")
  originalActionButton_PlayAbilityUsedBounce(self, offset)
  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- seems OK to ignore for now
end

local originalActionButton_HideKeys = ActionButton["HideKeys"]
local function myActionButton_HideKeys(self)
  -- we override ZO_WeaponSwap_SetPermanentlyHidden to have the override disabled for the ultimate button activation
  -- but we need to turn it back on, and while this function doesn't have gamepad-specific code it allows us to reset the override
  if ADCUI:originalIsInGamepadPreferredMode() then
    --ADCUI:setGamepadPreferredModeOverrideState(true)  -- if set to true screws with squeeze
  end
end

local function onActionUpdateCooldowns()
  if ADCUI:originalIsInGamepadPreferredMode() then
    ADCUI:setGamepadPreferredModeOverrideState(true, "onActionUpdateCooldowns")
  end
end

local function onActionSlotStateUpdated()
  -- if we call this immediately, we break flip animations and ultimate button fill animations
  -- but we need to do this so that after the reticle swings by a targetable object we aren't stuck in gamepad mode
  -- so we use this hack to just take care of that one situation without breaking the animations
  if ADCUI:originalIsInGamepadPreferredMode() then
    ADCUI:setGamepadPreferredModeOverrideStateDelayed(true, 50, "onActionSlotStateUpdated")
  end
end

local function onActionSlotAbilityUsed()
  if ADCUI:originalIsInGamepadPreferredMode() then
    ADCUI:setGamepadPreferredModeOverrideState(true, "onActionSlotAbilityUsed")
  end
end

-- mirror code in ActionBar.SetUltimateMeter that are only affected by gamepad mode setting
local function onPowerUpdate(evt, unitTag, powerPoolIndex, powerType, ultimate, powerPoolMax)
  if not ADCUI:originalIsInGamepadPreferredMode() or not ADCUI.vars.isHudOrHudUIShowing then
    return
  end
  local slotIndex = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
  local isSlotUsed = IsSlotUsed(slotIndex)
  local ultimateButton = ZO_ActionBar_GetButton(slotIndex)
  local ultimateFillLeftTexture = GetControl(ultimateButton.slot, "FillAnimationLeft")
  local ultimateFillRightTexture = GetControl(ultimateButton.slot, "FillAnimationRight")
  local ultimateFillFrame = GetControl(ultimateButton.slot, "Frame")
  local ultimateMax = GetSlotAbilityCost(slotIndex)

  if IsSlotUsed then
    if ultimate >= ultimateMax then
      ultimateFillFrame:SetHidden(false)
      ultimateFillLeftTexture:SetHidden(false)
      ultimateFillRightTexture:SetHidden(false)
    else
      local barTexture = GetControl(ultimateButton.slot, "UltimateBar")
      local leadingEdge = GetControl(ultimateButton.slot, "LeadingEdge")
      barTexture:SetHidden(true)
      leadingEdge:SetHidden(true)
      ultimateFillLeftTexture:SetHidden(false)
      ultimateFillRightTexture:SetHidden(false)
      ultimateFillFrame:SetHidden(false)
    end
  end

  ultimateButton:HideKeys(false)
end

-- adjust settings after ActionBar:ApplyStyle()
local function onGamepadModeChanged_ActionBar(eventCode, gamepadPreferred)
  if not gamepadPreferred then
    return
  end


  local ultimateButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
  ultimateButton:SetShowBindingText(false)

  -- quickslot and action button texts
  for control, text in pairs(ADCUI.vars.backupActionButtonIcons) do
    control:SetText(text)
  end
end

-- player deactivated means loading screen is starting
local function onPlayerDeactivated()
  --ADCUI:setGamepadPreferredModeOverrideState(true) --doesn't work
end

-- disable all action bar related overrides when not in hudui or hud scene
-- otherwise interactions in the scene cause very undesirable behavior, like getting stuck in gamepad mode
local function onSceneStateChanged_ActionBar(scene, oldState, newState)
  if not ADCUI:originalIsInGamepadPreferredMode() or not scene or (newState == SCENE_SHOWN) or (newState == SCENE_HIDDEN) then
    return
  end

  ADCUI:setGamepadPreferredModeOverrideState(true)
  ADCUI.vars.isHudOrHudUIShowing = false

  if newState == SCENE_SHOWING then
    local name = scene:GetName()
    ADCUI.vars.isHudOrHudUIShowing = (name == HUD_SCENE:GetName()) or (name == HUD_UI_SCENE:GetName())
  end
end

function ADCUI:setGamepadActionBarOverrideState(state)
  if state then
    PLAYER_ATTRIBUTE_BARS["OnGamepadPreferredModeChanged"] = myZO_PlayerAttributeBars_OnGamepadPreferredModeChanged
    ZO_PlatformStyle["Apply"] = myZO_PlatformStyle_Apply
    _G["ZO_GetPlatformTemplate"] = myZO_GetPlatformTemplate
    _G["ZO_WeaponSwap_SetPermanentlyHidden"] = myZO_WeaponsSwap_SetPermanentlyHidden
    ActionButton["ResetVisualState"] = myActionButton_ResetVisualState
    ActionButton["HandleSlotChanged"] = myActionButton_HandleSlotChanged
    ActionButton["Clear"] = myActionButton_Clear
    ActionButton["SetCooldownIconAnchors"] = myActionButton_SetCooldownIconAnchors
    ActionButton["RefreshCooldown"] = myActionButton_RefreshCooldown
    ActionButton["UpdateCooldown"] = myActionButton_UpdateCooldown
    ActionButton["ApplyStyle"] = myActionButton_ApplyStyle
    ActionButton["SetupFlipAnimation"] = myActionButton_SetupFlipAnimation
    ActionButton["SetupBounceAnimation"] = myActionButton_SetupBounceAnimation
    ActionButton["PlayAbilityUsedBounce"] = myActionButton_PlayAbilityUsedBounce
    ActionButton["HideKeys"] = myActionButton_HideKeys

    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_UPDATE_COOLDOWNS, onActionUpdateCooldowns)
    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_SLOT_STATE_UPDATED, onActionSlotStateUpdated)
    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_SLOT_ABILITY_USED, onActionSlotAbilityUsed)
    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_POWER_UPDATE, onPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, onGamepadModeChanged_ActionBar)
    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_PLAYER_ACTIVATED, onPlayerDeactivated)
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneStateChanged_ActionBar)

    ADCUI.vars.isHudOrHudUIShowing = SCENE_MANAGER:IsShowing(HUD_SCENE:GetName()) or SCENE_MANAGER:IsShowing(HUD_UI_SCENE:GetName())
  else
    PLAYER_ATTRIBUTE_BARS["OnGamepadPreferredModeChanged"] = originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged
    ZO_PlatformStyle["Apply"] = originalZO_PlatformStyle_Apply
    _G["ZO_GetPlatformTemplate"] = originalZO_GetPlatformTemplate
    _G["ZO_WeaponSwap_SetPermanentlyHidden"] = originalZO_WeaponsSwap_SetPermanentlyHidden
    ActionButton["ResetVisualState"] = originalActionButton_ResetVisualState
    ActionButton["HandleSlotChanged"] = originalActionButton_HandleSlotChanged
    ActionButton["Clear"] = originalActionButton_Clear
    ActionButton["SetCooldownIconAnchors"] = originalActionButton_SetCooldownIconAnchors
    ActionButton["RefreshCooldown"] = originalActionButton_RefreshCooldown
    ActionButton["UpdateCooldown"] = originalActionButton_UpdateCooldown
    ActionButton["ApplyStyle"] = originalActionButton_ApplyStyle
    ActionButton["SetupFlipAnimation"] = originalActionButton_SetupFlipAnimation
    ActionButton["SetupBounceAnimation"] = originalActionButton_SetupBounceAnimation
    ActionButton["PlayAbilityUsedBounce"] = originalActionButton_PlayAbilityUsedBounce
    ActionButton["HideKeys"] = originalActionButton_HideKeys

    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_UPDATE_COOLDOWNS)
    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_SLOT_STATE_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_SLOT_ABILITY_USED)
    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_PLAYER_ACTIVATED)
    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", onSceneStateChanged_ActionBar)

    -- make sure that we are leaving the override in the correct state
    ADCUI:setGamepadPreferredModeOverrideState(true)
  end
end

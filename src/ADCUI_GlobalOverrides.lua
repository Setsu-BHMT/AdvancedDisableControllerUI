-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


-- override ZO_Dialogs_ShowDialog to force gamepad buttons
-- we do this by reverting our override function back to the original during dialog creation, then switching back after the call
local originalZOShowDialog = _G["ZO_Dialogs_ShowDialog"]
local function myShowDialog(name, data, textParams, isGamepad)
  if not ADCUI:originalIsInGamepadPreferredMode() or 
     ADCUI:shouldUseGamepadUI() or not ADCUI:shouldUseGamepadButtons() then
    return originalZOShowDialog(name, data, textParams, isGamepad)
  end
  
  ADCUI:setGamepadPreferredModeOverrideState(false)
  local dialog = originalZOShowDialog(name, data, textParams, isGamepad)
  ADCUI:setGamepadPreferredModeOverrideState(true)

  return dialog
end
_G["ZO_Dialogs_ShowDialog"] = myShowDialog


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
  if not keybindButtonGroupDescriptor or not ADCUI:shouldUseGamepadButtons() then
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



---- hook ZO_PlatformStyle to build our own table of apply functions
--local platformStyles = {}
--ZO_PreHook(ZO_PlatformStyle, "Apply", function (self)
--  if platformStyles[self] == nil then
--    platformStyles[self] = self
--  end
--end)

local function foo()
--  -- ideas: switch all to force gamepad and see what happens: still no change in keybind, we probably need to modify directly
--  for style in pairs(platformStyles) do
--    if style.gamepadStyle then
--      ADCUI:setGamepadPreferredModeOverrideState(false)
--      style.applyFunction(style.gamepadStyle)
--      ADCUI:setGamepadPreferredModeOverrideState(true)
--    end
--  end

--  local mystyle = nil
--  for style in pairs(platformStyles) do
--    if style.keyboardStyle and (style.keyboardStyle.showWeaponSwapButton ~= nil) then
--      mystyle = style
--    end
--  end
--  -- ideas: switch mystyle to have gamepadstyle in keyboardStyle: failed Q still gets reverted back after using
--  if mystyle then
--    ADCUI:setGamepadPreferredModeOverrideState(false)
--    mystyle.applyFunction(mystyle.gamepadStyle)
--    ADCUI:setGamepadPreferredModeOverrideState(true)
--  end
end
SLASH_COMMANDS["/foo"] = foo



--
---- hook ZO_PlatformStyle 
--ZO_PreHook(ZO_PlatformStyle, "Apply", function (self)
--  if not self or not self.keyboardStyle or (self.keyboardStyle.showWeaponSwapButton == nil) then
--    return
--  end
--
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  self.applyFunction(self.gamepadStyle)
--  ADCUI:setGamepadPreferredModeOverrideState(true)
--
--  return true
--end)
--
---- hook ZO_GetPlatformTemplate
--ZO_PreHook("ZO_GetPlatformTemplate", function (baseTemplate)
--  if (baseTemplate == "ZO_ActionButton") or (baseTemplate == "ZO_UltimateActionButton") then
--    return baseTemplate .. "_Gamepad_Template"
--  end
--end)
--
---- called when ability button is pressed
--local originalActionButton_ResetVisualState = ActionButton["ResetVisualState"]
--local function myActionButton_ResetVisualState(self)
--  d(self.slot.slotNum .. ": ResetVisualState START")
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  originalActionButton_ResetVisualState(self)
--  --ADCUI:setGamepadPreferredModeOverrideState(true)
--  d(self.slot.slotNum .. ": ResetVisualState END")
--end
--ActionButton["ResetVisualState"] = myActionButton_ResetVisualState
--
----first thing that gets called when a button is created
--local originalActionButton_HandleSlotChanged = ActionButton["HandleSlotChanged"]
--local function myActionButton_HandleSlotChanged(self)
--  d(self.slot.slotNum .. ": HandleSlotChanged START")
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  originalActionButton_HandleSlotChanged(self)
--  ADCUI:setGamepadPreferredModeOverrideState(true)
--  d(self.slot.slotNum .. ": HandleSlotChanged END")
--end
--ActionButton["HandleSlotChanged"] = myActionButton_HandleSlotChanged
--
---- not called at all...
----local originalActionButton_Clear = ActionButton["Clear"]
----local function myActionButton_Clear(self)
----  d(self.slot.slotNum .. ": Clear START")
----  ADCUI:setGamepadPreferredModeOverrideState(false)
----  originalActionButton_Clear(self)
----  --ADCUI:setGamepadPreferredModeOverrideState(true)
----  d(self.slot.slotNum .. ": Clear END")
----end
----ActionButton["Clear"] = myActionButton_Clear
--
---- always wrapped inside update cooldown
------ called when button loads/initializes/weapon bar swap
------ called in pairs with UpdateCoolDown to form a reset of button state it seems
----local originalActionButton_UpdateUsable = ActionButton["UpdateUsable"]
----local function myActionButton_UpdateUsable(self)
----  --d(self.slot.slotNum .. ": UpdateUsable START")
----  ADCUI:setGamepadPreferredModeOverrideState(false)
----  originalActionButton_UpdateUsable(self)
----  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- removes squeeze animation and highlight around ultimate
----  --d(self.slot.slotNum .. ": UpdateUsable END")
----end
----ActionButton["UpdateUsable"] = myActionButton_UpdateUsable
--
---- not sandwiched between anything, but applying override after seems ok
--local originalActionButton_SetCooldownIconAnchors = ActionButton["SetCooldownIconAnchors"]
--local function myActionButton_SetCooldownIconAnchors(self, inCooldown)
--  d(self.slot.slotNum .. ": SetCooldownIconAnchors START")
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  originalActionButton_SetCooldownIconAnchors(self, inCooldown)
--  --ADCUI:setGamepadPreferredModeOverrideState(true)
--  d(self.slot.slotNum .. ": SetCooldownIconAnchors END")
--end
--ActionButton["SetCooldownIconAnchors"] = myActionButton_SetCooldownIconAnchors
--
---- this runs constantly during a cooldown, like dragon gem....
----local originalActionButton_RefreshCooldown = ActionButton["RefreshCooldown"]
----local function myActionButton_RefreshCooldown(self)
----  ADCUI:setGamepadPreferredModeOverrideState(false)
----  originalActionButton_RefreshCooldown(self)
----  --ADCUI:setGamepadPreferredModeOverrideState(true)
----  d(self.slot.slotNum .. ": RefreshCooldown")
----end
----ActionButton["RefreshCooldown"] = myActionButton_RefreshCooldown
--
---- last call after action is used [COMPLETED]
--local originalActionButton_UpdateCooldown = ActionButton["UpdateCooldown"]
--local function myActionButton_UpdateCooldown(self, options)
--  --d(self.slot.slotNum .. ": UpdateCooldown START")
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  originalActionButton_UpdateCooldown(self, options)
--  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- removes squeeze animation and highlight around ultimate
--  --d(self.slot.slotNum .. ": UpdateCooldown END")
--  if (self.slot.slotNum == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1) then
--    self.button:SetHidden(true)
--  end
--end
--ActionButton["UpdateCooldown"] = myActionButton_UpdateCooldown
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTION_UPDATE_COOLDOWNS, function (...) 
--                                                                                ADCUI:setGamepadPreferredModeOverrideState(true)
--                                                                                d("EVENT_ACTION_UPDATE_COOLDOWNS")  end)
--
------ called when a gamepad mode change occurs, seems to always be sandwiched between calls
----local originalActionButton_ApplyFlipAnimationStyle = ActionButton["ApplyFlipAnimationStyle"]
----local function myActionButton_ApplyFlipAnimationStyle(self)
----  d(self.slot.slotNum .. ": ApplyFlipAnimationStyle START")
----  ADCUI:setGamepadPreferredModeOverrideState(false)
----  originalActionButton_ApplyFlipAnimationStyle(self)
----  --ADCUI:setGamepadPreferredModeOverrideState(true)
----  d(self.slot.slotNum .. ": ApplyFlipAnimationStyle END")
----end
----ActionButton["ApplyFlipAnimationStyle"] = myActionButton_ApplyFlipAnimationStyle
--
---- last call after button load/initializes/gamepad change
--local originalActionButton_ApplyStyle = ActionButton["ApplyStyle"]  
--local function myActionButton_ApplyStyle(self, template)
--  d(self.slot.slotNum .. ": ApplyStyle START")
--  ADCUI:setGamepadPreferredModeOverrideState(false) -- breaks things if we switch weapon bars
--  originalActionButton_ApplyStyle(self, template)
--  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- removes highlight around ultimate before switching weapon bars
--  d(self.slot.slotNum .. ": ApplyStyle END")
--end
--ActionButton["ApplyStyle"] = myActionButton_ApplyStyle
--
--local originalActionButton_SetupFlipAnimation = ActionButton["SetupFlipAnimation"]
--local function myActionButton_SetupFlipAnimation(self, OnStopHandlerFirst, OnStopHandlerLast)
--  d(self.slot.slotNum .. ": SetupFlipAnimation START")
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  originalActionButton_SetupFlipAnimation(self, OnStopHandlerFirst, OnStopHandlerLast)
--  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- seems ok for now
--  d(self.slot.slotNum .. ": SetupFlipAnimation END")
--end
--ActionButton["SetupFlipAnimation"] = myActionButton_SetupFlipAnimation
--
--local originalActionButton_SetupBounceAnimation = ActionButton["SetupBounceAnimation"]
--local function myActionButton_SetupBounceAnimation(self)
--  d(self.slot.slotNum .. ": SetupBounceAnimation START")
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  originalActionButton_SetupBounceAnimation(self)
--  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- seems ok for now
--  d(self.slot.slotNum .. ": SetupBounceAnimation END")
--end
--ActionButton["SetupBounceAnimation"] = myActionButton_SetupBounceAnimation
--
--local originalActionButton_PlayAbilityUsedBounce = ActionButton["PlayAbilityUsedBounce"]
--local function myActionButton_PlayAbilityUsedBounce(self, offset)
--  d(self.slot.slotNum .. ": PlayAbilityUsedBounce START")
--  ADCUI:setGamepadPreferredModeOverrideState(false)
--  originalActionButton_PlayAbilityUsedBounce(self, offset)
--  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- seems OK for now
--  d(self.slot.slotNum .. ": PlayAbilityUsedBounce END")
--end
--ActionButton["PlayAbilityUsedBounce"] = myActionButton_PlayAbilityUsedBounce
--
----local originalActionButton_SetupKeySlideAnimation = ActionButton["SetupKeySlideAnimation"]
----local function myActionButton_SetupKeySlideAnimation(self)
----  d(self.slot.slotNum .. ": SetupKeySlideAnimation START")
----  ADCUI:setGamepadPreferredModeOverrideState(false)
----  originalActionButton_SetupKeySlideAnimation(self)
----  --ADCUI:setGamepadPreferredModeOverrideState(true)  -- seems ok for now
----  d(self.slot.slotNum .. ": SetupKeySlideAnimation END")
----end
----ActionButton["SetupKeySlideAnimation"] = myActionButton_SetupKeySlideAnimation
--
--
----
----local function SetupActionSlot(slotObject, slotId)
----    local slotIcon = GetSlotTexture(slotId)
----
----    slotObject.slot:SetHidden(false)
----    slotObject.hasAction = true
----
----    local isGamepad = true
----    ZO_ActionSlot_SetupSlot(slotObject.icon, slotObject.button, slotIcon, isGamepad and "" or "EsoUI/Art/ActionBar/abilityFrame64_up.dds", 
----                            isGamepad and "" or "EsoUI/Art/ActionBar/abilityFrame64_down.dds", slotObject.cooldownIcon)
----    slotObject:UpdateState()
----end
----
----local function SetupActionSlotWithBg(slotObject, slotId)
----    SetupActionSlot(slotObject, slotId)
----    slotObject.bg:SetTexture("EsoUI/Art/ActionBar/abilityInset.dds")
----end
----
----local function SetupAbilitySlot(slotObject, slotId)
----    SetupActionSlotWithBg(slotObject, slotId)
----
----    if slotId == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 then
----        slotObject:RefreshUltimateNumberVisibility()
----    else
----        slotObject:ClearCount()
----    end
----end
----
----local function SetupItemSlot(slotObject, slotId)
----    SetupActionSlotWithBg(slotObject, slotId)
----    slotObject:SetupCount()
----end
----
----local function SetupCollectibleActionSlot(slotObject, slotId)
----    SetupActionSlotWithBg(slotObject, slotId)
----    slotObject:ClearCount()
----end
----
----local function SetupQuestItemActionSlot(slotObject, slotId)
----    SetupActionSlotWithBg(slotObject, slotId)
----    slotObject:SetupCount()
----end
----
----local function SetupEmptyActionSlot(slotObject, slotId)
----    slotObject:Clear()
----end
----
----SetupSlotHandlers =
----{
----    [ACTION_TYPE_ABILITY]       = SetupAbilitySlot,
----    [ACTION_TYPE_ITEM]          = SetupItemSlot,
----    [ACTION_TYPE_COLLECTIBLE]   = SetupCollectibleActionSlot,
----    [ACTION_TYPE_QUEST_ITEM]    = SetupQuestItemActionSlot,
----    [ACTION_TYPE_NOTHING]       = SetupEmptyActionSlot,
----}
--
--local function foo()
--  if (IsInGamepadPreferredMode()) then
--    d("NOT OVERRIDE!")
--  else
--    d("in override")
--  end
--end
--SLASH_COMMANDS["/foo"] = foo
--
--
--ZO_PreHook("ZO_ActionBar_GetButton", function (slotNum)
--  --ADCUI:setGamepadPreferredModeOverrideState(false)
--  d("ZO_ActionBar_GetButton: " .. slotNum)
--end)
--ZO_PreHook("ZO_ActionBar_OnActionButtonDown", function (slotNum)
--  --ADCUI:setGamepadPreferredModeOverrideState(false)
--  d("ZO_ActionBar_OnActionButtonDown: " .. slotNum)
--end)
--ZO_PreHook("ZO_ActionBar_OnActionButtonUp", function (slotNum)
--  --ADCUI:setGamepadPreferredModeOverrideState(false)
--  d("ZO_ActionBar_OnActionButtonUp: " .. slotNum)
--end)
--
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTION_SLOT_UPDATED, function (_, slotnum) d("EVENT_ACTION_SLOT_UPDATED: " .. slotnum)  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function (...) d("EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function (...) d("EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTION_SLOT_STATE_UPDATED, function (_, slotnum) d("EVENT_ACTION_SLOT_STATE_UPDATED: " .. slotnum)  
--  --ADCUI:setGamepadPreferredModeOverrideState(true)  --causes squeeze not to fire, also cooldown doesn't play
--  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTION_SLOT_ABILITY_USED, function (_, slotnum) d("EVENT_ACTION_SLOT_ABILITY_USED: " .. slotnum)  
--  ADCUI:setGamepadPreferredModeOverrideState(true)
--  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_INVENTORY_FULL_UPDATE, function (...) d("EVENT_INVENTORY_FULL_UPDATE")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (...) d("EVENT_INVENTORY_SINGLE_SLOT_UPDATE")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_CURSOR_PICKUP, function (...) d("EVENT_CURSOR_PICKUP")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_CURSOR_DROPPED, function (...) d("EVENT_CURSOR_DROPPED")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ITEM_SLOT_CHANGED, function (...) d("EVENT_ITEM_SLOT_CHANGED")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTIVE_QUICKSLOT_CHANGED, function (...) d("EVENT_ACTIVE_QUICKSLOT_CHANGED")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function (...) d("EVENT_ACTIVE_WEAPON_PAIR_CHANGED")  end)
--EVENT_MANAGER:RegisterForEvent("ACDUI_DEBUG", EVENT_POWER_UPDATE, function (...) d("EVENT_POWER_UPDATE")  end)
--EVENT_MANAGER:AddFilterForEvent("ACDUI_DEBUG", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "player")
--
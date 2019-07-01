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

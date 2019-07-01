-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


-- override ZO_Dialogs_ShowDialog to force gamepad buttons
-- we do this by reverting our override function back to the original during dialog creation, then switching back after the call
local originalZOShowDialog = _G["ZO_Dialogs_ShowDialog"]
local function myShowDialog(name, data, textParams, isGamepad)
  if not ADCUI.vars.isGamepadEnabled or ADCUI:shouldUseGamepadUI() then
    return originalZOShowDialog(name, data, textParams, isGamepad)
  end
  
  _G["IsInGamepadPreferredMode"] = ADCUI.vars.originalIsInGamepadPreferredMode
  local dialog = originalZOShowDialog(name, data, textParams, isGamepad)
  _G["IsInGamepadPreferredMode"] = myIsInGamepadPreferredMode
  
  return dialog
end
_G["ZO_Dialogs_ShowDialog"] = myShowDialog

-- [BROKEN DO NOT USE]
-- local isShowingDialog = false
-- ZO_PreHook("ZO_Dialogs_ShowDialog", function (...)
  -- if isShowingDialog or not ADCUI.vars.isGamepadEnabled then
    -- return false
  -- end
  
  -- isShowingDialog = true
  -- _G["IsInGamepadPreferredMode"] = ADCUI.vars.originalIsInGamepadPreferredMode
  -- local dialog = ZO_Dialogs_ShowDialog(...)
  -- isShowingDialog = false
  -- _G["IsInGamepadPreferredMode"] = myIsInGamepadPreferredMode
  
  -- return dialog or true -- don't continue calling the original function even if return value was nil
-- end)
-- [/BROKEN DO NOT USE]

-- hook button group add to adjust controls for the store scene
-- we have to do this for store and inventory scenes because their classes don't expose the descriptor structures globally

 -- adjust stack all to be compatable with gamepad controls or revert them back to keyboard
local function setStackAllKeybind(keybindButtonGroupDescriptor)
  for _, keybindButtonDescriptor in ipairs(keybindButtonGroupDescriptor) do
    if ADCUI.vars.isGamepadEnabled then -- set override
      if not keybindButtonDescriptor.modByADCUI and
        (keybindButtonDescriptor.keybind == "UI_SHORTCUT_STACK_ALL") then
        
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
  if not keybindButtonGroupDescriptor then 
    return
  end
  
  sceneName = SCENE_MANAGER:GetCurrentSceneName()
  if not sceneName or (sceneName ~= "store") and (sceneName ~= "inventory") and (sceneName ~= "fence_keyboard") then
    return
  end
  
  setStackAllKeybind(keybindButtonGroupDescriptor)
end

ZO_PreHook(KEYBIND_STRIP, "AddKeybindButtonGroup", onAddOrUpdateKeybindButtonGroup)
ZO_PreHook(KEYBIND_STRIP, "UpdateKeybindButtonGroup", onAddOrUpdateKeybindButtonGroup)

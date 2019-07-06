-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end

-- override indicator
local function UpdateDebugIndicator()
  ADCUI_debug:ClearAnchors()
  if _G["IsInGamepadPreferredMode"] == ADCUI.debugPtr then
    ADCUI_debugLabel:SetText("ON")
    ADCUI_debug:SetAnchor(BOTTOM, GuiRoot, LEFT, 20, -100)
  else
    ADCUI_debugLabel:SetText("OFF")
    ADCUI_debug:SetAnchor(BOTTOM, GuiRoot, LEFT, 20, 100)
  end
end
EVENT_MANAGER:RegisterForUpdate(ADCUI.const.ADDON_NAME .. "_debug", 50, UpdateDebugIndicator)

-- slash command
--  local function foo()
 
--  end
--  SLASH_COMMANDS["/foo"] = foo

-- Show scene changes and what it's changing to
SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldstate, newstate)
  if not scene then return end
  
  local sceneName = scene:GetName()

  local nextScene = SCENE_MANAGER:GetNextScene()

  if (nextScene) then
    ADCUI.debugLogger:Debug(sceneName .. " -> " .. newstate .. "  NEXT: " .. nextScene:GetName())
  else
    ADCUI.debugLogger:Debug(sceneName .. " -> " .. newstate)
  end
end)

-- -- add keybind hooks
-- ZO_PreHook(SCENE_MANAGER, "OnSceneStateShown", function(self, scene)
  -- if not scene then return end
  -- if not scene.GetName then return end
  -- d(scene:GetName() .. " is now shown")
-- end)
-- ZO_PreHook(KEYBIND_STRIP, "AddKeybindButton", function(self, keybindButtonDescriptor, stateIndex)
  -- if keybindButtonDescriptor.keybind then
    -- d("AddKeybindButton: " .. keybindButtonDescriptor.keybind)
  -- else
    -- d("AddKeybindButton: [NO KEYBIND]")
  -- end
-- end)
-- ZO_PreHook(KEYBIND_STRIP, "RemoveKeybindButton", function(self, keybindButtonDescriptor, stateIndex)
  -- if keybindButtonDescriptor.keybind then
    -- d("RemoveKeybindButton: " .. keybindButtonDescriptor.keybind)
  -- else
    -- d("RemoveKeybindButton: [NO KEYBIND]")
  -- end
-- end)
-- ZO_PreHook(KEYBIND_STRIP, "UpdateKeybindButton", function(self, keybindButtonDescriptor, stateIndex)
  -- if keybindButtonDescriptor.keybind then
    -- d("UpdateKeybindButton: " .. keybindButtonDescriptor.keybind)
  -- else
    -- d("UpdateKeybindButton: [NO KEYBIND]")
  -- end
-- end)
-- ZO_PreHook(KEYBIND_STRIP, "RemoveKeybindButtonGroup", function(self, keybindButtonGroupDescriptor, stateIndex)
  -- d("RemoveKeybindButtonGroup: size " .. #keybindButtonGroupDescriptor)
-- end)
-- ZO_PreHook(KEYBIND_STRIP, "HandleDuplicateAddKeybind", function(self, existingButtonOrEtherealDescriptor, keybindButtonDescriptor, state, stateIndex, currentSceneName)
  -- if existingButtonOrEtherealDescriptor.name and keybindButtonDescriptor.name then
    -- d("HandleDuplicateAddKeybind: " .. existingButtonOrEtherealDescriptor.name .. " -> " .. keybindButtonDescriptor.name)
  -- elseif existingButtonOrEtherealDescriptor.keybind and keybindButtonDescriptor.keybind then
    -- d("HandleDuplicateAddKeybind: " .. existingButtonOrEtherealDescriptor.keybind .. " -> " .. keybindButtonDescriptor.keybind)
  -- else
    -- d("HandleDuplicateAddKeybind: [NO INFO]")
  -- end
-- end)
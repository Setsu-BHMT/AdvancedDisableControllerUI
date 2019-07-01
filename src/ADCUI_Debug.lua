-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


-- slash command
-- local function foo()

 -- RETICLE:ApplyPlatformStyle(style) 
    -- {
        -- font = "ZoFontGamepad42",
        -- keybindButtonStyle = KEYBIND_STRIP_GAMEPAD_STYLE,
    -- }
 -- RETICLE.stealthIcon:ApplyPlatformStyle(style) {font = "ZoFontGamepad36"}
 -- LOCK_PICK.stealthIcon:ApplyPlatformStyle(style)
-- end
-- SLASH_COMMANDS["/foo"] = foo

-- -- hook the SCENE_MANAGER so that we know when interested scenes are shown
-- ZO_PreHook(SCENE_MANAGER, "OnSceneStateChange", function(self, scene, oldstate, newstate)
  -- if not scene or not scene.GetName then
    -- return
  -- end
  
  -- local sceneName = scene:GetName()
  
  -- if sceneName then
    -- d(sceneName .. ": " .. oldstate .. " -> " .. newstate)
  -- end
-- end)

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
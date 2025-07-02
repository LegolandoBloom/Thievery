local T = Thievery_Translate

function Thievery_FitVisualToKeybind()
    local ppKey = Thievery_Config.ppKey 
    if ppKey then
        local visual = Thievery_Visual
        visual.keybind:SetText(ppKey)
        local width, height = visual.keybind:GetSize()
        print("Size: ", width, height)
        visual.keybindFrameBG:SetSize((width * 1.1) + 6, height + (width*0.05))
        visual.keybindFrameTexture:SetSize((width * 1.1) + 6, height + (width*0.05))
    end
end

function Thievery_UpdateVisualPosition()
    local visual = Thievery_Visual
    visual:ClearAllPoints()
    local location = Thievery_UI.VisualLocation
    if next(Thievery_UI.VisualLocation) ~= nil then
        visual:SetPoint(location[1], location[2], location[3], location[4], location[5])
    else
        visual:SetPoint("CENTER", UIParent, "CENTER", 50, 30)
    end
end

function Thievery_SetupConfigPanel(parent)
    local configPanel = parent.configPanel
    local checkboxes = configPanel.checkboxes
    local keybindFrame = configPanel.keybindFrame
    local moveFrame = configPanel.moveFrame

    moveFrame.moveAndPlaceFrame.placeholderTexture:SetTexture("Interface/AddOns/Thievery/images/placeholder.png")
    moveFrame.callFunction = Thievery_UpdateVisualPosition

    keybindFrame.menuTitle:SetText(T["Thievery Keybind"])
    keybindFrame.onBindFunction = Thievery_FitVisualToKeybind
    keybindFrame.disclaimerText = T["The next key you press will be set as the Thievery key"]
    keybindFrame.disclaimerTextModified = T["Awaiting additional key press. Modifier key down: "]
    keybindFrame.disclaimerTextModified = T["Awaiting additional key press. Modifier key down: "]

    checkboxes.playSound.text:SetText(T["Play Sound Effect"])
    checkboxes.playSound.text.tooltip = T["When checked, plays a sound effect when the pickpocket key is pressed"]
    checkboxes.playSound:reposition()
    checkboxes.playSound.reference = "playSound"
    
    checkboxes.enableSap.text:SetText(T["Enable Sap"])
    checkboxes.enableSap.text.tooltip = T["Cast sap before pick pocket, with the same keybind."]
    checkboxes.enableSap:reposition()
    checkboxes.enableSap.reference = "enableSap"

end


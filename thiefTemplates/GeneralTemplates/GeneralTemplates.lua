local colorDebug = CreateColor(0.65, 1, 0) -- grass green
local colorYello = CreateColor(1.0, 0.82, 0.0)
local colorGrae = CreateColor(0.85, 0.85, 0.85)
local colorBlu = CreateColor(0.61, 0.85, 0.92)


Thievery_LegolandoKeybindFrameMixin = {}

Thievery_LegolandoKeybindFrameMixin.Modifiers = {
    modifiedListening = nil,
    modifierKeys = {
        LSHIFT = {"LSHIFT"},
        RSHIFT = {"RSHIFT"},
        LALT = {"LALT"},
        RALT = {"RALT"},
        LCTRL = {"LCTRL"},
        RCTRL = {"RCTRL"}
    }
}

function Thievery_LegolandoKeybindFrameMixin:CallOnBindFunction()
    if self.onBindFunction then
        self.onBindFunction()
    end
end

function Thievery_LegolandoKeybindFrameMixin:checkTableAndReference()
    local teeburu = self.savedVarTable
    if not teeburu then
        print("no saved variable table linked to keybind frame")
        return false
    end
    local key = self.savedVarKey
    if not self.savedVarKey then
        print("no reference key for the saved var table")
        return false
    end
    return true
end

function Thievery_LegolandoKeybindFrameMixin.OnClick(self, button, down)
    if self:checkTableAndReference() == false then return end
    if InCombatLockdown() then return end
    if button == "LeftButton" then
        if self.selected then
            self:StopWatching()
        else
            self.selected = true
            self:SetSelected(true)
            self:SetScript("OnKeyDown", Legolando_KeybindFrame_Modified)
            self:SetScript("OnMouseWheel", Legolando_KeybindFrame_MouseWheel)
            self:SetScript("OnMouseDown", Legolando_KeybindFrame_Mouse)
            self:SetScript("OnGamePadButtonDown", Legolando_KeybindFrame_GamePad)
            self:SetPropagateKeyboardInput(false)
            if self.disclaimerText then 
                self.disclaimer:Show()
                self.disclaimer:SetText(self.disclaimerText)
            end
            self.warning:Hide()
        end
    elseif button == "RightButton" then
        self:Unbind(self)
    end
end

function Legolando_KeybindFrame_OnUp(self, key)
    if self.Modifiers.modifiedListening == key then
        self.Modifiers.modifiedListening = nil
        if self.disclaimerText then 
            self.disclaimer:SetText(self.disclaimerText)
        end
        self:SetText(self.savedVarTable[self.savedVarKey])
        self:SetScript("OnKeyUp", nil)
        self:SetScript("OnKeyDown", Legolando_KeybindFrame_Modified)
        self:SetScript("OnMouseWheel", Legolando_KeybindFrame_MouseWheel)
        self:SetScript("OnMouseDown", Legolando_KeybindFrame_Mouse)
        self:SetScript("OnGamePadButtonDown", Legolando_KeybindFrame_GamePad)
    end
end

local mouseButtons = {
    ["MiddleButton"] = "BUTTON3",
    ["Button4"] = "BUTTON4",
    ["Button5"] = "BUTTON5",
}
function Legolando_KeybindFrame_Mouse(self, button)
    if button == "LeftButton" or button =="RightButton" then
        --nothing
    else
        local buttonName = mouseButtons[button]
        local teeburu = self.savedVarTable
        local refKey = self.savedVarKey
        if not buttonName then
            print("Unregistered mouse button, please contact the addon author")
        end
        if self.Modifiers.modifiedListening then
            self.savedVarTable[self.savedVarKey] = self.Modifiers.modifiedListening .. "-" .. buttonName
            self.Modifiers.modifiedListening = nil
            print("Key set to: " .. teeburu[refKey])
        else
            teeburu[refKey] = buttonName
            print("Key set to: " .. teeburu[refKey])
        end
        self.disclaimer:Hide()
        self:SetSelected(false)
        self.selected = false
        self:SetScript("OnKeyUp", nil)
        self:SetScript("OnKeyDown", nil)
        self:SetScript("OnMouseWheel", nil)
        self:SetScript("OnMouseDown", nil)
        self:SetScript("OnGamePadButtonDown", nil)
        self:SetText(teeburu[refKey])
        self:CallOnBindFunction()
    end
end

function Legolando_KeybindFrame_GamePad(self, button)
    local teeburu = self.savedVarTable
    local refKey = self.savedVarKey
    self:SetScript("OnKeyUp", nil)
    self:SetScript("OnKeyDown", nil)
    self:SetScript("OnMouseWheel", nil)
    self:SetScript("OnMouseDown", nil)
    self:SetScript("OnGamePadButtonDown", nil)
    self.disclaimer:Hide()
    self:SetSelected(false)
    self.selected = false
    teeburu[refKey] = button
    self:SetText(teeburu[refKey])
    print("Key set to: " .. teeburu[refKey])
    self:CallOnBindFunction()
end

function Legolando_KeybindFrame_MouseWheel(self, delta)
    local scroll
    if delta == 1 then
        scroll = "MOUSEWHEELUP"
    elseif delta == -1 then
        scroll = "MOUSEWHEELDOWN"
    end
    local teeburu = self.savedVarTable
    local refKey = self.savedVarKey
    if self.Modifiers.modifiedListening then
        local colorBlu = CreateColor(0.61, 0.85, 0.92)
        local colorWhite = CreateColor(1, 1, 1)
        local colorGrae = CreateColor(0.5, 0.5, 0.5)
        local colorYello = CreateColor(1.0, 0.82, 0.0)
        teeburu[refKey] = self.Modifiers.modifiedListening .. "-" .. scroll
        self.Modifiers.modifiedListening = nil
        print("Key set to: " .. teeburu[refKey])
        print(colorBlu:WrapTextInColorCode("Note: ") .. colorYello:WrapTextInColorCode("Modifier Keys ") 
        .. "won't be recognized when the game is in the " .. colorGrae:WrapTextInColorCode("background. ") 
        .. "If you are using the scroll wheel for that purpose. Just bind the wheel alone instead, without modifiers.")
    else
        teeburu[refKey] = scroll
        print("Key set to: ".. teeburu[refKey])
    end
    self.disclaimer:Hide()
    self:SetSelected(false)
    self.selected = false
    self:SetScript("OnKeyUp", nil)
    self:SetScript("OnKeyDown", nil)
    self:SetScript("OnMouseWheel", nil)
    self:SetScript("OnMouseDown", nil)
    self:SetScript("OnGamePadButtonDown", nil)
    self:SetText(teeburu[refKey])
    self:CallOnBindFunction()
end

function Legolando_KeybindFrame_Modified(self, key)
    local teeburu = self.savedVarTable
    local refKey = self.savedVarKey
    if key == "ENTER" then

    elseif key == "ESCAPE" then
        self:StopWatching()
    elseif self.Modifiers.modifierKeys[key] then
        self:SetText(key .. "-" .. "?")
        self.Modifiers.modifiedListening = key
        if self.disclaimerTextModified then
            self.disclaimer:SetText(self.disclaimerTextModified .. key)
        end
        self:SetScript("OnKeyUp", Legolando_KeybindFrame_OnUp)
        self:SetScript("OnKeyDown", Legolando_KeybindFrame_Modified)
        self:SetScript("OnMouseWheel", Legolando_KeybindFrame_MouseWheel)
        self:SetScript("OnMouseDown", Legolando_KeybindFrame_Mouse)
    elseif self.Modifiers.modifiedListening then
        self:SetScript("OnKeyUp", nil)
        self:SetScript("OnKeyDown", nil)
        self:SetScript("OnMouseWheel", nil)
        self:SetScript("OnMouseDown", nil)
        self:SetScript("OnGamePadButtonDown", nil)
        self.disclaimer:Hide()
        self:SetSelected(false)
        self.selected = false
        teeburu[refKey] = self.Modifiers.modifiedListening .. "-" .. key
        self:SetText(teeburu[refKey])
        print("Key set to: " .. key .. ", with modifier " .. self.Modifiers.modifiedListening)
        self.Modifiers.modifiedListening = nil
        self:CallOnBindFunction()
    else
        self:SetScript("OnKeyUp", nil)
        self:SetScript("OnKeyDown", nil)
        self:SetScript("OnMouseWheel", nil)
        self:SetScript("OnMouseDown", nil)
        self:SetScript("OnGamePadButtonDown", nil)
        self.disclaimer:Hide()
        self:SetSelected(false)
        self.selected = false
        teeburu[refKey] = key
        self:SetText(teeburu[refKey])
        print("Key set to: " .. teeburu[refKey])
        self:CallOnBindFunction()
    end 
end

function Thievery_LegolandoKeybindFrameMixin:StopWatching()
    local teeburu = self.savedVarTable
    local refKey = self.savedVarKey
    self.Modifiers.secondPressListening = false
    self.Modifiers.modifiedListening = nil
    self:SetScript("OnKeyUp", nil)
    self:SetScript("OnKeyDown", nil)
    self:SetScript("OnMouseWheel", nil)
    self:SetScript("OnMouseDown", nil)
    self:SetScript("OnGamePadButtonDown", nil)
    self:SetText(teeburu[refKey])
    self.disclaimer:Hide()
    self.selected = false
    self:SetSelected(false)
end

function Thievery_LegolandoKeybindFrameMixin:Unbind(self)
    local teeburu = self.savedVarTable
    local refKey = self.savedVarKey
    teeburu[refKey] = nil
    self:SetText(self.savedVarTable[self.savedVarKey])
    self:CallOnBindFunction()
    print("Keybind removed")
end



Legolando_CheckboxesFrameMixin = {}

function Legolando_CheckboxesFrameMixin:UpdateCheckboxes()
    local teeburu = self.savedVarTable
    if not teeburu then
        print("checkbox parent doesn't have a saved variable table attached")
        return
    end
    local children = {self:GetChildren()}
    for i, child in pairs(children) do
        if child:GetObjectType() == "CheckButton" and child.reference then
            local savedVar = teeburu[child.reference]
            if savedVar then
                if savedVar == true then
                    child:SetChecked(true)
                elseif savedVar == false then
                    child:SetChecked(false)
                end
            end
        end
    end
end

Legolando_CheckboxMixin = {};

function Legolando_CheckboxMixin:greyOut()
    self:SetChecked(false)
    self:Disable()
    self.text:SetTextColor(0.9, 0.9, 0.9)
    self.disabledText:Show()
    if self.dropDown then
        self.dropDown:Hide()
    end
end

function Legolando_CheckboxMixin:reposition()
    local width, height = self.text:GetSize()
    self.text:ClearAllPoints()
    self.text:SetPoint("RIGHT", self, "LEFT")
    self.disabledText:SetPoint("LEFT", self, "RIGHT")
    local _, _, _, offsetX, offsetY = self:GetPoint()
    self:AdjustPointsOffset(width, 0)
end

function Legolando_CheckboxMixin:OnClick()
    local parent = self:GetParent()
    local teeburu = parent.savedVarTable
    if not self.reference then
        print("no checkbox reference string")
        return
    end
    if not teeburu then
        print("no saved variable table attached")
        return
    end
    if teeburu[self.reference] == nil then
        print("checkbox reference not found in saved variable table")
        return
    end
    if self:GetChecked() then
        teeburu[self.reference] = true
    elseif self:GetChecked() == false then
        teeburu[self.reference] = false
    end
end


Thievery_TutorialTooltipMixin = {}

function Thievery_TutorialTooltipMixin:OnShow()
    self:SetPadding(self.paddingL, self.paddingB, self.paddingR, self.paddingT)
end

function Thievery_TutorialTooltipMixin:PlaceTexture(texturePath, width, height, anchor, padOffsetX, padOffsetY)
    if not texturePath then return end
    self.texture:ClearAllPoints()
    self.texture:SetTexture(texturePath)
    self.texture:SetSize(width, height)
    self.texture:SetPoint(anchor, self, anchor)
    self:ResetPadding()
    if anchor == "TOPLEFT" then
        self.paddingL = width + padOffsetX
        self.paddingT = height + padOffsetY
    elseif anchor == "TOPRIGHT" then
        self.paddingR = width + padOffsetX
        self.paddingT = height + padOffsetY
    elseif anchor == "BOTTOMLEFT" then
        self.paddingL = width + padOffsetX
        self.paddingB = height + padOffsetY
    elseif anchor == "BOTTOMRIGHT" then
        self.paddingR = width + padOffsetX
        self.paddingB = height + padOffsetY
    end
end

function Thievery_TutorialTooltipMixin:ResetPadding()
    self.paddingL = 0
    self.paddingB = 0
    self.paddingR = 0
    self.paddingT = 0
end

function Thievery_TutorialTooltipMixin:OnHide()
    self.texture:SetTexture(nil)
    self.texture:ClearAllPoints()
    self:ResetPadding()    
end
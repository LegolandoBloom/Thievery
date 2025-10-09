Legolando_MoveFrameMixin_Thievery = {}



Legolando_MoveAndPlaceMixin_Thievery = {}


function Legolando_MoveAndPlaceMixin_Thievery:UpdateScale(resetting, value)
    local parent = self:GetParent()
    local teeburu = parent.savedVarTable
    local key = parent.savedVarKey
    if teeburu and key then
        if resetting then
            
        elseif value then
            local scale = value/10
            
        end
    else
        print("No saved var table or key attached")
    end
    if parent.scaleCallback then
        parent.scaleCallback(self.placeholderTexture) 
    end
end
function Legolando_MoveAndPlaceMixin_Thievery:UpdatePosition(resetting, newScale)
    local parent = self:GetParent()
    local teeburu = parent.savedVarTable
    local key = parent.savedVarKey
    if teeburu and key then
        if resetting then
            self.placeholderTexture:SetScale(1)
            self.scaleSlider:SetValue(10)
        else
            if newScale then 
                teeburu[key].scale = newScale
                self.placeholderTexture:SetScale(newScale)
            end
            local scale = teeburu[key].scale
            if not scale then 
                scale = 1
                teeburu[key].scale = 1
            end
            local left, bottom, _, height = self.placeholderTexture:GetScaledRect()
            local top = bottom + height            
            -- ____________________ BOTH :GetScaledRect() AND left/scale(+top/scale) ARE NECESSARY. ______________________
            -- placeholderTexture is anchored to the 'MoveFrame', whereas the addon's frame will be anchored to 'UIParent'
            -- ___________________________________________________________________________________________________________
            teeburu[key].left = left/scale
            teeburu[key].top = top/scale
        end
    else
        print("No saved var table or key attached")
    end
    if parent.callFunc then
        parent.callFunc()
    end
end

function Legolando_MoveAndPlaceMixin_Thievery:ResetPosition()
    local parent = self:GetParent()
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", parent, "TOPRIGHT")
    parent.savedVarTable[parent.savedVarKey] = {}
    self:UpdatePosition(true, 1)
end
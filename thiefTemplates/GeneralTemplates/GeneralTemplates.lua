-- ____________________________________[1]______________________________________________
--       Templates Ported directly from Blizzard's FrameXML, for classic parity
-- ____________________________________[1]______________________________________________
local TabSideExtraSpacing = 20;
Legolando_PortedTabSystemButtonArtMixin_Thievery = {};
function Legolando_PortedTabSystemButtonArtMixin_Thievery:HandleRotation()
	if self.isTabOnTop then
		for _, texture in ipairs(self.RotatedTextures) do
			texture:ClearAllPoints();
			texture:SetRotation(math.pi);
		end
		self.RightActive:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -7, 0);
		self.LeftActive:SetPoint("BOTTOMRIGHT");
		self.MiddleActive:SetPoint("LEFT", self.RightActive, "RIGHT");
		self.MiddleActive:SetPoint("RIGHT", self.LeftActive, "LEFT");
		self.Right:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -6, 0);
		self.Left:SetPoint("BOTTOMRIGHT");
		self.Middle:SetPoint("LEFT", self.Right, "RIGHT");
		self.Middle:SetPoint("RIGHT", self.Left, "LEFT");
		self.LeftHighlight:SetPoint("TOPRIGHT", self.Left);
		self.RightHighlight:SetPoint("TOPLEFT", self.Right);
		self.MiddleHighlight:SetPoint("LEFT", self.Middle, "LEFT");
		self.MiddleHighlight:SetPoint("RIGHT", self.Middle, "RIGHT");
	end
end
function Legolando_PortedTabSystemButtonArtMixin_Thievery:GetTextYOffset(isSelected)
	if self.isTabOnTop then
		return isSelected and 0 or -3;
	else
		return isSelected and -3 or 2;
	end
end
function Legolando_PortedTabSystemButtonArtMixin_Thievery:SetTabSelected(isSelected)
	self.isSelected = isSelected;
	self.Left:SetShown(not isSelected);
	self.Middle:SetShown(not isSelected);
	self.Right:SetShown(not isSelected);
	self.LeftActive:SetShown(isSelected);
	self.MiddleActive:SetShown(isSelected);
	self.RightActive:SetShown(isSelected);
	local selectedFontObject = self.selectedFontObject or GameFontHighlightSmall;
	local unselectedFontObject = self.unselectedFontObject or GameFontNormalSmall;
	self:SetNormalFontObject(isSelected and selectedFontObject or unselectedFontObject);
	self:SetEnabled(not isSelected and not self.forceDisabled);
	self.Text:SetPoint("CENTER", self, "CENTER", 0, self:GetTextYOffset(isSelected));
	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end
function Legolando_PortedTabSystemButtonArtMixin_Thievery:SetTabWidth(width)
	self:SetWidth(width);
end

Legolando_PortedTabSystemButtonMixin_Thievery = {};
function Legolando_PortedTabSystemButtonMixin_Thievery:OnEnter()
	if not self:IsEnabled() and self.errorReason ~= nil then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -6);
		GameTooltip_AddErrorLine(GameTooltip, self.errorReason);
		if self.tooltipText then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
		end
		GameTooltip:Show();
	elseif self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -6);
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
		GameTooltip:Show();
	elseif self.Text:IsTruncated() then
		local text = self.Text:GetText();
		if text then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -6);
			GameTooltip_AddNormalLine(GameTooltip, text);
			GameTooltip:Show();
		end
	end
end
function Legolando_PortedTabSystemButtonMixin_Thievery:OnLeave()
	GameTooltip_Hide();
end
function Legolando_PortedTabSystemButtonMixin_Thievery:OnClick()
	local tabSystem = self:GetTabSystem();
	tabSystem:PlayTabSelectSound();
	tabSystem:SetTab(self:GetTabID());
end
function Legolando_PortedTabSystemButtonMixin_Thievery:Init(tabID, tabText)
	self.tabID = tabID;
	self:HandleRotation();
	self.tabText = tabText;
	self:SetText(tabText);
	self:UpdateTabWidth();
	self:SetTabSelected(false);
end
function Legolando_PortedTabSystemButtonMixin_Thievery:SetTooltipText(tooltipText)
	self.tooltipText = tooltipText;
end
function Legolando_PortedTabSystemButtonMixin_Thievery:SetTabEnabled(enabled, errorReason)
	self.forceDisabled = not enabled;
	self:SetEnabled(enabled and not self.isSelected);
	local text = enabled and self.tabText or DISABLED_FONT_COLOR:WrapTextInColorCode(self.tabText);
	self.Text:SetText(text);
	self.errorReason = errorReason;
end
function Legolando_PortedTabSystemButtonMixin_Thievery:UpdateTabWidth()
	local sidesWidth = self.Left:GetWidth() + self.Right:GetWidth();
	local width = sidesWidth + TabSideExtraSpacing;
	local minTabWidth, maxTabWidth = self:GetTabSystem():GetTabWidthConstraints();
	local textWidth;
	if maxTabWidth and width > maxTabWidth then
		width = maxTabWidth;
		textWidth = width - 10;
	end
	if minTabWidth and width < minTabWidth then
		width = minTabWidth;
		textWidth = width - 10;
	end
	self.Text:SetWidth(textWidth or 0);
	self:SetTabWidth(width);
end
function Legolando_PortedTabSystemButtonMixin_Thievery:GetTabID()
	return self.tabID;
end
function Legolando_PortedTabSystemButtonMixin_Thievery:GetTabSystem()
	return self:GetParent();
end

Legolando_PortedTabSystemMixin_Thievery = {};
function Legolando_PortedTabSystemMixin_Thievery:OnLoad()
	self.tabs = {};
	self.tabPool = CreateFramePool("BUTTON", self, self.tabTemplate);
end
function Legolando_PortedTabSystemMixin_Thievery:AddTab(tabText)
	local tabID = #self.tabs + 1;
	local newTab = self.tabPool:Acquire();
	table.insert(self.tabs, newTab);
	newTab.layoutIndex = tabID;
	newTab:Init(tabID, tabText);
	newTab:Show();
	self:MarkDirty();
	return tabID;
end
function Legolando_PortedTabSystemMixin_Thievery:SetTabSelectedCallback(tabSelectedCallback)
	self.tabSelectedCallback = tabSelectedCallback;
end
function Legolando_PortedTabSystemMixin_Thievery:SetTab(tabID)
	if not self.tabSelectedCallback(tabID) then
		self:SetTabVisuallySelected(tabID);
	end
end
function Legolando_PortedTabSystemMixin_Thievery:SetTabVisuallySelected(tabID)
	self.selectedTabID = tabID;
	for i, tab in ipairs(self.tabs) do
		tab:SetTabSelected(tab:GetTabID() == tabID);
	end
end
function Legolando_PortedTabSystemMixin_Thievery:SetTabShown(tabID, isShown)
	self.tabs[tabID]:SetShown(isShown);
	self:MarkDirty();
end
function Legolando_PortedTabSystemMixin_Thievery:SetTabEnabled(tabID, enabled, errorReason)
	self.tabs[tabID]:SetTabEnabled(enabled, errorReason);
	self:MarkDirty();
end
function Legolando_PortedTabSystemMixin_Thievery:GetTabWidthConstraints()
	return self.minTabWidth, self.maxTabWidth;
end
function Legolando_PortedTabSystemMixin_Thievery:GetTabButton(tabID)
	return self.tabs[tabID];
end
function Legolando_PortedTabSystemMixin_Thievery:PlayTabSelectSound()
	if self.tabSelectSound then
		PlaySound(self.tabSelectSound);
	end
end
-- ____________________________________[1]______________________________________________
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
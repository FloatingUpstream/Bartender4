--[[ $Id: StanceBar.lua 62418 2008-02-21 16:53:12Z nevcairiel $ ]]

-- register module
local MicroMenuMod = Bartender4:NewModule("MicroMenu", "AceHook-3.0")

-- fetch upvalues
local ActionBars = Bartender4:GetModule("ActionBars")
local Bar = Bartender4.Bar.prototype

-- create prototype information
local MicroMenuBar = setmetatable({}, {__index = Bar})

local table_insert = table.insert

local defaults = { profile = Bartender4:Merge({ 
	enabled = true,
	vertical = false,
}, Bartender4.Bar.defaults) }

function MicroMenuMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("MicroMenu", defaults)
	self:SetEnabledState(self.db.profile.enabled)
	self:SetupOptions()
end

local noopFunc = function() end

function MicroMenuMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.Bar:Create("MicroMenu", nil, self.db.profile), {__index = MicroMenuBar})
		local buttons = {}
		table_insert(buttons, CharacterMicroButton)
		table_insert(buttons, SpellbookMicroButton)
		table_insert(buttons, TalentMicroButton)
		table_insert(buttons, QuestLogMicroButton)
		table_insert(buttons, SocialsMicroButton)
		table_insert(buttons, LFGMicroButton)
		table_insert(buttons, MainMenuMicroButton)
		table_insert(buttons, HelpMicroButton)
		self.bar.buttons = buttons
		
		self:RawHook("UpdateTalentButton", noopFunc, true)
		
		for i,v in pairs(buttons) do 
			v:SetParent(self.bar)
			v:Show() 
			v:SetFrameLevel(self.bar:GetFrameLevel() + 1)
		end
		
		-- TODO: real start position
		self.bar:SetPoint("CENTER")
		
		self.bar:ApplyConfig(self.db.profile)
	end
	self.bar.disabled = nil
	self:SetupOptions()
end

function MicroMenuMod:OnDisable()
	if not self.bar then return end
	self.bar.disabled = true
	self.bar:UnregisterAllEvents()
	self.bar:Hide()
	self:SetupOptions()
end

function MicroMenuMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function MicroMenuMod:SetupOptions()
	if not self.options then
		self.options = Bar:GetOptionObject()
		local enabled = {
			type = "toggle",
			order = 1,
			name = "Enabled",
			desc = "Enable the Micro Menu",
			get = function() return self.db.profile.enabled end,
			set = "ToggleModule",
			handler = self,
		}
		self.options:AddElement("general", "enabled", enabled)
		
		self.disabledoptions = {
			general = {
				type = "group",
				name = "General Settings",
				cmdInline = true,
				order = 1,
				args = {
					enabled = enabled,
				}
			}
		}
		ActionBars.options.args["MicroMenu"] = {
				order = 30,
				type = "group",
				name = "Micro Menu",
				desc = "Configure the Micro Menu",
				childGroups = "tab",
			}
	end
	ActionBars.options.args["MicroMenu"].args = self:IsEnabled() and self.options.table or self.disabledoptions
end

function MicroMenuBar:ApplyConfig(config)
	Bar.ApplyConfig(self, config)
	self:PerformLayout()
end

function MicroMenuBar:PerformLayout()
	if self.config.vertical then
		-- TODO: vertical
	else
		self:SetSize(212, 45)
		self.buttons[1]:ClearAllPoints()
		self.buttons[1]:SetPoint("TOPLEFT", self, "TOPLEFT", 5, 18)
		for i = 2, #self.buttons do
			self.buttons[i]:ClearAllPoints()
			self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i-1], "TOPRIGHT", -4, 0)
		end
	end
end
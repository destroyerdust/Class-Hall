---------------------------------------------
-- Local Ace3 Declarations
---------------------------------------------
local name = "ClassHall"
ClassHall = LibStub("AceAddon-3.0"):NewAddon(name, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ClassHall")

local icon = LibStub("LibDBIcon-1.0", true)
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("ClassHall", {label = "ClassHall", type = "data source", icon = "Interface\\Icons\\Spell_Lightning_LightningBolt01", text = "n/a"})

---------------------------------------------
-- Options
---------------------------------------------
ClassHall.options = {
    name = "ClassHall",
    handler = ClassHall,
    type = 'group',
    args = {
        debug = {
            type = "toggle",
            name = L["Enable/Disable Debug"],
            desc = L["Enables or Disables Debug Printouts"],
            get  = function() return ClassHall.db.profile.debug end,
            set  = function(_, value) ClassHall.db.profile.debug = value end,
            order = 1,
        },
        icon = {
            type = "toggle",
            name = L["Show/Hide Icon"],
            desc = L["Shows or Hides minimap icon"],
            get = function() return ClassHall.db.profile.icon.hide end,
            set = function(_, value) ClassHall.db.profile.icon.hide = value end,
            order = 1,

        }
    },
}

---------------------------------------------
-- Message and enable option defaults
---------------------------------------------
ClassHall.defaults = {
    profile = {
        debug = false,
        icon  = {
            hide = true,
        }
    },
}

---------------------------------------------
-- Initilize 
---------------------------------------------
function ClassHall:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ClassHallDB", self.defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("ClassHall", self.options, {"ClassHall", "ClassHall"})
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ClassHall", "ClassHall")

    --icon:Register("ClassHall", dataobj, self.db.profile.icon)

    self:RegisterChatCommand("ch", "HideTheIcon")
    self:RegisterChatCommand("classhall", "ChatCommand")

    self:Debug("Initialized")
end

---------------------------------------------
-- Enable Event Registration
---------------------------------------------
function ClassHall:OnEnable()

    -- Minimap button.
    if icon and not icon:IsRegistered("ClassHall") then
        icon:Register("ClassHall", dataobj, self.db.profile.icon)
    end

    self.db.char.followers = C_Garrison.GetFollowers()
    self:Debug("OnEnable - Followers Loaded")

    self:DisableOrderHallBar()
    self:Debug("OnEnable - Disabled Class Hall Bar")


    self:Debug("OnEnable - Enabled")
end

---------------------------------------------
-- Unregister Events
---------------------------------------------
function ClassHall:DisableOrderHallBar()
    -- Hide Bar
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(self,...)
        if OrderHallCommandBar then
            OrderHallCommandBar:Hide()
            OrderHallCommandBar:UnregisterAllEvents()
            OrderHallCommandBar.Show = function() end
        end
        OrderHall_CheckCommandBar = function () end
    self:SetScript("OnUpdate", nil)
    end)

    self:Debug("DisableOrderHallBar - Disabled Class Hall Bar")
end

---------------------------------------------
-- Unregister Events
---------------------------------------------
function ClassHall:OnDisable()
    self:Debug("OnDisable - Unregistered Events")
end

---------------------------------------------
-- Debug Printout Function
---------------------------------------------
function ClassHall:Debug(string)
    if self.db.profile.debug then
        self:Print(string)
    end
end
---------------------------------------------
-- Slash Command Function
---------------------------------------------
function ClassHall:HideTheIcon(input)
    self.db.profile.icon.hide = not self.db.profile.icon.hide
    if self.db.profile.icon.hide then
        icon:Hide("ClassHall")
    else
        icon:Show("ClassHall")
    end
end


---------------------------------------------
-- Slash Command Function
---------------------------------------------
function ClassHall:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("ch", "ClassHall", input)
    end
end

function dataobj:OnEnter()
    ClassHall:Debug("dataobj:OnEnter - Mouse In")
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()

    -- Orderhall Resources
    local name, amount = GetCurrencyInfo(1220)
    --local name, amount, texturePath, earnedThisWeek, weeklyMax, totalMax, isDiscovered, quality = GetCurrencyInfo(1220)
    GameTooltip:AddLine("ClassHall Information", 0, 1, 0)

    GameTooltip:AddLine("Order Resources - " .. amount)

    ClassHall.db.char.followers = C_Garrison.GetFollowers()
    ClassHall:Debug("dataobj:OnEnter - Loaded Followers")

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Followers: ")

    for i, follower in ipairs(ClassHall.db.char.followers) do
      --ClassHall:Print(follower.name)
      if follower.isCollected then
        if follower.followerTypeID == 4 then
            if follower.isTroop then
                GameTooltip:AddLine(follower.name .. " - Durability: " .. follower.durability .. "/" .. follower.maxDurability)
            else
                GameTooltip:AddLine(follower.name)
            end
        end
      end
    end

    GameTooltip:Show()
end

function dataobj:OnLeave()
    GameTooltip:Hide()
    ClassHall:Debug("dataobj:OnLeave - Mouse Out")
end
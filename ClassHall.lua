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
    },
}

---------------------------------------------
-- Message and enable option defaults
---------------------------------------------
local defaults = {
    profile = {
    },
}

---------------------------------------------
-- Initilize 
---------------------------------------------
function ClassHall:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ClassHallDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("ClassHall", self.options, {"ClassHall", "ClassHall"})

    -- Hide Bar
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(self,...)
        if OrderHallCommandBar then
            OrderHallCommandBar:Hide()
            OrderHallCommandBar:UnregisterAllEvents()
            OrderHallCommandBar.Show = function() end
        end
    self:SetScript("OnUpdate", nil)
    end)

    self:Print("ClassHall Initialized")

    ClassHall.db.char.followers = C_Garrison.GetFollowers()
    self:Print("ClassHall Followers Loaded")
end

---------------------------------------------
-- Enable Event Registration
---------------------------------------------
function ClassHall:OnEnable()

    -- Minimap button.
    if icon and not icon:IsRegistered("ClassHall") then
        icon:Register("ClassHall", dataobj, self.db.profile.icon)
    end
	self:Print("ClassHall Enabled")
end

---------------------------------------------
-- Unregister Events
---------------------------------------------
function ClassHall:OnDisable()
end


function dataobj:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()

    -- Orderhall Resources
    local name, amount = GetCurrencyInfo(1220)
    --local name, amount, texturePath, earnedThisWeek, weeklyMax, totalMax, isDiscovered, quality = GetCurrencyInfo(1220)
    GameTooltip:AddLine("ClassHall Information", 0, 1, 0)

    GameTooltip:AddLine("Order Resources - " .. amount)

    -- Temp Fix for Initialization Fail
    if ClassHall.db.char.followers == nil then
        ClassHall.db.char.followers = C_Garrison.GetFollowers()
        ClassHall:Print("Had to load not in Initialization")
    end

    for i, follower in ipairs(ClassHall.db.char.followers) do
      --ClassHall:Print(follower.name)
      if follower.isCollected then   
        GameTooltip:AddLine("Follower - " .. follower.name)
      end
    end

    GameTooltip:Show()
end

function dataobj:OnLeave()
    GameTooltip:Hide()
end
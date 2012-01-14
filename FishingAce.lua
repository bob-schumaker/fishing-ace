--[[
Fishing Ace!
Copyright (c) by Bob Schumaker
Licensed under a Creative Commons "Attribution Non-Commercial Share Alike" License
]]--

local L = LibStub("AceLocale-3.0"):GetLocale("FishingAce", true)
local FL = LibStub("LibFishing-1.0")

local ADDONNAME = "Fishing Ace!"

local db;
local FISHINGTEXTURE = "Interface\\Icons\\Trade_Fishing"

local FISHINGLURES = {
   [34861] = {
      ["n"] = "Sharpened Fish Hook",       		  -- 100 for 10 minutes
      ["b"] = 100,
      ["s"] = 100,
      ["d"] = 10,
   },
   [6533] = {
      ["n"] = "Aquadynamic Fish Attractor",       -- 100 for 10 minutes
      ["b"] = 100,
      ["s"] = 100,
      ["d"] = 10,
   },
   [46006] = {
      ["n"] = "Glow Worm",       		 		  -- 100 for 60 minutes
      ["b"] = 100,
      ["s"] = 100,
      ["d"] = 60,
   },
   [33820] = {
      ["n"] = "Weather-Beaten Fishing Hat",       -- 75 for 10 minutes
      ["b"] = 75,
      ["s"] = 1,
      ["d"] = 10,
      ["w"] = 1,
   },
   [7307] = {
      ["n"] = "Flesh Eating Worm",                -- 75 for 10 mins
      ["b"] = 75,
      ["s"] = 100,
      ["d"] = 10,
   },
   [6532] = {
      ["n"] = "Bright Baubles",                   -- 75 for 10 mins
      ["b"] = 75,
      ["s"] = 100,
      ["d"] = 10,
   },
   [6811] = {
      ["n"] = "Aquadynamic Fish Lens",            -- 50 for 10 mins
      ["b"] = 50,
      ["s"] = 50,
      ["d"] = 10,
   },
   [6530] = {
      ["n"] = "Nightcrawlers",                    -- 50 for 10 mins
      ["b"] = 50,
      ["s"] = 50,
      ["d"] = 10,
   },
   [6529] = {
      ["n"] = "Shiny Bauble",                     -- 25 for 10 mins
      ["b"] = 25,
      ["s"] = 1,
      ["d"] = 10,
   },
}

local AddingLure = false

function FAOptions(uiType, uiName)
	local options = {
		type='group',
		icon = FISHINGTEXTURE,
		name = L["Fishing Ace!"],
		get = function(key) return db[key.arg] end,
		set = function(key, val) db[key.arg] = val end,
		args = {
			loot = {
				type = 'toggle',
				name = L["Auto Loot"],
				desc = L["AutoLootMsg"],
				arg = "loot",
			},
			lure = {
				type = 'toggle',
				name = L["Auto Lures"],
				desc = L["AutoLureMsg"],
				arg = "lure",
			},
			sound = {
				type = 'toggle',
				name = L["Enhance Sounds"],
				desc = L["EnhanceSoundsMsg"],
				arg = "sound",
			},
			action = {
				type = 'toggle',
				name = L["Use Action"],
				desc = L["UseActionMsg"],
				arg = "action",
			},
		}
	}
	if (uiType == "dialog") then
		options.args["desc"] = {
				type = "description",
				order = 0,
				name = L["Description"],
			}

		options.args.loot.order = 1
		options.args.loot.width = "full"
		
		options.args.lure.order = 2
		options.args.lure.width = "full"
		
		options.args.sound.order = 3
		options.args.sound.width = "full"
		
		options.args.action.order = 4
		options.args.action.width = "full"
	else
		for arg,info in pairs(options.args) do
			local onoff = db[info.arg] and "FF00FF00"..L["on"] or "FFFF0000"..L["off"]
			options.args[arg].desc = options.args[arg].desc.." [|c"..onoff.."|r]"
		end
	end

	-- Debugging
	-- options.db = db
	
	return options
end

FishingAce = LibStub("AceAddon-3.0"):NewAddon("FishingAce", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

local casting_timer = null
function FishingAce:PostCastUpdate(self)
	local stop = true
    ResetFAButton();
	if ( not InCombatLockdown() ) then
		if ( AddingLure ) then
			local sp, sub, txt, tex, st, et, trade, int = UnitChannelInfo("player");
			if ( not sp or (dn and dn ~= LastLure) ) then
				AddingLure = false
			else
				stop = false
			end
		end
		if ( stop and casting_timer ) then
			FishingAce:CancelTimer(casting_timer)
			casting_timer = null
		end
	end
end

local function HideAwayAll(self, button, down)
	if ( not casting_timer ) then
		casting_timer = FishingAce:ScheduleRepeatingTimer("PostCastUpdate", 1, self)
	end
end

function FishingAce:OnInitialize()
	local defaults = {
		profile = {
			loot = true,
			lure = false,
			sound = true,
			action = false,
		},
	}
    self.db = LibStub("AceDB-3.0"):New("FishingAceDB", defaults, "Default")
	db = self.db.profile

	if AddonLoader and AddonLoader.RemoveInterfaceOptions then
		AddonLoader:RemoveInterfaceOptions(ADDONNAME)
	end
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDONNAME, FAOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDONNAME, L["Fishing Ace!"])
	
	-- 	L["Slash-Commands"] = { "/fishingace", "/fa" }
	local config = LibStub("AceConfigCmd-3.0")
	config:CreateChatCommand("fishingace", ADDONNAME)
	config:CreateChatCommand("fa", ADDONNAME)

    FL:CreateSAButton()
    FL:WatchBobber(false)
end

local function HijackCheck()
	if ( not InCombatLockdown() and FL:IsFishingPole() ) then
		return true
	end
end

-- do everything we think is necessary when we start fishing
-- even if we didn't do the switch to a fishing pole
local efsv = nil
local function EnhanceFishingSounds(self, enhance)
	if ( self.db.profile.sound ) then
		if ( enhance ) then
            local mv = tonumber(GetCVar("Sound_MasterVolume"))
            local mu = tonumber(GetCVar("Sound_MusicVolume"))
            local av = tonumber(GetCVar("Sound_AmbienceVolume"))
            local sv = tonumber(GetCVar("Sound_SFXVolume"))
            local pd = tonumber(GetCVar("particleDensity"))
			if ( not efsv ) then
				-- collect the current value
				efsv = {}
                efsv["Sound_MasterVolume"] = mv
                efsv["Sound_MusicVolume"] = mu
                efsv["Sound_AmbienceVolume"] = av
                efsv["Sound_SFXVolume"] = sv
				efsv["particleDensity"] = pd;
				-- turn 'em off!
                SetCVar("Sound_MasterVolume", 1.0)
                SetCVar("Sound_SFXVolume", 1.0)
                SetCVar("Sound_MusicVolume", 0.0)
                SetCVar("Sound_AmbienceVolume", 0.0)
                SetCVar("particleDensity", 1.0)
			end
		else
			if ( efsv ) then
				for setting, value in pairs(efsv) do
					SetCVar(setting, value)
				end
				efsv = nil
			end
		end
	end
end

local function StartFishingMode(self)
	if ( not self.startedFishing ) then
		-- Disable Click-to-Move if we're fishing
		if ( GetCVarBool("autointeract") ) then
			self.resetClickToMove = true
			SetCVar("autointeract", "0")
		end
		if ( self.db.profile.loot ) then
			if ( not GetCVarBool("autoLootDefault") ) then
				self.resetAutoLoot = true
				SetCVar("autoLootDefault", 1)
			end
		end
		self.startedFishing = GetTime()
		EnhanceFishingSounds(self, true)
	end
end

local function StopFishingMode(self)
	if ( self.startedFishing ) then
		EnhanceFishingSounds(self, false)
		self.startedFishing = nil
	end
	if ( self.resetClickToMove ) then
		-- Re-enable Click-to-Move if we changed it
		SetCVar("autointeract", "1")
		self.resetClickToMove = nil
	end
	if ( self.resetAutoLoot ) then
		SetCVar("autoLootDefault", 0)
		self.resetAutoLoot = nil
	end
end

local function FishingMode(self)
	if ( FL:IsFishingPole() ) then
		StartFishingMode(self)
	else
		StopFishingMode(self)
	end
end

local LastLure
local function SetupLure()
	if ( not AddingLure ) then
		if ( FishingAce.db.profile.lure ) then
            local pole, tempenchant = FL:GetPoleBonus()
            local state, bestlure = FL:FindBestLure(tempenchant, 0)
			if ( state and bestlure ) then
			   FL:InvokeLuring(bestlure.id)
			   AddingLure = true
			   LastLure = bestlure.n
			   return true
			end
		end
	end
	return false
end

-- handle mouse up and mouse down in the WorldFrame so that we can steal
-- the hardware events to implement 'Easy Cast'
-- Thanks to the Cosmos team for figuring this one out -- I didn't realize
-- that the mouse handler in the WorldFrame got everything first!
local function WF_OnMouseDown(...)
	-- Only steal 'right clicks' (self is arg #1!)
	local button = select(2, ...)
	if ( button == "RightButton" and HijackCheck() ) then
		if ( FL:CheckForDoubleClick() ) then
			-- We're stealing the mouse-up event, make sure we exit MouseLook
			if ( IsMouselooking() ) then
				MouselookStop()
			end
			if ( not SetupLure() ) then
				FL:InvokeFishing(FishingAce.db.profile.action)
			end
			FL:OverrideClick(HideAwayAll)
		end
	end
end

function FishingAce:OnEnable()
	if not self:IsHooked(WorldFrame, "OnMouseDown") then
		self:HookScript(WorldFrame, "OnMouseDown", WF_OnMouseDown)
	end
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	if ( FishingBuddy and FishingBuddy.Message ) then
         FishingBuddy.Message(L["FishingAce is active, easy cast disabled."]);
	end
end

function FishingAce:OnDisable()
	self:UnregisterAllEvents()
	if self:IsHooked(WorldFrame, "OnMouseDown") then
		self:Unhook(WorldFrame, "OnMouseDown")
	end
	ResetFAButton()
	if ( FishingBuddy and FishingBuddy.Message ) then
         FishingBuddy.Message(L["FishingAce on standby, easy cast enabled."]);
	end
end

function FishingAce:SPELLS_CHANGED()
	-- Fishing might have moved, go look again
	FL:GetFishingSkillInfo(true)
end

function FishingAce:ITEM_LOCK_CHANGED()
	FishingMode(self)
end

function FishingAce:PLAYER_EQUIPMENT_CHANGED()
	FishingMode(self)
end

function FishingAce:PLAYER_REGEN_DISABLED()
   ResetFAButton()
end

function FishingAce:PLAYER_REGEN_ENABLED()
   ResetFAButton()
end

function FishingAce:PLAYER_ENTERING_WORLD()
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("SPELLS_CHANGED")
end

function FishingAce:PLAYER_LEAVING_WORLD()
	self:UnregisterEvent("ITEM_LOCK_CHANGED")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("SPELLS_CHANGED")
end

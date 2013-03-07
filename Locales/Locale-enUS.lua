local L = LibStub("AceLocale-3.0"):NewLocale("FishingAce", "enUS", true)

if L then
	L["on"] = "on"
	L["off"] = "off"

	L["Fishing Ace!"] = "Fishing Ace!"
	L["Description"] = "Fishing Ace! enables you to fish with a double-click whenever it detects you're using a fishing pole. Settings to enhance your fishing experience can be set below."

	L["Auto Loot"] = true
	L["AutoLootMsg"] = "If set, Fishing Ace! will turn Auto Loot on while you're fishing."

	L["Auto Lures"] = true
	L["AutoLureMsg"] = "If set, Fishing Ace! will add a lure when you need one, instead of casting."

	L["Enhance Sounds"] = true
	L["EnhanceSoundsMsg"] = "If set, Fishing Ace! will enhance the ambient sound while you're fishing."

	L["Volume"] = true
	L["VolumeMsg"] = "If set, Fishing Ace! will enhance the ambient sound while you're fishing."

	L["Use Action"] = true
	L["UseActionMsg"] = "If set, Fishing Ace! will find an action button to cast with."

	L["LureSkill"] = "Use: When applied to your fishing pole, increases Fishing by (%d) for %d minutes."

	L["Casting Key"] = "Casting Key"
	L["CastingKeyMsg"] = "Set to a modifier key to force a fishing cast, even when no pole equipped."

	L["Partial Gear"] = "Partial Gear"
	L["PartialGearMsg"] = "If set, cast if any piece of fishing gear is equipped."

	L["Watch Bobber"] = true
	L["WatchBobberMsg"] = "If set, do not cast if the cursor is over the fishing bobber."

	L["FishingAce is active, easy cast disabled."] = true
	L["FishingAce on standby, easy cast enabled."] = true
end

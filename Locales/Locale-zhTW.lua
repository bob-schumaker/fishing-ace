--$Id$

local L = LibStub("AceLocale-3.0"):NewLocale("FishingAce", "zhTW", false)

if L then
	L["on"] = "開"
	L["off"] = "關"

	L["Fishing Ace!"] = "Fishing Ace!"
	L["Description"] = "Fishing Ace! 讓您釣魚雙擊時檢測到您使用的是釣竿。設置以提高你的捕魚經驗可以設置如下。"

	L["Auto Loot"] = "自動拾取"
	L["AutoLootMsg"] = "如果設定，在釣魚時會將自動拾取物品的選項暫時打開，而不會出現拾取物品視窗。"

	L["Auto Lures"] = "自動加上誘餌"
	L["AutoLureMsg"] = "如果設定，在釣魚時會自動在需要時上釣餌。"

	L["Enhance Sounds"] = "加強音效"
	L["EnhanceSoundsMsg"] = "如果設定，在釣魚時會加強魚上鉤的音效。"

	L["Volume"] = "音效"
	L["VolumeMsg"] = "如果設定，當釣魚時 Fishing Ace! 會提高周圍環境的音效。"

	L["Use Action"] = "使用按鈕"
	L["UseActionMsg"] = "如果設定，會在動作條上使用釣魚按鈕。"

	L["LureSkill"] = "使用:裝備在魚竿上之後，可以使你的釣魚技能提高(%d)點，持續%d分鐘。"

	L["FishingAce is active, easy cast disabled."] = "FishingAce 已開啟，快速施法已禁用。"
	L["FishingAce on standby, easy cast enabled."] = "FishingAce 已掛起，快速施法已啟用。"
end

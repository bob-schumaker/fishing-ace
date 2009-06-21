--[[
Name: FishLib-1.0
Author(s): Sutorix <sutorix@hotmail.com>
Description: A library with common routines used by FishingBuddy and addons.
--]]

local MAJOR_VERSION = "LibFishing-1.0"
local MINOR_VERSION = 2

if not LibStub then error(MAJOR_VERSION .. " requires LibStub") end

local FishLib, oldLib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not FishLib then
	return
end

local WOW = {};
function FishLib:WOWVersion()
   return WOW.major, WOW.minor, WOW.dot;
end

if ( GetBuildInfo ) then
   local v, b, d = GetBuildInfo();
   WOW.build = b;
   WOW.date = d;
   local s,e,maj,min,dot = string.find(v, "(%d+).(%d+).(%d+)");
   WOW.major = tonumber(maj);
   WOW.minor = tonumber(min);
   WOW.dot = tonumber(dot);
else
   WOW.major = 1;
   WOW.minor = 9;
   WOW.dot = 0;
end

local bobber = {};
bobber["enUS"] = "Fishing Bobber";
bobber["zhTW"] = "釣魚浮標";
bobber["zhCN"] = "垂钓水花";
bobber["esES"] = "Anzuelo";
bobber["esMX"] = "Anzuelo";
bobber["deDE"] = "Blinker";

local locale = GetLocale();
if ( bobber[locale] ) then
   FishLib.BOBBER_NAME = bobber[locale];
else
   FishLib.BOBBER_NAME = bobber["enUS"];
end

local Crayon = LibStub("LibCrayon-3.0");

local function FixupThis(target, tag, what)
   if ( type(what) == "table" ) then
      for idx,str in pairs(what) do
         what[idx] = FixupThis(target, tag, str);
      end
      return what;
   elseif ( type(what) == "string" ) then
      local pattern = "#([A-Z0-9_]+)#";
      local s,e,w = string.find(what, pattern);
      while ( w ) do
         if ( type(target[w]) == "string" ) then
            local s1 = strsub(what, 1, s-1);
            local s2 = strsub(what, e+1);
            what = s1..target[w]..s2;
            s,e,w = string.find(what, pattern);
         elseif ( Crayon and Crayon["COLOR_HEX_"..w] ) then
            local s1 = strsub(what, 1, s-1);
            local s2 = strsub(what, e+1);
            what = s1.."ff"..Crayon["COLOR_HEX_"..w]..s2;
            s,e,w = string.find(what, pattern);
         else
            -- stop if we can't find something to replace it with
            w = nil;
         end
      end
      return what;
   else
      FishingBuddy.Debug("tag "..tag.." type "..type(what));
      FishingBuddy.Dump(what);
   end
end

function FishLib:FixupEntry(constants, tag)
   FixupThis(constants, tag, constants[tag]);
end

local function FixupStrings(source, target)
   local translation = source["enUS"];
   for tag,_ in pairs(translation) do
      target[tag] = FixupThis(target, tag, target[tag]);
   end
end

local function FixupBindings(source, target)
   local translation = source["enUS"];
   for tag,str in pairs(translation) do      
      if ( string.find(tag, "^BINDING") ) then
         setglobal(tag, target[tag]);
         target[tag] = nil;
      end
   end
end

local missing = {};
local function LoadTranslation(source, lang, target, record)
   local translation = source[lang];
   if ( translation ) then
      for tag,value in pairs(translation) do
         if ( not target[tag] ) then
            target[tag] = value;
            if ( record ) then
               missing[tag] = 1;
            end
         end
      end
   end
end

function FishLib:Translate(addon, source, target, record)
   local locale = GetLocale();
   --locale = "deDE";
   target.VERSION = GetAddOnMetadata(addon, "Version");
   LoadTranslation(source, locale, target);
   if ( locale ~= "enUS" ) then
      LoadTranslation(source, "enUS", target, record);
   end
   FixupStrings(source, target);
   FixupBindings(source, target);
end

local itempattern = "|c(%x+)|Hitem:(%d+)(:%d+):%d+:%d+:%d+:%d+:[-]?%d+:[-]?%d+:[-]?%d+|h%[(.*)%]|h|r";
function FishLib:SplitLink(link)
   if ( link ) then
      local _,_, color, id, item, name = string.find(link, itempattern);
      return color, id..item, name;
   end
end

function FishLib:SplitFishLink(link)
   if ( link ) then
      local _,_, color, id, item, name = string.find(link, itempattern);
      return color, tonumber(id), name;
   end
end

function FishLib:GetItemInfo(link)
   local maj,min,dot = FishLib:WOWVersion();
-- name, link, rarity, itemlevel, minlevel, itemtype
-- subtype, stackcount, equiploc, texture
   local nm,li,ra,il,ml,it,st,sc,el,tx;
   if ( maj > 1 ) then
      nm,li,ra,il,ml,it,st,sc,el,tx = GetItemInfo(link);
   else
      nm,li,ra,ml,it,st,sc,el,tx = GetItemInfo(link);
   end
   return nm,li,ra,ml,it,st,sc,el,tx,il;
end

function FishLib:IsLinkableItem(item)
   local link = "item:"..item;
   local n,l,_,_,_,_,_,_ = FishLib:GetItemInfo(link);
   return ( n and l );
end

function FishLib:ChatLink(item, name, color)
   if( item and name and ChatFrameEditBox:IsVisible() ) then
      if ( not color ) then
         color = Crayon.COLOR_HEX_WHITE;
      elseif ( Crayon["COLOR_HEX_"..color] ) then
         color = Crayon["COLOR_HEX_"..color];
      end
      if ( string.len(color) == 6) then
         color = "ff"..color;
      end
      local link = "|c"..color.."|Hitem:"..item.."|h["..name.."]|h|r";
      ChatFrameEditBox:Insert(link);
   end
end

local fp_itemtype = nil;
local fp_subtype = nil;
local mainhand = nil;

function FishLib:GetPoleType()
   if ( not fp_itemtype ) then
      _,_,_,_,fp_itemtype,fp_subtype,_,_,_,_ = FishLib:GetItemInfo(6256);
      if ( not fp_itemtype ) then
         -- make sure it's in our cache
         GameTooltip:SetHyperlink("item:6256");
         _,_,_,_,fp_itemtype,fp_subtype,_,_,_,_ = FishLib:GetItemInfo(6256);
      end
   end
   return fp_itemtype, fp_subtupe;
end

function FishLib:IsFishingPole()
   -- Get the main hand item texture
   if (not mainhand) then
      mainhand = GetInventorySlotInfo("MainHandSlot");
   end
   local itemLink = GetInventoryItemLink("player", mainhand);
   if ( itemLink ) then
      self:GetPoleType();
      if ( not fp_itemtype ) then
          -- If there is infact an item in the main hand, and it's texture
          -- that matches the fishing pole texture, then we have a fishing pole
          local itemTexture = GetInventoryItemTexture("player", mainhand);
          itemTexture = string.lower(itemTexture);
          if ( string.find(itemTexture, "inv_fishingpole") or
               string.find(itemTexture, "fishing_journeymanfisher") ) then
             local _, id, _ = FishLib:SplitFishLink(itemLink);
             -- Make sure it's not "Nat Pagle's Fish Terminator"
             if ( id ~= 19944) then
                _,_,_,_,fp_itemtype,fp_subtype,_,_,_,_ = FishLib:GetItemInfo(id);
                return true;
             end
          end
      else
         local _,_,_,_,itemtype,subtype,_,_,_,_ = FishLib:GetItemInfo(itemLink);
         return (itemtype == fp_itemtype) and (subtype == fp_subtype);
      end
   end
   return false;
end

function FishLib:IsWorn(itemid)
   for slot=1,19 do
      local link = GetInventoryItemLink("player", slot);
      if ( link ) then
         local _, id, _ = self:SplitFishLink(link);
         if ( itemid == id ) then
            return true;
         end
      end
   end
   -- return nil
end

-- fish tracking skill
function FishLib:GetTrackingID(tex)
   if ( not tex ) then
      tex = GetTrackingTexture();
   end
   for id=1,GetNumTrackingTypes() do
      local _, texture, _, _ = GetTrackingInfo(id);
      if ( texture == tex) then
         return id;
      end
   end
   -- return nil;
end

local FINDFISHTEXTURE = "Interface\\Icons\\INV_Misc_Fish_02";
function FishLib:GetFindFishID()
   if ( not self.FindFishID ) then
      self.FindFishID = self:GetTrackingID(FINDFISHTEXTURE);
   end
   return self.FindFishID;
end

-- in case the addon is smarter than us
function FishLib:SetBobberName(name)
   self.BOBBER_NAME = name;
end

function FishLib:GetBobberName()
   return self.BOBBER_NAME;
end

function FishLib:GetTooltipText()
   if ( GameTooltip:IsVisible() ) then
      local text = getglobal("GameTooltipTextLeft1");
      if ( text ) then
         return text:GetText();
      end
   end
   -- return nil;
end

function FishLib:OnFishingBobber()
   if ( GameTooltip:IsVisible() and not UIFrameIsFading(GameTooltip) ) then
      local text = self:GetTooltipText();
      if ( text ) then
         -- let a partial match work (for translations)
         return ( text and string.find(text, self.BOBBER_NAME ) );
      end
   end
   return false;
end

local ACTIONDOUBLEWAIT = 0.4;
local MINACTIONDOUBLECLICK = 0.05;

-- look for double clicks
function FishLib:CheckForDoubleClick()
   if ( self.lastClickTime ) then
      local pressTime = GetTime();
      local doubleTime = pressTime - self.lastClickTime;
      if ( doubleTime < ACTIONDOUBLEWAIT and doubleTime > MINACTIONDOUBLECLICK ) then
         if ( not self:OnFishingBobber() ) then
            self.lastClickTime = nil;
            return true;
         end
      end
   end
   self.lastClickTime = GetTime();
   if ( self:OnFishingBobber() ) then
      GameTooltip:Hide();
   end
   return false;
end

function FishLib:ExtendDoubleClick()
   if ( self.lastClickTime ) then
      self.lastClickTime = self.lastClickTime + ACTIONDOUBLEWAIT/2;
   end
end

-- support finding the fishing skill
function FishLib:FindSpellID(thisone)
   local id = 1;
   local spellTexture = GetSpellTexture(id, BOOKTYPE_SPELL);
   while (spellTexture) do
      if (spellTexture and spellTexture == thisone) then
                return id;
      end
      id = id + 1;
      spellTexture = GetSpellTexture(id, BOOKTYPE_SPELL);
   end
   return nil;
end

local FISHINGTEXTURE = "Interface\\Icons\\Trade_Fishing";
function FishLib:GetFishingSkillInfo(force)
   if ( force or not self.SpellID or not self.SkillName) then
      self.SpellID = self:FindSpellID(FISHINGTEXTURE);
      self.SkillName = nil;
   end
   if ( self.SpellID and not SkillName ) then
      self.SkillName = GetSpellName(self.SpellID, BOOKTYPE_SPELL);
   end
   return self.SpellID, self.SkillName;
end

-- get our current fishing skill level
local lastSkillIndex = nil;
function FishLib:GetCurrentSkill()
   local _,fsn = FishLib:GetFishingSkillInfo();
   if ( self.lastSkillIndex ) then
      local name, _, _, rank, _, modifier, skillmax = GetSkillLineInfo(self.lastSkillIndex);
      if ( name == fsn )then
         return rank, modifier, skillmax;
      end
   end
   local n = GetNumSkillLines();
   for i=1,n do
      local name, _, _, rank, _, modifier, skillmax = GetSkillLineInfo(i);
      if ( name == fsn ) then
         self.lastSkillIndex = i;
         return rank, modifier, skillmax;
      end
   end
   return 0, 0, 0;
end

function FishLib:GetFishingActionBarID(force)
   if ( force or not self.ActionBarID ) then
      for slot=1,72 do
         if ( HasAction(slot) and not IsAttackAction(slot) ) then
            local t,_,_ = GetActionInfo(slot);
            if ( t == "spell" ) then
               local tex = GetActionTexture(slot);
               if ( tex and tex == FISHINGTEXTURE ) then
                  self.ActionBarID = slot;
                  break;
               end
            end
         end
      end
   end
   return self.ActionBarId;
end

-- handle classes of fish
local MissedFishItems = {};
MissedFishItems[45190] = "Driftwood";
MissedFishItems[45200] = "Sickly Fish";
MissedFishItems[45194] = "Tangled Fishing Line";
MissedFishItems[45196] = "Tattered Cloth";
MissedFishItems[45198] = "Weeds";
MissedFishItems[45195] = "Empty Rum Bottle";
MissedFishItems[45199] = "Old Boot";
MissedFishItems[45201] = "Rock";
MissedFishItems[45197] = "Tree Branch";
MissedFishItems[45202] = "Water Snail"; 

function FishLib:IsMissedFish(id)
   if ( MissedFishItems[id] ) then
      return true;
   end
   -- return nil;
end

-- utility functions
local function SplitColor(color)
   if ( color ) then
      if ( type(color) == "table" ) then
         for i,c in pairs(color) do
            color[i] = SplitColor(c);
         end
      elseif ( type(color) == "string" ) then
         local a = tonumber(string.sub(color,1,2),16);
         local r = tonumber(string.sub(color,3,4),16);
         local g = tonumber(string.sub(color,5,6),16);
         local b = tonumber(string.sub(color,7,8),16);
         color = { a = a, r = r, g = g, b = b };
      end
   end
   return color;
end

local function AddTooltipLine(l)
   if ( type(l) == "table" ) then
      -- either { t, c } or {{t1, c1}, {t2, c2}}
      if ( type(l[1]) == "table" ) then
         local c1 = SplitColor(l[1][2]) or {};
         local c2 = SplitColor(l[2][2]) or {};
         GameTooltip:AddDoubleLine(l[1][1], l[2][1],
                                   c1.r, c1.g, c1.b,
                                   c2.r, c2.g, c2.b);
      else
         local c = SplitColor(l[2]) or {};
         GameTooltip:AddLine(l[1], c.r, c.g, c.b, 1);
      end
   else
      GameTooltip:AddLine(l,nil,nil,nil,1);
   end
end

function FishLib:AddTooltip(text)
   local c = color or {{}, {}};
   if ( text ) then
      if ( type(text) == "table" ) then
         for _,l in pairs(text) do
            AddTooltipLine(l);
         end
      else
         -- AddTooltipLine(text, color);
         GameTooltip:AddLine(text,nil,nil,nil,1);
      end
   end
end

function FishLib:FindChatWindow(name)
   local frame;
   for i = 1, NUM_CHAT_WINDOWS do
      local tab = getglobal("ChatFrame" .. i .. "Tab");
      if (tab:GetText() == name) then
         return getglobal("ChatFrame" .. i), frametab;
      end
   end
   -- return nil, nil;
end

function FishLib:GetChatWindow(name)
   local frame, frametab = self:FindChatWindow(name);
   if ( frame ) then
      if( not frametab:IsVisible() ) then 
         frametab:Show(); 
      end
      return frame, frametab;
   else
      -- this doesn't return anything, so we have to assume we
      -- can call again to find it
      FCF_OpenNewWindow(name);
      frame, frametab = self:FindChatWindow(name);
      if ( frame ) then
         FCF_SetLocked(frame, true, false);
         ChatFrame_RemoveAllMessageGroups(frame);
         return frame, frametab;
      end
   end
   -- if we didn't find our frame, something bad has happened, so
   -- let's just use the default chat frame
   return DEFAULT_CHAT_FRAME, nil;
end


local ARB_channel, ARB_focus
local ARB_mobs = {}
local ARB_guids = {}

---------------------
-- utility functions
---------------------
function RGBPercToHex(r, g, b)
   r = r <= 1 and r >= 0 and r or 0
   g = g <= 1 and g >= 0 and g or 0
   b = b <= 1 and b >= 0 and b or 0
   return string.format("%02x%02x%02x", math.ceil(r*255), math.ceil(g*255), math.ceil(b*255))
end

function ARB_classColor() 
   local class, classFileName = UnitClass("player")
   local color = RAID_CLASS_COLORS[classFileName]
   return RGBPercToHex(color.r,color.g,color.b)
end

function ARB_show(text, sendIt)
   local c = ARB_classColor()

   -- get highest allowed channel to send messages
   if (UnitIsRaidOfficer('player') or UnitIsGroupLeader('player')) then
      ARB_channel = 'RAID_WARNING'
   elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
      ARB_channel = 'INSTANCE_CHAT'
   elseif GetNumGroupMembers()>5 then
      ARB_channel = 'RAID'
   elseif GetNumGroupMembers()>0 then
      ARB_channel = 'PARTY'
   else
      ARB_channel = 'SAY'
   end

   -- determine if we are self messaging
   if sendIt == 1 then
      if (ARB_channel == 'WHISPER' and ARB_focus ~= false) then
         SendChatMessage(text,channel,nil,ARB_focus)
      else
         SendChatMessage(text,channel)
      end
   else
      print("|cff" ..c.. " [ARB] : " ..text.. "|r")
   end
end

function ARB_getCount(array)
   local count = 0
   for _ in pairs(array) do count = count + 1 end
   return count
end

function ARB_moveIt(frame)
   frame:EnableMouse(true)
   frame:SetMovable(true)
   frame:RegisterForDrag("LeftButton")
   frame:SetScript("OnDragStart", frame.StartMoving)
   frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

function ARB_BtnCoordsX(btnNumber,btnSpacing,btnWidth)
   return (btnNumber * btnSpacing) + (btnWidth * (btnNumber - 1))
end

function ARB_BtnCoordsY(btnRow,btnSpacing,btnHeight)
   return (btnRow * btnSpacing) + (btnHeight * (btnRow - 1))
end

function ARB_getFocus()
   if UnitExists("focus") then
      ARB_focus = GetUnitName("focus",true)
   else
      ARB_focus = false
   end
end

function ARB_setBtnTex(frame)
   frame:SetNormalTexture("Interface\\Addons\\ARB\\Media\\Themes\\SyncUI\\ButtonNormal")
   frame:SetPushedTexture("Interface\\Addons\\ARB\\Media\\Themes\\SyncUI\\ButtonPushed")
end

function ARB_setBtnFont(frame)
   local ARB_font = ARB_f:CreateFontString()
   ARB_font:SetFont("Interface\\Addons\\ARB\\Media\\Fonts\\Roboto.ttf",10)
   frame:SetFontString(ARB_font)
end

---------------------
-- frame functions
---------------------
function ARB_makeFrame()
   local ARB_maxButtonsPerRow = 4
   local ARB_buttonSpacing = 10
   local ARB_buttonWidth = 60
   local ARB_buttonHeight = 30
   local ARB_buttons = {
      "Taunt",
      "Stack",
      "Spread",
      "Adds",
      "Chains",
      "Tanks",
      "Priority"
   }
   local ARB_numButtons = ARB_getCount(ARB_buttons)
   local ARB_numRows = ((ARB_numButtons < ARB_maxButtonsPerRow) and 1 or math.ceil(ARB_numButtons/ARB_maxButtonsPerRow))
   local ARB_frameWidth = (ARB_maxButtonsPerRow * ARB_buttonWidth) + ((ARB_maxButtonsPerRow + 1) * ARB_buttonSpacing)
   local ARB_frameHeight = (ARB_numRows * ARB_buttonHeight) + ((ARB_numRows + 1) * ARB_buttonSpacing)

   local ARB_f = CreateFrame("FRAME","ARB_f",UIParent)
   ARB_f:SetSize(ARB_frameWidth,ARB_frameHeight)
   ARB_f:SetPoint("CENTER",0,0)
   ARB_f:SetBackdrop({bgFile = [[Interface\AddOns\ARB\Media\Themes\SyncUI\Background]], edgeFile = [[Interface\AddOns\ARB\Media\Themes\SyncUI\Edge]], edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
   ARB_f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
   ARB_f:SetScript("OnEvent", function(self,event,...)
      local count = 1
      local mob = select(9,...)
      local mobGUID = select(8,...)
    
      if event == "COMBAT_LOG_EVENT_UNFILTERED" then
         if select(2,...) ~= "UNIT_DIED" then
            if mob == "Darkwraith" then
               table.insert(ARB_mobs,count,mob)
               table.insert(ARB_guids,count,mobGUID)
            end
         else
            for i = 1, #ARB_mobs do
               if select(9,...) == ARB_mobs[i] then
                  table.remove(ARB_mobs, i)
                  table.remove(ARB_guids, i)
               end
            end
         end
         count = count + 1
      end
   end)

   -- allow frame to be moved
   ARB_moveIt(ARB_f)

   -- create buttons
   -- btn : Taunt
   local ARB_taunt = CreateFrame("BUTTON","ARB_taunt",ARB_f,"UIPanelButtonTemplate")
   ARB_taunt:SetSize(ARB_buttonWidth,ARB_buttonHeight)
   ARB_taunt:SetPoint("TOPLEFT",ARB_BtnCoordsX(1,ARB_buttonSpacing,ARB_buttonWidth),-ARB_BtnCoordsX(1,ARB_buttonSpacing,ARB_buttonHeight))
   ARB_setBtnTex(ARB_taunt)
   ARB_setBtnFont(ARB_taunt)
   ARB_taunt:SetText("Taunt")
   ARB_taunt:RegisterForClicks("AnyDown")
   ARB_taunt:SetScript("OnClick", function()
      ARB_getFocus()
      if ARB_focus ~= false then
         ARB_show("{rt3} %f, Taunt! {rt3}",1)
      end         
      ARB_show("{rt3} Taunt! {rt3}",1)
   end)
   ARB_taunt:SetAlpha(1) 

   -- btn : Stack
   local ARB_stack = CreateFrame("BUTTON","ARB_stack",ARB_f,"UIPanelButtonTemplate")
   ARB_stack:SetSize(ARB_buttonWidth,ARB_buttonHeight)
   ARB_stack:SetPoint("TOPLEFT",ARB_BtnCoordsX(2,ARB_buttonSpacing,ARB_buttonWidth),-ARB_BtnCoordsX(1,ARB_buttonSpacing,ARB_buttonHeight))
   ARB_setBtnTex(ARB_stack)
   ARB_setBtnFont(ARB_stack)
   ARB_stack:SetText("Stack")
   ARB_stack:RegisterForClicks("AnyDown")
   ARB_stack:SetScript("OnClick", function()
      ARB_show("{rt1} Stack on tanks! {rt1}",1)
   end)
   ARB_stack:SetAlpha(1)

   -- btn : Spread
   local ARB_spread = CreateFrame("BUTTON","ARB_spread",ARB_f,"UIPanelButtonTemplate")
   ARB_spread:SetSize(ARB_buttonWidth,ARB_buttonHeight)
   ARB_spread:SetPoint("TOPLEFT",ARB_BtnCoordsX(3,ARB_buttonSpacing,ARB_buttonWidth),-ARB_BtnCoordsX(1,ARB_buttonSpacing,ARB_buttonHeight))
   ARB_setBtnTex(ARB_spread)
   ARB_setBtnFont(ARB_spread)
   ARB_spread:SetText("Spread")
   ARB_spread:RegisterForClicks("AnyDown")
   ARB_spread:SetScript("OnClick", function()
      ARB_show("{rt8} Ranged, spread out! {rt8}",1)
   end)
   ARB_spread:SetAlpha(1)

   -- btn : Adds
   local ARB_adds = CreateFrame("BUTTON","ARB_adds",ARB_f,"UIPanelButtonTemplate")
   ARB_adds:SetSize(ARB_buttonWidth,ARB_buttonHeight)
   ARB_adds:SetPoint("TOPLEFT",ARB_BtnCoordsX(4,ARB_buttonSpacing,ARB_buttonWidth),-ARB_BtnCoordsX(1,ARB_buttonSpacing,ARB_buttonHeight))
   ARB_setBtnTex(ARB_adds)
   ARB_setBtnFont(ARB_adds)
   ARB_adds:SetText("Adds")
   ARB_adds:RegisterForClicks("AnyDown")
   ARB_adds:SetScript("OnClick", function()
      ARB_show(gsub("{rt7} Use {spell:34477} / {spell:57934} or run the adds to the tanks! {rt7}","{spell:(%d+)}",GetSpellLink),1)
   end)
   ARB_adds:SetAlpha(1)

   -- btn : Chains
   local ARB_chains = CreateFrame("BUTTON","ARB_chains",ARB_f,"UIPanelButtonTemplate")
   ARB_chains:SetSize(ARB_buttonWidth,ARB_buttonHeight)
   ARB_chains:SetPoint("TOPLEFT",ARB_BtnCoordsX(1,ARB_buttonSpacing,ARB_buttonWidth),-ARB_BtnCoordsX(2,ARB_buttonSpacing,ARB_buttonHeight))
   ARB_setBtnTex(ARB_chains)
   ARB_setBtnFont(ARB_chains)
   ARB_chains:SetText("Chains")
   ARB_chains:RegisterForClicks("AnyDown")
   ARB_chains:SetScript("OnClick", function() 
      ARB_show("{rt4} Break your chains! {rt4}",1)
   end)
   ARB_chains:SetAlpha(1)

   -- btn : Tanks [LEFTBUTTONDOWN-mark self and focus(if exists), RIGHTBUTTONDOWN-remove raid target icons from self and focus(if exists)]
   local ARB_tanks = CreateFrame("BUTTON","ARB_tanks",ARB_f,"UIPanelButtonTemplate")
   ARB_tanks:SetSize(ARB_buttonWidth,ARB_buttonHeight)
   ARB_tanks:SetPoint("TOPLEFT",ARB_BtnCoordsX(2,ARB_buttonSpacing,ARB_buttonWidth),-ARB_BtnCoordsX(2,ARB_buttonSpacing,ARB_buttonHeight))
   ARB_setBtnTex(ARB_tanks)
   ARB_setBtnFont(ARB_tanks)
   ARB_tanks:SetText("Tanks")
   ARB_tanks:RegisterForClicks("AnyDown")
   ARB_tanks:SetScript("OnMouseDown", function(self,button)
      ARB_getFocus()
      if button == "LeftButton" then 
         if GetRaidTargetIndex("player") == nil then
            SetRaidTarget("player",2) 
            ARB_show(GetUnitName("player").." marked")
         end
         if ARB_focus ~= false then
            if GetRaidTargetIndex("focus") == nil then
               SetRaidTarget("focus",5)
               ARB_show(ARB_focus.." marked")
            end
         end
      end

      if button == "RightButton" then
         SetRaidTarget("player",0)
         if ARB_focus ~= false then
            SetRaidTarget("focus",0) 
         end
         ARB_show("Lucky Charms removed.")
      end
   end)
   ARB_tanks:SetAlpha(1)

   -- btn : Priority
   local ARB_priority = CreateFrame("BUTTON","ARB_priority",ARB_f,"UIPanelButtonTemplate")
   ARB_priority:SetSize(ARB_buttonWidth,ARB_buttonHeight)
   ARB_priority:SetPoint("TOPLEFT",ARB_BtnCoordsX(3,ARB_buttonSpacing,ARB_buttonWidth),-ARB_BtnCoordsX(2,ARB_buttonSpacing,ARB_buttonHeight))
   ARB_setBtnTex(ARB_priority)
   ARB_setBtnFont(ARB_priority)
   ARB_priority:SetText("Priority")
   ARB_priority:RegisterForClicks("AnyDown")
   ARB_priority:SetScript("OnClick", function()
      ARB_show("Button Disabled!")
      ARB_show("This button is still being worked on.")
      for _,v in pairs(mobs) do
         if v == "Darkwraith" then
            SetRaidTarget("Darkwraith",8)
         end
      end
   end)
   ARB_priority:SetAlpha(1)

   ARB_f:Hide()
end

--=================================
-- slash commands
--=================================
SlashCmdList['MYADDON_SLASHCMD'] = function(m)
   if m == 'show' then 
      ARB_f:Show()
   elseif m == 'hide' then 
      ARB_f:Hide()
   else
      ARB_show("Error: Unknown Command")
   end
end
SLASH_MYADDON_SLASHCMD1 = '/arb'

--=================================
-- load the frame
--=================================
if (not ARB_f) then
   ARB_makeFrame()
   local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo("ARB")
   local version = GetAddOnMetadata("ARB", "version")
   ARB_show(title.." ("..name..") "..version)
end
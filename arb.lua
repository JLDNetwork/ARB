--=================================
-- slash commands
--=================================
SlashCmdList['MYADDON_SLASHCMD'] = function(m)
  if m == 'show' then 
      ARBButtonFrame:Show() 
   end

   if m == 'hide' then 
      ARBButtonFrame:Hide()
   end
end
SLASH_MYADDON_SLASHCMD1 = '/arb'

--=================================
-- local variables
--=================================
local f, msg

--=================================
-- general fucntions 
--=================================
function RaidChannel()
   if (UnitIsRaidOfficer('player') or UnitIsGroupLeader('player')) then
      return 'RAID_WARNING'
   elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
      return 'INSTANCE_CHAT'
   elseif GetNumGroupMembers()>5 then
      return 'RAID'
   elseif GetNumGroupMembers()>0 then
      return 'PARTY'
   else
      return 'SAY'
   end
end

function SayIt(message,channel)
   if channel == 'WHISPER' then
      SendChatMessage(msg,channel,nil,f)
   else
      SendChatMessage(msg,channel)
   end
end

function hasFocus()
   if UnitExists("focus") then
      return true
   else 
      return false
   end
end

function doTaunt()
   local channel1, channel2
   
   if hasFocus() then
      msg = '{rt3} %f, Taunt! {rt3}'
      f = UnitName("focus")
      SayIt(msg,'WHISPER')
      --print(msg..' : WHISPER')
   else
      msg = "{rt3} Taunt! {rt3}"
   end
   
   SayIt(msg, RaidChannel())
   --print(msg..' : '..RaidChannel())
   return true
end

function doStack()
   msg = '{rt1} Stack on tanks! {rt1}'
   
   SayIt(msg, RaidChannel())
   --print(msg..' : '..RaidChannel())
   return true
end

function doSpread()
   msg = '{rt8} Ranged, spread out! {rt8}'
   
   SayIt(msg, RaidChannel())
   --print(msg..' : '..RaidChannel())
   return true
end

function doAdds()
   msg = gsub("{rt7} Use {spell:34477} / {spell:57934} or run the adds to the tanks! {rt7}","{spell:(%d+)}",GetSpellLink)
   
   SayIt(msg, RaidChannel())
   --print(msg..' : '..RaidChannel())
   return true
end

-- v1.5 update
function doMarkTanks()
   SetRaidTarget("player",2)
   if hasFocus() then SetRaidTarget("focus",5) end
   return true
end
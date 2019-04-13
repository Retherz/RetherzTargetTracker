function RTT_OnEvent()
  RTT_Clear();
  if(event == "CHAT_MSG_ADDON") then
    RTT_HandleMessageData(arg1, arg2, arg4);
  elseif(event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
    if(strfind(arg1, "dies.") and RTT_TargetsExist()) then
      local dead = string.gsub(arg1, " dies.", "");
      local t = RTT_GetExistingTargets();
        for k, v in pairs(t) do
          if(RTT_Symbols[v].target == dead) then
            RTT_KillBar(v);
          end
        end
    end
  elseif(event == "PLAYER_TARGET_CHANGED") then
    if(UnitExists("target") and not UnitIsDead("target")) then
      local i = GetRaidTargetIndex("target");
      if(i ~= nil and RTT_Symbols[i].target ~= UnitName("target") and not UnitIsFriend("target", "player")) then
        if((IsPartyLeader() or IsRaidLeader() or IsRaidOfficer())) then
          RTT_SendSetTarget("target", i);
        else
          local c = UnitName("target");
          RTT_ActivateBar(i, c);
        end
      end
    end
  else
    if(event == "CHAT_MSG_SPELL_SELF_DAMAGE" and strfind(arg1, RTT_CastSpellData.name)) then
      DEFAULT_CHAT_FRAME:AddMessage(arg1);
        RTT_CastSpellData.sent = true;
      return;
    end
  end
end

function RTT_OnLoad()
  if(RTT_PREFIX_TARGET ~= nil) then
    local _, englishClass = UnitClass("player");
    RTT_CommunicationInitialize();
    RTT_SetSpellID();
    RTT_SpellData_SetSpellTable(englishClass);
    RTT_CreateGUI();
    RTT_AddOnFrame:SetScript("OnUpdate", nil);
  end
end

local frame = CreateFrame("Frame", "RTT_AddOnFrame");
frame:SetScript("OnEvent", RTT_OnEvent);
frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
frame:RegisterEvent("PLAYER_TARGET_CHANGED");
frame:SetScript("OnUpdate", RTT_OnLoad);

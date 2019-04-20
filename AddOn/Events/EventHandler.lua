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
    RTT_TestTarget();
  else
    if(event == "CHAT_MSG_SPELL_SELF_DAMAGE" and strfind(arg1, RTT_CastSpellData.name)) then
        RTT_CastSpellData.sent = true;
      return;
    end
  end
end

function RTT_OnLoad()
  if(RTT_PREFIX_TARGET ~= nil) then
    RTT_HandleConfig();
    local _, englishClass = UnitClass("player");
    RTT_CommunicationInitialize();
    RTT_SetSpellID();
    RTT_SpellData_SetSpellTable(englishClass);
    RTT_CreateGUI();
    RTT_AddOnFrame:SetScript("OnUpdate", nil);
    RTT_CreateConfigGUI();
    if(RetherzTargetTracker.X == 0 and RetherzTargetTracker.Y == 0) then
      message("''/rtt' to configure Retherz Target Tracker.")
    end
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

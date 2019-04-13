local hasCleared = false;
RTT_Symbols = {
  [1] = {
    state = false;
    name = "Star";
    target = "TARGET_NAME";
    health = 100;
  },
  [2] = {
    state = false;
    name = "Circle";
    target = "TARGET_NAME";
    health = 100;
  },
  [3] = {
    state = false;
    name = "Diamond";
    target = "TARGET_NAME";
    health = 100;
  },
  [4] = {
    state = false;
    name = "Triangle";
    target = "TARGET_NAME";
    health = 100;
  },
  [5] = {
    state = false;
    name = "Moon";
    target = "TARGET_NAME";
    health = 100;
  },
  [6] = {
    state = false;
    name = "Square";
    target = "TARGET_NAME";
    health = 100;
  },
  [7] = {
    state = false;
    name = "Cross";
    target = "TARGET_NAME";
    health = 100;
  },
  [8] = {
    state = false;
    name = "Skull";
    target = "TARGET_NAME";
    health = 100;
  },
}

function RTT_TexCoord(i)
  i = i / 4;
  if(i > 1) then
    return i - 1.25, i - 1, 0.25, 0.5;
  else
    return i - 0.25, i, 0, 0.25;
  end
end

function RTT_TargetsExist()
  for i=1, 8 do
    if(RTT_Symbols[i].state) then
      return true;
    end
  end
  return false;
end

local AssignIndex = 8;

local function CanSetTargetUnit(unit)
  return (UnitExists(unit) and (UnitIsPartyLeader("player") or UnitIsGroupAssistant("player")));
end

function RTT_Target(symbol)
  for i = 0, GetNumRaidMembers() do
    if(RTT_GetTarget("raid" .. i .. "target", symbol)) then
      return true;
    end
    for i = 0, GetNumPartyMembers() do
      if(RTT_GetTarget("party" .. i .. "target", symbol)) then
        return true;
      end
    end
  end
  return false;
end

function RTT_GetExistingTargets()
  local t = {}
  for i = 0, GetNumRaidMembers() do
    local ts = tonumber(GetRaidTargetIndex("raid" .. i .. "target"));
    if(ts ~= nil and t[ts] == nil) then
      table.insert(t, ts);
    end
    for i = 0, GetNumPartyMembers() do
      local ts = tonumber(GetRaidTargetIndex("party" .. i .. "target"));
      if(ts ~= nil and t[ts] == nil) then
        table.insert(t, ts);
      end
    end
  end
  return t;
end

function RTT_GetTarget(target, symbol)
  if(UnitExists(target) and GetRaidTargetIndex(target) == symbol) then
    TargetUnit(target);
    --use action configured id (slot) i.e auto attack.
    return true;
  end
  return false;
end

function RTT_AssignFree()
  if(CanSetTargetUnit("target")) then
    for i=8, 1, -1 do
      if(RTT_Symbols[i].state ~= true) then
        RTT_Remove("target");
        SetRaidTarget("target", i);
        RTT_SendSetTarget("target", i);
        RTT_Symbols[i].state = true;
        return true;
      end
    end
  end
  return false;
end

function RTT_AssignFreeMO()
  if(CanSetTargetUnit("mouseover")) then
    for i=8, 1, -1 do
      if(RTT_Symbols[i] ~= true) then
        RTT_Remove("mouseover");
        SetRaidTarget("mouseover", i);
        RTT_SendSetTarget("mouseover", i);
        RTT_Symbols[i].state = true;
        return true;
      end
    end
  end
  return false;
end

function RTT_AssignNext()
  if(CanSetTargetUnit("target")) then
    RTT_Remove("target");
    RTT_Symbols[AssignIndex].state = true;
    SetRaidTarget("target", AssignIndex);
    RTT_SendSetTarget("target", AssignIndex);
    if(AssignIndex == 1) then
      AssignIndex = 8;
    else
      AssignIndex = AssignIndex - 1;
    end
    return true;
  else
    return false;
  end
end

function RTT_AssignNextMO()
  if(CanSetTargetUnit("mouseover")) then
    RTT_Remove("mouseover");
    RTT_Symbols[AssignIndex].state = true;
    SetRaidTarget("mouseover", AssignIndex);
    RTT_SendSetTarget("mouseover", AssignIndex);
    if(AssignIndex == 1) then
      AssignIndex = 8;
    else
      AssignIndex = AssignIndex - 1;
    end
    return true;
  else
    return false;
  end
end

function RTT_ClearSymbols()
  if(not CanSetTargetUnit("player")) then
    return
  end

  for i =1, 8 do
    SetRaidTarget("player", i);
    RTT_Symbols[i].state = false;
  end
  AssignIndex = 8;
  RTT_SendTargetData("C");
  hasCleared = true;
end

function RTT_Clear()
  if(hasCleared) then
    hasCleared = false;
    SetRaidTarget("player", 0);
  end
end

function RTT_ClearTarget()
  if(not UnitExists("target")) then
    return false;
  end
  RTT_Remove("target");
end

function RTT_ClearMO()
  if(not UnitExists("mouseover")) then
    return false;
  end
  RTT_Remove("mouseover");
end

function RTT_Remove(unit)
  local i = GetRaidTargetIndex(unit);
  if(i ~= 0 and i ~= nil) then
    RTT_Symbols[i].state = false;
    SetRaidTarget(unit, 0);
    if(CanSetTargetUnit("player")) then
      RTT_SendTargetData("RM", i);
    end
    return true;
  end
  return false;
end

function RTT_RecieveRemove(i)
  RTT_Symbols[i].state = false;
end

function RTT_RecieveClear()
  for i=1, 8 do
    RTT_Symbols[i].state = false;
  end
end

function RTT_SetHealth(unit, health)
  RTT_Symbols[unit].health = health;
  getglobal("RTT_Bar" .. unit .. "HealthLabel"):SetText(health .. "%");
end

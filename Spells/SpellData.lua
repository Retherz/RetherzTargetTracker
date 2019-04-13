local data = {
  ["Sunder Armor"] = {
    duration = 30;
    class = "WARRIOR";
    icon = "Interface\\Icons\\Ability_Warrior_Sunder";
  },
  ["Faerie Fire"] = {
    duration = 40;
    class = "DRUID";
    icon = "";
  },
  ["Faerie Fire (Feral)"] = {
    duration = 40;
    class = "DRUID";
    icon = "";
  },
  ["Curse of Recklessness"] = {
    duration = 120;
    class = "WARLOCK";
    icon = "Interface\\Icons\\Spell_Shadow_UnholyStrength";
  },
  ["Curse of Shadow"] = {
    duration = 300;
    class = "WARLOCK";
    icon = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde";
  },
  ["Curse of the Elements"] = {
    duration = 300;
    class = "WARLOCK";
    icon = "Interface\\Icons\\Spell_Shadow_ChillTouch";
  },
  ["Curse of Tongues"] = {
    duration = 30;
    class = "WARLOCK";
    icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges";
  },
}

local classSpellTable = {};

function RTT_SpellData_GetDuration(name)
  return data[name].duration;
end

function RTT_SpellData_GetIcon(name)
  return data[name].icon;
end

function RTT_SpellData_SetSpellTable(class)
  for k, v in pairs(data) do
    if(data[k].class == class) then
      table.insert(classSpellTable, k)
    end
  end
end

function RTT_SpellData_GetSpellTable(class)
  local t = {}
  for k, v in pairs(data) do
    if(data[k].class == class) then
      table.insert(t, data[k])
    end
  end
  return t;
end

function RTT_SpellIsTrackable(string)
  for k, v in pairs(classSpellTable) do
    if(strfind(string, v)) then
      return true;
    end
  end
end

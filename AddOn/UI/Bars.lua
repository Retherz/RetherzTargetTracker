local BarHeight = 60;
local BarWidth = 240;
local Padding = 3;
local Scale = 1.0;
local Border = 3;
local OffsetX, OffsetY = 300, 0;

local nextUpdate = 0;


function RTT_CreateGUI()
  RTT_CreateGUIFrame();
  RTT_CreateBars();
end

function RTT_CreateGUIFrame()
  local f = CreateFrame("Frame", "RTT_Frame", UIParent);
  f:SetWidth((BarWidth + Border * 2) * Scale);
  f:SetHeight((BarHeight * 8 + Padding * 7 + Border * 2) * Scale);
  f:SetPoint("CENTER", UIParent, "CENTER", OffsetX, OffsetY);
	f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"});
	--f:SetBackdropColor(0,0,0,1);
end

function RTT_CreateBars()
  for i=1, 8 do
    local f = CreateFrame("Frame", "RTT_Bar" .. i, RTT_Frame);
    f:SetWidth((BarWidth) * Scale);
    f:SetHeight((BarHeight) * Scale);
    f:SetPoint("TOPLEFT", Border * Scale, -(Border + ((BarHeight + Padding) * (8 - i))) * Scale);
  	f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"});
  	f:SetBackdropColor(0,0,0,1);
    RTT_CreateBarSymbolTexture(f, i);
    RTT_CreateBarHealthLabel(f, i);
    RTT_CreateBarNameLabel(f, i);
    RTT_CreateBarDebuffTextures(f, i);
    f:SetAlpha(0.5);
  end
  RTT_Frame:SetScript("OnUpdate", function(self)
    if(GetTime() >= nextUpdate) then
      nextUpdate = GetTime() + 1;
    else
      return
    end
    RTT_UpdateHealth();
    for bar=1,8 do
      if(RTT_Symbols[bar].state) then
        for debuff=1,RTT_TrackedDebuffCount do
          RTT_Bar_DebuffUpdate(bar, debuff);
        end
      end
    end
  end)

  --DEBUG
  for z=1, RTT_TrackedDebuffCount do
    RTT_SetTrackedDebuff(z, RTT_TrackedDebuffs[z]);
  end

end

function RTT_CreateBarSymbolTexture(parent, i)
  local f = parent:CreateTexture("RTT_Bar" .. i .. "SymbolTexture", "ARTWORK");
	f:SetPoint("TOPLEFT", Padding, -Padding);
	f:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons");
  f:SetTexCoord(RTT_TexCoord(i));
	f:SetHeight((BarHeight - Padding * 2) * Scale);
	f:SetWidth((BarHeight - Padding * 2) * Scale);
end

function RTT_CreateBarHealthLabel(parent, i)
  local f = parent:CreateFontString("RTT_Bar" .. i .. "HealthLabel", "OVERLAY", "GameFontHighlightLarge");
	f:SetPoint("TOPLEFT", BarHeight  - Padding * 3, -Padding * 3);
	f:SetHeight((BarHeight - Padding * 2) * Scale);
	f:SetWidth((BarHeight - Padding * 2) * Scale);
	f:SetJustifyH("RIGHT");
end

function RTT_CreateBarNameLabel(parent, i)
  local f = parent:CreateFontString("RTT_Bar" .. i .. "NameLabel", "OVERLAY", "GameFontNormalSmall");
	f:SetPoint("TOPLEFT", BarHeight, -Padding);
	f:SetHeight((BarHeight - Padding * 2) / 3 * Scale);
	f:SetWidth((BarWidth - (BarHeight - Padding * 2)) * Scale);
	f:SetJustifyH("LEFT");
end

function RTT_CreateBarDebuffTextures(parent, i)
  for n=1, RTT_TrackedDebuffCount do
    local f = parent:CreateTexture("RTT_Bar" .. i .. "DebuffTexture" .. n, "ARTWORK");
  	f:SetPoint("TOPLEFT", BarHeight + Padding * 7 + n * (BarHeight / 2), -(BarHeight / 2 - Padding * 3));
    f:SetHeight((BarHeight / 2.2) * Scale);
    f:SetWidth((BarHeight / 2.2) * Scale);
    RTT_CreateBarDebuffLabel(parent, i, n, BarHeight + Padding * 7 + n * (BarHeight / 2), -(BarHeight / 2 - Padding * 3));
  end
end

function RTT_CreateBarDebuffLabel(parent, i, n, xOffset, yOffset)
  local f = parent:CreateFontString("RTT_Bar" .. i .. "DebuffTextureLabel" .. n, "OVERLAY", "GameFontNormalSmall");
	f:SetPoint("TOPLEFT", xOffset - ((BarHeight / 2.2) * Scale / 4), yOffset + Padding * 3 - (BarHeight / 2.2) * Scale);
  f:SetHeight((BarHeight / 2.2) * Scale);
  f:SetWidth((BarHeight / 2.2) * Scale);
	f:SetJustifyH("RIGHT");
end

function RTT_Bar_DebuffUpdate(bar, index)
  if(not RTT_BarData[bar].debuffs[index].active) then
    return
  end
  local timeLeft = RTT_Round(RTT_BarData[bar].debuffs[index].timestamp - GetTime());
  local label = getglobal("RTT_Bar" .. bar .. "DebuffTextureLabel" .. index);
  local texture = getglobal("RTT_Bar" .. bar .. "DebuffTexture" .. index);
  if(timeLeft > 0) then
    texture:SetAlpha(1);
    label:SetAlpha(1);
    label:SetText(timeLeft);
  else
    texture:SetAlpha(0.25);
    label:SetAlpha(0.25);
    label:SetText("");
    RTT_BarData[bar].debuffs[index].active = false;
  end
end

function RTT_Bar_SetDebuff(bar, name)
  for i=1, RTT_TrackedDebuffCount do
    if(name == RTT_BarData[bar].debuffs[i].name) then
      RTT_BarData[bar].debuffs[i].timestamp = GetTime()
        + RTT_SpellData_GetDuration(name) - 1;
        RTT_BarData[bar].debuffs[i].active = true;
    end
  end
end

function RTT_SetTrackedDebuffs()
  for i=1,RTT_TrackedDebuffCount do
  --RETRIEVE CONFIG DATA.
  RTT_TrackedDebuffs[i] = "";
  end
end

function RTT_SetTrackedDebuff(i, name)
  for d=1, 8 do
    RTT_BarData[d].debuffs[i].name = name;
    local t = getglobal("RTT_Bar" .. d .. "DebuffTexture" .. i);
    t:SetTexture(RTT_SpellData_GetIcon(name));
  end
end

function RTT_UpdateHealth()
  if(not UnitExists("target") or UnitIsFriend("target", "player")) then
    return
  end
  local i = GetRaidTargetIndex("target");
  if(i ~= nil and UnitHealth("target") ~= RTT_Symbols[i].health) then
    RTT_SetHealth(i, UnitHealth("target"));
    if((UnitExists("targettarget")
      and UnitName("targettarget") == UnitName("player"))
      or not UnitExists("targettarget") and (IsPartyLeader() or IsRaidLeader() or IsRaidOfficer())) then
        RTT_SendTargetData(i, UnitHealth("target"));
    end
  end
end

function RTT_KillBar(i)
  for c=1, RTT_TrackedDebuffCount do
    RTT_BarData[i].debuffs[c].timestamp = 0;
  end
  local f = getglobal("RTT_Bar" .. i);
  f:SetAlpha(0.5);
  local t = getglobal("RTT_Bar" .. i .. "NameLabel");
  t:SetText("");
  local t = getglobal("RTT_Bar" .. i .. "HealthLabel");
  t:SetText("");
  RTT_Symbols[i].target = "";
  RTT_Symbols[i].health = 0;
end

function RTT_ActivateBar(bar, name)
    getglobal("RTT_Bar" .. bar .. "NameLabel"):SetText(name);
    RTT_Symbols[bar].target = name;
    RTT_Symbols[bar].state = true;
    local f = getglobal("RTT_Bar" .. bar);
    f:SetAlpha(1);
    for i=1, 4 do
      local label = getglobal("RTT_Bar" .. bar .. "DebuffTextureLabel" .. i);
      local texture = getglobal("RTT_Bar" .. bar .. "DebuffTexture" .. i);
      texture:SetAlpha(0.25);
      label:SetAlpha(0.25);
      label:SetText("");
    end
end

-- 初始化木材系统
if Lumber == nil then Lumber = class( { }) end
function Lumber:Init()
    -- 监听单位击杀事件
    ListenToGameEvent("entity_killed", Dynamic_Wrap(Lumber, "AddLumber"), self)
end

function Lumber:AddLumber(keys)
    local entity_killed = EntIndexToHScript(keys.entindex_killed)
    local entity_attacker = EntIndexToHScript(keys.entindex_attacker)
    if not(entity_killed and entity_attacker) then return end
    local team_attacker = entity_attacker:GetTeam()
    if not(team_attacker == DOTA_TEAM_GOODGUYS or team_attacker == DOTA_TEAM_BADGUYS) then return end

    if not entity_attacker:GetOwner() then
        if not entity_attacker:IsControllableByAnyPlayer() then return end
    end

    local player_id = entity_attacker:GetOwner():GetPlayerID()
    local player = PlayerResource:GetPlayer(player_id)
    if not player then return end
    local hero = player:GetAssignedHero()
    if not hero then return end
    -- 一直到这里，所有的判定都是为了确认击杀者是一个玩家的单位

    if hero.__lumber_data == nil then hero.__lumber_data = 1 end

    -- 如果击杀的是英雄，增加5木材
    if entity_killed:IsRealHero() then
       hero.__lumber_data =hero.__lumber_data + 5
    else
    -- 如果击杀的是普通单位，且是敌人，增加1木材
        if entity_killed:GetTeam() ~= entity_attacker:GetTeam() then
           hero.__lumber_data =hero.__lumber_data + 1
        end
    end

    -- 刷新界面的木材信息
    self:UpdateLumberToHUD(player_id, hero.__lumber_data )
end

function Lumber:UpdateLumberToHUD(player_id, val)

    -- 现在先用屏幕数字，之后改成图形界面
    UTIL_ResetMessageText(player_id + 1)
    UTIL_MessageText_WithContext(player_id + 1, "#Lumber_Data", 255, 255, 255, 125, { value = val })

    -- HUD图形界面，待使用
    -- FireGameEvent("update_player_lumber_data", {PlayerID = player_id, Lumbers =hero.__lumber_data})
end
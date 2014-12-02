-- 真·三国无双 V3.9D 复刻
-- 作者：XavierCHN
-- @2014.11.30

-- 载入刷怪器
require("ZSSpawner")
-- 载入技能监听
require('abilities/AbilityCore')
-- 载入木材系统
require('Lumber')
-- 载入平衡性常数修正
require('ParaAdjuster')
-- 载入物品核心
require('items/ItemCore')

-- 初始化真三游戏模式
if ZhensanGameMode == nil then
    ZhensanGameMode = class( { })
end

-- 预载入KV里面定义的各种资源
function PrecacheEveryThingFromKV(context)
    local kv_files = { "scripts/npc/npc_units_custom.txt", "scripts/npc/npc_abilities_custom.txt", "scripts/npc/npc_heroes_custom.txt", "scripts/npc/npc_abilities_override.txt", "npc_items_custom.txt" }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
            PrecacheEverythingFromTable(context, kvs)
        end
    end
end
function PrecacheEverythingFromTable(context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            PrecacheEverythingFromTable(context, value)
        else
            if string.find(value, "vpcf") then
                PrecacheResource("particle", value, context)
                print("PRECACHE PARTICLE RESOURCE", value)
            end
            if string.find(value, "vmdl") then
                PrecacheResource("model", value, context)
                print("PRECACHE MODEL RESOURCE", value)
            end
            if string.find(value, "vsndevts") then
                PrecacheResource("soundfile", value, context)
                print("PRECACHE SOUND RESOURCE", value)
            end
        end
    end
end

-- 预载入
function Precache(context)
    -- 预载入所有KV资源
    PrecacheEveryThingFromKV(context)

    -- 为英雄载入使用其他英雄的资源
    -- 诸葛雷暴雨
    PrecacheUnitByNameSync("npc_dota_hero_leshrac", context)
    -- 诸葛雾隐
    PrecacheUnitByNameSync("npc_dota_hero_mirana", context)
    -- 诸葛雷霆
    PrecacheUnitByNameSync("npc_dota_hero_zuus", context)

    -- 诸葛东风
    PrecacheResource("particle", "particles/neutral_fx/tornado_ambient.vpcf", context)
    -- 司马焰击波
    PrecacheResource("particle", "particles/heroes/simayi/lina_spell_light_strike_array.vpcf", context)
    -- 司马火焰雨
    PrecacheResource("particle", "particles/heroes/simayi/mirana_starfall_attack.vpcf", context)
    -- 司马星落三个特效
    PrecacheResource("particle", "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start_meteor.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf", context)

    -- 诸葛急冻凝结的地面特效
    PrecacheResource("particle", "particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", context)
end

-- 当游戏载入的时候执行
function Activate()
    GameRules.__thisGameMode = ZhensanGameMode()
    GameRules.__thisGameMode:InitGameMode()
end

-- 初始化
function ZhensanGameMode:InitGameMode()
    print("Sanguo Game Mode is loaded")

    -- 设定英雄选择时间为20秒
    GameRules:SetHeroSelectionTime(20)
    -- 设定选择英雄之后时间为40秒
    GameRules:SetPreGameTime(40)
    -- 设置允许选择相同英雄
    GameRules:SetSameHeroSelectionEnabled(true)
    -- 设置不允许使用储藏处
    GameRules:SetStashPurchasingDisabled(true)

    -- 监听游戏阶段变更事件
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(ZhensanGameMode, "OnGameRuleStateChanged"), self)
    -- 监听NPC出生
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(ZhensanGameMode, "OnNPCSpawned"), self)
    -- 监听玩家选择英雄事件
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(ZhensanGameMode, "OnPlayerPicked"), self)

    -- 初始化技能监听
    AbilityCore:Init()
    -- 初始化木材系统监听
    Lumber:Init()
    -- 初始化平衡性常数修正
    ParaAdjuster:Init()
    -- 初始化物品核心
    ItemCore:Init()
    
    -- 设置力量平衡性常数19.12
    ParaAdjuster:SetStrToHealth(19.12)
    -- 设置智力提供魔法常数13.05
    ParaAdjuster:SetIntToMana(13.05)
    -- 设置敏捷-护甲常数0.02
    ParaAdjuster:SetAgiToAtkSpd(0.02)
    -- 设置敏捷-护甲常数0.15
    ParaAdjuster:SetAgiToAmr(0.15)

end

function ZhensanGameMode:OnGameRuleStateChanged(keys)
    local newState = GameRules:State_Get()

    -- 游戏进行到0秒，开始刷怪
    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        ZSSpawner:Start()
    end
    -- 当英雄选择结束，告知作者信息
    if newState == DOTA_GAMERULES_STATE_PRE_GAME then
        self:TellAuthorMessage()
    end
end

-- NPC出生Handler示例
if ZhensanGameMode.__NpcSpawnedHandler == nil then ZhensanGameMode.__NpcSpawnedHandler = class( { }) end

if ZhensanGameMode.__NpcSpawnedHandler.npc_dota_hero_silencer == nil then
    ZhensanGameMode.__NpcSpawnedHandler.npc_dota_hero_silencer = class( { })
end

function ZhensanGameMode.__NpcSpawnedHandler.npc_dota_hero_silencer:Handle(hero)
    -- 把司马懿变红·暂时无效
    local wearables = { }
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model ~= nil and model:GetClassname() == "dota_item_wearable" then
            table.insert(wearables, model)
        end
        model = model:NextMovePeer()
    end
    for _, wearable in pairs(wearables) do
        local index = wearable:entindex()
        wearable_handle = wearable:GetEntityHandle()
        wearable:SetRenderColor(150, 20, 20)
    end
end

-- NPC出生的事件监听
function ZhensanGameMode:OnNPCSpawned(keys)
    local unit = EntIndexToHScript(keys.entindex)
    local unit_name = unit:GetUnitName()
    if self.__NpcSpawnedHandler[unit_name] then
        self.__NpcSpawnedHandler[unit_name]:Handle(unit)
    end
end

-- 玩家选择英雄的事件监听
function ZhensanGameMode:OnPlayerPicked(event)
    print('on player picked')
    local unit = EntIndexToHScript(event.heroindex)
    local unit_name = unit:GetUnitName()
    if self.__NpcSpawnedHandler[unit_name] then
        print('on player picked')
        self.__NpcSpawnedHandler[unit_name]:Handle(unit)
    end
end

-- 告知作者信息
function ZhensanGameMode:TellAuthorMessage()
    GameRules:SendCustomMessage("#author_line1", DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("#author_line2", DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("#author_line3", DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("#author_line4", DOTA_TEAM_GOODGUYS, 0)
end
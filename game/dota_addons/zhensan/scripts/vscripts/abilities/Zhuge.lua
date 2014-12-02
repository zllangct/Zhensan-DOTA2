--[[����� ���ܽű� XavierCHN @ 2012.11.30]]
require('abilities/ability_generic')

-- ������ͷű�����
function OnBaoleiyuStart(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    -- ������ײ��ͷ���ϯ�˵ı�����
    CreateDummyAndCastAbilityOnTarget(caster, "leshrac_lightning_storm", ability:GetLevel(), target, 5, false)
end

-- ������ͷ�쫷硤[쫷����׵�λ�������֮��]
function OnJufeng(keys)

    local caster = keys.caster
    local ability = keys.ability
    -- ���target��ȡ����쫷����׵�λ
    local jufeng = keys.target

    -- ������׵��˺����ܵȼ�Ϊ쫷缼�ܵȼ�
    local ability_effect = jufeng:FindAbilityByName("Zhuge_Jufeng_Dummy")
    ability_effect:SetLevel(ability:GetLevel())

    -- �����ȡһ��λ��
    local random_angle = QAngle(0, RandomInt(-60, 60), 0)
    local caster_fv = caster:GetForwardVector()
    local target_pos = jufeng:GetOrigin() + caster_fv * 1000
    local random_pos = RotatePosition(jufeng:GetOrigin(), random_angle, target_pos)
    -- ��쫷������λ���ƶ�
    jufeng:SetContextThink(DoUniqueString('move'), function() jufeng:MoveToPosition(random_pos) end, 0)

    -- ����һ��������ЧҲ���Ǹ������ƶ�
    local info =
    {
        Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
        vSpawnOrigin = jufeng:GetAbsOrigin(),
        fDistance = 1000,
        fStartRadius = 64,
        fEndRadius = 64,
        Source = jufeng,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = false,
        vVelocity = (random_pos - jufeng:GetOrigin()):Normalized() * 100,
        bProvidesVision = false,
        iVisionRadius = 0,
        iVisionTeamNumber = jufeng:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)

end

-- ��AbilityCore�����ģ����ѧϰ���ܵļ���
if AbilityCore.npc_dota_hero_Invoker == nil then
    AbilityCore.npc_dota_hero_Invoker = class( { })
end

-- �����ѧϰĳ���������ܣ���ͬʱ��������������������
function ZhugeLevelupAllWeatherAbilities(hero)
    local weather_abilities = { "Zhuge_Wolongguangxian", "Zhuge_Wuyin", "Zhuge_Leiting", "Zhuge_Bingxuebao" }
    local max_level = 0
    for _, ability_name in pairs(weather_abilities) do
        local ability = hero:FindAbilityByName(ability_name)
        if ability:GetLevel() > max_level then
            max_level = ability:GetLevel()
        end
    end
    for _, ability_name in pairs(weather_abilities) do
        local ability = hero:FindAbilityByName(ability_name)
        ability:SetLevel(max_level)
    end
end

-- �����ѧϰ���ܵ��¼�����
function AbilityCore.npc_dota_hero_Invoker:LearnAbilityHandler(keys, hero, ability_name)
    -- �����ѧϰ�������ߣ����������������������ܵĵȼ�
    if ability_name == 'Zhuge_Wolongguangxian' then
        local ability = hero:FindAbilityByName('Zhuge_Tianbian')
        if ability:GetLevel() < 1 then
            hero:FindAbilityByName('Zhuge_Tianbian'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Wu'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Xue'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Yu'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Cancel'):SetLevel(1)
        end
    end
    local weather_abilities = { "Zhuge_Wolongguangxian", "Zhuge_Wuyin", "Zhuge_Leiting", "Zhuge_Bingxuebao" }
    for _, name in pairs(weather_abilities) do
        if name == ability_name then
            ZhugeLevelupAllWeatherAbilities(hero)
        end
    end
end

-- �����л�
-- �����ʹ������ʱ���л�����Ϊ �� �� ѩ��ȡ��
function ZhugeSwapAbilityToTianbian(caster)
    caster:SwapAbilities("Zhuge_Baoleiyu", "Zhuge_Tianbian_Wu", false, true)
    caster:SwapAbilities("Zhuge_Jidongningjie", "Zhuge_Tianbian_Yu", false, true)
    caster:SwapAbilities("Zhuge_Jufeng", "Zhuge_Tianbian_Xue", false, true)
    caster:SwapAbilities("Zhuge_Tianbian", "Zhuge_Tianbian_Cancel", false, true)
end
-- �����ʹ��ȡ��������ĳ���������ͰѼ����л�Ϊ�ױ��� �������� 쫷� �����
function ZhugeTianbianSwapBack(caster)
    caster:SwapAbilities("Zhuge_Baoleiyu", "Zhuge_Tianbian_Wu", true, false)
    caster:SwapAbilities("Zhuge_Jidongningjie", "Zhuge_Tianbian_Yu", true, false)
    caster:SwapAbilities("Zhuge_Jufeng", "Zhuge_Tianbian_Xue", true, false)
    caster:SwapAbilities("Zhuge_Tianbian", "Zhuge_Tianbian_Cancel", true, false)
end
-- ����ѡ����������Ѵ����л�Ϊ��Ӧ����������
function SwapAbilityToCurrentWeather(caster, weather_ability_name)
    local weather_abilities = { "Zhuge_Wolongguangxian", "Zhuge_Wuyin", "Zhuge_Leiting", "Zhuge_Bingxuebao" }
    for _, ability_name in pairs(weather_abilities) do
        if ability_name ~= weather_ability_name then
            caster:SwapAbilities(ability_name, weather_ability_name, false, true)
        end
    end
end

-- �����ʹ�����
function OnTianBian(keys)
    local caster = keys.caster
    ZhugeSwapAbilityToTianbian(caster)
end

-- �����ʹ����䡤��
function OnTianBianWu(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    SwapAbilityToCurrentWeather(caster, "Zhuge_Wuyin")
    GameRules:SendCustomMessage("#tianbian_wu", caster:GetTeam(), 0)
end

-- �����ʹ����䡤��
function OnTianBianYu(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    -- caster:SwapAbilities("Zhuge_Wolongguangxian","Zhuge_Leiting",false,true)
    SwapAbilityToCurrentWeather(caster, "Zhuge_Leiting")
    GameRules:SendCustomMessage("#tianbian_yu", caster:GetTeam(), 0)
end

-- �����ʹ����䡤ѩ
function OnTianBianXue(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    SwapAbilityToCurrentWeather(caster, "Zhuge_Bingxuebao")
    GameRules:SendCustomMessage("#tianbian_xue", caster:GetTeam(), 0)
end

-- �����ʹ����䡤ȡ��
function OnTianBianCancel(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    local ability_tianbian = caster:FindAbilityByName("Zhuge_Tianbian")
    ability_tianbian:EndCooldown()
end

-- �����ʹ����䡤����Ч������
function OnTianbianEnd(keys)
    local caster = keys.caster
    SwapAbilityToCurrentWeather(caster, "Zhuge_Wolongguangxian")
end

-- ��ȡ�������ߵ�Ŀ��λ��
function GetWolongGuangxianPoint(keys)
    local caster = keys.caster
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    
    -- ��������30�ȵ������㣬�����м��Ǹ���
    ang_right = QAngle(0, -30, 0)
    ang_left = QAngle(0, 30, 0)
    point_mid = caster_origin + caster_fv * 1200
    point_left = RotatePosition(caster_origin, ang_left, point_mid)
    point_right = RotatePosition(caster_origin, ang_right, point_mid)

    local result = { }
    table.insert(result, point_mid)
    table.insert(result, point_left)
    table.insert(result, point_right)

    return result
end

-- ������������ȡ���ǵ����εģ�������ȵ�λ��
function GetWolongGuangxianPointMid3(keys)
    local caster = keys.caster
    local result = { }
    table.insert(result, caster.__point_left)
    return result
end
function GetWolongGuangxianPointMid2(keys)
    local caster = keys.caster
    local result = { }
    table.insert(result, caster.__point_right)
    return result
end
function GetWolongGuangxianPointMid1(keys)
    local caster = keys.caster
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    ang_left = QAngle(0, 3, 0)
    ang_right = QAngle(0, -3, 0)
    point_mid = caster_origin + caster_fv * 1200
    point_right = RotatePosition(caster_origin, ang_right, point_mid)
    point_left = RotatePosition(caster_origin, ang_left, point_mid)

    caster.__point_left = point_left
    caster.__point_right = point_right

    local result = { }
    table.insert(result, point_mid)
    return result
end

-- ������������ʹ������ͷż���
function OnWuyin(keys)
    local caster = keys.caster
    local ability = keys.ability
    CreateDummyAtPositionAndCastAbilityNoTarget(caster, "mirana_invis", ability:GetLevel(), caster:GetOrigin(), 25, false)
end
function OnLeiting(keys)
    local caster = keys.caster
    local ability = keys.ability
    CreateDummyAtPositionAndCastAbilityNoTarget(caster, "zuus_thundergods_wrath", ability:GetLevel(), caster:GetOrigin(), 3, false)
end

-- �����������Ч
function OnJidongningjieDummy(keys)
    local caster = keys.caster
    local ningjie = keys.target

    local point = ningjie:GetOrigin()

    local p = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_CUSTOMORIGIN, ningjie)
    ParticleManager:SetParticleControl(p, 0, point)
    ParticleManager:ReleaseParticleIndex(p)
end
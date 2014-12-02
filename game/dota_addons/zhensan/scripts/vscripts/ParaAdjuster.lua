--[[
    ��������ƽ���Գ����Ķ���
    ���ݵ���DOTA��׼����
    ÿ����������19��Ѫ
    ÿ������13����
    ÿ����������0.01�㹥���ٶ�
    ÿ����������0.14�㻤��

    ��������õĳ��������������һ��
    ����Ҫͬ����������Ŀ��
    scripts\npc\npc_abilities_custom.txt�е������й���
    ability_health_modifier
    ability_mana_modifier
    ability_atkspeed_modifier
    ability_armor_modifier
    �ĸ����ܵ����ݷŵ����Լ���npc_abilities_custom.txt��
    ֮���������Ϸģʽ��Init��ȷ�����κ����ѡ������κ�Ӣ�۵�ʱ�򣩺�����
    require���ļ��������� ParaAdjuster:Init()
]]

-- ��ʼ����������
if ParaAdjuster == nil then
    ParaAdjuster = class( { })
end
function ParaAdjuster:Init()
    -- ������λ�����¼�
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(ParaAdjuster, "OnNPCSpawned"), self)
    -- �������ѡ��Ӣ���¼�
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(ParaAdjuster, "OnPlayerPicked"), self)
    -- ��ʼ������
    self.__sth_para = 0
    self.__itm_para = 0
    self.__ats_para = 0
    self.__ata_para = 0
    -- �������������ĵ�λ�б�
    self.__adjusting_units = { }
end

-- [Comment]
-- API: ����ÿ�������Ӷ��ٵ�Ѫ��ƽ���Գ���
function ParaAdjuster:SetStrToHealth(value)
    self.__sth_para = value - 19
end
-- [Comment]
-- API: ����ÿ�������Ӷ��ٵ�����ƽ���Գ���
function ParaAdjuster:SetIntToMana(value)
    self.__itm_para = value - 13
end
-- [Comment]
-- API: ����ÿ�����ݼӶ��ٵ㹥���ٶȵ�ƽ���Գ���
function ParaAdjuster:SetAgiToAtkSpd(value)
    self.__ats_para = value - 0.01
end
-- [Comment]
-- API: ����ÿ�����ݼӶ��ٵ㻤�׵�ƽ���Գ���
function ParaAdjuster:SetAgiToAmr(value)
    self.__ata_para = value - 0.14
end

-- �����ѡ��Ӣ�ۣ���������ĳ���������Һ�DOTA�Ĳ�һ������ʼ������������
function ParaAdjuster:OnPlayerPicked(event)
    local unit = EntIndexToHScript(event.heroindex)
    if self.__sth_para ~= 0 then
        self:ModifyData(unit, self.__sth_para, "health")
    end
    if self.__itm_para ~= 0 then
        self:ModifyData(unit, self.__itm_para, "mana")
    end
    if self.__ats_para ~= 0 then
        self:ModifyData(unit, self.__ats_para, "atkspeed")
    end
    if self.__ata_para ~= 0 then
        self:ModifyData(unit, self.__ata_para, "armor")
    end
    table.insert(self.__adjusting_units, unit)
end
-- ��ĳ����λ����������˵�������˻���Ӣ��������ʱ�����൱�ڵ���һ�����ѡ��Ӣ���¼�
function ParaAdjuster:OnNPCSpawned(event)
    local unit = EntIndexToHScript(event.entindex)
    if unit:IsHero() then
        if not self.__adjusting_units.unit then
            -- �����Ѿ���¼����ֵ����ΪӢ��������������������£����ܻ��Ƴ�Ӣ�۵�ĳ��Modifier
            unit.__recorder__ = nil
            unit.__recorder__modified_data__ = nil
            self:OnPlayerPicked( { heroindex = unit:entindex() })
        end
    end
end

-- [Comment]
-- ��������
-- unit: Ҫ�����ĵ�λ
-- data: ƽ���Գ�������ֵ��Ϊ���DOTA��׼��ֵ��ƫ�����˵��Ҫ��������-Ѫ��ƽ���Գ���Ϊ15����ô���data��ֵ��Ϊ-4
-- mod_name: ��������
-- �����Ҫ���������Զ����ĳ����ֵ����ô����Ҫ����npc_abilities_custom.txt����
-- ability_[��������]_modifier�������
-- ���������Ҫ�� modifier_[��������]_mod_[1,2,4,8,16,32,64,128,256,512,-1,-2,-4,-8,-16,-32,-64,-128,-256,-512]
-- ��Щmodifier��������Բο���д�� ability_health_modifier
-- ����if mod_name == "health" then current_data = unit:GetStrength() modified_data = unit:GetMaxHealth() end��Щ�е�λ��
-- ������ĵ�ǰ��ֵ���ݺ����������ֵ
-- ���磬Ҫ���������������ظ��������������Ӧ����
-- if mod_name == "health_regen" then current_data = unit:GetStrength() modified_data = unit:GetHealthRegen() end
-- ��Ȼ����Ҳ���Ը����ɵ�����
-- ����˵������ÿ���������ӽ�Ǯ��ȡ�ٶȣ�ÿ����������[͵���ɹ�����]ʲô�ģ�2333
-- ò����������õ���һ���Զ������ֵ����ô��������һЩ����Ϊ������û�б�Ҫ��ô���ӵ���Modifier��
-- ��һ�������ʵ�����
--
function ParaAdjuster:ModifyData(unit, data, mod_name)
    -- Ϊ��λ����ѭ����ʱ���������ʱ����Ϊ�˾����ڵ�λ����ֵ���������ʱ��
    unit:SetContextThink(DoUniqueString("modify_data"),
    function()
        -- ������ݴ��治���ڣ����ʼ��֮
        if unit.__recorder__ == nil then unit.__recorder__ = { } end
        if unit.__recorder__modified_data__ == nil then unit.__recorder__modified_data__ = { } end
        if unit.__recorder__[mod_name] == nil then unit.__recorder__[mod_name] = 0 end
        if unit.__recorder__modified_data__[mod_name] == nil then unit.__recorder__modified_data__[mod_name] = 0 end

        -- ��ȡ��ǰ��ֵ��������Ķ�Ӧ��ֵ
        local current_data = nil
        local modified_data = nil
        if mod_name == "health" then current_data = unit:GetStrength() modified_data = unit:GetMaxHealth() end
        if mod_name == "mana" then current_data = unit:GetIntellect() modified_data = unit:GetMaxMana() end
        if mod_name == "atkspeed" then current_data = unit:GetAgility() modified_data = unit:GetAttackSpeed() end
        if mod_name == "armor" then current_data = unit:GetAgility() modified_data = unit:GetPhysicalArmorValue() end

        -- �����ǰ����ֵ�ʹ������ֵ��һ�£���˵����λ����������ֵ�����˱����
        if current_data ~= unit.__recorder__[mod_name]
            -- or
            -- �������������ֵ�ʹ�������������ֵ��һ�£���˵����λ��Modifier�����ܵ���Ӱ�죬�����Ƚ��ã�
            -- modified_data ~= unit.__recorder__modified_data__[mod_name]
        then
            -- ���ü������ƺͶ�Ӧ������/����Modifier��
            ability_name = 'ability_' .. mod_name .. '_modifier'
            mod_name_pos_prefix = 'modifier_' .. mod_name .. '_mod_'
            mod_name_neg_prefix = 'modifier_' .. mod_name .. '_mod_neg_'

            -- Ϊ��λ���������ļ���
            local ModifierAbility = unit:FindAbilityByName(ability_name)
            if not ModifierAbility then
                unit:AddAbility(ability_name)
                ModifierAbility = unit:FindAbilityByName(ability_name)
                ModifierAbility:SetLevel(1)
            end

            -- �����Ʊ�
            local bitTable = { 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }

            -- ѭ����λ������Modifier������������Modifier����ô�Ƴ�֮
            local modCount = unit:GetModifierCount()
            for i = 0, modCount do
                for u = 1, #bitTable do
                    local val = bitTable[u]
                    if unit:GetModifierNameByIndex(i) == mod_name_pos_prefix .. val then
                        unit:RemoveModifierByName(mod_name_pos_prefix .. val)
                    end
                    if unit:GetModifierNameByIndex(i) == mod_name_neg_prefix .. val then
                        unit:RemoveModifierByName(mod_name_neg_prefix .. val)
                    end
                end
            end

            -- ������Ҫ��������ֵ
            local to_modify_value = data * current_data

            -- ����������
            if to_modify_value > 0 then
                mod_prefix = mod_name_pos_prefix
            else
                mod_prefix = mod_name_neg_prefix
                to_modify_value = 0 - to_modify_value
            end
            -- ����кܴ�����ݣ�����1023����ô����N��512�ȸɵ�512����
            if to_modify_value > 1023 then
                local out_count = math.floor(to_modify_value / 512)
                for i = 1, out_count do
                    ModifierAbility:ApplyDataDrivenModifier(unit, unit, mod_prefix .. "512", { })
                end
                to_modify_value = to_modify_value - out_count * 512
            end
            -- ѭ������Modifier���������ӵ���ȷ������Modifier
            for p = 1, #bitTable do
                local val = bitTable[p]
                local count = math.floor(to_modify_value / val)
                if count >= 1 then
                    ModifierAbility:ApplyDataDrivenModifier(unit, unit, mod_prefix .. val, { })
                    to_modify_value = to_modify_value - val
                end
            end

            -- Ϊ��λ�Ƴ��������
            unit:RemoveAbility(ability_name)

            -- �ټ�¼һ����ֵ
            if mod_name == "health" then current_data = unit:GetStrength() modified_data = unit:GetMaxHealth() end
            if mod_name == "mana" then current_data = unit:GetIntellect() modified_data = unit:GetMaxMana() end
            if mod_name == "atkspeed" then current_data = unit:GetAgility() modified_data = unit:GetAttackSpeed() end
            if mod_name == "armor" then current_data = unit:GetAgility() modified_data = unit:GetPhysicalArmorValue() end

            -- ��Ȼ��ǧ�����ʲô1����������0.5��������0.5������������1������������ɶ����˵������Ǹ���ѭ����
            -- ������ﶼ����ѭ����ѽ��
            unit.__recorder__[mod_name] = current_data
            unit.__recorder__modified_data__[mod_name] = modified_data
        end
        -- 0.2����ٵ���һ��
        return 0.2
    end ,
    0.2)
end
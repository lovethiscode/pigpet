
local assets = {
	Asset("ANIM", "anim/ui_portablecellar.zip"),
}



local function OnAttacked(inst, data)
    local attacker = data.attacker
    inst.components.combat:SetTarget(attacker)
end


local function OnItemGet(inst, data)
    --没有leader 就返回
    if not inst.components.follower.leader then
        return
    end
    if data.slot == 116 or data.slot == 117 or data.slot == 118 then
        print("装备物品")
        inst.components.inventory:Equip(data.item)
        return
    end
end

local function OnItemLose(inst, data) 
    if data.slot == 116 then       
        inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
    elseif data.slot == 117 then
        inst.components.inventory:Unequip(EQUIPSLOTS.BODY)
    elseif data.slot == 118 then
        inst.components.inventory:Unequip(EQUIPSLOTS.HEAD)
    end

end

local function itemtest(inst, item, slot)
    if slot == 116 then
        --判断是不是武器
        if not item.components.equippable or item.components.equippable.equipslot ~= EQUIPSLOTS.HANDS then
            --leader 说一句话
            inst.components.talker:Say("这里只能放手持物品")
            return false
        end
    elseif slot == 117 then
        --判断是不是防具
        if not item.components.equippable or item.components.equippable.equipslot ~= EQUIPSLOTS.BODY then
            --leader 说一句话
            inst.components.talker:Say("这里只能放防具")
            return false
        end
    elseif slot == 118 then
        --判断是不是帽子
        if not item.components.equippable or item.components.equippable.equipslot ~= EQUIPSLOTS.HEAD then
            --leader 说一句话
            inst.components.talker:Say("这里只能放帽子")
            return false
        end
    end
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.Transform:SetFourFaced()
    
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeCharacterPhysics(inst, 50, .5)

    inst:AddTag("fridge")
    inst:AddTag("character")

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("pig_build")
    inst.AnimState:PlayAnimation("idle_loop")

    --可以移动
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3

   
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(20)

    --可以战斗
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetDefaultDamage(5)
    inst.components.combat:SetAttackPeriod(2)

    inst:ListenForEvent("attacked", OnAttacked)

    --添加talker 组件
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0,-400,0)

    --可以跟随玩家
    inst:AddComponent("follower")
    --物品栏，可以装备武器，防具，背包等
    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")
    
    --添加一个容器，可以用房物品     
    inst:AddComponent("container")
    local slotpos = {}
    local x_offset = (-72-72-40-2)*2
    for z = 1,4 do
        for y = 0.5,-1.5,-1 do
            for x = -2,2 do
                table.insert(slotpos, Vector3(72*x +x_offset, 72*y -2-40-72-36, 0))
            end
        end
        x_offset = x_offset + (72+72+40+2)*2
    end

    inst.components.container:SetNumSlots(#slotpos)      
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
   -- inst.components.container.widgetanimbuild = "ui_portablecellar"
    inst.components.container.widgetpos = Vector3(-100, -285, 0)
    inst.components.container.side_align_tip = 0
    inst.components.container.type = "pack"

    --[[
    inst:ListenForEvent("itemget", OnItemGet)
    inst:ListenForEvent("itemlose", OnItemLose)
    inst.components.container.itemtestfn = itemtest]]

    --[[local widgetbuttoninfo = {
        text = "关闭",
        position = Vector3(0, -330, 0),
        fn = function(inst)
            inst.components.container:Close()
        end,
        validfn = function(inst)
            return true
        end,
    }
    --添加一个关闭按钮
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo--]]

    --添加growth 组件
    inst:AddComponent("growth")

     --设置状态图
     inst:SetStateGraph("SGpigpet")
     --设置brain
     inst:SetBrain(require "brains/pigpetbrain")
     inst:ListenForEvent("attacked", OnAttacked)         
    return inst
end

return Prefab("common/pigpet", fn, assets)
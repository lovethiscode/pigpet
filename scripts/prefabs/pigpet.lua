
local assets = {
	Asset("ANIM", "anim/ui_portablecellar.zip"),
}



local function OnAttacked(inst, data)
    local attacker = data.attacker
    inst.components.combat:SetTarget(attacker)
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
    inst.components.health:SetMaxHealth(10000)


    --可以战斗
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetDefaultDamage(5)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRange(2)

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
    for z = 1,3 do
        for y = 1.5,-1.5,-1 do
            for x = -2,2 do
                table.insert(slotpos, Vector3(72*x +x_offset, 72*y +2+40+72+36, 0))
            end
        end
        for y = 1.5,-1.5,-1 do
            for x = -2,2 do
                table.insert(slotpos, Vector3(72*x +x_offset, 72*y -2-40-72-36, 0))
            end
        end
        x_offset = x_offset + (72+72+40+2)*2
    end

    inst.components.container:SetNumSlots(#slotpos)      
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_portablecellar"
    inst.components.container.widgetpos = Vector3(0, 130, 0)
    inst.components.container.side_align_tip = 0
    inst.components.container.type = "pack"

    local widgetbuttoninfo = {
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
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo

     --设置状态图
     inst:SetStateGraph("SGpigpet")
     --设置brain
     inst:SetBrain(require "brains/pigpetbrain")

     inst:ListenForEvent("attacked", OnAttacked)
    return inst
end

return Prefab("common/pigpet", fn, assets)
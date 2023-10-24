
local assets =
{
    
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeCharacterPhysics(inst, 50, .5)

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("pig_build")
    inst.AnimState:PlayAnimation("pig_reject", true)

    --可以移动
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(100)


    --可以战斗
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(5)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRange(2)

    --可以跟随玩家
    inst:AddComponent("follower")
    --物品栏，可以装备武器，防具，背包等
    inst:AddComponent("inventory")

    return inst
end

return Prefab("common/pigpet", fn, assets)
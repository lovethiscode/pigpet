local assets=
{
    Asset("ATLAS", "images/inventoryimages/mybackpack.xml")
}

local function common(inst)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    inst:AddComponent("edible") 
    inst.components.edible.foodtype = "PigPet"
    
    inst:AddComponent("stackable")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    return inst
end

local function fn(Sim)
	local inst = common()
    inst.AnimState:SetBank("meat")
    inst.AnimState:SetBuild("meat")
    inst.AnimState:PlayAnimation("raw")
    inst.components.edible.healthvalue = 10
    
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mybackpack.xml" 

    inst:AddComponent("tradable") 
    
    return inst
end

return Prefab( "common/pigpetfood", fn, assets) 
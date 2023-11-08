local assets=
{
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "swap_body")
    owner.components.inventory:SetOverflow(inst)
    inst.components.container:Open(owner)
    
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner.components.inventory:SetOverflow(nil)
    inst.components.container:Close(owner)
end


local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end


local slotpos = {}

for y = 0, 3 do
	table.insert(slotpos, Vector3(-162, -y*75 + 114 ,0))
	table.insert(slotpos, Vector3(-162 +75, -y*75 + 114 ,0))
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("backpack")
    inst.AnimState:PlayAnimation("anim")
    inst:AddTag("fridge")
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("backpack.png")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/backpack"

    MakeInventoryFloatable(inst, "idle_water", "anim")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    
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
   
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    
    return inst
end

return Prefab( "common/mybackpack", fn, assets) 

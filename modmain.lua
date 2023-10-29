GLOBAL.Pigpet = {}

GLOBAL.Pigpet.pick_prefeb = {
    sapling = "twigs",
    flower = "petals",
    grass = "cutgrass",
    carrot_planted = "carrot",
    berrybush = "berries",
}
--声明预制物
PrefabFiles = {
    "pigpet"
}

Assets =
{
	Asset("IMAGE", "images/slots5.tex"),
	Asset("ATLAS", "images/slots5.xml"),
}

GLOBAL.STRINGS.NAMES.PIGPET = "皮皮熊"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIGPET = "我是一只宠物" -- 物体的检查描述

modimport("showinfo.lua")

--监听所有预制物的构造
AddPrefabPostInitAny(function(inst)
    --如果可以堆叠
    if inst.components.stackable then
        --设置最大堆叠999
        inst.components.stackable.maxsize = 999
    end
end)

AddClassPostConstruct("widgets/containerwidget", function(self)
    --替换 OnUpdate 函数
    local old_OnUpdate = self.OnUpdate
    self.OnUpdate = function(self, dt)
        if self.container and self.container.prefab == "pigpet" then
            return
        end
        --调用原来的函数
        old_OnUpdate(self, dt)
    end
end)


--增加两个物品栏
GLOBAL.EQUIPSLOTS.BACK = "back"
GLOBAL.EQUIPSLOTS.NECK = "neck"
AddClassPostConstruct("screens/playerhud", function(self) 
	local oldfn = self.SetMainCharacter
	function self:SetMainCharacter(maincharacter,...)
		oldfn(self, maincharacter,...)
		if not(self.controls and self.controls.inv) then
			print("ERROR: Can't inject in screens/playerhud.")
			return
		end
        --背包
		self.controls.inv:AddEquipSlot(GLOBAL.EQUIPSLOTS.BACK, "images/slots5.xml", "back.tex")
        --项链，
		self.controls.inv:AddEquipSlot(GLOBAL.EQUIPSLOTS.NECK, "images/slots5.xml", "neck.tex")
		if self.controls.inv.bg then
			self.controls.inv.bg:SetScale(1.25,1,1.25)
		end
		local bp = maincharacter.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BACK)
		if bp and bp.components.container then
			bp.components.container:Close()
			bp.components.container:Open(maincharacter)
		end
	end
end)


local amulets = {"amulet", "blueamulet", "purpleamulet", "orangeamulet", "greenamulet", "yellowamulet", --standard
	    "blackamulet", "pinkamulet", "whiteamulet", "endiaamulet", "grayamulet", "broken_frosthammer",
	    "musha_egg", "musha_egg1", "musha_egg2", "musha_egg3", "musha_egg8", "musha_eggs1", "musha_eggs2", "musha_eggs3",
	} --mods

for i,v in ipairs(amulets) do
	AddPrefabPostInit(v, function(inst)
		if inst.components.equippable then
			inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.NECK
		end
	end)
end

GLOBAL.TheInput:AddKeyHandler(function(key, down)
    if key == GLOBAL.KEY_F1 and not down then
         --生成一个pigpet
        local pig = GLOBAL.SpawnPrefab("pigpet")
        pig.Transform:SetPosition(GLOBAL.GetPlayer().Transform:GetWorldPosition())
        pig.components.follower:SetLeader(GLOBAL.GetPlayer())

    elseif key == GLOBAL.KEY_F2 and not down then
        local pig = GLOBAL.SpawnPrefab("pigman")
        pig.Transform:SetPosition(GLOBAL.GetPlayer().Transform:GetWorldPosition())
        pig.components.follower:SetLeader(GLOBAL.GetPlayer())
        --设置状态图
        pig:SetStateGraph("SGpigpet")
        --设置brain
        pig:SetBrain(GLOBAL.require "brains/pigpetbrain")
    elseif key == GLOBAL.KEY_F3 and not down then
        local player = GLOBAL.GetPlayer()
        local target = GLOBAL.FindEntity(player, 10, function(item) return item.components.pickable and item.components.pickable:CanBePicked() end)
        if target then
            --放入背包       
            print("放入背包:" .. tostring(target))
            player.components.inventory:GiveItem(target)
        end
    end
end)
Assets =
{
	Asset("IMAGE", "images/slots5.tex"),
	Asset("ATLAS", "images/slots5.xml"),
}


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

--复活的红宝石有特殊逻辑，当人物死亡的时候，会查找BODY上是否有 复活红宝石，所以这里需要特殊处理

local comp_res = require "components/resurrectable"
local comp_inv = require "components/inventory"

local fix_once = nil --While hooking fix only once. May be not compatible with some mods.

local old_GetEquippedItem = comp_inv.GetEquippedItem
function comp_inv:GetEquippedItem(slot,...)
    if fix_once ~= nil then
        fix_once = nil
        local item = old_GetEquippedItem(self,EQUIPSLOTS.NECK,...)
        if item ~= nil and item.prefab == "amulet" then --We need to hook only amulet.
            return item
        end
    end
    return old_GetEquippedItem(self,slot,...)
end

--Fixing behaviour
local old_FindClosestResurrector = comp_res.FindClosestResurrector
function comp_res:FindClosestResurrector(...)
    fix_once = true
    return old_FindClosestResurrector(self,...)
end

local old_CanResurrect = comp_res.CanResurrect
function comp_res:CanResurrect(...)
    fix_once = true
    return old_CanResurrect(self,...)
end

local old_DoResurrect = comp_res.DoResurrect
function comp_res:DoResurrect(...)
    fix_once = true
    return old_DoResurrect(self,...)
end
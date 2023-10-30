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

GLOBAL.STRINGS.NAMES.PIGPET = "皮皮熊"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIGPET = "我是一只宠物" -- 物体的检查描述

modimport("showinfo.lua")
modimport("extraequipment.lua")

--监听所有预制物的构造
AddPrefabPostInitAny(function(inst)
    --如果可以堆叠
    if inst.components.stackable then
        --设置最大堆叠999
        inst.components.stackable.maxsize = 999
    end
end)

--重写containerwidget OnUpdate 函数
local container_widget = GLOBAL.require "widgets/containerwidget"
local old_OnUpdate = container_widget.OnUpdate
function container_widget:OnUpdate(dt)
    if self.container and self.container.prefab == "pigpet" then
        return
    end
    --调用原来的函数
    old_OnUpdate(self, dt)
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
    elseif key == GLOBAL.KEY_F4 and not down then
        --获取玩家的跟随者
        local player = GLOBAL.GetPlayer()
        local followers = player.components.leader.followers;
        for k,v in pairs(followers) do
            if k.prefab == "pigpet" then
                --如果没有打开背包就打开背包
                if k.components.container:IsOpen() then                   
                    k.components.container:Close()
                else                    
                    k.components.container:Open(player)
                end
                return true
            end
        end
    end
end)    
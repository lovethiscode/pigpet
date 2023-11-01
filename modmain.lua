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
--冰箱不会腐烂
TUNING.PERISH_FRIDGE_MULT = 0


local function CreatePigpetIfnot()
    local player = GLOBAL.GetPlayer()
    --获取玩家的跟随者
    local followers = player.components.leader.followers;
    --判断是否有pigpet跟随者
    local pigpet
    for k,v in pairs(followers) do
        --如果是pigpet
        if k.prefab == "pigpet" then
            pigpet = k
            break
        end
    end
    if not pigpet then
        pigpet = GLOBAL.SpawnPrefab("pigpet")
        pigpet.Transform:SetPosition(player.Transform:GetWorldPosition())
        pigpet.components.follower:SetLeader(player)
    end
    player.components.inventory:SetOverflow(pigpet)
end

local function ShowFullMap(inst)
    inst:DoTaskInTime( 0.001, function() 
        minimap = TheSim:FindFirstEntityWithTag("minimap")
        minimap.MiniMap:ShowArea(0,0,0,40000)
end)
end

--监听世界的构造
AddSimPostInit(function(inst)
   CreatePigpetIfnot()
   ShowFullMap(inst)
end)

local cooking = GLOBAL.require("cooking")

GLOBAL.TheInput:AddKeyHandler(function(key, down)
    if key == GLOBAL.KEY_F3 and not down then
        local pig = GLOBAL.SpawnPrefab("pigman")
        pig.Transform:SetPosition(GLOBAL.GetPlayer().Transform:GetWorldPosition())
        pig.components.follower:SetLeader(GLOBAL.GetPlayer())
        --设置状态图
        pig:SetStateGraph("SGpigpet")
        --设置brain
        pig:SetBrain(GLOBAL.require "brains/pigpetbrain")
    elseif key == GLOBAL.KEY_F2 and not down then
       local autoCook = GLOBAL.require "autocook"
       autoCook()
    elseif key == GLOBAL.KEY_F1 and not down then
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
    elseif key == GLOBAL.KEY_F4 and not down then
        --获取饥荒中所有的食材
        local content = "\n-----------------原料------------------------\n"
        local count = 0
        --枚举 原料
        for name, v in pairs(cooking.ingredients) do
             content = content .. tostring(GLOBAL.STRINGS.NAMES[string.upper(name)]) .. "(" .. name .. ")\n"
             if v.tags then              
                 for tag, tagval in pairs(v.tags) do
                     content = content .. tag .. ":" .. tostring(tagval) .. "\t"
                 end
             end
             count =  count + 1
             content = content .. "\n\n"
        end
        --枚举食谱
        content = content .. "总计食材:" .. tostring(count) .. "\n-----------------食谱------------------------\n"
        count = 0
        for cooker, v in pairs(cooking.recipes) do
             --便携锅， 普通锅
             content = content .. cooker .. "\n"
             --每种锅可烹饪的所有食物
             for name, recipe in pairs(v) do
                count = count + 1
                content = content .. tostring(GLOBAL.STRINGS.NAMES[string.upper(name)]) .. "("..  name .. "):" .. " foodtype:" .. tostring(recipe.foodtype) .. " health:" .. tostring(recipe.health) .. " hunger:" .. tostring(recipe.hunger) .. " sanity:" .. tostring(recipe.sanity) .. " \n\n"
             end
             content = content .. "\n"
        end
        content = content .. "总计食物:" .. tostring(count)
        TheSim:SetPersistentString("console_history.txt", content)	
    end
end)    
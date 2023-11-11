GLOBAL.Pigpet = {}

Assets = 
{
    Asset("IMAGE", "images/recipe_hud.tex"),
	Asset("ATLAS", "images/recipe_hud.xml"),
    Asset( "IMAGE", "images/beefalo.tex" ),
    Asset( "ATLAS", "images/beefalo.xml" ),
    Asset("IMAGE", "images/slots5.tex"),
	Asset("ATLAS", "images/slots5.xml"),
    Asset("IMAGE", "images/status_bgs.tex"),
	Asset("ATLAS", "images/status_bgs.xml"),
    Asset("ATLAS", "images/inventoryimages/pigpetfood.xml"),
    Asset( "IMAGE", "images/carrot_planted.tex" ),
    Asset( "ATLAS", "images/carrot_planted.xml" ),
    Asset( "IMAGE", "images/flint.tex" ),
    Asset( "ATLAS", "images/flint.xml" ),
    Asset( "IMAGE", "images/rabbithole.tex" ),
    Asset( "ATLAS", "images/rabbithole.xml" ),
    
}

GLOBAL.Pigpet.pick_prefeb = {
    sapling = "twigs",
    flower = "petals",
    grass = "cutgrass",
    carrot_planted = "carrot",
    berrybush = "berries",
    asparagus_planted = "asparagus",
    radish_planted = "radish",
    flower_rainforest = "petals",
    rock_flippable = "rocks",
    dungpile = "poop",
    aloe_planted = "aloe",
}


GLOBAL.Pigpet.homesigns = {}

--声明预制物
PrefabFiles = {
    "pigpet",
    "mybackpack",
    "pigpetfood"
}

local pigpetfood = GLOBAL.Recipe("pigpetfood",  {GLOBAL.Ingredient("cutgrass", 1), GLOBAL.Ingredient("twigs", 1)}, GLOBAL.RECIPETABS.SURVIVAL, GLOBAL.TECH.NONE)
pigpetfood.atlas = "images/inventoryimages/pigpetfood.xml"

GLOBAL.Pigpet.Enable = true
GLOBAL.STRINGS.NAMES.PIGPET = "皮皮熊"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIGPET = "我是一只宠物" -- 物体的检查描述

GLOBAL.STRINGS.NAMES.PIGPETFOOD = "宠物饲料"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIGPETFOOD = "这是给宠物吃的，可以恢复生命值"
GLOBAL.STRINGS.RECIPE_DESC.PIGPETFOOD = "可以恢复宠物生命值20点"


modimport("showinfo.lua")
modimport("extraequipment.lua")
modimport("travel.lua")

--监听所有预制物的构造
AddPrefabPostInitAny(function(inst)
    --如果可以堆叠
    if inst.components.stackable then
        --设置最大堆叠999
        inst.components.stackable.maxsize = 999
    end
    --如果是装备，则增加 tradable 组件
    if inst.components.equippable then
        inst:AddComponent("tradable") 
    end
end)

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

     --监听pigpet 死亡事件
     pigpet:ListenForEvent("death", function(inst)
        --player 说一句话
        player.components.talker:Say("皮皮熊死了，1分钟后自动复活")
       --启动一个5秒钟的一次性定时器
        player:DoTaskInTime(60, function() 
            CreatePigpetIfnot()
        end)
    end)
end

local function CreateMyBackpack()
    --判断玩家是否已经装备了mybackpack
    local player = GLOBAL.GetPlayer()
    local backpack = player.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BACK)
    if not backpack or backpack.prefab ~= "mybackpack" then
        backpack = GLOBAL.SpawnPrefab("mybackpack")
        player.components.inventory:Equip(backpack)
    end
end

local function ShowFullMap(inst)
    --读取 show_global_map 配置，判断是否开启地图
    local show_global_map = GetModConfigData("show_global_map")
    if not show_global_map then
        return
    end
    inst:DoTaskInTime( 0.001, function() 
        minimap = TheSim:FindFirstEntityWithTag("minimap")
        minimap.MiniMap:ShowArea(0,0,0,40000)
    end)
end

--监听世界的构造
AddSimPostInit(function(inst)
   CreatePigpetIfnot()
   ShowFullMap(inst)
   CreateMyBackpack()
end)


local cooking = GLOBAL.require("cooking")
local cookbook = GLOBAL.require("widgets/cookbook")

GLOBAL.TheInput:AddKeyHandler(function(key, down)
   if key == GLOBAL.KEY_F1 and not down then       
        local screen = TheFrontEnd:GetActiveScreen()
        -- End if we can't find the screen name (e.g. asleep)
        if not screen or not screen.name then return true end
        -- If the hud exists, open the UI
        if screen.name:find("HUD") then
            -- We want to pass in the (clientside) player entity
           
            TheFrontEnd:PushScreen(cookbook())
            return true
        else
            -- If the screen is already open, close it
            if screen.name == "CookBook" then
                screen:Close()
            end
        end
    elseif key == GLOBAL.KEY_F2 and not down then     
        if GLOBAL.Pigpet.Enable then
            GLOBAL.Pigpet.Enable = false
        else
            GLOBAL.Pigpet.Enable = true
        end
    elseif key == GLOBAL.KEY_F5 and not down then
        GLOBAL.GetPlayer().components.autosaver:DoSave()
    elseif key == GLOBAL.KEY_F6 and not down then
        GLOBAL.Settings.save_slot = GLOBAL.SaveGameIndex.saveslot
		GLOBAL.SetPause(true)
		GLOBAL.StartNextInstance({reset_action=GLOBAL.RESET_ACTION.LOAD_SLOT, save_slot = GLOBAL.SaveGameIndex:GetCurrentSaveSlot()}, true)
		GLOBAL.SetPause(false)
    end
end)    

AddPlayerPostInit(function(inst)
    inst:AddTag("fridge")
end)

--获取关闭自动保存配置，如果关闭了，将 AUTOSAVE_INTERVAL 设置无限大
local disableautosave = GetModConfigData("disableautosave")
if disableautosave then
    GLOBAL.TUNING.AUTOSAVE_INTERVAL = 99999999999
end

--读取配置，如果死亡不删除档案，将删除档案的方法替换为一个空方法
local disabledeleteondeath = GetModConfigData("disabledeleteondeath")
if disabledeleteondeath then
    function GLOBAL.SaveIndex:EraseCurrent(cb)
        GLOBAL.GetPlayer():DoTaskInTime(2, function()
            GLOBAL.TheFrontEnd:Fade(false,1)
        end )
        GLOBAL.GetPlayer():DoTaskInTime(5, function()
            GLOBAL.StartNextInstance({reset_action=GLOBAL.RESET_ACTION.LOAD_SLOT, save_slot = GLOBAL.SaveGameIndex:GetCurrentSaveSlot()}, true)
        end )
    end
end


--一键制作
local ImageButton = GLOBAL.require "widgets/imagebutton"
AddClassPostConstruct("widgets/recipepopup", function(self)
    local old = self.Refresh
	self.Refresh = function(...)
		old(...)
        if not self.shown then
            return
        end
        local recipe = self.recipe
        local owner = self.owner
        if self.doAction then
            --先隐藏
            self.doAction:Hide()
        end

        for k,v in pairs(recipe.ingredients) do
            --判断是否是需要合成的物品
            local slotrecipe = GLOBAL.Recipes[v.type]
            if slotrecipe then
                local knows = owner.components.builder:KnowsRecipe(v.type)
                local can_build = owner.components.builder:CanBuild(v.type)
                local has, num_found = owner.components.inventory:Has(v.type, GLOBAL.RoundUp(v.amount * owner.components.builder.ingredientmod), true)
                print("需要：" .. tostring(k) .. " :" .. v.type .. " " .. v.amount .. " knows:" .. tostring(knows) .. " can_build:" .. tostring(can_build) .. " has:" .. tostring(has).. " num_found:" .. tostring(num_found))
                --如果知道配方，材料充足，并且不够


                if knows and can_build and not has and not self.doAction then                
                    self.doAction = self.contents:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
                    self.doAction:SetPosition(220, 140)
                    self.doAction:SetText("材料")
                    self.doAction:MoveToFront()
                    self.doAction:SetOnClick(function()
                        GLOBAL.DoRecipeClick(self.owner, slotrecipe)
                    end)
                    print("可以制作完成")
                end

                if knows and can_build and not has then
                    self.doAction:Show()
                end

            end
        end
    end
end)
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

local pigpetfood
if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) or GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC) then
    pigpetfood = GLOBAL.Recipe("pigpetfood",  {GLOBAL.Ingredient("cutgrass", 10), GLOBAL.Ingredient("twigs", 10)}, GLOBAL.RECIPETABS.SURVIVAL, GLOBAL.TECH.NONE, nil, nil, nil, nil, 10)
else
    pigpetfood = GLOBAL.Recipe("pigpetfood",   {GLOBAL.Ingredient("cutgrass", 10), GLOBAL.Ingredient("twigs", 10)}, GLOBAL.RECIPETABS.SURVIVAL, GLOBAL.TECH.NONE, nil, 10) 
end

pigpetfood.atlas = "images/inventoryimages/pigpetfood.xml"

--0 正常 1 禁用 2 隐藏
GLOBAL.Pigpet.Status = 0
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
--
--监听是否已经有背包了
AddPrefabPostInit("mybackpack", function(inst)
    GLOBAL.Pigpet.mybackpack = inst
end)

--监听pigpet构造    
AddPrefabPostInit("pigpet", function(inst)
    GLOBAL.Pigpet.pet = inst
end)

local function CreatePigpetIfnot()
    if not GLOBAL.Pigpet.pet then
        GLOBAL.SpawnPrefab("pigpet")
    end

    local player = GLOBAL.GetPlayer()
    GLOBAL.Pigpet.pet.Transform:SetPosition(player.Transform:GetWorldPosition())
    GLOBAL.Pigpet.pet.components.follower:SetLeader(player)

    GLOBAL.Pigpet.Status = 0
     --监听pigpet 死亡事件
    GLOBAL.Pigpet.pet:ListenForEvent("death", function(inst)
        --player 说一句话
        player.components.talker:Say("皮皮熊死了，1分钟后自动复活")
       --启动一个5秒钟的一次性定时器
        player:DoTaskInTime(60, function() 
            CreatePigpetIfnot()
        end)
    end)
end

local function CreateMyBackpack()
    local player = GLOBAL.GetPlayer()
    if not GLOBAL.Pigpet.mybackpack then
        GLOBAL.SpawnPrefab("mybackpack")
    end
    player.components.inventory:Equip(GLOBAL.Pigpet.mybackpack)
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
local arrange = GLOBAL.require("arrange")

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
        GLOBAL.Pigpet.Status = GLOBAL.Pigpet.Status + 1
        if GLOBAL.Pigpet.Status > 2 then
            GLOBAL.Pigpet.Status = 0
            GLOBAL.Pigpet.pet:Show()
        end  
        if GLOBAL.Pigpet.Status == 2 then
            --隐藏宠物
            GLOBAL.Pigpet.pet:Hide()
        end
    elseif key == GLOBAL.KEY_F3 and not down then
        arrange()
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
                        GLOBAL.DoRecipeClick(self.owner, self.doAction.slotrecipe)
                    end)
                end

                if knows and can_build and not has then
                    self.doAction.slotrecipe = slotrecipe
                    self.doAction:Show()
                end
                if not knows and can_build then
                    --说话
                    owner.components.talker:Say(GLOBAL.STRINGS.NAMES[string.upper(slotrecipe.name)] .. "(需要制作一个原型)")
                end
            end
        end
    end
end)
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
local cookbook = GLOBAL.require("widget/cookbook")

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
        local screen = TheFrontEnd:GetActiveScreen()
        -- End if we can't find the screen name (e.g. asleep)
        if not screen or not screen.name then return true end
        -- If the hud exists, open the UI
        if screen.name:find("HUD") then
            -- We want to pass in the (clientside) player entity
           
            print("cookbook:" .. tostring(cookbook))
            TheFrontEnd:PushScreen(cookbook())
            return true
        else
            -- If the screen is already open, close it
            if screen.name == "cookbook" then
                screen:Close()
            end
        end
    end
end)    













local function IsDST()
    return GLOBAL.TheSim:GetGameID() == "DST"
  end
  
  local function IsClientSim()
    return IsDST() and GLOBAL.TheNet:GetIsClient()
  end
  
  local function GetPlayer()
    if IsDST() then
      return GLOBAL.ThePlayer
    else
      return GLOBAL.GetPlayer()
    end
  end
  
  local function GetWorld()
    if IsDST() then
      return GLOBAL.TheWorld
    else
      return GLOBAL.GetWorld()
    end
  end
  
  local function AddPlayerPostInit(fn)
    if IsDST() then
      env.AddPrefabPostInit("world", function(wrld)
        wrld:ListenForEvent("playeractivated", function(wlrd, player)
          if player == GLOBAL.ThePlayer then
            fn(player)
          end
        end)
      end)
    else
      env.AddPlayerPostInit(function(player)
        fn(player)
      end)
    end
  end
  
  
  local require = GLOBAL.require
  local TheInput = GLOBAL.TheInput
  local STRINGS = GLOBAL.STRINGS
  
  local MouseFoodCrafting = require "widgets/mousefoodcrafting"
  require "ingredienttags"
  
  Assets = {
    Asset("ATLAS", "images/food_tags.xml"),
    Asset("ATLAS", "images/recipe_hud.xml"),
  }
  
  local _SimLoaded = false
  local _GameLoaded = false
  local _ControlsLoaded = false
  local _PlayerLoaded = false
  
  local function OnAfterLoad(controls)
    if _GameLoaded ~= true or _SimLoaded ~= true or _PlayerLoaded ~= true or _ControlsLoaded ~= true then
      return false
    end
  
      --- OnAfterLoad may be executed once more if player gets rebuild,
      --- e.g.: it could happen if player repicked his character via Celestial Portal or such
      --- so we reset PlayerLoaded and ControlsLoaded to prevent double call on OnAfterLoad once that happens
      _PlayerLoaded = false
      _ControlsLoaded = false
  
      local player = GetPlayer()
      local foodcrafting = controls and controls.foodcrafting or player.HUD.controls.foodcrafting
  
      if player and player.components and player.components.knownfoods and foodcrafting then
      local config = {
        lock_uncooked=GetModConfigData("lock_uncooked"),
        invert_controller=GetModConfigData("invert_controller"),
        has_popup=GetModConfigData("has_popup"),
      }
      player.components.knownfoods:OnAfterLoad(config)
      foodcrafting:OnAfterLoad(config, player)
    end
  end
  
  local function OnPlayerLoad(player)
    _PlayerLoaded = true
    if not IsDST() then
      player:AddComponent('knownfoods')
    end
    OnAfterLoad()
  end
  
  local function OnSimLoad()
    _SimLoaded = true
    OnAfterLoad()
  end
  
  local function OnGameLoad()
    _GameLoaded = true
    OnAfterLoad()
  end
  
  
  local function ControlsPostInit(self)
    _ControlsLoaded = true
    if IsDST() then
      GetPlayer():AddComponent('knownfoods')
    end
      self.foodcrafting = self.containerroot:AddChild(MouseFoodCrafting())
      self.foodcrafting:Hide()
      OnAfterLoad(self)
  end
  
  local function ContainerPostConstruct(inst, prefab)
      -- if inst.type is not defined, it would mean that OnEntityReplicated has not been called yet
      if not inst.type and not inst.__craftPotPatched then
          -- this variable prevents possibility of endless loop for ContainerPostConstruct
          inst.__craftPotPatched = true
  
          -- thus we need to delay ContainerPostConstruct call until it is fully initialized
          if prefab and prefab.OnEntityReplicated then
              originalEntityReplicatedHandler = prefab.OnEntityReplicated
              prefab.OnEntityReplicated = function(...)
                  originalEntityReplicatedHandler(...)
                  ContainerPostConstruct(inst, prefab)
              end
          end
    end
  
  
    -- only apply mod to components that are cookers and that have no widget
    if not inst.type or inst.type ~= "cooker" or (
        not inst.widget or not inst.widget.buttoninfo or
        inst.widget.buttoninfo.text ~= STRINGS.ACTIONS.COOK and inst.widget.buttoninfo.text ~= "Cook"
      ) and IsDST()
    then
      return false
    end
  
    -- store base methods
    local onopenfn = inst.Open
    local onclosefn = inst.Close
    local getitemsfn = inst.GetItems
    local onstartcookingfn = inst.widget and inst.widget.buttoninfo.fn
    local ondonecookingfn = inst.inst.components.stewer and inst.inst.components.stewer.ondonecooking
  
    -- define modded actions
    local function mod_onopen(inst, doer, ...)
        onopenfn(inst, doer, ...)
  
      if doer == GetPlayer() then
      doer.HUD.controls.foodcrafting:Open(inst.GetItems and inst or inst.inst)
      end
    end
  
    local function mod_onclose(inst, ...)
        onclosefn(inst, ...)
      local player = GetPlayer()
      if player and player.HUD and player.HUD.controls and player.HUD.controls.foodcrafting and inst then
      player.HUD.controls.foodcrafting:Close(inst.inst)
      end
    end
  
    local function mod_onstartcooking(inst, ...)
      -- local doer = inst.components.container.opener
      local recipe = GetPlayer().HUD.controls.foodcrafting:GetProduct()
      if recipe ~= nil and recipe.name then
        GetPlayer().components.knownfoods:IncrementCookCounter(recipe.name)
      end
      onstartcookingfn(inst, ...)
      return items
    end
  
    local function mod_ondonecooking(inst, ...)
      if ondonecookingfn then ondonecookingfn(inst, ...) end
      local foodname = inst.components.stewer.product
      GetPlayer().components.knownfoods:IncrementCookCounter(foodname)
      return items
    end
  
    local function cookerchangefn(inst)
      local player = GetPlayer()
      if player and player.HUD then player.HUD.controls.foodcrafting:SortFoods() end
    end
  
    -- override methods
    inst.Open = mod_onopen
    inst.Close = mod_onclose
    if onstartcookingfn then
      inst.widget.buttoninfo.fn = mod_onstartcooking
    else
      inst.inst.components.stewer.ondonecooking = mod_ondonecooking
    end
  
    inst.inst:ListenForEvent("itemget", cookerchangefn)
    inst.inst:ListenForEvent("itemlose", cookerchangefn)
    --GetPlayer():ListenForEvent( "itemget", cookerchangefn)
    -- TODO: track itemget of additional open inventories
  end
  
  
  local function FollowCameraPostInit(inst)
    local old_can_control = inst.CanControl
    inst.CanControl = function(inst, ...)
      return old_can_control(inst, ...) and not GetPlayer().HUD.controls.foodcrafting:IsFocused()
    end
  end
  
  -- follow camera modification is required to cancel the scrolling
  AddClassPostConstruct("cameras/followcamera", FollowCameraPostInit)
  
  -- first block is used for DST clients, second - for DS/DST Host
  if IsClientSim() then
    AddClassPostConstruct("components/container_replica",  ContainerPostConstruct)
  else
    local function PrefabPostInitAny(inst)
      if inst.components.stewer then
        ContainerPostConstruct(inst.components.container)
      end
    end
    -- sadly we have to try every prefab ingame, since we just can't bind events onto postinit of stewer.host prefab
    AddPrefabPostInitAny(PrefabPostInitAny)
  end
  
  AddClassPostConstruct("screens/playerhud", function(inst)
    if TheInput:ControllerAttached() then
      --local old_open_controller_inventory = inst.OpenControllerInventory
      --[[inst.OpenControllerInventory = function(self)
        if not inst.controls.foodcrafting:IsOpen() then
          old_open_controller_inventory(self)
        end
      end]]
  
      local old_on_control = inst.OnControl
      inst.OnControl = function(self, control, down, ...)
        old_on_control(self, control, down, ...)
        if inst.controls.foodcrafting:IsOpen() then
          inst.controls.foodcrafting:OnControl(control, down)
        end
      end
    end
  
  end)
  
  AddClassPostConstruct("widgets/inventorybar", function(inst)
    if TheInput:ControllerAttached() then
      local actions = {
        CursorUp=   {GLOBAL.CONTROL_INVENTORY_UP, GLOBAL.CONTROL_MOVE_UP},
        CursorDown= {GLOBAL.CONTROL_INVENTORY_DOWN, GLOBAL.CONTROL_MOVE_DOWN},
        CursorLeft= {GLOBAL.CONTROL_INVENTORY_LEFT, GLOBAL.CONTROL_MOVE_LEFT},
        CursorRight={GLOBAL.CONTROL_INVENTORY_RIGHT, GLOBAL.CONTROL_MOVE_RIGHT}
      }
      for action, controls in pairs(actions) do
        local old_cursor_action = inst[action]
        inst[action] = function(self, ...)
          if not inst.owner.HUD.controls.foodcrafting:IsFocused()
            or TheInput:IsControlPressed(controls[GetModConfigData("invert_controller") and 2 or 1])
          then
            old_cursor_action(self, ...)
          else
            inst.owner.HUD.controls.foodcrafting
              :DoControl(controls[GetModConfigData("invert_controller") and 1 or 2])
          end
        end
      end
    end
  end)
  
  -- these three loads race each other, last one gets to launch OnAfterLoad
  AddSimPostInit(OnSimLoad) -- fires before game init
  AddGamePostInit(OnGameLoad) -- fires last, unless it is first game launch in DS, then it fires first
  AddPlayerPostInit(OnPlayerLoad) -- fire last in DST, but first in DS, i think
  AddClassPostConstruct("widgets/controls", ControlsPostInit)
  
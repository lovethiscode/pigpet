local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"

local CookBookItem = Class(Widget, function(self, cookbook, ingredient,  x, y, scale)
    Widget._ctor(self, "CookBookItem")
    self.ingredient = ingredient
    self.cookbook = cookbook
    --背景
    self.bg = self:AddChild(Image("images/recipe_hud.xml", "recipe_hud.tex"))
    self.bg:SetPosition(x, y)
    self.bg:SetScale(scale * 0.5)
    --内容
    self.contents = self.bg:AddChild(Widget(""))
    self.contents:SetPosition(20,120,0)

    --名字
    self.name = self.contents:AddChild(Text(UIFONT, 42))
    self.name:SetPosition(3, 0, 0)
    self.name:SetString(STRINGS.NAMES[string.upper(ingredient.recipe.name)])

    --食物的图片
    self.image = self.contents:AddChild(Image(resolvefilepath("images/inventoryimages.xml"), ingredient.recipe.name .. ".tex"))
    self.image:SetPosition(-90, 0, 0)
   

    --三维
    self.hunger = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.hunger:SetPosition(5,82,0)
    self.hunger:SetString(tostring(ingredient.recipe.hunger))

    self.sanity = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.sanity:SetPosition(-73,54,0)
    self.sanity:SetString(tostring(ingredient.recipe.sanity))

    self.health = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.health:SetPosition(84,54,0)
    self.health:SetString(tostring(ingredient.recipe.health))


    --食材
    local num_ingredients = #ingredient.selectedIngredient
    local ingredient_spacing = 70
    local ingredient_start_x = -((num_ingredients - 1) * ingredient_spacing) / 2
    for i, item in ipairs(ingredient.selectedIngredient) do
        local ingredient_image = self.contents:AddChild(Image(resolvefilepath("images/inventoryimages.xml"), item.inst.prefab .. ".tex"))
        ingredient_image:SetPosition(ingredient_start_x + (i - 1) * ingredient_spacing, -70, 0)
    end

    self.button = self.contents:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
    self.button:SetPosition(0, -280)
    self.button:SetScale(scale)
    self.button:SetText("烹饪")
    self.button:SetFont(BUTTONFONT)
    self.button:SetOnClick(function()
        self:Cook()
    end)
end)

local function FindAvaibleCookpot(guy)
    if guy.prefab == "cookpot" then
        if not guy.components.stewer then
            return
        end
        --判断烹饪锅是否已经完成或者正在烹饪
        if guy.components.stewer:IsDone() or guy.components.stewer.cooking then
            return
        end
        --判断烹饪锅是否有食材
        local number_items = guy.components.container:GetNumSlots()
        --遍历所有的items
        for i = 1, number_items do
            local item = guy.components.container:GetItemInSlot(i)
            if item  then
                return
            end
        end
        return true
    end
end

function CookBookItem:Cook()
     --单机版获取玩家的位置
     local player = GetPlayer()
     local x, y, z = player.Transform:GetWorldPosition()
     --查找玩家附近可用的烹饪锅
     local cookerpot = FindEntity(player, 10, function(guy)
        return FindAvaibleCookpot(guy)
     end)
     if cookerpot == nil then
        --让主角说一句话
        player.components.talker:Say("附近没有烹饪锅或者烹饪锅有食材")
        return
     end
    --将选中的食材放入烹饪锅
    for _, item in ipairs(self.ingredient.selectedIngredient) do
        if item.inst.components.stackable and item.inst.components.stackable.stacksize > 1 then
            --有堆叠多个的时候拿出一个来
            local ingredient = item.inst.components.stackable:Get(1)      
            cookerpot.components.container:GiveItem(ingredient)
        else
            cookerpot.components.container:GiveItem(item.inst)
            player.components.inventory:RemoveItem(item.inst)
        end
    end
    --烹饪
    cookerpot.components.stewer:StartCooking()
    --刷新父容器
    self.cookbook:Refresh()
end

return CookBookItem
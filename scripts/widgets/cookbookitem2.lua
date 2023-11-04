local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"

local CookBookItem2 = Class(Widget, function(self, cookbook, ingredient,  x, y, scale)
    Widget._ctor(self, "CookBookItem2")
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
   
    --显示食物的材料
    local num_ingredients = 4
    local ingredient_spacing = 70
    local ingredient_start_x = -((num_ingredients - 1) * ingredient_spacing) / 2
    for row, items in ipairs(ingredient.ingredients) do
        --遍历items 里面的食材
       for i, item in ipairs(items) do
            local ingredient_image = self.contents:AddChild(Image(resolvefilepath("images/inventoryimages.xml"), item .. ".tex"))
            ingredient_image:SetPosition(ingredient_start_x + (i - 1) * ingredient_spacing, -70 * row, 0)
       end
    end

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
end)

return CookBookItem2
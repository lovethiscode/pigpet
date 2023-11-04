local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"



local CookBookItem = Class(Widget, function(self, index, x, y, scale)
    Widget._ctor(self, "CookBookItem")
    --背景
    self.bg = self:AddChild(Image("images/recipe_hud.xml", "recipe_hud.tex"))
    self.bg:SetPosition(x, y)
    self.bg:SetScale(scale * 0.5)
    --名字
    self.contents = self.bg:AddChild(Widget(""))
    self.contents:SetPosition(20,120,0)

    self.name = self.contents:AddChild(Text(UIFONT, 42))
    self.name:SetPosition(3, 0, 0)
    self.name:SetString(tostring(index))

    self.hunger = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.hunger:SetPosition(5,82,0)
    self.hunger:SetString("10")

    self.sanity = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.sanity:SetPosition(-73,54,0)
    self.sanity:SetString("20")

    self.health = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.health:SetPosition(84,54,0)
    self.health:SetString("30")

    self.button = self.contents:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
    self.button:SetPosition(0, -280)
    self.button:SetScale(scale)
    self.button:SetText("烹饪")
    self.button:SetFont(BUTTONFONT)
    self.button:SetOnClick(function()
        print("点击了我：" .. tostring(index))
    end)
end)

return CookBookItem
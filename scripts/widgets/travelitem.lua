local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local TravelItem = Class(Widget, function(self, homesign, isCurrent, traveller, screen)
    Widget._ctor(self, "TravelItem")
    self.homesign = homesign
    self.traveller = traveller
    self.screen = screen
    --添加一个背景
    self.bg = self:AddChild(UIAnim())
    self.bg:GetAnimState():SetBuild("savetile")
    self.bg:GetAnimState():SetBank("savetile")
    self.bg:GetAnimState():PlayAnimation("anim")
    self.bg:SetScale(1, 0.8, 1)



    self.name = self.bg:AddChild(TextEdit(BODYTEXTFONT, 35))
    self.name:SetVAlign(ANCHOR_MIDDLE)
    self.name:SetHAlign(ANCHOR_LEFT)
    self.name:SetPosition(0, 10, 0)
    self.name:SetRegionSize(300, 40)

    self.name:SetString(homesign.components.travelable.name)
    if isCurrent then
        self.name:SetColour(0, 1, 0, 0.4)
    else
         --添加一个传送按钮
        self.go = self.bg:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
        self.go:SetPosition(220, 0)
        self.go:SetText("传送")
        self.go:SetFont(BUTTONFONT)
        self.go:SetOnClick(function()
            self:Go()
        end)
    end

    --添加一个编辑按钮
    self.button = self.bg:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
    self.button:SetPosition(-220, 0)
    self.button:SetText("编辑")
    self.button:SetFont(BUTTONFONT)
    self.button:SetOnClick(function()
        self:Edit()
    end)
end)

function TravelItem:Edit() 
    local text = self.name:GetLineEditString()
    --如果文本和原来的不一样
    if text ~= self.homesign.components.travelable.name then
        self.homesign.components.travelable.name = text
    end
end


function TravelItem:Go()
    self.homesign.components.travelable:DoTravel(self.traveller)
    self.screen:OnCancel()
end

return TravelItem
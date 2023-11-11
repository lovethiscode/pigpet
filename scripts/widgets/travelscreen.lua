
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local TravelItem = require "widgets/travelitem"

local TravelScreen = Class(Screen, function(self, homesign, traveller)
    Screen._ctor(self, "TravelScreen")
    self.homesign = homesign
    self.traveller = traveller
    SetPause(true, "TravelScreen")

    --画一个背景
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --添加一个背景
    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "panel.tex"))
    self.bg:SetSize(500, 650)
    self.bg:SetPosition(0, 25)

    --添加一个当前标题
    self.current = self.root:AddChild(Text(BODYTEXTFONT, 35))
    self.current:SetPosition(0, 225, 0)
    self.current:SetRegionSize(350, 50)
    self.current:SetHAlign(ANCHOR_MIDDLE)
    self.current:SetString(self.homesign.components.travelable.name)


    --添加一个menu，用来显示修改和取消按钮
    self.menu = self.root:AddChild(Menu(nil, 200, true))
    self.menu:SetScale(0.6)
    self.menu:SetPosition(0, -225, 0)
    self.cancelbutton = self.menu:AddItem("关闭", function()
                                            self:OnCancel()
                                        end)


    --放两个按钮，翻页
    self.upbutton = self.root:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.upbutton:SetPosition(180, 200, 0)
    self.upbutton:SetRotation(-90)
    self.upbutton:SetScale(0.5)
    self.upbutton:SetOnClick(
        function()
            self:ScrollUp()
        end
    )

    self.downbutton = self.root:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.downbutton:SetPosition(180, -200, 0)
    self.downbutton:SetRotation(90)
    self.downbutton:SetScale(0.5)
    self.downbutton:SetOnClick(
        function()
            self:ScrollDown()
        end
    )


    self.menu:SetHRegPoint(ANCHOR_MIDDLE)
    self.travelitems = self.root:AddChild(Widget("ROOT"))
    self.travelitems:SetPosition(-100, 0)
    self.travelitems:SetScale(0.8)
    self.currentRow = 1
    self:LoadTravelItems(self.currentRow)
end)


function TravelScreen:ScrollUp()
    if self.currentRow >= 5 then
        self.currentRow = self.currentRow - 5
        self:LoadTravelItems(self.currentRow)
    end
end

function TravelScreen:ScrollDown()
    if self.currentRow <= #Pigpet.homesigns - 5 then
        self.currentRow = self.currentRow + 5
        self:LoadTravelItems(self.currentRow)
    end
end


function TravelScreen:LoadTravelItems(index)
    self.travelitems:KillAllChildren()
    --从 index 开始遍历， 只显示5个
    local num_items = 0
    for i = index, #Pigpet.homesigns do
        if num_items >= 5 then
            break
        end
        local v = Pigpet.homesigns[i]
        local isCurrent = v == self.homesign
        local item = self.travelitems:AddChild(TravelItem(v, isCurrent, self.traveller, self))
        item:SetPosition(120, 200 - num_items * 100, 0)
        num_items = num_items + 1
    end
end


function TravelScreen:OnCancel()
    SetPause(false)
    TheFrontEnd:PopScreen(self)
end

return TravelScreen
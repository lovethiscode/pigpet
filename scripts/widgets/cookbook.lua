local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local CookBookItem = require "widgets/cookbookitem"
local autoCook = require "autocook"

local showMaxRow = 3
local cookbookitemHeight = 180

local CookBook = Class(Screen, function(self, inst)
    self.inst = inst
    self.currentRow = 0
    self.totalRow = 0
    Screen._ctor(self, "CookBook")
    --画一个背景
    self.background = self:AddChild(Image("images/global.xml", "square.tex"))
    self.background:SetVRegPoint(ANCHOR_MIDDLE)
    self.background:SetHRegPoint(ANCHOR_MIDDLE)
    self.background:SetVAnchor(ANCHOR_MIDDLE)
    self.background:SetHAnchor(ANCHOR_MIDDLE)
    self.background:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.background:SetTint(0, 0, 0, .3)
    --添加一个根节点
    self.proot = self:AddChild(Widget("root"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    -- 20 'pixels' to the right - This scales with the window size
    self.proot:SetPosition(20, 0, 0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.title = self.proot:AddChild(Text(DEFAULTFONT, 40, "可烹饪的食物"))
    self.title:SetPosition(0, 300)

    --放置可烹饪的食物
    self.disasters = self.proot:AddChild(Widget("ROOT"))
    self.disasters:SetPosition(-100, 0)

    self:Refresh()
    self:SetupUpDownButton()
  end)
  
  function CookBook:SetupUpDownButton()
    self.downbutton = self.proot:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
    self.downbutton:SetPosition(0, -250)
    self.downbutton:SetScale(0.5)

    self.upbutton = self.proot:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
    self.upbutton:SetPosition(0, 250)
    self.upbutton:SetScale(0.5)
    self.upbutton:SetRotation(180)


    self.downbutton:SetOnClick(function() self:ScrollDown() end)
    self.upbutton:SetOnClick(function() self:ScrollUp() end)
end


function CookBook:ScrollDown()
  --判断是否可以向下移动,当前的行数 + 3 <= 总行数
  if self.currentRow + showMaxRow <= self.totalRow then
    self.currentRow = self.currentRow + 1
    local x, y = self.disasters:GetPosition():Get() 
    self.disasters:SetPosition(x, y + cookbookitemHeight)
  end
end


function CookBook:ScrollUp()
  --判断是否可以向上移动,当前的行数 - 1 > 0
  if self.currentRow - 1 > 0 then
    self.currentRow = self.currentRow - 1
    local x, y = self.disasters:GetPosition():Get()  
    self.disasters:SetPosition(x, y - cookbookitemHeight)
  end
end

function CookBook:Close()
  local screen = TheFrontEnd:GetActiveScreen()
  -- Don't pop the HUD
  if screen and screen.name:find("HUD") == nil then
    -- Remove our screen
    TheFrontEnd:PopScreen()
  end
  --关闭的时候播放个声音
  TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
end

function CookBook:Refresh()
  --先移除 cookbookitems
  if self.cookbookitems then
    for _, v in ipairs(self.cookbookitems) do
      v:Kill()
    end
  end

  --刷新
  local productResult = autoCook.GetCookFood()
  self.cookbookitems = {}
  self.currentRow = 1
  self.totalRow = 1
  local column = 1
  
  local hasFood = false
  for k, v in pairs(productResult) do
    table.insert(self.cookbookitems, self.disasters:AddChild(CookBookItem(self, v , (column - 3) * cookbookitemHeight, (2 - self.totalRow) * cookbookitemHeight, 0.8)))
    column = column + 1
    if column > 6 then
      column = 1
      self.totalRow = self.totalRow + 1
    end
    hasFood = true
  end
  if not hasFood then
    self.title:SetString("没有可烹饪的食物")
  end
end

return CookBook
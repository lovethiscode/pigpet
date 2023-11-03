local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local CookBook = Class(Screen, function(self, inst)
    self.inst = inst
    Screen._ctor(self, "cookbook")
    --画一个背景
    self.background = self:AddChild(Image("images/global.xml", "square.tex"))
    self.background:SetVRegPoint(ANCHOR_MIDDLE)
    self.background:SetHRegPoint(ANCHOR_MIDDLE)
    self.background:SetVAnchor(ANCHOR_MIDDLE)
    self.background:SetHAnchor(ANCHOR_MIDDLE)
    --全屏缩放模式 
    self.background:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.background:SetTint(0, 0, 0, .5)
    --添加一个根节点
    self.proot = self:AddChild(Widget("root"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    -- 20 'pixels' to the right - This scales with the window size
    self.proot:SetPosition(20, 0, 0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.title = self.proot:AddChild(Text(DEFAULTFONT, 40, "烹饪书"))
    self.title:SetPosition(0, 250)

  end)
  
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

return CookBook
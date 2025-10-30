-- 优化并注释版：CookbookScreen（食谱界面）
-- 目的：
--   - 清晰展示玩家当前可烹饪的菜品（来源：自动烹饪模块）
--   - 支持翻页/滚动与关闭操作
-- 说明：
--   - 将原来的 CookBook 类重命名为 CookbookScreen（语义更明确）
--   - 将若干函数重命名为更具语义的名字（例如 Refresh -> RefreshItems, SetupUpDownButton -> SetupNavigationButtons）
--   - 保持对外接口与原逻辑一致（只改名和注释），便于维护
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local CookBookItem = require "widgets/cookbookitem" -- 保持现有 widget 路径
local autoCook = require "widgets/autocook"         -- 自动烹饪工具，提供可烹饪项

-- 可视化常量，便于调整布局与行为
local VISIBLE_ROWS = 3           -- 每次可见的行数
local ITEM_HEIGHT = 180          -- 单个 cookbook item 的纵向高度（像素）

-- CookbookScreen: 主界面类
local CookbookScreen = Class(Screen, function(self)
    Screen._ctor(self, "CookbookScreen")
    -- 当前已滚动到的行索引（1 开始）
    self.current_row = 1
    -- 总行数（根据内容动态计算）
    self.total_rows = 1

    -- 半透明背景，覆盖全屏
    self.background = self:AddChild(Image("images/global.xml", "square.tex"))
    self.background:SetVRegPoint(ANCHOR_MIDDLE)
    self.background:SetHRegPoint(ANCHOR_MIDDLE)
    self.background:SetVAnchor(ANCHOR_MIDDLE)
    self.background:SetHAnchor(ANCHOR_MIDDLE)
    self.background:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.background:SetTint(0, 0, 0, .3)

    -- 根节点：所有内容挂载在此，便于整体移动/缩放
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    -- 将内容整体右移 20 像素（响应窗口缩放）
    self.root:SetPosition(20, 0, 0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- 标题文本
    self.title = self.root:AddChild(Text(DEFAULTFONT, 40, "可烹饪的食物"))
    self.title:SetPosition(0, 300)

    -- 列表容器：所有 CookBookItem 会被加入到这里
    self.list_root = self.root:AddChild(Widget("list_root"))
    self.list_root:SetPosition(-100, 0)

    -- 初始化内容并创建控制按钮
    self:RefreshItems()
    self:SetupNavigationButtons()
    self:SetupCloseButton()
end)

-- SetupCloseButton: 创建并绑定“关闭”按钮
function CookbookScreen:SetupCloseButton()
    self.close_btn = self.root:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
    self.close_btn:SetPosition(0, 0)
    self.close_btn:SetText("关闭")
    self.close_btn:SetScale(0.75)
    self.close_btn:SetFont(BUTTONFONT)
    self.close_btn:SetOnClick(function()
        self:OnClose()
    end)
end

-- SetupNavigationButtons: 创建上下滚动按钮并绑定回调
function CookbookScreen:SetupNavigationButtons()
    -- 向下翻页（展示更后面的行）
    self.down_button = self.root:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
    self.down_button:SetPosition(0, -250)
    self.down_button:SetScale(0.5)
    self.down_button:SetOnClick(function() self:ScrollDown() end)

    -- 向上翻页（展示前面的行）
    self.up_button = self.root:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
    self.up_button:SetPosition(0, 250)
    self.up_button:SetScale(0.5)
    self.up_button:SetRotation(180)
    self.up_button:SetOnClick(function() self:ScrollUp() end)
end

-- ScrollDown: 向下滚动一行（若存在更多行）
function CookbookScreen:ScrollDown()
    -- 只有当还能下移（当前行 + 可视行数 <= 总行数）时才允许
    if self.current_row + VISIBLE_ROWS <= self.total_rows then
        self.current_row = self.current_row + 1
        local x, y = self.list_root:GetPosition():Get()
        self.list_root:SetPosition(x, y + ITEM_HEIGHT)
    end
end

-- ScrollUp: 向上滚动一行（若不是第一行）
function CookbookScreen:ScrollUp()
    if self.current_row - 1 > 0 then
        self.current_row = self.current_row - 1
        local x, y = self.list_root:GetPosition():Get()
        self.list_root:SetPosition(x, y - ITEM_HEIGHT)
    end
end

-- OnClose: 统一处理关闭界面逻辑（播放声音、关闭界面）
function CookbookScreen:OnClose()
    -- 只在不是 HUD 层时弹出（与原逻辑保持一致）
    local screen = TheFrontEnd:GetActiveScreen()
    if screen and screen.name:find("HUD") == nil then
        TheFrontEnd:PopScreen()
    end
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
end

-- RefreshItems: 重新读取自动烹饪模块提供的可烹饪项并展示
-- 主要流程：
--   1) 清理上次创建的 CookBookItem（Kill）
--   2) 获取 autoCook.GetAvailableInventoryCookpotRecipes() 返回结果
--   3) 按网格布局创建新的 CookBookItem 并加入 list_root
function CookbookScreen:RefreshItems()
    -- 清理旧的 item（如果有）
    if self.cookbook_items then
        for _, v in ipairs(self.cookbook_items) do
            v:Kill()
        end
    end

    -- 从自动烹饪模块获取可做菜品（结构：product -> cooktable）
    local product_result = autoCook.GetAvailableInventoryCookpotRecipes()
    self.cookbook_items = {}
    self.current_row = 1
    self.total_rows = 1
    local column = 1
    local has_any = false

    -- 遍历 product_result，按多列布局创建 CookBookItem
    for _, v in pairs(product_result) do
        -- 计算位置：横向以 ITEM_HEIGHT 为间隔，纵向以 total_rows 累进
        local x = (column - 3) * ITEM_HEIGHT
        local y = (2 - self.total_rows) * ITEM_HEIGHT
        table.insert(self.cookbook_items, self.list_root:AddChild(CookBookItem(self, v, x, y, 0.8)))

        column = column + 1
        if column > 6 then
            column = 1
            self.total_rows = self.total_rows + 1
        end
        has_any = true
    end

    if not has_any then
        self.title:SetString("没有可烹饪的食物")
    else
        self.title:SetString("可烹饪的食物")
    end
end

return CookbookScreen
local cooking = require("cooking")
local SELECTED_COUNT = 4

function create_node(inst, count)
    return {
        inst = inst,
        count = count
    }
end

--判断是否可以烹饪出食物
function CanCookFood(selectedIngredient)
    if #selectedIngredient ~= SELECTED_COUNT then
        return false
    end
    local ings = {}			
    for _, item in ipairs(selectedIngredient) do
      table.insert(ings, item.inst.prefab)
    end
    return cooking.CalculateRecipe("cookpot", ings)
end

function SaveCookProduct(selectedIngredient, product, cooktime, productResult)
  if not productResult[product] then
    local cooktable = {}
    cooktable.selectedIngredient = {}
    --拷贝一份selectedIngredient
    for _, item in ipairs(selectedIngredient) do
      table.insert(cooktable.selectedIngredient, item)
    end

    cooktable.cooktime = cooktime
    productResult[product] = cooktable
  end
end

function FindCookIngredient(selectedIngredient, start, n, nodes, productResult)
    local product, cooktime = CanCookFood(selectedIngredient) 
    if product and product ~= "wetgoopnil" and product ~= "wetgoop" then
        SaveCookProduct(selectedIngredient, product, cooktime, productResult)
    end
    if n == 0 or start > #nodes then
        return
    end

    for i = start, #nodes do
        if nodes[i].count > 0 then
            table.insert(selectedIngredient, nodes[i])
            nodes[i].count = nodes[i].count - 1
            FindCookIngredient(selectedIngredient, i, n - 1, nodes, productResult)
            table.remove(selectedIngredient)
            nodes[i].count = nodes[i].count + 1
        end

        FindCookIngredient(selectedIngredient, i + 1, n, nodes, productResult)
    end
end

local function CollectIngredient(container, result)
  for i = 1, container:GetNumSlots() do
    local item = container:GetItemInSlot(i)
    --判断是否是食材
    if item and cooking.IsCookingIngredient(item.prefab) then
      local count = 1
      if item.components.stackable then
        count = item.components.stackable:StackSize()
      end
      if count > SELECTED_COUNT then
        count = SELECTED_COUNT  
      end
      table.insert(result, create_node(item, count))
    end
  end
end

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

local function AutoCook()
     --单机版获取玩家的位置
     local player = GetPlayer()
     local x, y, z = player.Transform:GetWorldPosition()
     --查找玩家附近可用的烹饪锅
     local cookerpot = FindEntity(player, 10, function(guy)
        return FindAvaibleCookpot(guy)
     end)
     if cookerpot == nil then
        --让主角说一句话
        --player.components.talker:Say("附近没有烹饪锅或者烹饪锅有食材")
        --return
     end
    local Ingredients = {}
    --收集角色的食材
    CollectIngredient(player.components.inventory, Ingredients)
    --收集猪猪宠物的背包的食材
    local followers = player.components.leader.followers;
    for k,v in pairs(followers) do
        if k.prefab == "pigpet" then
          CollectIngredient(k.components.container, Ingredients)
          break
        end
    end

    local productResult = {}
    FindCookIngredient({}, 1, SELECTED_COUNT, Ingredients, productResult)
    --打印出 productResult 内容
    local hasProduct = false
    for k, v in pairs(productResult) do
        hasProduct = true
        for _, item in ipairs(v.selectedIngredient) do
          --info = info .. tostring(item.inst.prefab) .. " "
        end
    end
    if not hasProduct then
      player.components.talker:Say("没有可以烹饪的食材")
    end
end


return AutoCook
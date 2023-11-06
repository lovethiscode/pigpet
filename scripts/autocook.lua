local cooking = require("cooking")
local SELECTED_COUNT = 4

local function create_node(inst, count)
    return {
        inst = inst,
        count = count
    }
end

--判断是否可以烹饪出食物
local function CanCookFood(selectedIngredient)
    if #selectedIngredient ~= SELECTED_COUNT then
        return false
    end
    local ings = {}			
    for _, item in ipairs(selectedIngredient) do
      table.insert(ings, item.inst.prefab)
    end
    return cooking.CalculateRecipe("cookpot", ings)
end

local function SaveCookProduct(selectedIngredient, product, cooktime, productResult)
  if not productResult[product] then
    local cooktable = {}
    cooktable.selectedIngredient = {}
    --拷贝一份selectedIngredient
    for _, item in ipairs(selectedIngredient) do
      table.insert(cooktable.selectedIngredient, item)
    end

    cooktable.cooktime = cooktime
    cooktable.recipe = cooking.recipes["cookpot"][product]
    productResult[product] = cooktable
  end
end

local function FindCookIngredient(selectedIngredient, start, n, nodes, productResult)
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

local function GetCookFood()
    local player = GetPlayer()
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
    return productResult
end

--枚举所有的食谱
local function CanCookFood2(selectedIngredient)
  if #selectedIngredient ~= SELECTED_COUNT then
      return false
  end
  
  return cooking.CalculateRecipe("cookpot", selectedIngredient)
end

local function SaveCookProduct2(selectedIngredient, product, cooktime, productResult)
  if not productResult[product] then
    productResult[product] = {}
    productResult[product].cooktime = cooktime
    productResult[product].recipe = cooking.recipes["cookpot"][product]
    productResult[product].ingredients = {}
  end

  local cooktable = {}
  --拷贝一份selectedIngredient
  for _, item in ipairs(selectedIngredient) do
    table.insert(cooktable, item)
  end

  table.insert(productResult[product].ingredients, cooktable)
end

local function FindCookIngredient2(selectedIngredient, start, n, nodes, productResult)
  local product, cooktime = CanCookFood2(selectedIngredient) 
  if product and product ~= "wetgoopnil" and product ~= "wetgoop" then
      SaveCookProduct2(selectedIngredient, product, cooktime, productResult)
  end
  if n == 0 or start > #nodes then
      return
  end

  for i = start, #nodes do
      table.insert(selectedIngredient, nodes[i])
      FindCookIngredient2(selectedIngredient, i, n - 1, nodes, productResult)
      table.remove(selectedIngredient)
  end
end

local function GetCookbook2()
  local ingredients = {}
  for name, _ in pairs(cooking.ingredients) do
    --放入到食材列表中
    table.insert(ingredients, name)
    if #ingredients >= 20 then
      break
    end
  end
  print("ingredients count:" .. #ingredients)
  local productResult = {}
  FindCookIngredient2({}, 1, SELECTED_COUNT, ingredients, productResult)
  return productResult
end

return {GetCookFood = GetCookFood, GetCookbook2 = GetCookbook2}
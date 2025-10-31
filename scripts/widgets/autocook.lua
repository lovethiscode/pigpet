local cooking = require("cooking")
local selected_count = 4
local can_cook_cache = {}

local function MakeIngredientNode(inst, count)
    return {
        inst = inst,
        count = count
    }
end

-- 根据 selectedIngredient（节点数组）计算配方产物与烹饪时间，带缓存
local function CalculateRecipeForSelectedNodes(selected_ingredient)
    if #selected_ingredient ~= selected_count then
        return false
    end
    local ings_list = {}
    for _, item in ipairs(selected_ingredient) do
        table.insert(ings_list, item.inst.prefab)
    end
    local key = table.concat(ings_list, ",")
    if can_cook_cache[key] then
        local cache = can_cook_cache[key]
        return cache.product, cache.cooktime
    end
    local product, cooktime = cooking.CalculateRecipe("cookpot", ings_list)
    local cache = { product = product, cooktime = cooktime }
    can_cook_cache[key] = cache
    return product, cooktime
end

-- 保存从玩家背包组合中首次发现的某道菜（只保存代表性一个组合）
local function SaveInventoryRecipeResult(selected_ingredient, product, cooktime, product_result)
    if not product_result[product] then
        local cook_table = {}
        cook_table.selectedIngredient = {}
        for _, item in ipairs(selected_ingredient) do
            table.insert(cook_table.selectedIngredient, item)
        end
        cook_table.cooktime = cooktime
        cook_table.recipe = cooking.recipes["cookpot"][product]
        product_result[product] = cook_table
    end
end

-- 递归枚举玩家背包（nodes 为 {inst,count} 节点）中所有可能的组合（考虑堆叠数量）
local function EnumerateInventoryRecipeCombinations(selected_ingredient, start_index, n, nodes, product_result)
    local product, cooktime = CalculateRecipeForSelectedNodes(selected_ingredient)
    if product and product ~= "wetgoopnil" and product ~= "wetgoop" then
        SaveInventoryRecipeResult(selected_ingredient, product, cooktime, product_result)
    end
    if n == 0 or start_index > #nodes then
        return
    end

    for i = start_index, #nodes do
        if nodes[i].count > 0 then
            table.insert(selected_ingredient, nodes[i])
            nodes[i].count = nodes[i].count - 1
            EnumerateInventoryRecipeCombinations(selected_ingredient, i, n - 1, nodes, product_result)
            table.remove(selected_ingredient)
            nodes[i].count = nodes[i].count + 1
        end
    end

    EnumerateInventoryRecipeCombinations(selected_ingredient, start_index + 1, n, nodes, product_result)
end

-- 从容器收集可用的烹饪原料（转换为节点并截断到 selected_count）
local function CollectContainerIngredients(container, result_list)
    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item and cooking.IsCookingIngredient(item.prefab) then
            local count = 1
            if item.components.stackable then
                count = item.components.stackable:StackSize()
            end
            if count > selected_count then
                count = selected_count
            end
            table.insert(result_list, MakeIngredientNode(item, count))
        end
    end
end

-- 对外 API：获取玩家当前背包/装备中可在 cookpot 下锅制作的菜品（考虑物品数量）
local function GetAvailableInventoryCookpotRecipes()
    local player = GetPlayer()
    local ingredients_list = {}
    CollectContainerIngredients(player.components.inventory, ingredients_list)
    local back_item = player.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK)
    if back_item and back_item.components and back_item.components.container then
        CollectContainerIngredients(back_item.components.container, ingredients_list)
    end

    local product_result = {}
    EnumerateInventoryRecipeCombinations({}, 1, selected_count, ingredients_list, product_result)
    return product_result
end

local function GenerateCookbookRecipes()
  local ingredients = {}
  for name, _ in pairs(cooking.ingredients) do
    --放入到食材列表中
    table.insert(ingredients, name)
    if #ingredients >= 20 then
      break
    end
  end
  print("ingredients count:" .. #ingredients)
  local product_result = {}
  return product_result
end

-- 对外导出：保留兼容的函数名
return { GetAvailableInventoryCookpotRecipes = GetAvailableInventoryCookpotRecipes}
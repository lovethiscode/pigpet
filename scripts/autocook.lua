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
    cooktable.recipe = cooking.recipes["cookpot"][product]
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

local function GetCanCook()
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


return GetCanCook
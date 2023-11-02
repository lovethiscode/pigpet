local cooking = require("cooking")
local SELECTED_COUNT = 4

function create_node(inst, count)
    return {
        inst = inst,
        count = count
    }
end

--判断是否可以烹饪出食物
function is_ok(selected_nodes)
    if #selected_nodes ~= SELECTED_COUNT then
        return false
    end
    local ings = {}			
    for _, item in ipairs(selected_nodes) do
      table.insert(ings, item.prefab)
    end
   
    return cooking.CalculateRecipe("cookpot", ings)
end

function print_selected_nodes(selected_nodes, product, cooktime, printed_combinations)
  if not printed_combinations[product.prefab] then
    local cooktable = {}
    cooktable.selected_nodes = selected_nodes
    cooktable.cooktime = cooktime
    printed_combinations[product.prefab] = cooktable
  end
end

function find_combinations(selected_nodes, start, n, nodes, printed_combinations)
    local product, cooktime = is_ok(selected_nodes) 
    if product then
        print_selected_nodes(selected_nodes, product, cooktime, printed_combinations)
    end

    if n == 0 or start > #nodes then
        return
    end

    for i = start, #nodes do
        if nodes[i].count > 0 then
            table.insert(selected_nodes, nodes[i])
            nodes[i].count = nodes[i].count - 1
            find_combinations(selected_nodes, i, n - 1, nodes, printed_combinations)
            table.remove(selected_nodes)
            nodes[i].count = nodes[i].count + 1
        end

        find_combinations(selected_nodes, i + 1, n, nodes, printed_combinations)
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


local function AutoCook()
     --单机版获取玩家的位置
     local player = GetPlayer()
     local x, y, z = player.Transform:GetWorldPosition()
     --查找玩家附近可用的烹饪锅
     local cookerpot = FindEntity(player, 10, function(guy)
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
     end)
     if cookerpot == nil then
        --让主角说一句话
        player.components.talker:Say("附近没有烹饪锅或者烹饪锅有食材")
        return
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
    --打印出 Ingredients 内容
    --[[for k, v in pairs(Ingredients) do
        print("食材名称：" .. v.inst.prefab)
        print("食材数量：" .. v.count)
    end--]]


    local printed_combinations = {}
    print("start")
    find_combinations({}, 1, SELECTED_COUNT, Ingredients, printed_combinations)
    print("end")
    --判断 printed_combinations 是否有内容
    if next(printed_combinations) == nil then
        player.components.talker:Say("没有可以烹饪的食物")
        return
    end
    --打印出 printed_combinations 内容
    for k, v in pairs(printed_combinations) do
        print("食物名称：" .. k)
        print("烹饪时间：" .. v.cooktime)
        print("食材：")
        for _, item in ipairs(v.selected_nodes) do
            print(item.inst.prefab)
        end
    end

    --[[
    local ings = {}			
			for k,v in pairs (self.inst.components.container.slots) do
				table.insert(ings, v.prefab)
				if v.components.perishable then
					spoilage_n = spoilage_n + 1
					spoilage_total = spoilage_total + v.components.perishable:GetPercent()
				end
			end    
    local cooktime = 1
		self.product, cooktime = cooking.CalculateRecipe(self.inst.prefab, ings)
	]]
end


return AutoCook
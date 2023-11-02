local cooking = require("cooking")

SELECTED_COUNT = 4

function create_node(name, count, value)
    return {
        name = name,
        count = count,
        value = value
    }
end

printed_combinations = {}

function is_ok(selected_nodes)
    if #selected_nodes ~= SELECTED_COUNT then
        return false
    end
    local sum = 0
    for _, item in ipairs(selected_nodes) do
        sum = sum + item.value
    end
    if sum >= 3 then
        return true
    end
    return false
end

function print_selected_nodes(selected_nodes)
    local combination = ""
    local sum = 0
    for _, node in ipairs(selected_nodes) do
        combination = combination .. node.name
        sum = sum + node.value
    end

    if not printed_combinations[combination] then
        print("Selected nodes: " .. combination .. " = " .. sum)
        printed_combinations[combination] = true
    end
end
function find_combinations(selected_nodes, start, n, nodes)
    if is_ok(selected_nodes) then
        print_selected_nodes(selected_nodes)
    end

    if n == 0 or start > #nodes then
        return
    end

    for i = start, #nodes do
        if nodes[i].count > 0 then
            table.insert(selected_nodes, nodes[i])
            nodes[i].count = nodes[i].count - 1
            find_combinations(selected_nodes, i, n - 1, nodes)
            table.remove(selected_nodes)
            nodes[i].count = nodes[i].count + 1
        end

        find_combinations(selected_nodes, i + 1, n, nodes)
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
                print("1")
                return
            end
            --判断烹饪锅是否已经完成或者正在烹饪
            if guy.components.stewer:IsDone() or guy.components.stewer.cooking then
                
                print("3")
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
     
     printed_combinations = {}
  
        
    local nodes = {
      create_node("A", 1, 0.5),
      create_node("B", 2, 1.0),
      create_node("C", 3, 0.9),
      create_node("D", 4, 0.8),
      create_node("E", 5, 0.5)
    }

    find_combinations({}, 1, SELECTED_COUNT, nodes)


     if cookerpot == nil then
        --让主角说一句话
        player.components.talker:Say("附近没有烹饪锅或者烹饪锅有食材")
        return
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
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
     if cookerpot == nil then
        --让主角说一句话
        player.components.talker:Say("附近没有烹饪锅或者烹饪锅有食材")
        return
     end

end


return AutoCook
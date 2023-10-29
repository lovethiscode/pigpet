
GLOBAL.require("language-cn")

local round2 =function(num, idp)
	return GLOBAL.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

AddClassPostConstruct("widgets/hoverer",function(self)
	local old_SetString = self.text.SetString
	self.text.SetString = function(text,str)
		local target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
		if target   then
			if target.prefab then
			    str = str .. "\n代码: " .. target.prefab
			end
			if target.components then
				--生物血量
				if target.components.health then
					str = str.."\n"..math.ceil(target.components.health.currenthealth*10)/10 .."/"..math.ceil(target.components.health.maxhealth*10)/10
				end
				--生物攻击力
				if target.components.combat and target.components.combat.defaultdamage > 0 then
					str = str.."\n攻击力: "..target.components.combat.defaultdamage
				end
				--驯养皮弗娄牛
				if target.components.domesticatable ~= nil then
					if target.components.domesticatable.GetDomestication and target.components.domesticatable.GetObedience ~= nil then
						local hunger = target.components.hunger.current
						local obedience = target.components.domesticatable:GetObedience()
						local domestication = target.components.domesticatable:GetDomestication()
						if domestication ~= 0 then
							str = str.."\n饥饿: "..round2(hunger).."\n顺从: "..round2(obedience*100,0).."%".."\n驯服: "..round2(domestication*100,0).."%"
						end
					end
				end
				--距离成长时间：树枝、草、浆果、咖啡树
				if target.components.pickable and target.components.pickable.targettime then
					str = str .."\n距离成长: " .. tostring(math.ceil((target.components.pickable.targettime - GLOBAL.GetTime())/48)/10) .." 天"
				end
				--距离成长时间：藤蔓、竹林
				if target.components.hackable and target.components.hackable.targettime then
				str = str..GROW..tostring(math.ceil((target.components.hackable.targettime - GLOBAL.GetTime())/48)/10).." 天"
				end
				--树苗
				if target.components.deployable and target.growtime then
					str = str.."\n树苗: "..tostring(math.ceil((target.growtime - GLOBAL.GetTime())/48)/10).." 天"
				end
				--下一阶段：树
				if target.components.growable and target.components.growable.targettime then
					str = str.."\n下一阶段: "..tostring( math.ceil((target.components.growable.targettime - GLOBAL.GetTime())/48)/10).." 天"
				end
				--晾肉架
				if target.components.dryer and target.components.dryer:IsDrying() then
					if target.components.dryer:IsDrying() and target.components.dryer.GetTimeToDry then
						str = str.."\n剩余: "..round2((target.components.dryer:GetTimeToDry()/TUNING.TOTAL_DAY_TIME)+0.1,1).." 天"
					end
				end
				--烹饪
				if target.components.stewer and target.components.stewer:GetTimeToCook() > 0 then
					local tm = math.ceil(target.components.stewer.targettime-GLOBAL.GetTime(),0)
					local cookname = GLOBAL.STRINGS.NAMES[string.upper(target.components.stewer.product)]
					if tm <0 then tm=0 end
					str = str .."\n正在烹饪: "..tostring(cookname).."\n剩余时间(秒): "..tm
				end
				--预测农作物and距离成长时间
				if target.components.crop and target.components.crop.growthpercent then
					if target.components.crop.product_prefab and cropproduct == "yes" then
					str = str.."\n"..(GLOBAL.STRINGS.NAMES[string.upper(target.components.crop.product_prefab)])
				end 
				if target.components.crop.growthpercent < 1 then
					str = str.."\n距离成长: "..math.ceil(target.components.crop.growthpercent*1000)/10 .."%" 
				end	
				end
				--燃料
				if target.components.fueled and not target.components.inventorytarget then
				str = str.."\n燃料: "..math.ceil((target.components.fueled.currentfuel/target.components.fueled.maxfuel)*100) .."%" 
				end
				--忠诚
				if target.components.follower and target.components.follower.maxfollowtime then
					mx = target.components.follower.maxfollowtime
					cur = math.floor(target.components.follower:GetLoyaltyPercent()*mx+0.5)
					if cur>0 then
						str = str.."\n忠诚: "..cur
					end
				end
				--船耐久
				if target.components.boathealth and GetModConfigData("显示船耐久")=="yes"  then
					str = str.."\n船: "..math.ceil(target.components.boathealth.currenthealth).."/"..target.components.boathealth.maxhealth
				end
				--耐久
				if target.components.finiteuses then
					if target.components.finiteuses.consumption then
						local use = 1
						for k,v in pairs(target.components.finiteuses.consumption) do
							use = v
						end
						str = str .."\n耐久: "..math.floor(target.components.finiteuses.current/use+.5).."/"..math.floor(target.components.finiteuses.total/use+.5)
					else
						str = str .."\n耐久: "..target.components.finiteuses.current.."/"..target.components.finiteuses.total 
					end  
				end
				if target.components.workable then
					local action =  target.components.workable:GetWorkAction()
					str = str .."\n动作： ".. tostring(action.id)
				end
			end
		end
		return old_SetString(text,str)
	end
end)

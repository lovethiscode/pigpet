local round2 =function(num, idp)
	return GLOBAL.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
--鼠标悬浮在物品上显示信息
AddClassPostConstruct("widgets/hoverer",function(self)
	local old_SetString = self.text.SetString
	self.text.SetString = function(text,str)
		local target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
		if target   then
			if target.prefab then
			    str = str .. "\n代码: " .. target.prefab
			end
			if target.components.travelable then
				str = str .."\n".. tostring(target.components.travelable.name)
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
			
				if target.prefab == "winterometer" then
					--温度计
					local temp = GLOBAL.GetSeasonManager() and GLOBAL.GetSeasonManager():GetCurrentTemperature() or 30
					local high_temp = TUNING.OVERHEAT_TEMP
					local low_temp = 0
					
					temp = math.min( math.max(low_temp, temp), high_temp)
					
					str = str.."\n温度: ".. tostring(math.floor(temp)) .. "\176C"
				end
				if target.prefab == "pigpet" then
					--判断当前pigpet状态
					if GLOBAL.Pigpet.Status == 0 then
						str = str.."\n状态: 攻击"
					elseif GLOBAL.Pigpet.Status == 1 then
						str = str.."\n状态: 跟随"
					end
				end

				--是否有物品槽
				if target.components.inventory then
					--获取手部物品
					local handitem = target.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
					if handitem then
						--获取手部物品的耐久
						if handitem.components.finiteuses then
							str = str.."\n武器耐久: "..math.floor(handitem.components.finiteuses:GetPercent() *100).."%"
						end
					end
					--获取头部物品
					local headitem = target.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
					if headitem then
						--获取头部物品的防御
						if headitem.components.armor then
							str = str.."\n头部防御: "..headitem.components.armor.absorb_percent*100 .."%"
							--获取头部物品的耐久
							if headitem.components.finiteuses then
								str = str.." 头部耐久: "..math.floor(headitem.components.finiteuses:GetPercent() *100).."%"
							end
						end
					end
					--获取身体部位
					local bodyitem = target.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
					if bodyitem then
						--获取身体部位的防御
						if bodyitem.components.armor then
							str = str.."\n身体防御: "..bodyitem.components.armor.absorb_percent*100 .."%"
							--身体耐久
							if bodyitem.components.finiteuses then
								str = str.." 身体耐久: "..math.floor(bodyitem.components.finiteuses:GetPercent() *100).."%"
							end
						end
					end
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
						for k,v in pairs(target.components.domesticatable.tendencies) do
							local ten = "默认"
							if k == GLOBAL.TENDENCY.ORNERY then
								ten = "战牛"
							elseif k == GLOBAL.TENDENCY.RIDER then
								ten = "行牛"
							elseif k == GLOBAL.TENDENCY.PUDGY then
								ten = "肥牛"
							end
							str = str .. string.format("\n %s:%.2f", ten, v)
						end
					end
				end
				--距离成长时间：树枝、草、浆果、咖啡树
				if target.components.pickable and target.components.pickable.targettime then
					str = str .."\n距离成长: " .. tostring(math.ceil((target.components.pickable.targettime - GLOBAL.GetTime())/48)/10) .." 天"
				end
				--距离成长时间：藤蔓、竹林
				if target.components.hackable and target.components.hackable.targettime then
				str = str.."\n距离成长: "..tostring(math.ceil((target.components.hackable.targettime - GLOBAL.GetTime())/48)/10).." 天"
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
				--经验
				if target.components.growth then
					str = str .. "\n等级：" .. target.components.growth:GetLevel() .. " （经验: "..target.components.growth:GetCurrentExp().."/"..target.components.growth:GetCurrentMaxExp() .. "）"
				end
			end
		end
		return old_SetString(text,str)
	end
end)



--鼠标放在物品栏显示物品详细信息
local round = function(n)
    if not n or type(n) ~= "number" then return "NaN" end
    return math.floor(n + 0.5)
end
local roundsg = function(value) return math.floor(value * 10 + 0.5) / 10 end
local function roundstr(n) return tostring(round(n)) end


local function GetDesc(item)
	if not item then return "" end
	local str = ""
	local ic = item.components
	local tmp = 0
	--显示代码
	if item.prefab then
		str = str .."\n代码: ".. tostring(item.prefab)
	end
	--食物属性：三维回复效果
	if ic.edible then
        local hunger = roundsg(ic.edible:GetHunger(item))
        local health = roundsg(ic.edible:GetHealth(item))
        local sanity = roundsg(ic.edible:GetSanity(item))
		if hunger > 0 then
			hunger = "+" .. tostring(hunger)
		end
		if sanity > 0 then
			sanity = "+" .. tostring(sanity)
		end
		if health > 0 then
		    health = "+" .. tostring(health)
		end
        str = str .."\n饥饿: ".. tostring(hunger) .."/".."精神: "..tostring(sanity) .."/".."生命: ".. tostring(health) 
    end
	--食物价值金块
	if ic.tradable then
		if ic.tradable.goldvalue and ic.tradable.goldvalue > 0 then 
		str = str .."\n价值金块: "..ic.tradable.goldvalue end
	end
	--武器伤害，攻击范围：吹箭
	if ic.weapon then
		str = str .."\n伤害: "..math.ceil(ic.weapon.damage*10)/10
		if ic.weapon.hitrange then 
		    str = str .."\n范围: "..ic.weapon.hitrange 
		end
	end
	--食物距离腐烂时间
	if ic.perishable then
        local owner = ic.inventoryitem and ic.inventoryitem.owner or 0
        local modifier = 1
        if owner then
            if owner:HasTag("fridge") then
                if item:HasTag("frozen") then
                    modifier = TUNING.PERISH_COLD_FROZEN_MULT
                else
                    modifier = TUNING.PERISH_FRIDGE_MULT
                end
            elseif owner:HasTag("spoiler") then
                modifier = TUNING.PERISH_GROUND_MULT
            end
        else
            modifier = TUNING.PERISH_GROUND_MULT
        end
        if GLOBAL.GetSeasonManager() and 0 >
            GLOBAL.GetSeasonManager():GetCurrentTemperature() then
            if item:HasTag("frozen") and not ic.perishable.frozenfiremult then
                modifier = TUNING.PERISH_COLD_FROZEN_MULT
            else
                modifier = modifier * TUNING.PERISH_WINTER_MULT
            end
        end
        if ic.perishable.frozenfiremult then
            modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
        end
        if TUNING.OVERHEAT_TEMP ~= nil and GLOBAL.GetSeasonManager() and
            GLOBAL.GetSeasonManager():GetCurrentTemperature() >
            TUNING.OVERHEAT_TEMP then
            modifier = modifier * TUNING.PERISH_SUMMER_MULT
        end
        modifier = modifier * TUNING.PERISH_GLOBAL_MULT
        local perishremainingtime = math.floor(ic.perishable.perishremainingtime / TUNING.TOTAL_DAY_TIME / modifier *10 + 0.5) / 10
        str = str .."\n距离腐烂: ".. perishremainingtime.." 天"
    end
	--格子内鸟的hp
	if ic.health then
		str = str .."\n"..ic.health.currenthealth.."/"..ic.health.maxhealth
	end
	--回血，比如药膏回血量
	if ic.healer and (ic.healer.health ~= 0) then
		str = str .."\n生命: +"..ic.healer.health
	end
	--穿戴物的防御、耐久度
    if ic.armor then
		str = str.."\n防御: "..ic.armor.absorb_percent*100 .."%("
	    if ic.armor.tags then	
			for _, v in ipairs(ic.armor.tags) do
				str = str .. v .. ";"
			end
		end		
		str = str .. ")"
	end
	--暖石温度
	if ic.temperature then
		str = str .."\n温度: "..math.floor(ic.temperature.current*10)/10 .. "\176C"
	end
	--summer隔热、warm保暖效果
	if ic.insulator then
        if ic.insulator.insulation then
            local insulation = round(ic.insulator.insulation)
            if insulation and string.lower(ic.insulator.type) == "summer" and
                summer~=0 then
                str = str .."\n隔热: "..tostring(insulation)
            end
        end
        if ic.insulator.insulation then
            local insulation = round(ic.insulator.insulation)
            if insulation and string.lower(ic.insulator.type) == "winter" and
                winter~=0 then
                str = str .."\n保暖: "..tostring(insulation)
            end
        end
    end
	--防水效果
	if ic.waterproofer and ic.waterproofer.effectiveness ~= 0 then
        str = str.."\n防水: ".. ic.waterproofer.effectiveness*100 .."%"
    end
	--精神回复效果
	if ic.dapperness and ic.dapperness.dapperness and
        type(ic.dapperness.dapperness) == "number" and ic.dapperness.dapperness ~= 0 then
        local sanity = roundstr(ic.dapperness.dapperness)
        str = str .."\n".."精神: "..sanity
    elseif ic.equippable and ic.equippable.dapperness and
        type(ic.equippable.dapperness) == "number" and ic.equippable.dapperness ~= 0 then
        local sanity = roundsg(ic.equippable.dapperness * 60)
		if sanity > 0 then
			sanity = "+" .. tostring(sanity)
		end
        str = str .."\n".."精神: "..sanity.."/min"
    end
	--装备增加的移速
	if ic.equippable then
	    if ic.equippable.walkspeedmult and ic.equippable.walkspeedmult ~= 0 then 
	        local added_speed = ic.equippable.walkspeedmult*100
	        if added_speed > 0 then
	            added_speed = "+" .. tostring(added_speed)
		    end
		    str = str .."\n移速: "..added_speed .."%"
	    end
	end
	--爆炸伤害
	if item.components.explosive then
		str = str .."\n爆炸伤害: "..item.components.explosive.explosivedamage.."\n爆炸伤害: "..item.components.explosive.explosiverange
	end
	--手持物耐久度
	if ic.finiteuses then
	    if ic.finiteuses.consumption then
	        local use = 1
	        for k,v in pairs(ic.finiteuses.consumption) do
		   	 use = v
	        end
	    	str = str .."\n耐久: "..math.floor(ic.finiteuses.current/use+.5).."/"..math.floor(ic.finiteuses.total/use+.5).."\n "
	    else
	    	str = str .."\n耐久: "..ic.finiteuses.current.."/"..ic.finiteuses.total 
	    end  
	end
	--燃料性能
	if ic.fueled then
        str = str .. "\n剩余燃料:" .. tostring(ic.fueled.currentfuel) .. "/" .. tostring(ic.fueled.fueltype)
    end

	if ic.fuel then
		str = str .. "\n燃料:" .. tostring(ic.fuel.fuelvalue) .. "/" .. tostring(ic.fuel.fueltype)
	end
	--火山献祭
	if ic.appeasement then
        str = str .."\n火山献祭: ".. tostring(ic.appeasement.appeasementvalue)
    end
	--显示打包物品
	if ic.unwrappable then
        local packageprefabname = ""
        for i, v in ipairs(ic.unwrappable.itemdata) do
            if v and v.data.stackable and v.data.stackable.stack then
                packageprefabname = packageprefabname.."\n" ..GLOBAL.STRINGS.NAMES[string.upper(v.prefab)] .."*".. v.data.stackable.stack
            elseif v and not v.data.stackable then
                packageprefabname = packageprefabname.."\n"..GLOBAL.STRINGS.NAMES[string.upper(v.prefab)]
            end
        end
        return packageprefabname
    end
	return str
end

local Inv = GLOBAL.require "widgets/inventorybar"
local OldUpdCT = Inv.UpdateCursorText
local ItemTile = GLOBAL.require "widgets/itemtile"
local OldGDS = ItemTile.GetDescriptionString
local Text = GLOBAL.require "widgets/text"

function Inv:UpdateCursorText()
	if self.actionstringbody.GetStringAdd and self.actionstringbody.SetStringAdd then
		local str = GetDesc(self:GetCursorItem())
		self.actionstringbody:SetStringAdd(str)
	end
	OldUpdCT(self)
end


function ItemTile:GetDescriptionString()
	local oldstr = OldGDS(self)
	local str = ""
	if self.item and self.item.components and self.item.components.inventoryitem then
		str = GetDesc(self.item)
	end
	if string.len(str) > 3 then
		str = oldstr..str
	else
		str = oldstr
	end
	return str
end


function Text:SetStringAdd(str)
	self.stringadd = str
end

function Text:SetString(str)
	if not str then str = "" else str = tostring(str) end
	self.string = str
	if self.stringadd and (type(self.stringadd) == "string") then str = str .. self.stringadd end
	self.inst.TextWidget:SetString(str or "")
end

function Text:GetStringAdd()
	if self.stringadd and (type(self.stringadd) == "string") then 
		return self.stringadd 
	else
		return ""
	end
end




local function CreateLabel(inst, parent)
	inst.persists = false
	if not inst.Transform then
	  inst.entity:AddTransform()
	end
	inst.Transform:SetPosition(parent.Transform:GetWorldPosition() )
  
	return inst
  end
--伤害显示

local HEALTH_LOSE_COLOR = {
	r = 0.7,
	g = 0,
	b = 0
  }
local HEALTH_GAIN_COLOR = {
	r = 0,
	g = 0.7,
	b = 0
  }

local LIFT_ACC = 0.003

local LABEL_TIME_DELTA = 0.05
local function CreateDamageIndicator(inst, amount)
	local labelEntity = CreateLabel(GLOBAL.CreateEntity(), inst)
	local label = labelEntity.entity:AddLabel()
	label:SetFont(GLOBAL.NUMBERFONT)
	label:SetFontSize(70)
	label:SetPos(0, 4, 0)
	local color
	if amount < 0 then
		color = HEALTH_LOSE_COLOR
	else
		color = HEALTH_GAIN_COLOR
	end
	label:SetColour(color.r, color.g, color.b)
	label:SetText(string.format("%d", amount))

	labelEntity:StartThread(function()
		local t = 0
		local ddy = 0.0
		local dy = 0.05
		local side = 0
		local dside = 0.0
		local ddside = 0.0
		local t_max = 0.5
		local y = 4
		while labelEntity:IsValid() and t < t_max do
  		 
		-- waving upon mode ------------------
		ddy = LIFT_ACC * (math.random() * 0.5 + 0.5)
		dy = dy + ddy
		y = y + dy

		ddside = -side * math.random()* 0.15
		dside = dside + ddside
		side = side + dside

  
		  local headingtarget = 45 --[[TheCamera.headingtarget]] % 180
		  if headingtarget == 0 then
			label:SetPos(0, y, 0)  		-- from 3d plane x = 0
		  elseif headingtarget == 45 then
			label:SetPos(side, y, 0)	-- from 3d plane x + z = 0
		  elseif headingtarget == 90 then
			label:SetPos(side, y, 0)		-- from 3d plane z = 0
		  elseif headingtarget == 135 then
			label:SetPos(side, y, 0)		-- from 3d plane z - x = 0
		  end
		  t = t + LABEL_TIME_DELTA
		  label:SetFontSize(70 * math.sqrt(1 - t / t_max))
		  GLOBAL.Sleep(LABEL_TIME_DELTA)
		end
  
		labelEntity:Remove()
	end)
end

local function ShowHealthBar(inst)
	--非角色， 并且有生命组件的
	if inst:HasTag("player") or not inst.components.health then
		return
	end
	local label = inst.entity:AddLabel()
	label:SetFont(GLOBAL.NUMBERFONT)
	label:SetFontSize(20)
	label:SetText(string.format("%d/%d", inst.components.health.currenthealth, inst.components.health:GetMaxHealth()))
	--将label 的位置设置在inst 的上方
	label:SetPos(0, 0, 0)
	--启动0.5秒的定时器更新生命值
	inst:DoPeriodicTask(1, function()
		label:SetText(string.format("%d/%d", inst.components.health.currenthealth, inst.components.health:GetMaxHealth()))
	end)
end

AddComponentPostInit("health", function(Health, inst)
	ShowHealthBar(inst)
	inst:ListenForEvent("healthdelta", function(inst, data)
	  if inst.components.health then
		local amount = (data.newpercent - data.oldpercent) * inst.components.health:GetMaxHealth()
		if math.abs(amount) > 0.99 then
			CreateDamageIndicator(inst, amount)
		end
	  end
	end)
  end)
  

  --定一个表用来存储需要加入的图片文档
  local minimapAtlas = {
	"beefalo",
	"carrot_planted",
	"flint",
	"rabbithole"
  }
  --遍历表，将图片文档加入到游戏中
  for i, v in ipairs(minimapAtlas) do
	AddMinimapAtlas("images/"..v..".xml")
  end
  --遍历表，设置小地图图标
  for i, v in ipairs(minimapAtlas) do
	AddPrefabPostInit(v, function(inst)
	  local minimap = inst.entity:AddMiniMapEntity()
	  minimap:SetIcon( inst.prefab .. ".tex" )
	end)
  end
  
local Widget = GLOBAL.require('widgets/widget')
local Image = GLOBAL.require('widgets/image')
local Text = GLOBAL.require('widgets/text')
local function BadgePostConstruct(self)
	self:SetScale(.9,.9,.9)
	
	self.bg = self:AddChild(Image("images/status_bgs.xml", "status_bgs.tex"))
	self.bg:SetScale(.4,.43,0)
	self.bg:SetPosition(-.5, -40, 0)
	
	self.num:SetFont(GLOBAL.NUMBERFONT)
	self.num:SetSize(28)
	self.num:SetPosition(3.5, -40.5, 0)
	self.num:SetScale(1,.78,1)

	self.num:MoveToFront()
	self.num:Show()

	self.maxnum = self:AddChild(Text(GLOBAL.NUMBERFONT, 25))
	self.maxnum:SetPosition(6, 0, 0)
	self.maxnum:MoveToFront()
	self.maxnum:Hide()
	
	local OldOnGainFocus = self.OnGainFocus
	function self:OnGainFocus()
		OldOnGainFocus(self)
		self.maxnum:Show()
	end

	local OldOnLoseFocus = self.OnLoseFocus
	function self:OnLoseFocus()
		OldOnLoseFocus(self)
		self.maxnum:Hide()
		self.num:Show()
	end
	
	-- for health/hunger/sanity/beaverness
	local maxtxt = "Max:\n"
	local OldSetPercent = self.SetPercent
	if OldSetPercent then
		function self:SetPercent(val, max, ...)
			self.maxnum:SetString(maxtxt..tostring(math.ceil(max or 100)))
			OldSetPercent(self, val, max, ...)
		end
	end
	
end

AddClassPostConstruct("widgets/badge", BadgePostConstruct)
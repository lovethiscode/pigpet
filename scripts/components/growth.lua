require "class"
--每秒中1点经验值
Pigpet.growth.time_exp = 1
--每次收集增加2点经验
Pigpet.growth.collect_exp = 1
--每次攻击增加2点经验
Pigpet.growth.attack_exp = 2
--砍树经验
Pigpet.growth.chop_exp = 1


--每次升级增加的攻击力
Pigpet.growth.attack = 1
--每次升级增加的生命值
Pigpet.growth.health = 10

local Growth = Class(function(self, inst)
    self.inst = inst
    self.level = 1
    self.maxlevel = 999
    --当前等级经验值
    self.currentexp = 0
    --当前升级所需经验值
    self.currentmaxexp = 100
    --启动一个循环定时任务
    self.inst:DoPeriodicTask(5, function() self:AddExp(Pigpet.growth.time_exp) end)
end)


function Growth:GetLevel()
    return self.level
end

function Growth:GetMaxLevel()
    return self.maxlevel
end

function Growth:GetCurrentExp()
    return self.currentexp
end

function Growth:GetCurrentMaxExp()
    return self.currentmaxexp
end

function Growth:HandleUpgrade()
    --每次升级增加1点攻击力
    self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage + Pigpet.growth.attack
    --增加10点 最大生命值
    self.inst.components.health.maxhealth = self.inst.components.health.maxhealth + Pigpet.growth.health
    --增加10点当前生命值
    self.inst.components.health.currenthealth = self.inst.components.health.currenthealth + Pigpet.growth.health
end

function Growth:AddExp(exp)
    if self.level >= self.maxlevel then
        return
    end
    self.currentexp = self.currentexp + exp
    if self.currentexp >= self.currentmaxexp then
        self.currentexp = self.currentexp - self.currentmaxexp
        self.level = self.level + 1
        self:HandleUpgrade()
    end
end


function Growth:OnSave()
    local data = {}
    data.level = self.level
    data.currentexp = self.currentexp
    data.currentmaxexp = self.currentmaxexp
    return data
end   

function Growth:OnLoad(data)
    if data then
        self.level = data.level
        self.currentexp = data.currentexp
        self.currentmaxexp = data.currentmaxexp
    end
end


return Growth


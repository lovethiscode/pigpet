require "class"
--每秒中1点经验值
Pigpet.pick_prefeb.time_exp = 1
--每次收集增加10点经验
Pigpet.pick_prefeb.collect_exp = 5
--每次攻击增加20点经验
Pigpet.pick_prefeb.attack_exp = 2
--砍树经验
Pigpet.pick_prefeb.chop_exp = 1

local Growth = Class(function(self, inst)
    self.inst = inst
    self.level = 1
    self.maxlevel = 99
    --当前等级经验值
    self.currentexp = 0
    --当前升级所需经验值
    self.currentmaxexp = 20
    --启动一个循环定时任务
    self.inst:DoPeriodicTask(1, function() self:AddExp(Pigpet.pick_prefeb.time_exp) end)
    --攻击力
    self.attack = 5
    --生命值
    self.maxhealth = 20
    self.currenthealth = 20
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
    self.attack = self.attack + 1
    self.inst.components.combat.defaultdamage = self.attack
    --增加10点 最大生命值
    self.maxhealth = self.maxhealth + 10
    self.inst.components.health.maxhealth = self.maxhealth
    --增加10点当前生命值
    self.currenthealth = self.currenthealth + 10
    self.inst.components.health.currenthealth = self.currenthealth
end

function Growth:AddExp(exp)
    if self.level >= self.maxlevel then
        return
    end
    self.currentexp = self.currentexp + exp
    if self.currentexp >= self.currentmaxexp then
        self.currentexp = self.currentexp - self.currentmaxexp
        self.level = self.level + 1
        self.currentmaxexp = self.currentmaxexp * 2
        self:HandleUpgrade()
    end
end


function Growth:OnSave()
    local data = {}
    data.level = self.level
    data.currentexp = self.currentexp
    data.currentmaxexp = self.currentmaxexp
    data.maxlevel = self.maxlevel
    data.attack = self.attack
    data.maxhealth = self.maxhealth
    data.currenthealth = self.currenthealth
    return data
end   

function Growth:OnLoad(data)
    if data then
        self.level = data.level
        self.currentexp = data.currentexp
        self.currentmaxexp = data.currentmaxexp
        self.maxlevel = data.maxlevel
        self.attack = data.attack
        self.maxhealth = data.maxhealth
        self.currenthealth = data.currenthealth
        
        self.inst.components.combat.defaultdamage = data.attack
        self.inst.components.health.maxhealth = data.maxhealth
        self.inst.components.health.currenthealth = data.currenthealth

    end
end


return Growth


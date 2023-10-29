require "behaviours/wander"
local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 5
local TARGET_FOLLOW_DIST = 9
local MAX_WANDER_DIST = 3

local PigpetBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.tree_target = nil
end)

local function GetPlayerPosition(inst)
    local player = GetPlayer()
    if player then
        return player:GetPosition()
    end
    return inst:GetPosition()
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end


local function StartChoppingCondition(inst)
    return inst.components.follower.leader
end

local KEEP_CHOPPING_DIST = 15
local function KeepChoppingAction(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_CHOPPING_DIST*KEEP_CHOPPING_DIST
end


local function GetLeader(inst)
    return inst.components.follower.leader 
end

local SEE_TREE_DIST = 15
local function FindTreeToChopAction(inst)
    local target = FindEntity(inst.components.follower.leader, SEE_TREE_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.CHOP end)
    if target then
        return BufferedAction(inst, target, ACTIONS.CHOP)
    end
end

--直接拾取， 燧石
local function GetPickableTarget(inst)
    return FindEntity(inst, SEE_TREE_DIST, function(item) return item.components.inventoryitem and item.components.inventoryitem.canbepickedup end)
end

local function DoPickableTarget(inst)
    local target = GetPickableTarget(inst)
    if target then
        --放入背包       
        return BufferedAction(inst, target, ACTIONS.PICKUP)
    end
end


--采集 树枝， 浆果等
local function GetPickTarget(inst)
    local target = FindEntity(inst.components.follower.leader, SEE_TREE_DIST, function(item) 
        if item.components.pickable and item.components.pickable:CanBePicked() then
            local prefb_name = Pigpet.pick_prefeb[item.prefab]
            if prefb_name then
                return true
            else 
                print("没有对应的prefb:" .. tostring(item.prefab))
            end
        end
    end)
    return target
end

local function  DoPickTarget(inst)
    local target = GetPickTarget(inst)
    if target then      
        return BufferedAction(inst, target, ACTIONS.PICK)
    end
end

function PigpetBrain:OnStart()
    local root = PriorityNode ({
            --可直接拾取
            IfNode(function() return GetPickableTarget(self.inst) and KeepChoppingAction(self.inst) end, "keep pickup",  DoAction(self.inst, DoPickableTarget)),
            --采集
            IfNode(function() return GetPickTarget(self.inst) and KeepChoppingAction(self.inst) end, "keep pickup",  DoAction(self.inst, DoPickTarget)),
            IfNode(function() return StartChoppingCondition(self.inst) end, "chop", 
                WhileNode(function() return KeepChoppingAction(self.inst) end, "keep chopping", 
                    DoAction(self.inst, FindTreeToChopAction))),
            Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
            Wander(self.inst, GetPlayerPosition, MAX_WANDER_DIST)
        },0.25)

    self.bt = BT(self.inst, root)
end

return PigpetBrain
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


local function GetPickupTarget(inst)
    local target = FindEntity(inst.components.follower.leader, SEE_TREE_DIST, function(item) return item.components.inventoryitem and item.components.inventoryitem.canbepickedup end)
    if target then
        --放入背包       
        return BufferedAction(inst, target, ACTIONS.PICKUP)
    end
end

local function HasPickableTarget(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, function(item) return item.components.inventoryitem and item.components.inventoryitem.canbepickedup end)
    return target ~= nil and KeepChoppingAction(inst)
end

function PigpetBrain:OnStart()
    local root = PriorityNode ({
            IfNode(function() return HasPickableTarget(self.inst) end, "keep pickup",  DoAction(self.inst, GetPickupTarget)),

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
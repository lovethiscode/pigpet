require "behaviours/wander"
local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 6
local TARGET_FOLLOW_DIST = 4
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

function PigpetBrain:OnStart()
    local root = PriorityNode({
        Follow(self.inst, function() return self.inst.components.follower.leader end,  MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetPlayerPosition, MAX_WANDER_DIST),
    }, 0.25)
    self.bt = BT(self.inst, root)
end

return PigpetBrain
require("stategraphs/commonstates")

local actionhandlers = 
{
}


local events=
{
    CommonHandlers.OnLocomote(true,true),
}

local states=
{
    --添加一个idle状态
    State{
        name = "idle",
        tags = {"idle"},
        onenter = function(inst)
            inst.Physics:Stop()
            if inst.components.follower.leader then
                inst.AnimState:PlayAnimation("hungry")
            else
                inst.AnimState:PlayAnimation("idle_angry", true)
            end
        end,
        events=
         {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
         },
    },
}

CommonStates.AddWalkStates(states,
{
	
})
CommonStates.AddRunStates(states,
{
})

return StateGraph("pigpet", states, events, "idle", actionhandlers)

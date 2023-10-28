require("stategraphs/commonstates")

local actionhandlers = 
{
    --收到ACTIONS.CHOP 的时候，轉換到chop狀態
    ActionHandler(ACTIONS.CHOP, "chop"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
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
    State{
        name = "chop",
        tags = {"chopping"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            
            TimeEvent(13*FRAMES, function(inst) inst:PerformBufferedAction() end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "pickup",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pig_pickup")
        end,
        
        timeline=
        {      
            TimeEvent(10*FRAMES, function(inst) 
                local ba = inst:GetBufferedAction()
                if ba and ba.target then
                    inst.components.container:GiveItem(ba.target)
                end
                inst:PerformBufferedAction() 
            end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst)                
                inst.sg:GoToState("idle")
            end),
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

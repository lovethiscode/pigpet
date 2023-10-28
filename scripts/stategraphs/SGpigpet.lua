require("stategraphs/commonstates")

local actionhandlers = 
{
    --收到ACTIONS.CHOP 的时候，轉換到chop狀態
    ActionHandler(ACTIONS.CHOP, "chop"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.PICK, "pick"),
}

local pick_prefeb = {
    sapling = "twigs",
    flower = "petals",
    grass = "cutgrass",
    carrot_planted = "carrot",
    green_mushroom = "green_cap",
    red_mushroom = "red_cap",
    blue_mushroom = "blue_cap",
    berrybush = "berries",
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
    
    State{
        name = "pick",
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
                    local prefb_name = pick_prefeb[ba.target.prefab]
                    if prefb_name then
                        local item = SpawnPrefab(prefb_name)
                        inst.components.container:GiveItem(item)
                    else 
                        ba.target:Remove()
                        print("没有对应的prefb:" .. tostring(ba.target.prefab))
                    end
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

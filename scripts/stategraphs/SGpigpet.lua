require("stategraphs/commonstates")

local actionhandlers = 
{
    --收到ACTIONS.CHOP 的时候，轉換到chop狀態
    ActionHandler(ACTIONS.CHOP, "chop"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.PICK, "pick"),
}


local events=
{
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnAttacked(true),
    CommonHandlers.OnAttack(),
}

local states=
{
    --添加一个idle状态
    State{
        name = "idle",
        tags = {"idle"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
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
            
            TimeEvent(13*FRAMES, function(inst) 
                inst:PerformBufferedAction()
                inst.components.growth:AddExp(Pigpet.pick_prefeb.chop_exp)
             end ),
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
                    inst.components.growth:AddExp(Pigpet.pick_prefeb.collect_exp)
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
                    local prefb_name = Pigpet.pick_prefeb[ba.target.prefab]
                    if prefb_name then
                        local item = SpawnPrefab(prefb_name)
                        inst.components.container:GiveItem(item)
                        inst.components.growth:AddExp(Pigpet.pick_prefeb.collect_exp)
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
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) 
                inst.components.combat:DoAttack() 
                inst.components.growth:AddExp(Pigpet.pick_prefeb.attack_exp)
            end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        --受到攻击的状态
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
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

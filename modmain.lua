--声明预制物
PrefabFiles = {
    "pigpet"
}

GLOBAL.STRINGS.NAMES.PIGPET = "皮皮熊"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIGPET = "我是一只宠物" -- 物体的检查描述

GLOBAL.TheInput:AddKeyHandler(function(key, down)
    if key == GLOBAL.KEY_F1 and not down then
         --生成一个pigpet
        local pig = GLOBAL.SpawnPrefab("pigpet")
        pig.Transform:SetPosition(GLOBAL.GetPlayer().Transform:GetWorldPosition())
    end
end)
name = "宠物" -- mod的名称
description = "宠物可以帮你做什么事情，砍树，战斗，采集...\n五格装备栏  显示物品信息  显示伤害数值  \nF1: 打开背包\nF2: 打开烹饪界面" -- mod的描述
author = "Your Name" -- 作者名字
version = "1.0.0" -- mod的版本号


forumthread = ""
api_version = 6
api_version_dst = 10

dont_starve_compatible = true
dst_compatible = true
all_clients_require_mod = false

--mod 图标配置
icon_atlas = "modicon.xml" -- mod图标的xml文件
icon = "modicon.tex" -- mod图标的tex文件


-- mod的配置选项
configuration_options = {
    {
        name = "show_global_map",
        label = "显示全局地图",
        options = {
            {description = "是", data = true},
            {description = "否", data = false},
        },
        default = true,
    },
}


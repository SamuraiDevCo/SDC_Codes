fx_version 'cerulean'
games { 'gta5' }

author 'HoboDevCo#3011'
description 'SDC | Codes Script'
version '1.0.4'

shared_script {
    "@ox_lib/init.lua",
    "config/config.lua",
    "config/lang.lua"
}

client_scripts {
    "src/client/client_customize_me.lua",
    "src/client/client.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "src/server/server_customize_me.lua",
    "src/server/server.lua",
}

escrow_ignore {
    "config/config.lua",
    "src/client/client.lua",
    "src/server/server.lua",
    "src/server/server_customize_me.lua",
}

lua54 'yes'
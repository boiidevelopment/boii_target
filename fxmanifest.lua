--[[
     ____   ____ _____ _____   _   _____  ________      ________ _      ____  _____  __  __ ______ _   _ _______ 
    |  _ \ / __ \_   _|_   _| | | |  __ \|  ____\ \    / /  ____| |    / __ \|  __ \|  \/  |  ____| \ | |__   __|
    | |_) | |  | || |   | |   | | | |  | | |__   \ \  / /| |__  | |   | |  | | |__) | \  / | |__  |  \| |  | |   
    |  _ <| |  | || |   | |   | | | |  | |  __|   \ \/ / |  __| | |   | |  | |  ___/| |\/| |  __| | . ` |  | |   
    | |_) | |__| || |_ _| |_  | | | |__| | |____   \  /  | |____| |___| |__| | |    | |  | | |____| |\  |  | |   
    |____/ \____/_____|_____| | | |_____/|______|   \/   |______|______\____/|_|    |_|  |_|______|_| \_|  |_|   
                              | |                                                                                
                              |_|                 TARGET
]]

fx_version 'cerulean'
games { 'gta5', 'rdr3' }

name 'boii_target'
version '0.4.0'
description 'BOII | Development - Target'
author 'boiidevelopment'
repository 'https://github.com/boiidevelopment/boii_target'
lua54 'yes'

ui_page 'html/index.html'

files {
    'html/**/**/**',
}

server_script 'server/version.lua'

client_scripts {
    'client/config.lua',
    'client/main.lua',
    'client/targets/*',
    'client/wrapper/*',
    'client/test.lua',
    'client/export.lua',
}

escrow_ignore {
    'client/**/*',
    'server/*'
}

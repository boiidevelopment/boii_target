----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

fx_version 'cerulean'
game {'gta5'}

author 'boiidevelopment'

description 'BOII | Development - Utility: Target'

version '0.0.1'

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/**/**/**',
}

client_scripts {
    'client/config.lua',
    'client/main.lua',
    'client/peds.lua',
    'client/players.lua',
    'client/vehicles.lua',
    'client/test.lua',
    'client/export.lua',
}

escrow_ignore {
    'client/*'
}
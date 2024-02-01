----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

fx_version 'cerulean'
game {'gta5'}

author 'boiidevelopment'

description 'BOII | Development - Utility: Target'

version '0.1.0'

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/**/**/**',
}

client_scripts {
    'client/config.lua',
    'client/main.lua',
    'client/targets/*',
    'client/wrapper/*',
    'client/test.lua',
    'client/export.lua',
}

escrow_ignore {
    'client/**/*'
}

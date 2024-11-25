fx_version 'cerulean'
game 'gta5'

description 'bbv-blips'
version '1.0.0'

client_scripts {
    'config.lua',
    'wrapper/cl_wp_callback.lua',
    'client/cl_main.lua',
}

server_scripts {
    'wrapper/sv_wp_callback.lua',
    'server/sv_main.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}


lua54 'yes'


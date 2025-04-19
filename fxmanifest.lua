fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Payaso'
description 'GTA:World Inspired Vehicle System - Utilizing OX Lib'
version '1.0.2'

shared_script 'config.lua'
client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

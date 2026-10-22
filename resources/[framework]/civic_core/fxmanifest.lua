fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'civic_core'
author 'Civic Framework'
description 'Standalone player, money, job, inventory, vehicle, and housing data core.'
version '0.1.0'

shared_scripts {
    'shared/config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

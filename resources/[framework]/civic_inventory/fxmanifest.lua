fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'civic_inventory'
author 'Civic Framework'
description 'Server-authoritative starter inventory and consumables.'
version '0.1.0'

shared_scripts {
    'shared/items.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependency 'civic_core'

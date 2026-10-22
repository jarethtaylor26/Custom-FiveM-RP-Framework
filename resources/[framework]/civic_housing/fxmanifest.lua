fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'civic_housing'
author 'Civic Framework'
description 'Starter property ownership and interior access.'
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

dependency 'civic_core'

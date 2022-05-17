fx_version 'cerulean'

game 'gta5'

name 'Community Service'
description 'QBCore powered community service resource'
author 'zeixna'

version '1.1.0'

shared_scripts {
	'config.lua',
    '@qb-core/shared/locale.lua',
	'locales/en.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/sv_main.lua',
}

client_scripts {
	'client/cl_main.lua'
}
fx_version 'cerulean'
game 'gta5'

name "tug"
description "yes"
author "Berry"
version "0.1"

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_scripts {
	"@ox_lib/init.lua",
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

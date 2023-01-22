fx_version "bodacious"
game "gta5"

ui_page "nui/index.html"

client_scripts {
	"@vrp/lib/utils.lua",
	"config.lua",
	"tkzClient.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"config.lua",
	"tkzServer.lua"
}

files {
	"nui/*",
	"nui/**/*"
}
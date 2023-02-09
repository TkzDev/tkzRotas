local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface(GetCurrentResourceName(), src)

---- ---- ---- ---- ---- ------
---- [[ VARIAVEIS SERVER ]] ---
---- ---- ---- ---- ---- ------

local blips = {}
local idgens = Tools.newIDGenerator()

---- ---- ---- ---- ---- ------
---- [[ FUNCTIONS SERVER ]] ---
---- ---- ---- ---- ---- ------

function src.checkPermission(selectedRoute,permissao)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id,config.modulosRotas[selectedRoute].permissao) then
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui acesso.")
			return false
		end
	end
end

function src.checkPayment(selectedRoute, position)
	local source = source
	local user_id = vRP.getUserId(source)
	local ped = GetPlayerPed(source)
	if user_id then
		if src.checkPermission(selectedRoute) then
			for k,v in pairs(config.modulosRotas[selectedRoute].itens) do
				if ((k - 1) == tonumber(position)) then
					if config.modulosRotas[selectedRoute].mode == 'coletar' then
						if vRP.getInventoryWeight(user_id) + vRP.getItemWeight(v.item) * parseInt(v.quantidade) <= vRP.getInventoryMaxWeight(user_id) then
							TriggerClientEvent('cancelando',source,true)
							TriggerClientEvent("progress",source,10000,"Coletando")
							TriggerClientEvent("emotes",source,"verificar")
							FreezeEntityPosition(ped,true)
							SetTimeout(10000, function()
								vRPclient._stopAnim(source,false)
								FreezeEntityPosition(ped,false)
								TriggerClientEvent('cancelando',source,false)
								vRP.giveInventoryItem(user_id, v.item, tonumber(v.quantidade))
								TriggerClientEvent("Notify",source,"sucesso","<b>Você</b> coletou "..v.quantidade.."x "..v.item.." ",8000)
							end)
						else
							TriggerClientEvent("Notify",source,"negado","<b>Mochila</b> cheia.",8000)
						end
					elseif config.modulosRotas[selectedRoute].mode == 'entregar' then
						if vRP.getInventoryItemAmount(user_id,v.item) >= tonumber(v.quantidade) then
							TriggerClientEvent('cancelando',source,true)
							TriggerClientEvent("progress",source,10000)
							TriggerClientEvent("emotes",source,"verificar")
							FreezeEntityPosition(ped,true)
							SetTimeout(10000, function()
								vRPclient._stopAnim(source,false)
								FreezeEntityPosition(ped,false)
								TriggerClientEvent('cancelando',source,false)
								vRP.tryGetInventoryItem(user_id, v.item,tonumber(v.quantidade))
								TriggerClientEvent("Notify",source,"sucesso","<b>Você</b> entregou "..v.quantidade.."x "..v.item.." ",8000)
							end)
						else
							TriggerClientEvent("Notify",source,"negado","<b>Você não possui esse item na mochila</b>.",8000)
						end
					end
				end
				if config.modulosRotas[selectedRoute].callpolice == true then
					if math.random(100) >= 1 then
						local source = source
						local ped = GetPlayerPed(source)
						local x,y,z = vRPclient.getPosition(source)
						local policia = vRP.getUsersByPermission(config.modulosRotas[selectedRoute].permissaopolicia)
						for l,w in pairs(policia) do
							local player = vRP.getUserSource(parseInt(w))
							if player then
								async(function()
									local id = idgens:gen()
									blips[id] = vRPclient.addBlip(player,x,y,z,10,84,"Denuncia Entregas",0.6,false)
									vRPclient._playSound(player,"CONFIRM_BEEP","HUD_MINI_GAME_SOUNDSET")
									TriggerClientEvent('chatMessage',player,"911",{64,64,255},"Recebemos uma denuncia de entregas ilicitas, vá até o local para verificar.")
									SetTimeout(20000,function() vRPclient.removeBlip(player,blips[id]) idgens:free(id) end)
								end)
							end
						end
					end
				end
			end
		end
	end
end

function src.getItems(routes)
	return config.modulosRotas[routes].itens
end

---- ---- ---- ---- ---- ----
---- [[ EVENTS SERVER ]] ----
---- ---- ---- ---- ---- ----

RegisterNetEvent("tkzRotasselectRoute", function(selectedRoute, position)
AddEventHandler("tkzRotasselectRoute")
	local source = source
	local user_id = vRP.getUserId(source)
		if user_id then
		for k,v in pairs(config.modulosRotas[selectedRoute].itens) do
			if ((k - 1) == tonumber(position)) then
				TriggerClientEvent("tkzRotasstartRoute", source, selectedRoute, v.name)		
			end
		end
	end
end)
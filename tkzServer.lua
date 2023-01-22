-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface(GetCurrentResourceName(), src)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO DE VERIFICAR PERMISSÃO 
-----------------------------------------------------------------------------------------------------------------------------------------
function src.checkPermission(currentRoute,permissao)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id,config.modulosRotas[currentRoute].permissao) then
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui acesso.")
			return false
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO DE PAGAMENTO 
-----------------------------------------------------------------------------------------------------------------------------------------
function src.checkPayment(currentRoute, position)
	local source = source
	local user_id = vRP.getUserId(source)
	local ped = GetPlayerPed(source)
	if user_id then
		if src.checkPermission(currentRoute) then
			for k,v in pairs(config.modulosRotas[currentRoute].itens) do
				if ((k - 1) == tonumber(position)) then
					if config.modulosRotas[currentRoute].mode == 'coletar' then
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
					elseif config.modulosRotas[currentRoute].mode == 'entregar' then
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
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO QUE RETORNA OS ITENS DO CONFIG.LUA
-----------------------------------------------------------------------------------------------------------------------------------------
function src.getItems(routes)
	return config.modulosRotas[routes].itens
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO PARA SELECIONAR A ROTA DO CONFIG.LUA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("routes:selectRoute", function(currentRoute, position)
AddEventHandler("routes:selectRoute")
	local source = source
	local user_id = vRP.getUserId(source)
		if user_id then
		for k,v in pairs(config.modulosRotas[currentRoute].itens) do
			if ((k - 1) == tonumber(position)) then
				TriggerClientEvent("routes:startRoute", source, currentRoute, v.name)		
			end
		end
	end
end)
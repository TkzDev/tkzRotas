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
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
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
			for key,value in pairs(config.modulosRotas[currentRoute].itens) do
				if ((key - 1) == tonumber(position)) then
					if vRP.getInventoryWeight(user_id) + vRP.getItemWeight(value.item) * parseInt(value.quantidade) <= vRP.getInventoryMaxWeight(user_id) then
						TriggerClientEvent('cancelando',source,true)
						TriggerClientEvent("progress",source,10000,"Coletando")
						TriggerClientEvent("emotes",source,"verificar")
						FreezeEntityPosition(ped,true)
						SetTimeout(10000, function()
							vRPclient._stopAnim(source,false)
							FreezeEntityPosition(ped,false)
							TriggerClientEvent('cancelando',source,false)
							vRP.giveInventoryItem(user_id, value.item, tonumber(value.quantidade))
							TriggerClientEvent("Notify",source,"sucesso","<b>Você</b> coletou "..value.quantidade.."x "..value.item.." ",8000)
						end)
					else
						TriggerClientEvent("Notify",source,"negado","<b>Mochila</b> cheia.",8000)
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
		for key,value in pairs(config.modulosRotas[currentRoute].itens) do
			if ((key - 1) == tonumber(position)) then
				TriggerClientEvent("routes:startRoute", source, currentRoute, value.name)		
			end
		end
	end
end)



--[[
	tete
]]
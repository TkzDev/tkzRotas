local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vSERVER = Tunnel.getInterface(GetCurrentResourceName())

local currentRoute = nil
local currentBlip = nil
local position = 0
local currentPathPosition = 1
-------------------------------------------------------------------------------------------------
--[ MENU ]---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
local menuactive = false

function ToggleActionMenu()
	menuactive = not menuactive
    if menuactive then
		SetNuiFocus(true,true)
		SendNUIMessage({ action = "open", title = "Rotas para "..config.moduloIniciarRotas[currentRoute].title, items = vSERVER.getItems(currentRoute) })
    else
		SetNuiFocus(false)
		SendNUIMessage({ action = "exit" })
	end
end
-------------------------------------------------------------------------------------------------
--[ BOTÕES ]-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
RegisterNUICallback("selectRoute", function(data,cb)
    if data.code then
			position = data.code
	    TriggerServerEvent("routes:selectRoute", currentRoute, data.code)
    end
end)

RegisterNUICallback("exit", function(data,cb)
    ToggleActionMenu()
end)

RegisterNetEvent("routes:exit")
AddEventHandler("routes:exit", function()
	ToggleActionMenu()
end)

RegisterNetEvent("routes:startRoute")
AddEventHandler("routes:startRoute", function(route, item)
    if currentBlip then
			RemoveBlip(currentBlip)
	end

	currentRoute = route
	currentPathPosition = 1
    createBlip(config.moduloIniciarRotas[currentRoute].title, config.moduloColetarRotas[currentRoute][currentPathPosition])
	TriggerEvent("Notify","sucesso","Iniciando rota de "..config.modulosRotas[currentRoute].mode.." <b>"..item.."</b>.",5000)
end)
Citizen.CreateThread(function()
	while true do
		local AE = 500

		for routeCode, route in pairs(config.moduloIniciarRotas) do
			for k, v in pairs(route.iniciarRota) do
				local ped = PlayerPedId()
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local bowz,cdz = GetGroundZFor_3dCoord(v[1],v[2],v[3])
				local distance = GetDistanceBetweenCoords(v[1],v[2],cdz,x,y,z,true)
				AE = 4
				if distance <= 3.5 then
					DrawText3D(v[1],v[2],v[3], "~w~PRESSIONE ~r~[E] ~w~PARA ABRIR PAINEL ROTAS")
					if IsControlJustPressed(0,38) then
						if vSERVER.checkPermission(routeCode) then
							currentRoute = routeCode
							ToggleActionMenu()
						end
					end
				end
			end
		end
        
		Citizen.Wait(AE)
	end
end)

Citizen.CreateThread(function()
	while true do
		local AE = 500

		if currentRoute then
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local distance = GetDistanceBetweenCoords(config.moduloColetarRotas[currentRoute][currentPathPosition].x,config.moduloColetarRotas[currentRoute][currentPathPosition].y,config.moduloColetarRotas[currentRoute][currentPathPosition].z,x,y,z,true)

			AE = 4
			if distance <= 1.5 then
				DrawText3D(config.moduloColetarRotas[currentRoute][currentPathPosition].x,config.moduloColetarRotas[currentRoute][currentPathPosition].y,config.moduloColetarRotas[currentRoute][currentPathPosition].z, "~w~PRESSIONE ~r~[E] ~w~PARA COLETAR")
				
				if not IsPedInAnyVehicle(ped) then
					if IsControlJustPressed(0,38) then
						vSERVER.checkPayment(currentRoute, position)
												
						RemoveBlip(currentBlip)
						currentPathPosition = currentPathPosition + 1

						if currentPathPosition > 30 then
							currentPathPosition = 1
						end

						createBlip(config.moduloIniciarRotas[currentRoute].title, config.moduloColetarRotas[currentRoute][currentPathPosition])
					end
				end
			end
		end

		Citizen.Wait(AE)
	end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD PARA CRIAR O PED
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	for routeCode, route in pairs(config.moduloIniciarRotas) do
		for k, v in pairs(route.iniciarRota) do
			RequestModel(GetHashKey('s_m_y_blackops_03'))
			while not HasModelLoaded(GetHashKey('s_m_y_blackops_03')) do
				Citizen.Wait(10)
			end
			local ped = CreatePed(4,0x5076A73B,v[1],v[2],v[3]-1,v[4],false,true)
			FreezeEntityPosition(ped,true)
			SetEntityInvincible(ped,true)
			SetBlockingOfNonTemporaryEvents(ped,true)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD PARA ENCERRAR A ROTA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if currentRoute then
			drawTxt("~w~PRESSIONE ~r~[F7] ~w~PARA FINALIZAR A ROTA",4,0.2,0.93,0.50,255,255,255,180)
			if IsControlJustPressed(0, 168) then
				currentRoute = nil
				currentPathPosition = 1
				RemoveBlip(currentBlip)
				TriggerServerEvent("routes:endRoute")
				TriggerEvent("Notify","negado","Rota encerrada",10000)
			end
		end
	end
end)
-------------------------------------------------------------------------------------------------
--[ FUNÇÃO ]-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
function DrawText3D(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.38, 0.38)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
end

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function createBlip(title, pos)
	currentBlip = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(currentBlip,12)
	SetBlipColour(currentBlip,1)
	SetBlipScale(currentBlip,0.9)
	SetBlipAsShortRange(currentBlip,false)
	SetBlipRoute(currentBlip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Rotas de "..title)
	EndTextCommandSetBlipName(currentBlip)
end
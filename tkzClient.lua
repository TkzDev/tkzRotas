local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vSERVER = Tunnel.getInterface(GetCurrentResourceName())


---- ---- ---- ---- ---- ------
---- [[ VARIAVEIS CLIENT ]] ---
---- ---- ---- ---- ---- ------
local currentRoute = nil
local currentBlip = nil
local position = 0
local currentPathPosition = 1
local menuactive = false


---- ---- ---- ---- ---- --------
---- [[ MENU ACTIVE CLIENT ]] ---
---- ---- ---- ---- ---- --------
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
---- ---- ---- ---- ---- ------
---- [[ BUTTONS CLIENT ]] -----
---- ---- ---- ---- ---- ------
RegisterNUICallback("selectRoute", function(data,cb)
    if data.code then
			position = data.code
	    TriggerServerEvent("tkzRotas:selectRoute", currentRoute, data.code)
    end
end)

RegisterNUICallback("exit", function(data,cb)
    ToggleActionMenu()
end)

RegisterNetEvent("tkzRotas:exit")
AddEventHandler("tkzRotas:exit", function()
	ToggleActionMenu()
end)

RegisterNetEvent("tkzRotas:startRoute")
AddEventHandler("tkzRotas:startRoute", function(route, item, mode)
	if currentBlip then
			RemoveBlip(currentBlip)
	end

	currentRoute = route
	currentPathPosition = 1
	createBlip(config.moduloIniciarRotas[currentRoute].title, config.moduloColetarRotas[currentRoute][currentPathPosition])
	TriggerEvent(config.moduloNotify['startRoute']['event'],config.moduloNotify['startRoute']['type'],config.moduloNotify['startRoute']['message'],5000)
end)
---- ---- ---- ---- ---- ------
---- [[ THREADS CLIENT ]] ---
---- ---- ---- ---- ---- ------
Citizen.CreateThread(function()
	while true do
		local tkzOtmz = 1000

		for routeCode, route in pairs(config.moduloIniciarRotas) do
			for k, v in pairs(route.iniciarRota) do
				local ped = PlayerPedId()
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local bowz,cdz = GetGroundZFor_3dCoord(v[1],v[2],v[3])
				local distance = GetDistanceBetweenCoords(v[1],v[2],cdz,x,y,z,true)
				tkzOtmz = 1
				if distance <= 2.5 then
					DrawText3D(v[1],v[2],v[3], "~b~[E] ~w~PARA ABRIR PAINEL ~b~ROTAS")
					if IsControlJustPressed(0,38) then
						if vSERVER.checkPermission(routeCode) then
							currentRoute = routeCode
							ToggleActionMenu()
						end
					end
				end
			end
		end
        
		Citizen.Wait(tkzOtmz)
	end
end)

Citizen.CreateThread(function()
	while true do
		local tkzOtmz = 1000

		if currentRoute then
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local distance = GetDistanceBetweenCoords(config.moduloColetarRotas[currentRoute][currentPathPosition].x,config.moduloColetarRotas[currentRoute][currentPathPosition].y,config.moduloColetarRotas[currentRoute][currentPathPosition].z,x,y,z,true)

			tkzOtmz = 1
			if distance <= 1.5 then
				DrawText3D(config.moduloColetarRotas[currentRoute][currentPathPosition].x,config.moduloColetarRotas[currentRoute][currentPathPosition].y,config.moduloColetarRotas[currentRoute][currentPathPosition].z, "~b~[E] ~w~PARA ~b~COLETAR")
				
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

		Citizen.Wait(tkzOtmz)
	end
end)

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

Citizen.CreateThread(function()
	while true do
		local tkzOtmz = 1000
		if currentRoute then
			tkzOtmz = 1
			drawTxt("~b~[F7] ~w~PARA FINALIZAR A ROTA",4,0.2,0.93,0.39,255,255,255,180)
			if IsControlJustPressed(0, 168) then
				currentRoute = nil
				currentPathPosition = 1
				RemoveBlip(currentBlip)
				TriggerServerEvent("tkzRotas:endRoute")
				TriggerEvent("Notify","negado","Rota encerrada",10000)
			end
		end
		Citizen.Wait(tkzOtmz)
	end
end)

---- ---- ---- ---- ---- ------
---- [[ DRAWTXT CLIENT ]] ----
---- ---- ---- ---- ---- ------
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
	SetBlipColour(currentBlip,2)
	SetBlipScale(currentBlip,0.9)
	SetBlipAsShortRange(currentBlip,false)
	SetBlipRoute(currentBlip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Rotas de "..title)
	EndTextCommandSetBlipName(currentBlip)
end


print("^5Script ["..GetCurrentResourceName().."] ^2 Successfully Loaded")
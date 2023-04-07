local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("empLixeiro",src)
vSERVER = Tunnel.getInterface("empLixeiro")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local emservico = false
local dinheiro_ganho = 0

Citizen.CreateThread(function()
	while true do
		local msec = 1000
		if not emservico then
			for _,v in pairs(coordenadas) do
				local ped = PlayerPedId()
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
				local distance = GetDistanceBetweenCoords(v.x,v.y,cdz,x,y,z,true)
				if distance <= 3 then
					msec = 3
	
					DrawMarker(21, v.x,v.y,v.z-0.7,0,0,0,0,0,0,0.2,0.2,0.3,255, 255, 255,255,0,0,0,1)
					DrawMarker(27, v.x,v.y,v.z-1,0,0,0,0,0,0,0.4,0.4,0.5,66, 245, 84,255,0,0,0,1)
					if distance <= 1.2 then
						msec = 3
						if IsControlJustPressed(0,38) then
							if vSERVER.checkItem() then	
							local rc,level,exp = vSERVER.CheckLevel()
							local money = vSERVER.return_dinheiro()
							SetNuiFocus(true,true)
							SendNUIMessage({ action = "showMenu", rc = rc, level = level, exp = exp, money = money, exp_por_level = exp_por_level, quantidade_de_blips = quantidade_de_blips })
							StartScreenEffect("MenuMGSelectionIn", 0, true)
							end
						end
					end
				end
			end
		end
		Wait(msec)
	end
end)

RegisterNUICallback("Close",function(data)
	SetNuiFocus(false,false)
	SendNUIMessage({ action = "hideMenu" })
	StopScreenEffect("MenuMGSelectionIn")
	invOpen = false
end)

RegisterNUICallback("iniciartrampo",function(data,cb)
	for _,v in pairs(coordenadas) do

		SetNuiFocus(false,false)
		StopScreenEffect("MenuMGSelectionIn")

		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped))
		local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
		local distance = GetDistanceBetweenCoords(v.x,v.y,cdz,x,y,z,true)
		emservico = true

		destino = 1

		-- vRP._playAnim(false,{{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"}},true)
		-- ColocarRoupa()

		
		--SetTimeout(8000,function()
		vRP._stopAnim(false)
		
		CriandoBlip(entregas,destino)
		TriggerEvent("Notify","sucesso","Você entrou em serviço.")

		local rc,level,exp = vSERVER.CheckLevel()

		cb({retorno = 'iniciou', rc = rc, level = level, exp = exp, exp_por_level = exp_por_level, quantidade_de_blips = quantidade_de_blips })
	end
end)

Citizen.CreateThread(function()
	while true do
		--Citizen.Wait(5)
		local ped = PlayerPedId()
		local slep = 1000
		if emservico then
			slep = 5
				local vehicle = GetVehiclePedIsIn(ped)
				local distance = GetDistanceBetweenCoords(GetEntityCoords(ped),entregas[destino].x,entregas[destino].y,entregas[destino].z,true)
				if distance <= 50 then
					DrawMarker(21,entregas[destino].x,entregas[destino].y,entregas[destino].z+0.20,0,0,0,0,0,0,0.2,0.4,0.5,255, 255, 255,255,0,0,0,1)
					if distance <= 4 then
						lastVehicle = GetPlayersLastVehicle()
						if IsVehicleModel(lastVehicle, GetHashKey(carro_emprego)) and not IsPedInAnyVehicle(PlayerPedId())  then
					
				
								if distance <= 2 then
						
									if IsControlJustPressed(0,38) and vSERVER.checkItem() then
							
									RemoveBlip(blip)

									local dinheiro_recebido = math.random(premios.Dinheiro_Minimo,premios.Dinheiro_Maximo)
									local exp_ganho = math.random(premios.ExP_Minimo,premios.ExP_Maximo)

									if destino == quantidade_de_blips then
										ExecuteCommand("e procurar")
										FreezeEntityPosition(ped, true)
										TriggerEvent('cancelando',true)
										TriggerEvent("progress",5000,"Coletando")
										Wait(5000)
										FreezeEntityPosition(ped, false)
										vRP._DeletarObjeto()
										vRP.stopAnim(false)
										TriggerEvent('cancelando',false)

										local dinheiro_total = vSERVER.pagar(dinheiro_recebido)
										vSERVER.GetEXP(exp_ganho)
										vSERVER.addRota()
										destino = 1
										dinheiro_ganho = dinheiro_ganho + dinheiro_total
									else
										ExecuteCommand("e procurar")
										FreezeEntityPosition(ped, true)
										TriggerEvent('cancelando',true)
										TriggerEvent("progress",5000,"Coletando")
										Wait(5000)
										FreezeEntityPosition(ped, false)
										vRP._DeletarObjeto()
										vRP.stopAnim(false)
										TriggerEvent('cancelando',false)

										local dinheiro_total = vSERVER.pagar(dinheiro_recebido)
										vSERVER.GetEXP(exp_ganho)
										destino = destino + 1
										dinheiro_ganho = dinheiro_ganho + dinheiro_total
									end

									local rc,level,exp = vSERVER.CheckLevel()
									CriandoBlip(entregas,destino)
									SendNUIMessage({ action = "atualizar", rc = rc, level = level, exp = exp, checkpoint = destino, dinheiro_ganho = dinheiro_ganho, exp_por_level = exp_por_level, quantidade_de_blips = quantidade_de_blips })
						
							end
						end
					end
				end
			end
		end
		Citizen.Wait(slep)
	end
end)




-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		--Citizen.Wait(5)
		local slep = 1000
		if emservico then
			slep = 4
			drawTxt('PRESSIONE ~b~F7 ~w~PARA SAIR DE TRABALHO',2,0.23,0.93,0.40,255,255,255,180)
			if IsControlJustPressed(0,168) then
				emservico = false
				RemoveBlip(blip)
				SetNuiFocus(false,false)
				SendNUIMessage({ action = "hideMenu" })
				StopScreenEffect("MenuMGSelectionIn")
				TriggerEvent("Notify","aviso","Você saiu de serviço.")
			end
		end
		Citizen.Wait(slep)
	end
end)





-----------------------------------------------------------------------------------------------------------------------------------------
-- TRABALHAR
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCOES
-----------------------------------------------------------------------------------------------------------------------------------------
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

function CriandoBlip(entregas,destino)
	blip = AddBlipForCoord(entregas[destino].x,entregas[destino].y,entregas[destino].z)
	SetBlipSprite(blip,8)
	SetBlipColour(blip,2)
	SetBlipScale(blip,0.4)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Emprego Blip")
	EndTextCommandSetBlipName(blip)

end

function DrawText3D(x,y,z, text, r,g,b)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.0, 0.35)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local roupa = {
    ['lixeiro'] = {
	    [1885233650] = {
			[3] = {67,0,2}, -- MÃOS
			[4] = {36,0,2}, -- CALÇA
			[6] = {54,3,2}, --SAPATOS
			[8] = {59,0,2}, --BLUSA
			[11] = {57,0,2}, -- JAQUETA	
	    },
	    [-1667301416] = {
			[3] = {83,0,2}, -- MÃOS
			[4] = {35,0,2}, -- CALÇA
			[6] = {55,3,2}, --SAPATOS
			[8] = {36,0,2}, --BLUSA
			[11] = {50,0,2}, -- JAQUETA
        }
    }
}

function ColocarRoupa()
    if GetEntityHealth(PlayerPedId()) > 101 then
        if not vRP.isHandcuffed() then
            local custom = roupa['lixeiro']
            if custom then
                local old_custom = vRP.getCustomization()
				roupaantiga = old_custom
                local idle_copy = {}
                idle_copy.modelhash = nil
                for l, w in pairs(custom[old_custom.modelhash]) do
                    idle_copy[l] = w
                end
                FadeRoupa(1200, 1, idle_copy)
            end
        end
    end
end

function FadeRoupa(time, tipo, idle_copy)
    DoScreenFadeOut(800)
    Wait(time)
    if tipo == 1 then
        vRP.setCustomization(idle_copy)
    else
        vRP.setCustomization(roupaantiga)
    end
    DoScreenFadeIn(800)
end

function MainRoupa()
    if vRP.getHealth() > 101 then
        if not vRP.isHandcuffed() then
            FadeRoupa(1200, 2)
        end
    end
end
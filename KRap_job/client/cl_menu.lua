local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData, CurrentActionData, handcuffTimer, dragStatus, blipsCops, currentTask, spawnedVehicles = {}, {}, {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, IsHandcuffed, hasAlreadyJoined, playerInService, isInShopMenu = false, false, false, false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
dragStatus.isDragged = false
blip = nil

local attente = 0

function OpenBillingMenu()

	ESX.UI.Menu.Open(
	  'dialog', GetCurrentResourceName(), 'billing',
	  {
		title = "Facture"
	  },
	  function(data, menu)
	  
		local amount = tonumber(data.value)
		local player, distance = ESX.Game.GetClosestPlayer()
  
		if player ~= -1 and distance <= 3.0 then
  
		  menu.close()
		  if amount == nil then
			  ESX.ShowNotification("~r~Problèmes~s~: Montant invalide")
		  else
			local playerPed        = GetPlayerPed(-1)
			TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
			Citizen.Wait(5000)
			  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_rap', ('rap'), amount)
			  Citizen.Wait(100)
			  ESX.ShowNotification("~r~Vous avez bien envoyer la facture")
		  end
  
		else
		  ESX.ShowNotification("~r~Problèmes~s~: Aucun joueur à proximitée")
		end
  
	  end,
	  function(data, menu)
		  menu.close()
	  end
	)
  end


  ESX = nil

  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local PlayerData = {}
local ped = PlayerPedId()
local vehicle = GetVehiclePedIsIn( ped, false )
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RMenu.Add('rap', 'main', RageUI.CreateMenu("Studio", "Studio"))
RMenu.Add('rap', 'inter', RageUI.CreateMenu("Studio", "Studio"))
RMenu.Add('rap', 'boissons', RageUI.CreateSubMenu(RMenu:Get('rap', 'main'), "Studio", "Studio"))

Citizen.CreateThread(function()
    while true do
        RageUI.IsVisible(RMenu:Get('rap', 'main'), true, true, true, function()

			RageUI.Button("📲 ~o~Gestions des Annonces~", nil, {RightLabel = "→→"},true, function ()
            end, RMenu:Get('rap', 'boissons'))

			RageUI.Button("📋 ~o~Donner une facture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
				if Selected then
					RageUI.CloseAll()        
					OpenBillingMenu() 
				end
			end)

			RageUI.Button("⏳~o~ Fermer le menu", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
				if (Selected) then
					RageUI.CloseAll()
				end
			end)

		end, function()
        end)

		RageUI.IsVisible(RMenu:Get('rap', 'boissons'), true, true, true, function()
					

		RageUI.Button("~g~Annonces d'ouverture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
			if Selected then      
				TriggerServerEvent('AnnonceOuvert')
			end
		end)

		RageUI.Button("~r~Annonces de fermeture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
			if Selected then     
				TriggerServerEvent('AnnonceFermer')
			end
		end)

	RageUI.Button("~b~Annonce recrutement", "Pour annoncer des recrutements au Studio", {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
			if (Selected) then   
			TriggerServerEvent('KRap_job:annoncerecrutement')
		end
		end)

	end, function()
	end)

	RageUI.IsVisible(RMenu:Get('rap', 'inter'), true, true, true, function()

end, function()
end)

Citizen.Wait(0)
end
end)

    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(100)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'rap' then 
        --    RegisterNetEvent('esx_rapjob:onDuty')
            if IsControlJustReleased(0 ,167) then
                RageUI.Visible(RMenu:Get('rap', 'main'), not RageUI.Visible(RMenu:Get('rap', 'main')))
            end
        end
        end
    end)

    RegisterNetEvent('openf6')
    AddEventHandler('openf6', function()
    RageUI.Visible(RMenu:Get('rap', 'main'), not RageUI.Visible(RMenu:Get('rap', 'main')))
    end)
    


		function demenotter()
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer ~= -1 and closestDistance <= 3.0 then
            local target, distance = ESX.Game.GetClosestPlayer()
            playerheading = GetEntityHeading(GetPlayerPed(-1))
            playerlocation = GetEntityForwardVector(PlayerPedId())
            playerCoords = GetEntityCoords(GetPlayerPed(-1))
            local target_id = GetPlayerServerId(target)
            TriggerServerEvent('KRap_job:requestrelease', target_id, playerheading, playerCoords, playerlocation)
            Wait(5000)
			TriggerServerEvent('KRap_job:handcuff', GetPlayerServerId(closestPlayer))
		else
			ESX.ShowNotification('~r~Aucun joueurs à proximité')
			end
        end
	  


		Citizen.CreateThread(function()

			local studiomap = AddBlipForCoord(2472.09, 4086.92, 37.99)
			SetBlipSprite(studiomap, 472)
			SetBlipColour(studiomap, 3)
			SetBlipAsShortRange(unicornmap, true)
	
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString("Studio")
			EndTextCommandSetBlipName(studiomap)
	
	
	end)

	-------garage

RMenu.Add('garageKaito', 'main', RageUI.CreateMenu("Garage", "Pour sortir un vehicule."))

Citizen.CreateThread(function()
    while true do
        RageUI.IsVisible(RMenu:Get('garageKaito', 'main'), true, true, true, function() 
            RageUI.Button("Ranger la voiture", "Pour ranger une voiture.", {RightLabel = "→→→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
            local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
            if dist4 < 4 then
                ESX.ShowAdvancedNotification("Garagiste Kaito", "La voiture est de retour merci!", "", "CHAR_BIKESITE", 1)
                DeleteEntity(veh)
            end 
            end
            end)         
            RageUI.Button("Sortir un véhicule", "Pour sortir une Sultan", {RightLabel = "→→→"},true, function(Hovered, Active, Selected)
            if (Selected) then
            ESX.ShowAdvancedNotification("Garagiste Kaito", "La voiture arrive gros porc !..", "", "CHAR_BIKESITE", 1) 
            Citizen.Wait(2000)   
            spawnuniCar("sultan")
            ESX.ShowAdvancedNotification("Garagiste Kaito", "Abime pas la voiture enculé !", "", "CHAR_BIKESITE", 1) 
            end
            end)
            

            
        end, function()
        end)
            Citizen.Wait(0)
        end
    end)

Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
    

    
                local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
                local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.garage.position.x, Config.pos.garage.position.y, Config.pos.garage.position.z)
            if dist3 <= 3.0 then
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'rap' then    
                    ESX.ShowHelpNotification("Appuyez sur [~b~E~w~] pour accéder au garage")
                    if IsControlJustPressed(1,51) then           
                        RageUI.Visible(RMenu:Get('garageKaito', 'main'), not RageUI.Visible(RMenu:Get('garageKaito', 'main')))
                    end   
                end
               end 
        end
end)

function spawnuniCar(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, Config.pos.spawnvoiture.position.x, Config.pos.spawnvoiture.position.y, Config.pos.spawnvoiture.position.z, Config.pos.spawnvoiture.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "STUDIO"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque) 
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1) 
end
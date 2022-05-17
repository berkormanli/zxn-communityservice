local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}

local isSentenced = false
local communityServiceFinished = false
local actionsRemaining = 0
local availableActions = {}
local disable_actions = false

local broommodel = "prop_tool_broom"
local broom_net = nil

local spatulamodel = "bkr_prop_coke_spatula_04"
local spatula_net = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	Wait(1000)
    PlayerData = QBCore.Functions.GetPlayerData()
	TriggerServerEvent('zxn-communityservice:server:checkIfSentenced')
end)

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    --DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function LocalRequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

local function FillActionTable(last_action)

	while #availableActions < 5 do

		local service_does_not_exist = true

		local random_selection = Config.ServiceLocations[math.random(1,#Config.ServiceLocations)]

		for i = 1, #availableActions do
			if random_selection.coords.x == availableActions[i].coords.x and random_selection.coords.y == availableActions[i].coords.y and random_selection.coords.z == availableActions[i].coords.z then

				service_does_not_exist = false

			end
		end

		if last_action ~= nil and random_selection.coords.x == last_action.coords.x and random_selection.coords.y == last_action.coords.y and random_selection.coords.z == last_action.coords.z then
			service_does_not_exist = false
		end

		if service_does_not_exist then
			table.insert(availableActions, random_selection)
		end

	end

end

local function RemoveAction(action)
	local action_pos = -1

	for i=1, #availableActions do
		if action.coords.x == availableActions[i].coords.x and action.coords.y == availableActions[i].coords.y and action.coords.z == availableActions[i].coords.z then
			action_pos = i
		end
	end

	if action_pos ~= -1 then
		table.remove(availableActions, action_pos)
	else
		print("User tried to remove an unavailable action")
	end
end

local function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function DrawAvailableActions()
	for i = 1, #availableActions do
		DrawMarker(2, availableActions[i].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 30, 30, 30, 100, false, true, 2, true, false, false, false)
	end

end

local function DisableViolentActions()

	if disable_actions == true then
		DisableAllControlActions(0)
	end

	RemoveAllPedWeapons(PlayerPedId(), true)

	DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
	DisablePlayerFiring(PlayerPedId(),true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
    DisableControlAction(0, 106, true) -- Disable in-game mouse controls
    DisableControlAction(0, 140, true)
	DisableControlAction(0, 141, true)
	DisableControlAction(0, 142, true)

	if IsDisabledControlJustPressed(2, 37) then --if Tab is pressed, send error message
		SetCurrentPedWeapon(PlayerPedId(),GetHashKey("WEAPON_UNARMED"),true) -- if tab is pressed it will set them to unarmed (this is to cover the vehicle glitch until I sort that all out)
	end

	if IsDisabledControlJustPressed(0, 106) then --if LeftClick is pressed, send error message
		SetCurrentPedWeapon(PlayerPedId(),GetHashKey("WEAPON_UNARMED"),true) -- If they click it will set them to unarmed
	end

end

local function draw2dText(text, pos)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextScale(0.45, 0.45)
	SetTextColour(255, 255, 255, 255)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(table.unpack(pos))
end

RegisterNetEvent('zxn-communityservice:client:inCommunityService')
AddEventHandler('zxn-communityservice:client:inCommunityService', function(actions_remaining)
	if isSentenced then
		return
	end

	actionsRemaining = actions_remaining

	FillActionTable()

	SetEntityCoords(PlayerPedId(), Config.ServiceLocation.x, Config.ServiceLocation.y, Config.ServiceLocation.z)
	SetEntityHeading(PlayerPedId(), Config.ServiceLocation.h)
	isSentenced = true
	communityServiceFinished = false

    TriggerEvent('zxn-communityservice:client:sendToCommunityService')

	while actionsRemaining > 0 and communityServiceFinished ~= true do
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			ClearPedTasksImmediately(PlayerPedId())
		end

		Citizen.Wait(20000)

		if #(GetEntityCoords(PlayerPedId()) - vector3(Config.ServiceLocation.x, Config.ServiceLocation.y, Config.ServiceLocation.z)) > 45 then
			SetEntityCoords(PlayerPedId(), Config.ServiceLocation.x, Config.ServiceLocation.y, Config.ServiceLocation.z)
			SetEntityHeading(PlayerPedId(), Config.ServiceLocation.h)
            QBCore.Functions.Notify(Lang:t('notify.escape_string'), "error", 5000)
			TriggerServerEvent('zxn-communityservice:server:extendService')
			actionsRemaining = actionsRemaining + Config.ServiceExtensionOnEscape
		end

	end

	TriggerServerEvent('zxn-communityservice:server:finishCommunityService', -1)
	SetEntityCoords(PlayerPedId(), Config.ReleaseLocation.x, Config.ReleaseLocation.y, Config.ReleaseLocation.z)
	SetEntityHeading(PlayerPedId(), Config.ReleaseLocation.h)
	isSentenced = false
end)

RegisterNetEvent('zxn-communityservice:client:finishCommunityService')
AddEventHandler('zxn-communityservice:client:finishCommunityService', function(source)
	communityServiceFinished = true
	isSentenced = false
	actionsRemaining = 0
    exports['qb-core']:HideText()
end)


RegisterNetEvent('zxn-communityservice:client:sendToCommunityService')
AddEventHandler('zxn-communityservice:client:sendToCommunityService', function()
    Citizen.CreateThread(function()
        while actionsRemaining > 0 and isSentenced do
            :: start_over ::
            Citizen.Wait(1)
            DrawAvailableActions()
            DisableViolentActions()

            local pCoords    = GetEntityCoords(PlayerPedId())

            for i = 1, #availableActions do
                local distance = GetDistanceBetweenCoords(pCoords, availableActions[i].coords, true)
                exports['qb-core']:DrawText(Lang:t('text.to_be_finished', {actionCount=actionsRemaining}), 'left')
                if distance < 1.5 then
                    DrawText3D(availableActions[i].coords.x, availableActions[i].coords.y, availableActions[i].coords.z, "[E]")

                    if(IsControlJustReleased(1, 38))then
                        exports['qb-core']:HideText()
                        tmp_action = availableActions[i]
                        RemoveAction(tmp_action)
                        FillActionTable(tmp_action)
                        disable_actions = true

                        TriggerServerEvent('zxn-communityservice:server:completeService')
                        actionsRemaining = actionsRemaining - 1

                        if (tmp_action.type == "cleaning") then
                            local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
                            local broomspawn = CreateObject(GetHashKey(broommodel), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
                            local netid = ObjToNet(broomspawn)

                            LocalRequestAnimDict("amb@world_human_janitor@male@idle_a", function()
                                    TaskPlayAnim(PlayerPedId(), "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false)
                                    AttachEntityToEntity(broomspawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
                                    broom_net = netid
                                end)

								
								QBCore.Functions.Progressbar("cleaning", Lang:t('progressbar.cleaning'), 10000, false, false, {}, {}, {}, {}, function() -- Done
                                    disable_actions = false
                                    DetachEntity(NetToObj(broom_net), 1, 1)
                                    DeleteEntity(NetToObj(broom_net))
                                    broom_net = nil
                                    ClearPedTasks(PlayerPedId())
								end, function() -- Cancel
									StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
									QBCore.Functions.Notify("Failed", "error")
								end)
                        end

                        if (tmp_action.type == "gardening") then
                            local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
                            local spatulaspawn = CreateObject(GetHashKey(spatulamodel), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
                            local netid = ObjToNet(spatulaspawn)

                            TaskStartScenarioInPlace(PlayerPedId(), "world_human_gardener_plant", 0, false)
                            AttachEntityToEntity(spatulaspawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,190.0,190.0,-50.0,1,1,0,1,0,1)
                            spatula_net = netid

								
							QBCore.Functions.Progressbar("gardening", Lang:t('progressbar.gardening'), 14000, false, false, {}, {}, {}, {}, function() -- Done
                                disable_actions = false
                                DetachEntity(NetToObj(spatula_net), 1, 1)
                                DeleteEntity(NetToObj(spatula_net))
                                spatula_net = nil
                                ClearPedTasks(PlayerPedId())
							end, function() -- Cancel
								StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
								QBCore.Functions.Notify("Failed", "error")
							end)
                        end
                        goto start_over
                    end
                end
            end
        end
    end)
end)
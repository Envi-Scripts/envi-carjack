ESX = exports['es_extended']:getSharedObject()

Carjack = function()
    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped)
    local closestPed, closestPedDist = ESX.Game.GetClosestPed(playerPos, nil)
    if closestPed ~= ped and closestPedDist < 2 then
        print(closestPed, closestPedDist)
        local vehicle = GetVehiclePedIsIn(closestPed, false)
        if vehicle ~= 0 then
            if not HasAnimDictLoaded('veh@break_in@0h@p_m_zero@') then
                RequestAnimDict('veh@break_in@0h@p_m_zero@')
                while not HasAnimDictLoaded('veh@break_in@0h@p_m_zero@') do 
                    Wait(0)
                end
            end
            TaskPlayAnim(ped, "veh@break_in@0h@p_m_zero@" ,"std_force_entry_ds" ,8.0, -8.0, -1, 48, 0, false, false, false )            Wait(1000)
            SetRelationshipBetweenGroups(5, `PLAYER`, `PLAYER`)
            SetPedCanBeDraggedOut(closestPed, true)
            TriggerServerEvent('envi-carjack:smash', NetworkGetNetworkIdFromEntity(vehicle))
            TaskEnterVehicle(ped, vehicle, -1, 0, 1.0, 524288, 0)
            Wait(5000)
            SetPedCanBeDraggedOut(closestPed, false)
            RemoveAnimDict('veh@break_in@0h@p_m_zero@')
        end
    end
end

RegisterNetEvent('envi-carjack:smash',function(netID)
    if NetworkDoesNetworkIdExist(netID) and NetworkDoesEntityExistWithNetworkId(netID) then
        SmashVehicleWindow(NetworkGetEntityFromNetworkId(netID),0)
    end
end)

if Config.Target == 'qtarget' then

    local door = {'door_dside_f', 'seat_dside_f' },
    exports['qtarget']:AddTargetBone(door, {
        options = {
            {
                icon = 'fa-solid fa-car-side',
                label = 'Commandeer Vehicle',
                canInteract =     function()
                   return Config.TakeVehWeapons[GetSelectedPedWeapon(PlayerPedId())] ~= nil
                end,
                action = function()
                    Carjack()
                end
            },
        },
    })

elseif Config.Target == 'ox_target' then
    exports.ox_target:addGlobalVehicle({
        {
            name = 'ox_target:carsteal',
            icon = 'fa-solid fa-car-side',
            label = ('Commandeer Vehicle'),
            distance = 1,
            bones = { 'door_dside_f', 'seat_dside_f' },
            canInteract =     function()
                return Config.TakeVehWeapons[GetSelectedPedWeapon(PlayerPedId())] ~= nil
            end,
            onSelect = function()
               Carjack()
            end
        }
    })

else
    RegisterCommand('carjack', function()
        if Config.TakeVehWeapons[GetSelectedPedWeapon(PlayerPedId())] ~= nil then
          Carjack()
        end
    end)   
end

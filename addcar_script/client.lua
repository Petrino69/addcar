ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx_addvehicletogarage:addVehicle')
AddEventHandler('esx_addvehicletogarage:addVehicle', function(targetId, vehicleType)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        TriggerServerEvent('esx_addvehicletogarage:saveVehicle', targetId, vehicleProps, vehicleType)
        ESX.ShowNotification('Your ' .. vehicleType .. ' has been added to the player\'s garage.')
    else
        ESX.ShowNotification('You are not in a vehicle.')
    end
end)
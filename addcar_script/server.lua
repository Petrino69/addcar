ESX = exports["es_extended"]:getSharedObject()

RegisterCommand('addvehicle', function(source, args, user)
    handleAddVehicleCommand(source, args, 'car')
end, false)

RegisterCommand('addplane', function(source, args, user)
    handleAddVehicleCommand(source, args, 'plane')
end, false)

RegisterCommand('addboat', function(source, args, user)
    handleAddVehicleCommand(source, args, 'boat')
end, false)

RegisterCommand('addmotorcycle', function(source, args, user)
    handleAddVehicleCommand(source, args, 'motorcycle')
end, false)

function handleAddVehicleCommand(source, args, vehicleType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if isAllowedGroup(xPlayer.getGroup()) then
        local targetId = tonumber(args[1])
        if targetId then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            if targetPlayer then
                TriggerClientEvent('esx_addvehicletogarage:addVehicle', source, targetId, vehicleType)
            else
                TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Invalid player ID.' } })
            end
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Invalid player ID.' } })
        end
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'You do not have permission to use this command.' } })
    end
end

function isAllowedGroup(group)
    for _, allowedGroup in ipairs(Config.AllowedGroups) do
        if group == allowedGroup then
            return true
        end
    end
    return false
end

RegisterServerEvent('esx_addvehicletogarage:saveVehicle')
AddEventHandler('esx_addvehicletogarage:saveVehicle', function(targetId, vehicleProps, vehicleType)
    local xPlayer = ESX.GetPlayerFromId(targetId)
    exports.oxmysql:execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
        xPlayer.identifier,
        vehicleProps.plate,
        json.encode(vehicleProps)
    }, function(rowsChanged)
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Your ' .. vehicleType .. ' has been added to your garage.')
        sendToDiscord(xPlayer.source, vehicleProps, vehicleType)
    end)
end)

function sendToDiscord(playerId, vehicleProps, vehicleType)
    local headers = {
        ['Content-Type'] = 'application/json'
    }

    local data = {
        username = 'ESX Vehicle Logger',
        embeds = {{
            title = 'Vehicle Added',
            description = 'A ' .. vehicleType .. ' has been added to the garage.',
            color = 3447003,
            fields = {
                { name = 'Player ID', value = playerId, inline = true },
                { name = 'Vehicle Plate', value = vehicleProps.plate, inline = true },
                { name = 'Vehicle Model', value = vehicleProps.model, inline = true }
            },
            footer = {
                text = 'ESX Vehicle Logger'
            },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end
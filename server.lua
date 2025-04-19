ESX = exports['es_extended']:getSharedObject()
ESX.RegisterServerCallback('parking:getOwnedVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
   
    if not xPlayer then
        cb({})
        return
    end
   
    exports.oxmysql:execute('SELECT * FROM owned_vehicles WHERE owner = ?', {
        xPlayer.identifier
    }, function(result)
        cb(result)
    end)
end)

RegisterCommand(Config.CommandNames.BuySpawnSlot, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
   
    if not xPlayer then return end
   
    local money = xPlayer.getAccount(Config.Currency).money
    if money < Config.SpawnFee then
        xPlayer.showNotification(string.format(Config.Notifications.InsufficientFunds, Config.SpawnFee))
        return
    end
   
    xPlayer.removeAccountMoney(Config.Currency, Config.SpawnFee)
   
    xPlayer.showNotification(string.format(Config.Notifications.SlotPurchased, Config.SpawnFee))
   
    TriggerClientEvent('parking:slotPurchased', source)
   
    if Config.Debug then
        print(('Player %s purchased a vehicle spawn slot'):format(
            xPlayer.identifier
        ))
    end
end, false)

RegisterServerEvent('parking:spawnVehicle')
AddEventHandler('parking:spawnVehicle', function(vehicleId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
   
    if not xPlayer then return end
   
    exports.oxmysql:execute('SELECT * FROM owned_vehicles WHERE plate = ? AND owner = ?', {
        vehicleId,
        xPlayer.identifier
    }, function(result)
        if result and result[1] then

            local vehicleProps = json.decode(result[1].vehicle)
           

            TriggerClientEvent('parking:spawnVehicleClient', source, vehicleProps, result[1].plate, result[1].plate)
           

            if Config.Debug then
                print(('Player %s spawned vehicle Plate: %s'):format(
                    xPlayer.identifier, result[1].plate
                ))
            end
        else
            xPlayer.showNotification('Vehicle not found or not owned by you.')
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if Config.Debug then
            print('^7Resource started successfully')
        end
    end
end)

RegisterServerEvent("parking:parkVehicle")
AddEventHandler("parking:parkVehicle", function(plate, coords, heading, props)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local position = json.encode({ x = coords.x, y = coords.y, z = coords.z, h = heading })
    local vehicle = json.encode(props)

    MySQL.update('UPDATE owned_vehicles SET stored = 1, vehicle = ?, parking_data = ? WHERE plate = ? AND owner = ?', {
        vehicle,        
        position,      
        plate,          
        xPlayer.identifier 
    })
end)

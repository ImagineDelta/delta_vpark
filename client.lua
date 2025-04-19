ESX = exports['es_extended']:getSharedObject()

local spawnedVehicles = {}
local hasSpawnSlot = false
local hasUsedFix = false

RegisterCommand('vget', function()
    if not hasSpawnSlot then
        lib.notify({ description = "You don't have an available vehicle slot.", type = "error" })
        return
    end

    ESX.TriggerServerCallback('parking:getOwnedVehicles', function(vehicles)
        if #vehicles > 0 then
            OpenVehicleListMenu(vehicles)
        else
            lib.notify({ description = "You don't own any vehicles.", type = "inform" })
        end
    end)
end, false)

RegisterCommand('vg', function()
    ExecuteCommand('vget')
end, false)

function OpenVehicleListMenu(vehicles)
    local options = {}
    for _, vehicle in ipairs(vehicles) do
        local vehicleProps = json.decode(vehicle.vehicle)
        local modelName = GetDisplayNameFromVehicleModel(vehicleProps.model)
        local label = GetLabelText(modelName) ~= "NULL" and GetLabelText(modelName) or modelName

        local alreadySpawned = false
        for _, v in pairs(spawnedVehicles) do
            if v.plate == vehicle.plate then
                alreadySpawned = true
                break
            end
        end

        if not alreadySpawned then
            table.insert(options, {
                title = '' .. label,
                description = "Plate: " .. vehicle.plate,
                icon = "car",
                onSelect = function()
                    SpawnVehicleMenu(vehicle, label)
                end
            })
        else
            table.insert(options, {
                title = '' .. label .. " [Spawned]",
                description = "Plate: " .. vehicle.plate,
                icon = "ban",
                disabled = true
            })
        end
    end

    lib.registerContext({
        id = 'vehicle_list_menu',
        title = 'Your Vehicles',
        options = options
    })

    lib.showContext('vehicle_list_menu')
end

function SpawnVehicleMenu(vehicle, vehicleName)
    lib.registerContext({
        id = 'vehicle_spawn_menu',
        title = '' .. vehicleName,
        menu = 'vehicle_list_menu',
        options = {
            {
                title = 'Spawn Vehicle',
                description = 'Spawn this vehicle nearby',
                icon = "car",
                onSelect = function()
                    TriggerServerEvent('parking:spawnVehicle', vehicle.plate)
                end
            }
        }
    })

    lib.showContext('vehicle_spawn_menu')
end

RegisterNetEvent('parking:spawnVehicleClient', function(vehicleProps, vehicleId, plate)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local spawnCoords = vector3(coords.x, coords.y + 3.0, coords.z)

    RequestModel(vehicleProps.model)
    local timeout = 0
    while not HasModelLoaded(vehicleProps.model) and timeout < 50 do
        timeout += 1
        Wait(100)
    end

    if not HasModelLoaded(vehicleProps.model) then
        lib.notify({ description = "Failed to load vehicle model.", type = "error" })
        return
    end

    local vehicle = CreateVehicle(vehicleProps.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)

    if not DoesEntityExist(vehicle) then
        lib.notify({ description = "Failed to create vehicle.", type = "error" })
        SetModelAsNoLongerNeeded(vehicleProps.model)
        return
    end

    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
    SetVehicleOnGroundProperly(vehicle)

    table.insert(spawnedVehicles, { id = vehicleId, entity = vehicle, plate = plate })
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)

    hasSpawnSlot = false
    hasUsedFix = false

    local displayName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps.model)) ~= "NULL"
        and GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps.model))
        or GetDisplayNameFromVehicleModel(vehicleProps.model)

    lib.notify({ description = ('%s has been spawned!'):format(displayName), type = "success" })
    SetModelAsNoLongerNeeded(vehicleProps.model)
end)

RegisterNetEvent('parking:slotPurchased', function()
    hasSpawnSlot = true
end)

RegisterCommand("vpark", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then 
        lib.notify({ type = 'error', description = 'You are not in a vehicle!' })
        return 
    end

    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        lib.notify({ type = 'error', description = 'You must be the driver!' })
        return
    end

    local props = ESX.Game.GetVehicleProperties(vehicle)
    
    local plate = GetVehicleNumberPlateText(vehicle)
    
    local coords = GetEntityCoords(vehicle)
    local heading = GetEntityHeading(vehicle)

    TriggerServerEvent("parking:parkVehicle", plate, coords, heading, props)

    lib.notify({ type = 'success', description = 'Vehicle parked!' })

    DeleteVehicle(vehicle)
end)


RegisterCommand('vp', function()
    ExecuteCommand('vpark')
end, false)

RegisterCommand('fixveh', function()
    if hasUsedFix then
        lib.notify({ description = "You've already used /fixveh for this vehicle.", type = "error" })
        return
    end

    if #spawnedVehicles == 0 then
        lib.notify({ description = "You don't have any vehicle spawned.", type = "error" })
        return
    end

    local vehicle = spawnedVehicles[#spawnedVehicles].entity

    if not DoesEntityExist(vehicle) then
        lib.notify({ description = "Your vehicle no longer exists.", type = "error" })
        return
    end

    if GetVehicleNumberOfPassengers(vehicle) > 0 or IsPedInVehicle(GetPlayerPed(-1), vehicle, true) then
        lib.notify({ description = "Nobody can be inside the vehicle to use /fixveh.", type = "error" })
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    SetEntityCoords(vehicle, coords.x, coords.y + 3.0, coords.z, false, false, false, true)
    SetVehicleOnGroundProperly(vehicle)

    hasUsedFix = true
    lib.notify({ description = "Your vehicle has been teleported to you.", type = "success" })
end, false)

CreateThread(function()
    while true do
        Wait(5000)
        for i, vehicle in ipairs(spawnedVehicles) do
            if not DoesEntityExist(vehicle.entity) or IsEntityDead(vehicle.entity) then
                table.remove(spawnedVehicles, i)
                break
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, vehicle in ipairs(spawnedVehicles) do
            if DoesEntityExist(vehicle.entity) then
                DeleteEntity(vehicle.entity)
            end
        end
    end
end)

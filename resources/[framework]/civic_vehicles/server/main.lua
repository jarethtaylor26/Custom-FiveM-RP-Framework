local function notify(source, message)
    exports.civic_core:Notify(source, message)
end

RegisterCommand('buyvehicle', function(source, args)
    if source == 0 then return end
    local modelName = string.lower(tostring(args[1] or ''))
    local vehicle = CivicVehicleCatalog[modelName]
    if not vehicle then
        notify(source, 'Usage: /buyvehicle [blista|prairie|stanier]')
        return
    end
    local player = exports.civic_core:GetPlayer(source)
    if not player then
        notify(source, 'Your character is still loading.')
        return
    end
    if not exports.civic_core:RemoveMoney(source, 'bank', vehicle.price, 'vehicle purchase') then
        notify(source, 'Not enough money in your bank account.')
        return
    end
    local owned = exports.civic_core:AddVehicle(source, {
        model = modelName,
        label = vehicle.label
    })
    if not owned then
        exports.civic_core:AddMoney(source, 'bank', vehicle.price, 'vehicle purchase refund')
        notify(source, 'Could not save the vehicle purchase; your payment was refunded.')
        return
    end
    exports.civic_core:SavePlayer(source)
    notify(source, ('Purchased %s for $%d. Use /myvehicles to view it.'):format(vehicle.label, vehicle.price))
end, false)

RegisterCommand('myvehicles', function(source)
    if source == 0 then return end
    local player = exports.civic_core:GetPlayer(source)
    if not player then return end
    if #player.vehicles == 0 then
        notify(source, 'You do not own any vehicles. Use /buyvehicle [model].')
        return
    end
    TriggerClientEvent('civic_vehicles:client:list', source, player.vehicles)
end, false)

RegisterCommand('spawnvehicle', function(source, args)
    if source == 0 then return end
    local player = exports.civic_core:GetPlayer(source)
    local index = math.floor(tonumber(args[1]) or 0)
    local owned = player and player.vehicles[index]
    if not owned then
        notify(source, 'Usage: /spawnvehicle [number from /myvehicles]')
        return
    end
    TriggerClientEvent('civic_vehicles:client:spawn', source, owned.model, owned.plate)
end, false)

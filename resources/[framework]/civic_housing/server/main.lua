local function notify(source, message)
    exports.civic_core:Notify(source, message)
end

RegisterCommand('buyhome', function(source, args)
    if source == 0 then return end
    local homeId = string.lower(tostring(args[1] or ''))
    local home = CivicHomes[homeId]
    local player = exports.civic_core:GetPlayer(source)
    if not home then
        notify(source, 'Usage: /buyhome [grove|delperro]')
        return
    end
    if not player then
        notify(source, 'Your character is still loading.')
        return
    end
    for _, owned in ipairs(player.homes or {}) do
        if owned.id == homeId then
            notify(source, 'You already own this property.')
            return
        end
    end
    if not exports.civic_core:RemoveMoney(source, 'bank', home.price, 'property purchase') then
        notify(source, 'Not enough money in your bank account.')
        return
    end
    if not exports.civic_core:AddHome(source, homeId) then
        exports.civic_core:AddMoney(source, 'bank', home.price, 'property purchase refund')
        notify(source, 'Could not save the property purchase; your payment was refunded.')
        return
    end
    exports.civic_core:SavePlayer(source)
    notify(source, ('Purchased %s for $%d.'):format(home.label, home.price))
end, false)

RegisterCommand('myhomes', function(source)
    if source == 0 then return end
    local player = exports.civic_core:GetPlayer(source)
    if not player then return end
    if #player.homes == 0 then
        notify(source, 'You do not own a property. Use /buyhome [grove|delperro].')
        return
    end
    TriggerClientEvent('civic_housing:client:list', source, player.homes)
end, false)

RegisterCommand('enterhome', function(source, args)
    if source == 0 then return end
    local homeId = string.lower(tostring(args[1] or ''))
    local player = exports.civic_core:GetPlayer(source)
    if not player then return end
    for _, owned in ipairs(player.homes or {}) do
        if owned.id == homeId and CivicHomes[homeId] then
            TriggerClientEvent('civic_housing:client:enter', source, homeId)
            return
        end
    end
    notify(source, 'You do not own that property.')
end, false)

RegisterCommand('exithome', function(source)
    if source == 0 then return end
    TriggerClientEvent('civic_housing:client:exit', source)
end, false)

RegisterNetEvent('civic_housing:server:requestExit', function()
    TriggerClientEvent('civic_housing:client:exit', source)
end)

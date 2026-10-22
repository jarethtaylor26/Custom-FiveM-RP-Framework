local function notify(source, message)
    exports.civic_core:Notify(source, message)
end

local function getPlayer(source)
    return exports.civic_core:GetPlayer(source)
end

RegisterCommand('inventory', function(source)
    if source == 0 then return end
    local player = getPlayer(source)
    if not player then
        notify(source, 'Your character is still loading.')
        return
    end
    TriggerClientEvent('civic_inventory:client:show', source, player.inventory or {})
end, false)

RegisterCommand('useitem', function(source, args)
    if source == 0 then return end
    TriggerEvent('civic_inventory:server:useItem', source, tostring(args[1] or ''))
end, false)

RegisterCommand('giveitem', function(source, args)
    local target = tonumber(args[1])
    local itemName = tostring(args[2] or '')
    local amount = math.floor(tonumber(args[3]) or 1)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'civic.admin') then
        notify(source, 'You do not have permission to use this command.')
        return
    end
    if not target or not CivicItems[itemName] or amount < 1 or amount > 100 then
        if source ~= 0 then notify(source, 'Usage: /giveitem [player id] [item] [amount]') end
        return
    end
    if exports.civic_core:AddItem(target, itemName, amount) then
        notify(target, ('Received %dx %s.'):format(amount, CivicItems[itemName].label))
        if source ~= 0 then notify(source, 'Item added.') end
    else
        if source ~= 0 then notify(source, 'Could not add the item; inventory may be full.') end
    end
end, false)

RegisterNetEvent('civic_inventory:server:useItem', function(requestedSource, itemName)
    local sourceId = tonumber(requestedSource) or source
    if source ~= 0 and source ~= sourceId then return end
    if sourceId < 1 or type(itemName) ~= 'string' then return end
    local definition = CivicItems[itemName]
    if not definition or not definition.usable then
        notify(sourceId, 'That item cannot be used.')
        return
    end
    local player = getPlayer(sourceId)
    if not player then return end
    local hasItem = false
    for _, item in ipairs(player.inventory or {}) do
        if item.name == itemName and item.count > 0 then
            hasItem = true
            break
        end
    end
    if not hasItem or not exports.civic_core:RemoveItem(sourceId, itemName, 1) then
        notify(sourceId, 'You do not have that item.')
        return
    end

    if itemName == 'bandage' then
        TriggerClientEvent('civic_inventory:client:heal', sourceId, 20)
    end
    notify(sourceId, ('Used %s.'):format(definition.label))
end)

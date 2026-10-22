RegisterNetEvent('civic_inventory:client:show', function(items)
    TriggerEvent('chat:addMessage', {
        color = { 117, 211, 190 },
        args = { 'Inventory', 'Use /useitem [name]. Items:' }
    })
    for _, item in ipairs(items or {}) do
        local definition = CivicItems[item.name]
        local label = definition and definition.label or item.name
        TriggerEvent('chat:addMessage', {
            color = { 220, 226, 230 },
            args = { label, ('x%d  |  /useitem %s'):format(item.count or 0, item.name) }
        })
    end
    if not items or #items == 0 then
        TriggerEvent('chat:addMessage', {
            color = { 220, 226, 230 },
            args = { 'Inventory', 'Your inventory is empty.' }
        })
    end
end)

RegisterNetEvent('civic_inventory:client:changed', function()
    TriggerEvent('civic:client:inventoryChanged')
end)

RegisterNetEvent('civic_inventory:client:heal', function(amount)
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    local maximum = GetEntityMaxHealth(ped)
    SetEntityHealth(ped, math.min(maximum, health + (tonumber(amount) or 0)))
end)

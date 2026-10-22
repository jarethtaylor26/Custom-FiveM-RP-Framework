local activeHome = nil

RegisterNetEvent('civic_housing:client:list', function(homes)
    TriggerEvent('chat:addMessage', {
        color = { 117, 211, 190 },
        args = { 'Housing', 'Use /enterhome [id] to enter an owned property.' }
    })
    for _, owned in ipairs(homes or {}) do
        local definition = CivicHomes[owned.id]
        TriggerEvent('chat:addMessage', {
            color = { 220, 226, 230 },
            args = { owned.id, definition and definition.label or owned.id }
        })
    end
end)

RegisterNetEvent('civic_housing:client:enter', function(homeId)
    local home = CivicHomes[homeId]
    if not home then return end
    local ped = PlayerPedId()
    SetEntityCoords(ped, home.inside.x, home.inside.y, home.inside.z, false, false, false, false)
    SetEntityHeading(ped, home.inside.w)
    activeHome = homeId
    TriggerEvent('civic_core:client:notify', ('Entered %s. Use /exithome to leave.'):format(home.label))
end)

RegisterNetEvent('civic_housing:client:exit', function()
    if not activeHome or not CivicHomes[activeHome] then
        TriggerEvent('civic_core:client:notify', 'You are not inside a property.')
        return
    end
    local outside = CivicHomes[activeHome].outside
    local ped = PlayerPedId()
    SetEntityCoords(ped, outside.x, outside.y, outside.z, false, false, false, false)
    SetEntityHeading(ped, outside.w)
    activeHome = nil
end)

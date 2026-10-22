RegisterNetEvent('civic_vehicles:client:list', function(vehicles)
    TriggerEvent('chat:addMessage', {
        color = { 117, 211, 190 },
        args = { 'Vehicles', 'Use /spawnvehicle [number] to retrieve a vehicle.' }
    })
    for index, vehicle in ipairs(vehicles or {}) do
        TriggerEvent('chat:addMessage', {
            color = { 220, 226, 230 },
            args = { tostring(index), ('%s  |  %s'):format(vehicle.label or vehicle.model, vehicle.plate or 'No plate') }
        })
    end
end)

RegisterNetEvent('civic_vehicles:client:spawn', function(modelName, plate)
    local model = joaat(tostring(modelName or ''))
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        TriggerEvent('civic_core:client:notify', 'That vehicle model is unavailable.')
        return
    end
    RequestModel(model)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    if not HasModelLoaded(model) then
        TriggerEvent('civic_core:client:notify', 'The vehicle model did not load.')
        return
    end

    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    if vehicle and vehicle ~= 0 then
        SetVehicleNumberPlateText(vehicle, tostring(plate or 'CIVIC'))
        SetPedIntoVehicle(ped, vehicle, -1)
        SetEntityAsMissionEntity(vehicle, true, true)
    end
    SetModelAsNoLongerNeeded(model)
end)

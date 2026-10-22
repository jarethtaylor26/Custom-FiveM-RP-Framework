local PlayerData = nil

RegisterNetEvent('civic_core:client:loaded', function(data)
    PlayerData = data
    TriggerEvent('civic:client:playerLoaded', data)
end)

RegisterNetEvent('civic_core:client:notify', function(message)
    TriggerEvent('chat:addMessage', {
        color = { 117, 211, 190 },
        args = { 'Civic', tostring(message) }
    })
end)

RegisterNetEvent('civic_core:client:moneyChanged', function(money)
    if PlayerData then PlayerData.money = money end
    TriggerEvent('civic:client:moneyChanged', money)
end)

RegisterNetEvent('civic_core:client:jobChanged', function(job)
    if PlayerData then PlayerData.job = job end
    TriggerEvent('civic:client:jobChanged', job)
end)

exports('GetPlayerData', function()
    return PlayerData
end)

CreateThread(function()
    Wait(1500)
    TriggerServerEvent('civic_core:server:load')
end)

local resourceName = GetCurrentResourceName()
local playersBySource = {}
local playersByLicense = {}
local persistedPlayers = {}

local function getLicense(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:sub(1, 8) == 'license:' then
            return identifier
        end
    end
    return nil
end

local function makeCitizenId()
    return ('C%05d%04d'):format(os.time() % 100000, math.random(0, 9999))
end

local function freshPlayer(source, license)
    local displayName = GetPlayerName(source) or 'Unknown'
    return {
        citizenid = makeCitizenId(),
        license = license,
        name = displayName,
        money = {
            cash = CivicConfig.StartingMoney.cash,
            bank = CivicConfig.StartingMoney.bank
        },
        job = {
            name = CivicConfig.DefaultJob,
            label = CivicConfig.Jobs[CivicConfig.DefaultJob].label,
            grade = 0,
            gradeLabel = CivicConfig.Jobs[CivicConfig.DefaultJob].grades[0]
        },
        inventory = {},
        vehicles = {},
        homes = {},
        metadata = {
            createdAt = os.time(),
            lastSeen = os.time()
        }
    }
end

local function readStorage()
    local raw = LoadResourceFile(resourceName, 'data/players.json')
    if not raw or raw == '' then
        return {}
    end

    local ok, decoded = pcall(json.decode, raw)
    if not ok or type(decoded) ~= 'table' then
        print(('[%s] Could not decode data/players.json; starting with empty storage.'):format(resourceName))
        return {}
    end
    return decoded
end

local function saveStorage()
    local encoded = json.encode(persistedPlayers)
    if not encoded then
        print(('[%s] Failed to encode player data; storage was not written.'):format(resourceName))
        return false
    end

    local saved = SaveResourceFile(resourceName, 'data/players.json', encoded, -1)
    if not saved then
        print(('[%s] Failed to write data/players.json.'):format(resourceName))
        return false
    end
    return true
end

local function getPlayer(source)
    return playersBySource[tonumber(source)]
end

local function savePlayer(source)
    local player = getPlayer(source)
    if not player then return false end
    player.name = GetPlayerName(source) or player.name
    player.metadata.lastSeen = os.time()
    persistedPlayers[player.license] = player
    playersByLicense[player.license] = player
    return saveStorage()
end

local function loadPlayer(source)
    if playersBySource[source] then return end
    local license = getLicense(source)
    if not license then
        DropPlayer(source, 'A FiveM license identifier is required to save player data.')
        return
    end

    local player = persistedPlayers[license]
    if not player then
        player = freshPlayer(source, license)
    else
        player.name = GetPlayerName(source) or player.name
        player.money = player.money or { cash = 0, bank = 0 }
        player.inventory = player.inventory or {}
        player.vehicles = player.vehicles or {}
        player.homes = player.homes or {}
        player.metadata = player.metadata or {}
        player.metadata.lastSeen = os.time()
    end

    playersBySource[source] = player
    playersByLicense[license] = player
    persistedPlayers[license] = player
    saveStorage()
    TriggerClientEvent('civic_core:client:loaded', source, player)
    print(('[%s] Loaded %s (%s).'):format(resourceName, player.name, player.citizenid))
end

local function notify(source, message)
    TriggerClientEvent('civic_core:client:notify', source, tostring(message))
end

local function addMoney(source, account, amount, reason)
    local player = getPlayer(source)
    amount = math.floor(tonumber(amount) or 0)
    if not player or (account ~= 'cash' and account ~= 'bank') or amount <= 0 then
        return false
    end
    player.money[account] = (tonumber(player.money[account]) or 0) + amount
    TriggerClientEvent('civic_core:client:moneyChanged', source, player.money)
    if reason then
        print(('[%s] %s received $%d %s (%s).'):format(resourceName, player.citizenid, amount, account, tostring(reason)))
    end
    return true
end

local function removeMoney(source, account, amount, reason)
    local player = getPlayer(source)
    amount = math.floor(tonumber(amount) or 0)
    if not player or (account ~= 'cash' and account ~= 'bank') or amount <= 0 then
        return false
    end
    local balance = tonumber(player.money[account]) or 0
    if balance < amount then return false end
    player.money[account] = balance - amount
    TriggerClientEvent('civic_core:client:moneyChanged', source, player.money)
    if reason then
        print(('[%s] %s paid $%d %s (%s).'):format(resourceName, player.citizenid, amount, account, tostring(reason)))
    end
    return true
end

local function addItem(source, itemName, count, metadata)
    local player = getPlayer(source)
    count = math.floor(tonumber(count) or 0)
    if not player or type(itemName) ~= 'string' or itemName == '' or count < 1 then
        return false
    end

    for _, item in ipairs(player.inventory) do
        if item.name == itemName then
            item.count = item.count + count
            TriggerClientEvent('civic_inventory:client:changed', source)
            return true
        end
    end

    if #player.inventory >= CivicConfig.MaxInventorySlots then return false end
    player.inventory[#player.inventory + 1] = {
        name = itemName,
        count = count,
        metadata = type(metadata) == 'table' and metadata or {}
    }
    TriggerClientEvent('civic_inventory:client:changed', source)
    return true
end

local function removeItem(source, itemName, count)
    local player = getPlayer(source)
    count = math.floor(tonumber(count) or 0)
    if not player or type(itemName) ~= 'string' or count < 1 then return false end

    for index, item in ipairs(player.inventory) do
        if item.name == itemName and item.count >= count then
            item.count = item.count - count
            if item.count == 0 then table.remove(player.inventory, index) end
            TriggerClientEvent('civic_inventory:client:changed', source)
            return true
        end
    end
    return false
end

local function addVehicle(source, vehicle)
    local player = getPlayer(source)
    if not player or type(vehicle) ~= 'table' or type(vehicle.model) ~= 'string' then return false end
    player.vehicles[#player.vehicles + 1] = {
        id = ('V%05d'):format(math.random(0, 99999)),
        model = vehicle.model,
        label = tostring(vehicle.label or vehicle.model),
        plate = ('CV%04d'):format(math.random(0, 9999)),
        purchasedAt = os.time()
    }
    return player.vehicles[#player.vehicles]
end

local function addHome(source, homeId)
    local player = getPlayer(source)
    if not player or type(homeId) ~= 'string' then return false end
    for _, existing in ipairs(player.homes) do
        if existing.id == homeId then return false end
    end
    player.homes[#player.homes + 1] = { id = homeId, purchasedAt = os.time() }
    return true
end

exports('GetPlayer', getPlayer)
exports('GetPlayerData', getPlayer)
exports('GetPlayers', function() return playersBySource end)
exports('AddMoney', addMoney)
exports('RemoveMoney', removeMoney)
exports('AddItem', addItem)
exports('RemoveItem', removeItem)
exports('AddVehicle', addVehicle)
exports('AddHome', addHome)
exports('SavePlayer', savePlayer)
exports('Notify', notify)

RegisterNetEvent('civic_core:server:load', function()
    loadPlayer(source)
end)

RegisterNetEvent('civic_core:server:requestData', function()
    local src = source
    local player = getPlayer(src)
    if player then TriggerClientEvent('civic_core:client:loaded', src, player) end
end)

RegisterCommand('cash', function(source)
    if source == 0 then return end
    local player = getPlayer(source)
    if player then notify(source, ('Cash: $%d | Bank: $%d'):format(player.money.cash, player.money.bank)) end
end, false)

RegisterCommand('job', function(source)
    if source == 0 then return end
    local player = getPlayer(source)
    if player then
        notify(source, ('Job: %s — %s'):format(player.job.label, player.job.gradeLabel))
    end
end, false)

RegisterCommand('setjob', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'civic.admin') then
        notify(source, 'You do not have permission to use this command.')
        return
    end
    local target = tonumber(args[1])
    local jobName = tostring(args[2] or '')
    local grade = math.floor(tonumber(args[3]) or 0)
    local player = target and getPlayer(target)
    local definition = CivicConfig.Jobs[jobName]
    if not player or not definition or not definition.grades[grade] then
        if source ~= 0 then notify(source, 'Usage: /setjob [player id] [job] [grade]') end
        return
    end
    player.job = {
        name = jobName,
        label = definition.label,
        grade = grade,
        gradeLabel = definition.grades[grade]
    }
    TriggerClientEvent('civic_core:client:jobChanged', target, player.job)
    notify(target, ('Your job is now %s — %s.'):format(player.job.label, player.job.gradeLabel))
    if source ~= 0 then notify(source, ('Updated %s.'):format(player.name)) end
end, false)

AddEventHandler('playerDropped', function()
    local src = source
    local player = getPlayer(src)
    if player then
        savePlayer(src)
        playersBySource[src] = nil
        playersByLicense[player.license] = nil
    end
end)

CreateThread(function()
    persistedPlayers = readStorage()
    for _, player in pairs(persistedPlayers) do
        if player.license then playersByLicense[player.license] = player end
    end

    for _, playerId in ipairs(GetPlayers()) do
        loadPlayer(tonumber(playerId))
    end

    while true do
        Wait((CivicConfig.AutoSaveMinutes or 5) * 60 * 1000)
        for source in pairs(playersBySource) do savePlayer(source) end
    end
end)

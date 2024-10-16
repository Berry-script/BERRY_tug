local QBCore = exports['qb-core']:GetCoreObject()
local deadDrivers = {}

-- Event handler for when a driver dies
RegisterNetEvent('tugboat:server:driverDied')
AddEventHandler('tugboat:server:driverDied', function(driverNetId)
    deadDrivers[driverNetId] = true
    TriggerClientEvent('tugboat:client:addLootOption', -1, driverNetId)
end)

-- Event handler for looting the driver
RegisterNetEvent('tugboat:server:lootDriver')
AddEventHandler('tugboat:server:lootDriver', function(driverNetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if deadDrivers[driverNetId] then
        for _, item in ipairs(Config.LootItems) do
            local amount = math.random(item.amount.min, item.amount.max)
            Player.Functions.AddItem(item.name, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add", amount)
        end
        
        deadDrivers[driverNetId] = nil
        TriggerClientEvent('tugboat:client:removeLootOption', -1, driverNetId)
        TriggerClientEvent('QBCore:Notify', src, 'You looted the tugboat driver', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'This driver has already been looted', 'error')
    end
end)

QBCore.Functions.CreateCallback('tugboat:server:spawnTugboat', function(source, cb, location)
    local tugboatHash = GetHashKey(Config.TugboatModel)
    local driverHash = GetHashKey(Config.DriverModel)

    local driver = CreatePed(4, driverHash, location.coords.x, location.coords.y, location.coords.z, location.coords.w, true, false)
    -- クライアントに無敵バフを付与
    TriggerClientEvent('tugboat:client:muteki', -1, driverHash)



    local tugboat = CreateVehicle(tugboatHash, location.coords.x, location.coords.y, location.coords.z, location.coords.w, true, true)


    while not DoesEntityExist(tugboat) or not DoesEntityExist(driver) do
        Wait(0)
    end

    local tugboatNetId = NetworkGetNetworkIdFromEntity(tugboat)
    local driverNetId = NetworkGetNetworkIdFromEntity(driver)


    -- サーバーサイドでは運転席に座らせない
    -- 代わりに、クライアントサイドで処理する

    TriggerClientEvent('tugboat:client:entityCreated', -1, tugboatNetId, driverNetId, location)

    cb({tugboat = tugboatNetId, driver = driverNetId})
end)

-- Event handler for looting the driver
RegisterNetEvent('tugboat:server:lootDriver', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    for _, item in ipairs(Config.LootItems) do
        local amount = math.random(item.amount.min, item.amount.max)
        Player.Functions.AddItem(item.name, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add", amount)
    end
    
    TriggerClientEvent('QBCore:Notify', src, 'You looted the tugboat driver', 'success')
end)
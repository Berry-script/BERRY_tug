local QBCore = exports['qb-core']:GetCoreObject()
local spawnedTugboats = {}

-- Function to spawn tugboat and driver
local function SpawnTugboat(location)
    QBCore.Functions.TriggerCallback('tugboat:server:spawnTugboat', function(netIds)
        local tugboatNetId = netIds.tugboat
        local driverNetId = netIds.driver

        local tugboat = NetworkGetEntityFromNetworkId(tugboatNetId)
        local driver = NetworkGetEntityFromNetworkId(driverNetId)

        SetEntityAsMissionEntity(tugboat, true, true)
        SetEntityAsMissionEntity(driver, true, true)

        SetPedIntoVehicle(driver, tugboat, -1)

        TaskVehicleDriveWander(driver, tugboat, 10.0, 786603)

        table.insert(spawnedTugboats, {boat = tugboat, driver = driver})
    end, location)
end

-- Command to spawn tugboat
RegisterCommand('starttug', function()
    local randomLocation = Config.SpawnLocations[math.random(#Config.SpawnLocations)]
    SpawnTugboat(randomLocation)
    QBCore.Functions.Notify('Tugboat spawned', 'success')
end, false)

-- Function to add loot option to dead driver (now called from server)
RegisterNetEvent('tugboat:client:addLootOption')
AddEventHandler('tugboat:client:addLootOption', function(driverNetId)
    local driver = NetworkGetEntityFromNetworkId(driverNetId)
    if DoesEntityExist(driver) then
        exports.ox_target:addLocalEntity(driver, {
            {
                name = 'loot_tugboat_driver',
                icon = 'fas fa-hand-paper',
                label = 'Loot Driver',
                onSelect = function()
                    if lib.progressBar({
                        duration = 10000,
                        label = '運転手を捜索中',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bum_bin@base',
                            clip = 'base'
                        },
                    }) then
                        TriggerServerEvent('tugboat:server:lootDriver', driverNetId)
                    end
                end
            }
        })
    end
end)

-- Event to remove loot option (called from server after successful looting)
RegisterNetEvent('tugboat:client:removeLootOption')
AddEventHandler('tugboat:client:removeLootOption', function(driverNetId)
    local driver = NetworkGetEntityFromNetworkId(driverNetId)
    if DoesEntityExist(driver) then
        exports.ox_target:removeLocalEntity(driver, 'loot_tugboat_driver')
    end
end)

-- Thread to check for dead drivers
CreateThread(function()
    while true do
        Wait(1000)
        for i, tugboat in ipairs(spawnedTugboats) do
            if DoesEntityExist(tugboat.driver) and IsEntityDead(tugboat.driver) then
                local driverNetId = NetworkGetNetworkIdFromEntity(tugboat.driver)
                TriggerServerEvent('tugboat:server:driverDied', driverNetId)
                table.remove(spawnedTugboats, i)
            end
        end
    end
end)

-- Event to handle entity creation
RegisterNetEvent('tugboat:client:entityCreated')
AddEventHandler('tugboat:client:entityCreated', function(tugboatNetId, driverNetId, location)
    local tugboat = NetworkGetEntityFromNetworkId(tugboatNetId)
    local driver = NetworkGetEntityFromNetworkId(driverNetId)

    if DoesEntityExist(tugboat) and DoesEntityExist(driver) then
        SetEntityAsMissionEntity(tugboat, true, true)
        SetEntityAsMissionEntity(driver, true, true)

        
        TaskVehicleDriveWander(driver, tugboat, 10.0, 786603)

        TaskWarpPedIntoVehicle(driver, tugboat, -1)
        SetVehicleEngineOn(tugboat, true, true, false)
        TaskVehicleDriveWander(driver, tugboat, 10.0, 786603)
    end
end)

RegisterNetEvent('tugboat:client:muteki')
AddEventHandler('tugboat:client:muteki', function(driverNetId)
    local driver = NetworkGetEntityFromNetworkId(driverNetId)
    if DoesEntityExist(driver) then
        SetEntityInvincible(driver, true)
        Citizen.Wait(2000)
        SetEntityInvincible(driver, false)
    end
end)
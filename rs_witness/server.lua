local VorpCore = {}
local Core = exports.vorp_core:GetCore()
TriggerEvent("getCore", function(core) VorpCore = core end)

local escapePlayers = {}

RegisterNetEvent("rs_witness:GetCharacterName")
AddEventHandler("rs_witness:GetCharacterName", function(coords, hasNeckwear, townName)
    local _source = source

    if escapePlayers[_source] then return end

    local user = VorpCore.getUser(_source)
    if user then
        local character = user.getUsedCharacter
        if character then
            local playerName = character.firstname .. " " .. character.lastname
            TriggerEvent("rs_witness:CheckJob", _source, playerName, coords, hasNeckwear, townName)
        end
    end
end)

RegisterNetEvent("rs_witness:CheckJob")
AddEventHandler("rs_witness:CheckJob", function(player, playerName, coords, hasNeckwear, townName)
    if type(townName) == "table" then
        townName = "Ubicación desconocida"
    end

    local policePlayers = {}
    local players = GetPlayers()

    for _, playerId in ipairs(players) do
        local user = VorpCore.getUser(playerId)
        if user then
            local character = user.getUsedCharacter
            if character then
                for _, job in ipairs(Config.Jobs) do
                    if character.job == job then
                        table.insert(policePlayers, playerId)

                        local dict, icon, color, duration = "generic_textures", "tick", "COLOR_RED", 18000

                        if hasNeckwear then
                            local hoodedMessage = Config.Notifications.crime .. townName .. Config.Notifications.hooded
                            VorpCore.NotifyAvanced(playerId, hoodedMessage, dict, icon, color, duration)
                        else
                            local policeAlertMessage = playerName .. Config.Notifications.policeAlertMessage .. townName
                            VorpCore.NotifyAvanced(playerId, policeAlertMessage, dict, icon, color, duration)
                        end
                        break
                    end
                end
            end
        end
    end

    escapePlayers[player] = os.time()

    if Config.EscapeNotification.enabled then
        VorpCore.NotifyAvanced(player, Config.Notifications.player, "generic_textures", "tick", "COLOR_BLUE", 10000)
    else
        VorpCore.NotifyAvanced(player, Config.Notifications.playerAlt, "generic_textures", "tick", "COLOR_BLUE", 10000)
    end

    local blips = {}
    local ped = GetPlayerPed(player)
    local playerCoords = GetEntityCoords(ped)

    if Config.EscapeNotification.enabled then
        for _, policeId in ipairs(policePlayers) do
            TriggerClientEvent("rs_witness:TriggerEscapeNotification", policeId)
            local blip = TriggerClientEvent('rs_witness:marcador', policeId, playerCoords, "escape", -2018361632)
            blips[policeId] = blip
        end

        for i = 1, 10 do
            Citizen.Wait(30000)

            ped = GetPlayerPed(player)
            playerCoords = GetEntityCoords(ped)

            if i % 2 == 0 then
                for policeId, blip in pairs(blips) do
                    TriggerClientEvent('rs_witness:remover_marcador', policeId, blip)
                    blips[policeId] = nil
                end
            end

            for _, policeId in ipairs(policePlayers) do
                TriggerClientEvent("rs_witness:TriggerEscapeNotification", policeId)
                local newBlip = TriggerClientEvent('rs_witness:marcador', policeId, playerCoords, "escape", -2018361632)
                blips[policeId] = newBlip
            end
        end

        Citizen.Wait(15000)
        for policeId, blip in pairs(blips) do
            TriggerClientEvent('rs_witness:remover_marcador', policeId, blip)
        end
    end

    escapePlayers[player] = nil

    TriggerClientEvent("rs_witness:FinalizarTestigo", player)
end)
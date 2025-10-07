local Core = exports.vorp_core:GetCore()
local witnessActive = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if IsPedShooting(PlayerPedId()) and not witnessActive then
            local retval, target = GetEntityPlayerIsFreeAimingAt(PlayerId())

            if GetPedType(target) == 4 or GetPedType(target) == 5 or GetPedType(target) == 2 then
                local random = math.random(1, 100)

                if random <= Config.WitnessProbability then
                     witnessActive = true
                    CreateWitness(target)
                end
            end
        end
    end
end)

function CreateWitness(target)
    local coords = GetEntityCoords(PlayerPedId())

    local excludedModels = Config.ExcludedModels
    local targetModel = GetEntityModel(target)

    for _, model in ipairs(excludedModels) do
        if targetModel == model then return end
    end

    local witness = GetClosestPed(target, coords)

    if witness ~= nil then
        Core.NotifyAvanced(Config.Notifications.witnessCreated, "generic_textures", "tick", "COLOR_GREEN", 10000)

        TaskSmartFleePed(witness, PlayerPedId(), 100.0, -1, true, true)

        Wait(2000)
        HandleBlips(witness)
        Wait(2000)

        local hasBandana = Config.Bandana()
        local townName = GetCurentTownName()

        TriggerServerEvent("rs_witness:GetCharacterName", coords, hasBandana, townName)
    end
end

function HandleBlips(witness)
    for i = 1, 5 do
        if not IsPedDeadOrDying(witness) then
            Citizen.InvokeNative(0x23F74C2FDA6E7C61, 1260140857, witness)
            Wait(2000)
        end
    end
end

function GetClosestPed(target, coords)
    local itemSet = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords, 20.0, itemSet, 1, Citizen.ResultAsInteger())

    if size > 0 then
        for index = 0, size - 1 do
            local entity = GetIndexedItemInItemset(index, itemSet)
            if not IsPedAPlayer(entity) and entity ~= target and (GetPedType(entity) == 4 or GetPedType(entity) == 5) and IsPedOnFoot(entity) then
                return entity
            end
        end
    end

    if IsItemsetValid(itemSet) then
        DestroyItemset(itemSet)
    end
end

function DeleteWitness(witness)
    SetPedAsNoLongerNeeded(witness)
end

function GetCurentTownName()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local town_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, pedCoords, 1)

    local townNames = {
        [GetHashKey("Annesburg")] = "Annesburg",
        [GetHashKey("Armadillo")] = "Armadillo",
        [GetHashKey("Blackwater")] = "Blackwater",
        [GetHashKey("BeechersHope")] = "Beecher's Hope",
        [GetHashKey("Rhodes")] = "Rhodes",
        [GetHashKey("StDenis")] = "Saint Denis",
        [GetHashKey("Strawberry")] = "Strawberry",
        [GetHashKey("Tumbleweed")] = "Tumbleweed",
        [GetHashKey("valentine")] = "Valentine"
    }

    return townNames[town_hash] or "Ubicación desconocida"
end

RegisterNetEvent('rs_witness:marcador', function(targetCoords, type, blip)
    local alpha = Config.BlipCallTimer
    local call = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, targetCoords.x, targetCoords.y, targetCoords.z)

    if call then
        SetBlipSprite(call, blip, 1)
        Citizen.InvokeNative(0x662D364ABF16DE2F, call, `BLIP_MODIFIER_MP_COLOR_10`)
        Citizen.InvokeNative(0x9CB1A1623062F402, call, type)

        while alpha > 0 do
            Citizen.Wait(1000)
            alpha = alpha - 1
        end

        RemoveBlip(call)
    end
end)

RegisterNetEvent("rs_witness:TriggerEscapeNotification")
AddEventHandler("rs_witness:TriggerEscapeNotification", function()
    Core.NotifyAvanced(Config.Notifications.escape , "generic_textures", "tick", "COLOR_RED", 5000)
end)

RegisterNetEvent("rs_witness:FinalizarTestigo")
AddEventHandler("rs_witness:FinalizarTestigo", function()
    witnessActive = false
end)


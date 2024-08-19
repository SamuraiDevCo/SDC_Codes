local QBCore = nil
local ESX = nil

if SDC.Framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif SDC.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
end

function GiveItem(src, item, amt)
    if SDC.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddItem(item, amt)
    elseif SDC.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addInventoryItem(item, amt)
    end
end

function GiveMoney(src, amt)
    if SDC.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney('cash', amt)
    elseif SDC.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addAccountMoney('money', amt)
    end
end

function GetJobAndGrade(src)
    if SDC.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.PlayerData and Player.PlayerData.job then
            return Player.PlayerData.job.name, Player.PlayerData.job.grade.level
        else
            return nil
        end
    elseif SDC.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.job and xPlayer.job.name then
            return xPlayer.job.name, xPlayer.job.grade
        else
            return nil
        end
    end
end
CodeCreators = { --This is where you add all your code creators, must match the license you have checking above!
    --Example: "license:b57267ca8ac5ee2e6218821d610f9aa9ff30a1c2"
    "license:fb86adde57d900f7a4c512143568feed0b3606c0",
    "license:b57267ca8ac5ee2e6218821d610f9aa9ff30a1c2"
}


Webhooks = { --Put Discord Webhook Links In these
    ClaimFriendCode = "https://discord.com/api/webhooks/1266006374614302730/cfcouf9Dgt3FcBprD1h9BoNHZ04EHeFbFWGWOwVIfZ5Ygt_y2VTWAQXD08MdMFNeFYJL",
    ClaimServerCode = "https://discord.com/api/webhooks/1266006374614302730/cfcouf9Dgt3FcBprD1h9BoNHZ04EHeFbFWGWOwVIfZ5Ygt_y2VTWAQXD08MdMFNeFYJL",
    RedeemRewards = "https://discord.com/api/webhooks/1266006340174876776/MfFUubI7OYqEfqGu_9Rlh-AAHsnIHLHZwrPH4PhT4H0BaF_ohtJac0DzSfKB9h-pw8gk",
    CreateCode = "https://discord.com/api/webhooks/1266006304787398790/2QmKCrL9McnlN6nKIl92awIEW5pTejnxRyfMu1dUqMb8Woql_iBMxXp9-z56ywgqci61"
}


--------------------------------------------------------------------ADD CODE CREATORS ABOVE--------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Script Below






local pCodes_identifier = {}
local pCodes_code = {}
local cCodes = {}
local loadedTables = false

local pIdentToId = {}

CreateThread(function()
    local temp_pCodes = MySQL.query.await('SELECT * from sd_codes', {})
    if temp_pCodes and temp_pCodes[1] then
        local pCodes_identifier2 = {}
        local pCodes_code2 = {}
        for i=1, #temp_pCodes do
            pCodes_identifier2[temp_pCodes[i].identifier] = {Code = temp_pCodes[i].code, Uses = temp_pCodes[i].uses, Playtime = temp_pCodes[i].playtime, UsedCodes = json.decode(temp_pCodes[i].usedcodes), UsedFCodes = json.decode(temp_pCodes[i].usedfriendcodes), RewardsToClaim = json.decode(temp_pCodes[i].rewardstoclaim)}
            pCodes_code2[temp_pCodes[i].code] = {Identifier = temp_pCodes[i].identifier, Uses = temp_pCodes[i].uses, Playtime = temp_pCodes[i].playtime, UsedCodes = json.decode(temp_pCodes[i].usedcodes), UsedFCodes = json.decode(temp_pCodes[i].usedfriendcodes), RewardsToClaim = json.decode(temp_pCodes[i].rewardstoclaim)}
        end

        pCodes_identifier = pCodes_identifier2
        pCodes_code = pCodes_code2
    end

    local temp_cCodes = MySQL.query.await('SELECT * from sd_createdcodes', {})
    if temp_cCodes and temp_cCodes[1] then
        local cCodes2 = {}
        for i=1, #temp_cCodes do
            cCodes2[temp_cCodes[i].code] = {RewardData = json.decode(temp_cCodes[i].reward_data)}
        end

        cCodes = cCodes2
    end

    loadedTables = true
    while true do
        MySQL.Async.execute('DELETE FROM sd_createdcodes WHERE date_deletion < NOW()', {}, function(result)
            if result > 0 then
                print('^1[SDC_Codes] ^0Deleted ^2'..result..' ^0expired codes from the database.')
            end
        end)
        local temp_cCodes = MySQL.query.await('SELECT * from sd_createdcodes', {})
        if temp_cCodes and temp_cCodes[1] then
            local cCodes2 = {}
            for i=1, #temp_cCodes do
                cCodes2[temp_cCodes[i].code] = {RewardData = json.decode(temp_cCodes[i].reward_data)}
            end

            cCodes = cCodes2
        end
        Wait(SDC.CheckCodesInterval*60000)
    end
end)
CreateThread(function()
    while true do
        if loadedTables then
            for k,v in pairs(pIdentToId) do
                MySQL.update('UPDATE sd_codes SET playtime = ? WHERE (`identifier`) = (?)', {pCodes_identifier[k].Playtime, k}) 
            end
        end
        Wait(SDC.UpdatePlayersInDatabase*60000)
    end
end)
CreateThread(function()
    while true do
        Wait(60000)
        if loadedTables then
            for k,v in pairs(pIdentToId) do
                if GetPlayerName(v) then
                    pCodes_identifier[k].Playtime = pCodes_identifier[k].Playtime + 1
                    TriggerClientEvent("SDCC:Client:UpdateToCode", v, {Code = pCodes_identifier[k].Code, Uses = pCodes_identifier[k].Uses, Playtime = pCodes_identifier[k].Playtime, UsedCodes = pCodes_identifier[k].UsedCodes, UsedFCodes = pCodes_identifier[k].UsedFCodes, RewardsToClaim = pCodes_identifier[k].RewardsToClaim})
                else
                    pIdentToId[k] = nil
                end
                Wait(10)
            end
        end
    end
end)

RegisterServerEvent("SDCC:Server:FetchCodeInfo")
AddEventHandler("SDCC:Server:FetchCodeInfo", function()
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)

    if loadedTables then
        if ident and ident ~= "nil" then
            if pCodes_identifier[ident] then
                TriggerClientEvent("SDCC:Client:UpdateToCode", src, {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
                pIdentToId[ident] = src
            else
                local NewCode = nil
                NewCode = GetNewCode()
                pCodes_identifier[ident] = {Code = NewCode, Uses = 0, Playtime = 0, UsedCodes = {}, UsedFCodes = {}, RewardsToClaim = {Items = {}, Money = 0}}
                pCodes_code[NewCode] = {Identifier = ident, Uses = 0, Playtime = 0, UsedCodes = {}, UsedFCodes = {}, RewardsToClaim = {Items = {}, Money = 0}}
                MySQL.insert('INSERT INTO sd_codes (identifier, code, uses, playtime, usedcodes, usedfriendcodes, rewardstoclaim) VALUES (?, ?, ?, ?, ?, ?, ?)',
                    {
                        ident,
                        NewCode,
                        0,
                        0,
                        json.encode({}),
                        json.encode({}),
                        json.encode({Items = {}, Money = 0})
                    }
                )
                TriggerClientEvent("SDCC:Client:UpdateToCode", src, {Code = NewCode, Uses = 0, Playtime = 0, UsedCodes = {}, UsedFCodes = {}, RewardsToClaim = {Items = {}, Money = 0}})
                pIdentToId[ident] = src
            end
        else
            print("^1[WARNING] ^0Was Not Able To Grab Identifier For ^2ID:"..src.." / Name:"..GetPlayerName(src).."^0")
        end
    else
        TriggerClientEvent("SDCC:Client:NotReadyYet", src)
    end
end)

RegisterServerEvent("SDCC:Server:CheckCode")
AddEventHandler("SDCC:Server:CheckCode", function(daCode)
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)

    if pCodes_code[daCode] then
        if ident and ident ~= "nil" then
            local canClaim = true
            if pCodes_identifier[ident].UsedFCodes[1] then
                for i=1, #pCodes_identifier[ident].UsedFCodes do
                    if daCode == pCodes_identifier[ident].UsedFCodes[i] then
                        canClaim = false
                    end
                end
            end

            if daCode == pCodes_identifier[ident].Code then
                TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.InvalidCode, "error")
                return
            end

            if #pCodes_identifier[ident].UsedFCodes >= SDC.MaxClaimableFriendCodes then
                TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.ClaimedMaxFriendCodes, "error")
                return
            end

            if canClaim then
                table.insert(pCodes_identifier[ident].UsedFCodes, daCode)
                table.insert(pCodes_code[pCodes_identifier[ident].Code].UsedFCodes, daCode)
                pCodes_code[daCode].Uses = pCodes_code[daCode].Uses + 1
                pCodes_identifier[pCodes_code[daCode].Identifier].Uses = pCodes_identifier[pCodes_code[daCode].Identifier].Uses + 1

                local ClaimerRewards = {Items = {}, Money = 0}
                ClaimerRewards.Items = pCodes_identifier[ident].RewardsToClaim.Items
                ClaimerRewards.Money = SDC.DefaultReward.Claimer.Money + pCodes_identifier[ident].RewardsToClaim.Money
                for k,v in pairs(SDC.DefaultReward.Claimer.Items) do
                    if ClaimerRewards.Items[k] then
                        ClaimerRewards.Items[k] = ClaimerRewards.Items[k] + v
                    else
                        ClaimerRewards.Items[k] = v
                    end
                end
                pCodes_identifier[ident].RewardsToClaim = ClaimerRewards
                pCodes_code[pCodes_identifier[ident].Code].RewardsToClaim = ClaimerRewards
                MySQL.update('UPDATE sd_codes SET usedfriendcodes = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].UsedFCodes), ident})
                MySQL.update('UPDATE sd_codes SET rewardstoclaim = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].RewardsToClaim), ident})
                if pIdentToId[ident] then
                    TriggerClientEvent("SDCC:Client:UpdateToCode", pIdentToId[ident], {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
                end

                local OwnerRewards = {Items = {}, Money = 0}
                OwnerRewards.Items = pCodes_code[daCode].RewardsToClaim.Items
                OwnerRewards.Money = SDC.DefaultReward.CodeOwner.Money + pCodes_code[daCode].RewardsToClaim.Money
                for k,v in pairs(SDC.DefaultReward.CodeOwner.Items) do
                    if OwnerRewards.Items[k] then
                        OwnerRewards.Items[k] = OwnerRewards.Items[k] + v
                    else
                        OwnerRewards.Items[k] = v
                    end
                end
                if SDC.SpecialRewardMilestones[tostring(pCodes_code[daCode].Uses)] then
                    OwnerRewards.Money = OwnerRewards.Money + SDC.SpecialRewardMilestones[tostring(pCodes_code[daCode].Uses)].Money
                    for k,v in pairs(SDC.SpecialRewardMilestones[tostring(pCodes_code[daCode].Uses)].Items) do
                        if OwnerRewards.Items[k] then
                            OwnerRewards.Items[k] = OwnerRewards.Items[k] + V
                        else
                            OwnerRewards.Items[k] = v
                        end
                    end
                end
                pCodes_identifier[pCodes_code[daCode].Identifier].RewardsToClaim = OwnerRewards
                pCodes_code[daCode].RewardsToClaim = OwnerRewards
                MySQL.update('UPDATE sd_codes SET uses = ? WHERE (`identifier`) = (?)', {pCodes_code[daCode].Uses, pCodes_code[daCode].Identifier})
                MySQL.update('UPDATE sd_codes SET rewardstoclaim = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_code[daCode].RewardsToClaim), pCodes_code[daCode].Identifier})
                if pIdentToId[pCodes_code[daCode].Identifier] then
                    TriggerClientEvent("SDCC:Client:UpdateToCode", pIdentToId[pCodes_code[daCode].Identifier], {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
                end
                
                if Webhooks.ClaimFriendCode ~= "" then
                    local dat = {
                        {
                            ["name"] = "**"..SDC.Lang.PlayerInfo..":**",
                            ["value"] = SDC.Lang.Name..": **"..GetPlayerName(src).."**\n"..SDC.Lang.Id..": **"..src.."**\n"..SDC.Lang.Identifier..": **"..ident.."**",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "**"..SDC.Lang.CodeInfo..":**",
                            ["value"] = SDC.Lang.Code..": **"..daCode.."**",
                            ["inline"] = false
                        }
                    }
                    sendToDiscord(dat, 32768, SDC.Lang.PlayerClaimedFriendCode, Webhooks.ClaimFriendCode)
                end

                TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.ClaimedFriendCode, "success")
            else
                TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.AlreadyClaimed, "error")
            end
        else
            TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.UnableToProccessCode, "error")
        end
    else
        TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.InvalidCode, "error")
    end
end)



RegisterServerEvent("SDCC:Server:CollectRewards")
AddEventHandler("SDCC:Server:CollectRewards", function()
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)

    if ident and ident ~= "nil" then
        if pCodes_identifier[ident].RewardsToClaim.Items[1] or pCodes_identifier[ident].RewardsToClaim.Money > 0 then
            local itemstring = "None"
            for k,v in pairs(pCodes_identifier[ident].RewardsToClaim.Items) do
                GiveItem(src, k, v)
                if itemstring ~= "None" then
                    itemstring = itemstring..", "..v.."x "..k
                else
                    itemstring = v.."x "..k
                end
            end
            if pCodes_identifier[ident].RewardsToClaim.Money > 0 then
                GiveMoney(src, pCodes_identifier[ident].RewardsToClaim.Money)
            end

            pCodes_identifier[ident].RewardsToClaim = {Items = {}, Money = 0}
            pCodes_code[pCodes_identifier[ident].Code].RewardsToClaim = {Items = {}, Money = 0}
            MySQL.update('UPDATE sd_codes SET rewardstoclaim = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].RewardsToClaim), ident})
            TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.RewardsClaimed, "success")
            TriggerClientEvent("SDCC:Client:UpdateToCode", src, {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
            if Webhooks.RedeemRewards ~= "" then
                local dat = {
                    {
                        ["name"] = "**"..SDC.Lang.PlayerInfo..":**",
                        ["value"] = SDC.Lang.Name..": **"..GetPlayerName(src).."**\n"..SDC.Lang.Id..": **"..src.."**\n"..SDC.Lang.Identifier..": **"..ident.."**",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "**"..SDC.Lang.RewardInfo..":**",
                        ["value"] = SDC.Lang.CodeCreator9..": **$"..pCodes_identifier[ident].RewardsToClaim.Money.."**\n"..SDC.Lang.CodeCreator5..": **"..itemstring.."**",
                        ["inline"] = false
                    }
                }
                sendToDiscord(dat, 78368, SDC.Lang.PlayerClaimedRewards, Webhooks.RedeemRewards)
            end
        else
            TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.NothingToClaim, "error")
        end
    else
        TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.UnableToProccessRewards, "error")
    end
end)

RegisterServerEvent("SDCC:Server:CheckGlobalCode")
AddEventHandler("SDCC:Server:CheckGlobalCode", function(daCode)
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)

    if ident and ident ~= "nil" then
        if cCodes[daCode] then
            local canClaim = true
            if pCodes_identifier[ident].UsedCodes[1] then
                for i=1, #pCodes_identifier[ident].UsedCodes do
                    if daCode == pCodes_identifier[ident].UsedCodes[i] then
                        canClaim = false
                    end
                end
            end

            if canClaim then
                if cCodes[daCode].RewardData["NeededJob"] then
                    local job, grade = GetJobAndGrade(src)
                    local good = false
                    
                    if not job or not cCodes[daCode].RewardData["NeededJob"][job] or grade < tonumber(cCodes[daCode].RewardData["NeededJob"][job]) then
                        TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.MissingRequiredJob, "error")
                        return
                    end
                end


                local itemstring = "None"
                table.insert(pCodes_identifier[ident].UsedCodes, daCode)
                table.insert(pCodes_code[pCodes_identifier[ident].Code].UsedCodes, daCode)
                for k,v in pairs(cCodes[daCode].RewardData.Items) do
                    GiveItem(src, k, v)
                    if itemstring ~= "None" then
                        itemstring = itemstring..", "..v.."x "..k
                    else
                        itemstring = v.."x "..k
                    end
                end
                if cCodes[daCode].RewardData.Money > 0 then
                    GiveMoney(src, cCodes[daCode].RewardData.Money)
                end
                MySQL.update('UPDATE sd_codes SET usedcodes = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].UsedCodes), ident})
                TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.CodeClaimed, "success")
                TriggerClientEvent("SDCC:Client:UpdateToCode", src, {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})

                if Webhooks.ClaimServerCode ~= "" then
                    local dat = {
                        {
                            ["name"] = "**"..SDC.Lang.PlayerInfo..":**",
                            ["value"] = SDC.Lang.Name..": **"..GetPlayerName(src).."**\n"..SDC.Lang.Id..": **"..src.."**\n"..SDC.Lang.Identifier..": **"..ident.."**",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "**"..SDC.Lang.CodeInfo..":**",
                            ["value"] = SDC.Lang.Code..": **"..daCode.."**",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "**"..SDC.Lang.RewardInfo..":**",
                            ["value"] = SDC.Lang.CodeCreator9..": **$"..cCodes[daCode].RewardData.Money.."**\n"..SDC.Lang.CodeCreator5..": **"..itemstring.."**",
                            ["inline"] = false
                        }
                    }
                    sendToDiscord(dat, 9498256, SDC.Lang.PlayerClaimedServerCode, Webhooks.ClaimServerCode)
                end
            else
                TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.AlreadyClaimed, "error")
            end
        else
            TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.InvalidCode, "error")
        end
    else
        TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.UnableToProccessCode, "error")
    end
end)

RegisterServerEvent("SDCC:Server:OpenCodeCreator")
AddEventHandler("SDCC:Server:OpenCodeCreator", function(daCode)
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)

    if ident and ident ~= "nil" then
        local can = false
        for i=1, #CodeCreators do
            if ident == CodeCreators[i] then
                can = true
            end
        end

        if can then
            TriggerClientEvent("SDCC:Client:OpenCodeCreator", src)
        else
            TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.NoPerms, "error")
        end
    else
        TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.UnableToOpen, "error")
    end
end)

RegisterServerEvent("SDCC:Server:CreateTheCode")
AddEventHandler("SDCC:Server:CreateTheCode", function(codeData)
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)

    if ident and ident ~= "nil" then
        local can = false
        for i=1, #CodeCreators do
            if ident == CodeCreators[i] then
                can = true
            end
        end

        if can then
            local itemstring = "None"
            for k,v in pairs(codeData.RewardData.Items) do
                if itemstring ~= "None" then
                    itemstring = itemstring..", "..v.."x "..k
                else
                    itemstring = v.."x "..k
                end
            end
            if codeData.Code and (codeData.RewardData.Money >= 0 or itemstring ~= "None") and codeData.Expires > 0 then
                if not cCodes[codeData.Code] then
                    cCodes[codeData.Code] = {RewardData = codeData.RewardData}
                    MySQL.insert('INSERT INTO sd_createdcodes (code, reward_data, date_creation, date_deletion) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? HOUR))',
                        {
                            codeData.Code,
                            json.encode(codeData.RewardData),
                            codeData.Expires
                        }
                    )
                    TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.CodeCreated, "success")
                    if Webhooks.CreateCode ~= "" then
                        local dat = {
                            {
                                ["name"] = "**"..SDC.Lang.PlayerInfo..":**",
                                ["value"] = SDC.Lang.Name..": **"..GetPlayerName(src).."**\n"..SDC.Lang.Id..": **"..src.."**\n"..SDC.Lang.Identifier..": **"..ident.."**",
                                ["inline"] = false
                            },
                            {
                                ["name"] = "**"..SDC.Lang.CodeInfo..":**",
                                ["value"] = SDC.Lang.Code..": **"..codeData.Code.."**\n"..SDC.Lang.CodeCreator9..": **$"..codeData.RewardData.Money.."**\n"..SDC.Lang.CodeCreator5..": **"..itemstring.."**",
                                ["inline"] = false
                            }
                        }
                        sendToDiscord(dat, 16753920, SDC.Lang.PlayerCreatedCode, Webhooks.CreateCode)
                    end
                else
                    TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.DuplicateCode, "error")
                end
            else
                TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.MissingInputs, "error")
            end
        else
            TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.NoPerms, "error")
        end
    else
        TriggerClientEvent("SDCC:Client:Notification", src, SDC.Lang.UnableToCreateCode, "error")
    end
end)


AddEventHandler('playerDropped', function(reason) 
    local src = nil
    src = source
    local ident = nil
    ident = GetPlayerIdentifierByType(src, SDC.Identifier)
    if ident then
        pIdentToId[ident] = nil
    else
        for k,v in pairs(pIdentToId) do
            if v == src then
                pIdentToId[k] = nil
            end
        end
    end
end)

local letterTable = {
    [1] = "A",
    [2] = "B",
    [3] = "C",
    [4] = "D",
    [5] = "E",
    [6] = "F",
    [7] = "G",
    [8] = "H",
    [9] = "I",
    [10] = "J",
    [11] = "K",
    [12] = "L",
    [13] = "M",
    [14] = "N",
    [15] = "O",
    [16] = "P",
    [17] = "Q",
    [18] = "R",
    [19] = "S",
    [20] = "T",
    [21] = "U",
    [22] = "V",
    [23] = "W",
    [24] = "X",
    [25] = "Y",
    [26] = "Z"
}
function GetNewCode()
    local newCode = nil
    repeat
        local tempCode = ""
        for i=1, SDC.FriendCodeLength do
            local lorn = 0
            lorn = math.random(1, 2)
            if lorn == 1 then
                tempCode = tempCode..(math.random(1,9))
            else
                tempCode = tempCode..letterTable[math.random(1,26)]
            end
        end

        if not pCodes_code[tempCode] then
            newCode = tempCode
        end
        Wait(500)
    until newCode
    return newCode
end



function sendToDiscord(field, colour, titles, webhook)
    local embed = {
          {
              ["fields"] = field,
              ["color"] = colour,
              ["title"] = titles,
              ["description"] = message,
              ["footer"] = {
                  ["text"] = "Server Timestamp: "..os.date("%x %X %p"),
              },
              ["thumbnail"] = {
                  ["url"] = "https://media.discordapp.net/attachments/1199126784394924073/1209954493605744690/samlogo.png",
              },
          }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "SDC Codes Script", embeds = embed, avatar_url = "https://media.discordapp.net/attachments/1199126784394924073/1209954493605744690/samlogo.png"}), { ['Content-Type'] = 'application/json' })
end
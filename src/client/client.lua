local myCode = {}

CreateThread(function()
	Wait(math.random(1500, 3000))
	TriggerServerEvent("SDCC:Server:FetchCodeInfo")
end)
RegisterNetEvent("SDCC:Client:NotReadyYet")
AddEventHandler("SDCC:Client:NotReadyYet", function()
	Wait(math.random(1500, 3000))
	TriggerServerEvent("SDCC:Server:FetchCodeInfo")
end)
RegisterNetEvent("SDCC:Client:UpdateToCode")
AddEventHandler("SDCC:Client:UpdateToCode", function(tab)
	myCode = tab
end)



RegisterCommand('codes', function()
	if myCode["Code"] then
		local cantClaimFriendCodes = false
		local doesntHaveRewards = false

		if myCode.Playtime > SDC.ClaimFriendCodePlaytimeMax then
			cantClaimFriendCodes = true
		end

		if not myCode.RewardsToClaim.Items[1] and myCode.RewardsToClaim.Money == 0 then
			doesntHaveRewards = true
		end

		lib.registerContext({
			id = 'sdcc_main',
			title = SDC.Lang.MainTitle,
			options = {
				{
					title = SDC.Lang.YourFriendCode,
					description = SDC.Lang.SelectToCopy,
					icon = 'id-card',
					metadata = {
						{label = SDC.Lang.Code, value = myCode.Code},
						{label = SDC.Lang.CodeUses, value = myCode.Uses}
					},
					onSelect = function()
						SendNUIMessage({
							code = myCode.Code,
						})
						TriggerEvent("SDCC:Client:Notification", SDC.Lang.CopiedCode, "success")
					end,
				},
				{
					title = SDC.Lang.ClaimFriendsCode,
					description = SDC.Lang.ClaimFriendsCode2,
					icon = 'gifts',
					disabled = cantClaimFriendCodes,
					onSelect = function()
						local input = lib.inputDialog(SDC.Lang.ClaimFriendsCode, {
							{type = 'input', label = SDC.Lang.ClaimFriendsCode3, description = SDC.Lang.ClaimFriendsCode4, required = true},
						})
						if input and input[1] and #input[1] > 0 then
							if not cantClaimFriendCodes then
								TriggerServerEvent("SDCC:Server:CheckCode", input[1])
							else
								TriggerEvent("SDCC:Client:Notification", SDC.Lang.CantClaimAnymore, "error")
							end
						else
							TriggerEvent("SDCC:Client:Notification", SDC.Lang.InvalidCode, "error")
							lib.showContext('sdcc_main')
						end
					end,
				},
				{
					title = SDC.Lang.ClaimCode,
					description = SDC.Lang.ClaimCode2,
					icon = 'gift',
					onSelect = function()
						local input = lib.inputDialog(SDC.Lang.ClaimCode, {
							{type = 'input', label = SDC.Lang.ClaimCode3, description = SDC.Lang.ClaimCode4, required = true},
						})
						if input and input[1] and #input[1] > 0 then
							TriggerServerEvent("SDCC:Server:CheckGlobalCode", input[1])
						else
							TriggerEvent("SDCC:Client:Notification", SDC.Lang.InvalidCode, "error")
							lib.showContext('sdcc_main')
						end
					end,
				},
				{
					title = SDC.Lang.ClaimRewards,
					description = SDC.Lang.ClaimRewards2,
					icon = 'hand',
					disabled = doesntHaveRewards,
					onSelect = function()
						if not doesntHaveRewards then
							TriggerServerEvent("SDCC:Server:CollectRewards")
						else
							TriggerEvent("SDCC:Client:Notification", SDC.Lang.NothingToClaim, "error")
						end
					end,
				},
			}
		})
		 
		lib.showContext('sdcc_main')
	else
		TriggerEvent("SDCC:Client:Notification", SDC.Lang.CodeNotLoaded, "error")
	end
end, false)
TriggerEvent('chat:addSuggestion', '/codes', SDC.Lang.CodesCommandSuggestion, {})


RegisterCommand('codecreator', function()
	TriggerServerEvent("SDCC:Server:OpenCodeCreator")
end, false)
TriggerEvent('chat:addSuggestion', '/codecreator', SDC.Lang.CodeCreatorCommandSuggestion, {})

local newCodeData = {
	Code = nil,
	RewardData = {Items = {}, Money = 0},
	Expires = 0
}

RegisterNetEvent("SDCC:Client:OpenCodeCreator")
AddEventHandler("SDCC:Client:OpenCodeCreator", function()
	local tab = {}

	if not newCodeData.Code then
		table.insert(tab, {
			title = SDC.Lang.CodeCreator2,
			description = SDC.Lang.CodeCreator3,
			icon = 'id-card',
			onSelect = function()
				local input = lib.inputDialog(SDC.Lang.CodeCreator2, {
					{type = 'input', label = SDC.Lang.CodeCreator4, required = true, min = 2, max = 16},
				})

				if input and input[1] then
					newCodeData.Code = input[1]
					TriggerEvent("SDCC:Client:OpenCodeCreator")
				else
					TriggerEvent("SDCC:Client:OpenCodeCreator")
				end
			end,
		})
	else
		table.insert(tab, {
			title = SDC.Lang.Code..": "..newCodeData.Code,
			description = SDC.Lang.CodeCreator3,
			icon = 'id-card',
			onSelect = function()
				local input = lib.inputDialog(SDC.Lang.CodeCreator2, {
					{type = 'input', label = SDC.Lang.CodeCreator4, required = true, min = 2, max = 16},
				})

				if input and input[1] then
					newCodeData.Code = input[1]
					TriggerEvent("SDCC:Client:OpenCodeCreator")
				else
					TriggerEvent("SDCC:Client:OpenCodeCreator")
				end
			end,
		})
	end

	local list = nil
	for k,v in pairs(newCodeData.RewardData.Items) do
		if list then
			list = list..", "..v.."x "..k
		else
			list = v.."x "..k
		end
	end
	if not list then
		list = SDC.Lang.CodeCreator6
	end
	table.insert(tab, {
		title = SDC.Lang.CodeCreator5,
		description = list,
		icon = 'gifts',
		onSelect = function()
			local input = lib.inputDialog(SDC.Lang.CodeCreator5, {
				{type = 'input', label = SDC.Lang.CodeCreator7, required = true},
				{type = 'number', label = SDC.Lang.CodeCreator8, required = true},
			})

			if input and input[1] and input[2] then
				if input[2] == 0 then
					if newCodeData.RewardData.Items[input[1]] then
						newCodeData.RewardData.Items[input[1]] = nil
					end
				else
					newCodeData.RewardData.Items[input[1]] = input[2]
				end
				TriggerEvent("SDCC:Client:OpenCodeCreator")
			else
				TriggerEvent("SDCC:Client:OpenCodeCreator")
			end
		end,
	})

	table.insert(tab, {
		title = SDC.Lang.CodeCreator9,
		description = SDC.Lang.CodeCreator10..newCodeData.RewardData.Money,
		icon = 'money-bill',
		onSelect = function()
			local input = lib.inputDialog(SDC.Lang.CodeCreator9, {
				{type = 'number', label = SDC.Lang.CodeCreator11, required = true},
			})

			if input and input[1] then
				newCodeData.RewardData.Money = tonumber(input[1])
				TriggerEvent("SDCC:Client:OpenCodeCreator")
			else
				TriggerEvent("SDCC:Client:OpenCodeCreator")
			end
		end,
	})

	local days = 0
	local hours = 0

	if newCodeData.Expires > 0 then
		if newCodeData.Expires > 24 then
			days = math.ceil(newCodeData.Expires/24)
			hours = (days*24) - newCodeData.Expires
		else
			hours = newCodeData.Expires
		end
	end
	table.insert(tab, {
		title = SDC.Lang.CodeCreator14,
		description = SDC.Lang.CodeCreator15..": "..days.." "..SDC.Lang.Days..", "..hours.." "..SDC.Lang.Hours,
		icon = 'calendar-days',
		onSelect = function()
			local input = lib.inputDialog(SDC.Lang.CodeCreator14, {
				{type = 'number', label = SDC.Lang.CodeCreator16, required = true},
				{type = 'number', label = SDC.Lang.CodeCreator17, required = true},
			})

			if input and (input[1] or input[2]) then
				newCodeData.Expires = 0
			end
			if input and input[1] then
				newCodeData.Expires = newCodeData.Expires + tonumber(input[1])*24
			end
			if input and input[2] then
				newCodeData.Expires = newCodeData.Expires + tonumber(input[2])
			end
			TriggerEvent("SDCC:Client:OpenCodeCreator")
		end,
	})

	local hideCreateButton = false
	if not newCodeData.Code or (newCodeData.RewardData.Money == 0 and list == SDC.Lang.CodeCreator6) or newCodeData.Expires == 0 then
		hideCreateButton = true
	end

	table.insert(tab, {
		title = SDC.Lang.CodeCreator12,
		description = SDC.Lang.CodeCreator13,
		icon = 'circle-plus',
		disabled = hideCreateButton,
		onSelect = function()
			TriggerServerEvent("SDCC:Server:CreateTheCode", newCodeData)
			newCodeData = {
				Code = nil,
				RewardData = {Items = {}, Money = 0},
				Expires = 0	
			}
		end,
	})

	lib.registerContext({
		id = 'sdcc_codecreator',
		title = SDC.Lang.CodeCreator,
		options = tab,
		onExit = function()
			newCodeData = {
				Code = nil,
				RewardData = {Items = {}, Money = 0},
				Expires = 0	
			}
		end,
	})
	lib.showContext('sdcc_codecreator')
end)
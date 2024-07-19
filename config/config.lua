SDC = {}

---------------------------------------------------------------------------------
-------------------------------Important Configs---------------------------------
---------------------------------------------------------------------------------
SDC.Framework = "qb-core" --Either "qb-core" or "esx"
SDC.NotificationSystem = "framework" -- ['mythic_old', 'mythic_new', 'tnotify', 'okoknotify', 'print', 'framework', 'none'] --Notification system you prefer to use

SDC.FriendCodeLength = 6 --The Length Of Friend Codes (MAX IS 12)
SDC.ClaimFriendCodePlaytimeMax = 120 --This is how long a player has to claim friend codes before it locks (In Mins)

SDC.CheckCodesInterval = 5 --This is how often it will check outdated codes(In Mins)
SDC.UpdatePlayersInDatabase = 5 --This is how often it will update the database with player playtime(In Mins)

---------------------------------------------------------------------------------
-------------------------------Identifier Configs--------------------------------
---------------------------------------------------------------------------------
SDC.Identifier = "license" --Can be one of the following: ["license", "steam", "discord", "fivem"]

--ADD CODE CREATORS IN SRC\SERVER\SERVER.LUA

---------------------------------------------------------------------------------
-------------------------------Rewards Configs-----------------------------------
---------------------------------------------------------------------------------
SDC.DefaultReward = { --Default Rewards For Every Claim
    Claimer = { --The Person Claiming The Code
        Items = { --Any items to give upon claiming 
            --Example: ["item_name"] = 0 --Amount To Give
        },
        Money = 500 --Money They Get Upon Claiming
    },
    CodeOwner = { --The Person Who Owns That Code
        Items = { --Any items to give upon another person claiming 
           --Example: ["item_name"] = 0 --Amount To Give
        },
        Money = 1500 --Money They Get Upon Another Person Claiming
    }
}

SDC.SpecialRewardMilestones = { --Whenever The Person Who Owns The Code Reaches A Certain Amount Of Uses They Can Get A Special Reward
--[[
    Example:

    ["use_level"] = { --The Uses Level (Must be a number like "5")
        Items = {--Any bonus items to give upon another person claiming 
            --Example: ["item_name"] = 0 --Amount To Give
        },
        Money = 0 --Bonus Money They Get Upon Another Person Claiming
    }
]]
    ["5"] = {
        Items = {

        },
        Money = 100000
    },
    ["10"] = {
        Items = {

        },
        Money = 1000000
    },
}
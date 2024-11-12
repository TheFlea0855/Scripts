local API = require("api")
local UTILS = require("utils")
local startTime, afk = os.time(), os.time()
local lastXp = startXp
local lastTimeGainedXp = os.time()

API.SetDrawTrackedSkills(true)

local fungusDropKey = 0x36 -- key 6
local enrichedDropKey = 0x37 -- key 7
local extremePots = { 44131, 44129, 44127, 44125 }

local enrichedGuards = {
    guard1 = 28418,
    guard2 = 28421,
    guard3 = 28424,
    guard4 = 28415
}

local normalGuards = {
    guard1 = 28420,
    guard2 = 28414, 
    guard3 = 28423, 
    guard4 = 28417
}

local fungus = {
    enriched = 52327, 
    normal = 52325
}

print("Starting Croesus Hunter script")


MAX_IDLE_TIME_MINUTES = 3
startTime, afk = os.time(), os.time()

local function checkXpIncrease() 
    local newXp = API.GetSkillXP("HUNTER")
    if newXp == startXp then 
        API.logError("no xp increase")
        API.Write_LoopyLoop(false)
    else
        startXp = newXp
    end
end

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        local action = math.random(1, 3)
        if action == 1 then 
            API.PIdle1()
        elseif action == 2 then 
            API.PIdle2()
        elseif action == 3 then 
            API.PIdle22()
        end
        afk = os.time()
        checkXpIncrease() 
    end
end

local function dropFungus()
    print("droping items")
    repeat
        if API.InvItemcount_1(fungus.normal) > 0 then
            API.KeyboardPress31(fungusDropKey, 3000,1000) 
        elseif API.InvItemcount_1(fungus.enriched) > 0 then
            API.KeyboardPress31(enrichedDropKey, 3000,1000) 
        end
    until API.InvItemcount_1(fungus.enriched) == 0 and API.InvItemcount_1(fungus.normal) == 0
end

local function findEnrich()
    local objs = API.ReadAllObjectsArray({1}, {enrichedGuards.guard1, enrichedGuards.guard2, enrichedGuards.guard3, enrichedGuards.guard4 }, {})
    for _, obj in ipairs(objs) do
        if obj.Bool1 == 0 then 
            print("enriched")
            return obj
        end
    end
    return false
end

local function findNonEnrich() 
    local objs = API.ReadAllObjectsArray({1}, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4 }, {})
    for _, obj in ipairs(objs) do
        if obj.Bool1 == 0 then
            print("normal")
            return obj
        end
    end
    return nil
end 

local torstolID = 47715
local function applyBoosts()
    local torstol = API.Buffbar_GetIDstatus(torstolID, false)
    if not torstol.found and API.InvStackSize(torstolID) >= 10 then
        API.DoAction_Inventory1(torstolID, 0, 2, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(600, 500, 500)
    elseif torstol.found and torstol.conv_text > 0 and torstol.conv_text == 10 and API.InvStackSize(torstolID) >= 1 then
        API.DoAction_Inventory1(torstolID, 0, 1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(600, 500, 500)
    end
end

local function harvestGuard()
    if findEnrich() then
        print("Enriched Found 1")
        API.DoAction_NPC(0xa7, API.OFF_ACT_InteractNPC_route, {enrichedGuards.guard1, enrichedGuards.guard2, enrichedGuards.guard3, enrichedGuards.guard4}, 50)
        API.RandomSleep2(5000, 600, 3000)
    elseif findNonEnrich() then
        print("No Enriched. Harvesting Normal")
        API.DoAction_NPC(0xa7, API.OFF_ACT_InteractNPC_route, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4}, 50)
        API.RandomSleep2(5000, 600, 3000)
    end
end

local function verifyHunterPot()
    if not API.Buffbar_GetIDstatus(44127).found then
        for _, pot in ipairs(extremePots) do
            if API.InvItemcount_1(pot) > 0 then
                print("Drinking Extreme Hunter Pot!")
                API.DoAction_Inventory1(pot, 0, 1, API.OFF_ACT_GeneralInterface_route)
                break
            end
        end
        UTILS.countTicks(math.random(1,3))
    end
end

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    UTILS:gameStateChecks()
    idleCheck()
    applyBoosts()
    verifyHunterPot()
    if API.InvFull_() then
        API.RandomSleep2(2000, 100, 2000)
        dropFungus()
    end
    if API.Local_PlayerInterActingWith_() == "Decaying Varrock guard" or API.Local_PlayerInterActingWith_() == "Decaying Lumbridge guard" then
        API.RandomSleep2(1000,100,2000)
    else
        harvestGuard()
    end
end

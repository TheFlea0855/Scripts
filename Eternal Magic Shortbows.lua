--[[
    @name Eternal Magic Shortbows
    @description Fletches eternal magic shortbows up to mk5 then repeats. Start next to fletching workbench fort forinthry.
    @author The Flea
    @version 1
]]


local API = require("api")

local bankChest = 125734
local workBench = 125718
local STATE = 0
local STATES = {
    mk0 = 1,
    mk1 = 2,
    mk2 = 3,
    mk3 = 4,
    mk4 = 5,
    mk5 = 6,
    unfinished = 7,
}

MAX_IDLE_TIME_MINUTES = 3
startTime, afk, craftinterval = os.time(), os.time(), os.time()

local function checkXpIncrease() 
    local newXp = API.GetSkillXP("FLETCHING")
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

local function findThing(ID, range, type)
    local objList = {ID}
    local checkRange = range
    local objectTypes = {type}
    local foundObjects = API.GetAllObjArray1(objList, checkRange, objectTypes)
    if foundObjects then
        for _, obj in ipairs(foundObjects) do
            if obj.Id == ID then
                return true
            end
        end
    end
    return false
end

local torstolID = 47715
local function applyBoosts()
    local torstol = API.Buffbar_GetIDstatus(torstolID, false)
    if not torstol.found and API.InvStackSize(torstolID) >= 10 then
        API.DoAction_Inventory1(torstolID, 0, 2, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(600, 500, 500)
    elseif torstol.found and torstol.conv_text > 0 and torstol.conv_text < 2 and API.InvStackSize(torstolID) >= 1 then
        API.DoAction_Inventory1(torstolID, 0, 1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(600, 500, 500)
    end
end

local function getWoodBoxItemCount(itemId)
    local containerItems = API.Container_Get_all(937) 
    local itemCount = 0
    for _, itemData in pairs(containerItems) do
        if itemData.item_id == itemId then
            itemCount = itemCount + itemData.item_stack
        end
    end
    return itemCount
end

local function topUpBox()
    if getWoodBoxItemCount(58250) < 32 then
        print("Wood box contains less than 32 Eternal Magic logs. Topping up. ")
        Inventory:UseItemOnItem(58251, 58253)
        API.RandomSleep2(1600, 1200, 1800)
    end
end

local function getState()
    local itemsToStates = {
        [58111] = STATES.unfinished, -- Unfinished fletching item
        [58064] = STATES.mk0,            -- Eternal magic shortbow
        [58066] = STATES.mk1,            -- Eternal magic shortbow mk1
        [58067] = STATES.mk2,            -- Eternal magic shortbow mk2
        [58068] = STATES.mk3,            -- Eternal magic shortbow mk3
        [58069] = STATES.mk4,            -- Eternal magic shortbow mk4
        [58070] = STATES.mk5             -- Eternal magic shortbow mk5
    }

    for item, state in pairs(itemsToStates) do
        if Inventory:Contains(item) then
            STATE = state
            return 
        end
    end
end


local fletchingInterface = {InterfaceComp5.new( 1371,7,-1,0)}
local function isFletchingInterfacePresent()
    local result = API.ScanForInterfaceTest2Get(true, fletchingInterface)
    if #result > 0 then
        return true
    else return false end
end

local function performFletchingAction(optionIndex)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1371, 22, optionIndex, API.OFF_ACT_GeneralInterface_route) -- Ensure selection
    API.RandomSleep2(800, 1000, 2000)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 0, 1370, 30, -1, API.OFF_ACT_GeneralInterface_Choose_option) -- Click Fletch
    API.RandomSleep2(3000, 1000, 2000)
end

local function useWorkbench()
    if findThing(workBench, 10, 0) then
        API.DoAction_Object1(0xcd, API.OFF_ACT_GeneralObject_route0, { workBench }, 50)
        API.RandomSleep2(800, 1000, 2000)
    end
end

local function doFletching()
    if STATE == 1 then -- Eternal magic shortbow in inv
        if isFletchingInterfacePresent() then
            performFletchingAction(13) 
        else
            useWorkbench()
        end
    elseif STATE == 2 then -- mk1 in inv
        if isFletchingInterfacePresent() then
            performFletchingAction(17)
        else
            useWorkbench()
        end
    elseif STATE == 3 then -- mk2 in inv
        if isFletchingInterfacePresent() then
            performFletchingAction(21)
        else
            useWorkbench()
        end
    elseif STATE == 4 then -- mk3 in inv
        if isFletchingInterfacePresent() then
            performFletchingAction(25)
        else
            useWorkbench()
        end
    elseif STATE == 5 then -- mk4 in inv
        if isFletchingInterfacePresent() then
            performFletchingAction(29) 
        else
            useWorkbench()
        end
    elseif STATE == 6 then -- mk5 in inv
        if findThing(bankChest, 10, 0) then
            print("load last preset") -- Load last preset
            API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, { bankChest }, 50)
            API.RandomSleep2(1600, 1000, 2000)
        end
    elseif STATE == 7 then -- Unfinished fletching item in inv
        if not API.CheckAnim(80) then
            print("click unfinished fletching item")
            API.DoAction_Inventory1(58111, 0, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(4000, 1000, 2000)
        end
    end
end

API.SetDrawTrackedSkills(true)
API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    idleCheck()
    applyBoosts()
    if API.GetGameState2() ~= 3 or not API.PlayerLoggedIn() then
        print("Bad game state, exiting.")
        break
    end
    topUpBox()
    getState()
    doFletching()
end
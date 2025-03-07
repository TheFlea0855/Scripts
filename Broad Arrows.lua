local API = require("api")
local CreationInterface = require("CreationInterface")
local UTILS = require("utils")

local fletcher = 106599
local fletcherINV = 35227
local broadArrowHeads = 13278
local headlessArrows = 53
local broadArrows = 4160
local torstolID = 47715

local inventoryKey = 0x70 -- F1 SET HOTKEY FOR OPEN INV https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

MAX_IDLE_TIME_MINUTES = 7
startTime, afk, craftinterval = os.time(), os.time(), os.time()

local function notFletching()
    if not API.isProcessing() then
        return true
    else
        return false
    end
end

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
        --checkXpIncrease() 
    end
end

local function haveSupplies()
    if API.InvStackSize(broadArrowHeads) >= 15 and API.InvStackSize(headlessArrows) >= 15 then
        return true
    else
        return false
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

local function DialogBoxOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 12
end


local function doFletching()
    if haveSupplies() and notFletching() then
        if CreationInterface.isOpen() then
            CreationInterface.process()
            API.RandomSleep2(3000,800,1000)         
        elseif findThing(fletcher, 10, 0) then
            if API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ fletcher },50) then
                API.RandomSleep2(600,600,2000)
            end
        elseif Inventory:Contains(fletcherINV) then
            if API.DoAction_Inventory1(fletcherINV,0,1,API.OFF_ACT_GeneralInterface_route) then
                UTILS.randomSleep(1000)
                if DialogBoxOpen() then
                    API.KeyboardPress2(0x31, 50, 200)
                    UTILS.randomSleep(1000)
                end
            end
        else
            API.DoAction_Inventory1(13278,0,1,API.OFF_ACT_GeneralInterface_route)
            UTILS.randomSleep(20000)
        end
    end
end

local mimicikingCount = 0
local unstableCount = 0
local lostCount = 0
local vengefulCount = 0
local function handleElidinisEvents()
    local lostSoul = 17720
    local unstableSoul = 17739
    local mimickingSoul = 18222
    local vengefulSoul = 17802
    local eventIDs = { lostSoul, unstableSoul, mimickingSoul, vengefulSoul }

    local found = false
    local eventObjs = API.GetAllObjArray1(eventIDs, 50, { 1 })
    if #eventObjs > 0 then
        print("Elidinis soul detected!")
        if eventObjs[1].Id == mimickingSoul then
            mimicikingCount = mimicikingCount + 1
        elseif eventObjs[1].Id == unstableSoul then
            unstableCount = unstableCount + 1 
        elseif eventObjs[1].Id == lostSoul then
            lostCount = lostCount + 1 
        elseif eventObjs[1].Id == vengefulSoul then
            vengefulCount = vengefulCount + 1 
        end
        found = true
    end

    local originTile = API.PlayerCoordfloat()
    while #eventObjs > 0 and API.Read_LoopyLoop() do
        if eventObjs[1].Id == mimickingSoul then
           -- API.DoAction_Dive_Tile(eventObjs[1].Tile_XYZ) 
            API.DoAction_TileF(eventObjs[1].Tile_XYZ)
        elseif eventObjs[1].Id == unstableSoul or eventObjs[1].Id == lostSoul then
            -- API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { eventObjs[1].Id }, 50)
            API.DoAction_NPC__Direct(0x29, API.OFF_ACT_InteractNPC_route, eventObjs[1])
        end

        API.RandomSleep2(1000, 250, 500)
        eventObjs = API.GetAllObjArray1(eventIDs, 50, { 1 })
    end

    if found then API.DoAction_TileF(originTile) end
end

local function inFletchingWorkRoom()
    if API.PInArea21(3287, 3290, 3533, 3540) then -- Fletchers workroom coordinates
        return true
    else
        return false
    end
end

local theSpot = WPOINT.new(3289, 3536, 0)
local function returnToSpot()
    if not inFletchingWorkRoom() then
        print("not in the workroom returning to the spot")
        API.DoAction_WalkerW(theSpot)
        API.WaitUntilMovingEnds(10,2)
    end
end

local function applyBoosts()
    local torstol = API.Buffbar_GetIDstatus(torstolID, false)
    if not torstol.found and API.InvStackSize(torstolID) >= 10 then
        API.DoAction_Inventory1(torstolID, 0, 2, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(600, 500, 500)
    elseif torstol.found and torstol.conv_text > 0 and torstol.conv_text < 3 and API.InvStackSize(torstolID) >= 1 then
        API.DoAction_Inventory1(torstolID, 0, 1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(600, 500, 500)
    end
end

API.SetDrawTrackedSkills(true)
API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    if not haveSupplies() then
        print("Out of supplies. Stopping script.")
        API.Write_LoopyLoop(false)
    end
    idleCheck()
    UTILS:gameStateChecks()
    applyBoosts()
    doFletching()
    if not API.OpenInventoryInterface2() then
        API.KeyboardPress2(inventoryKey, 50, 200)
    end
    handleElidinisEvents()
    returnToSpot()

end
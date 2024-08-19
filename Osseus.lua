-- OSSEUS REX SCRIPT
-- USE THE PVME AFK SETUP
-- CREATED BY: The Flea
-- Might need to check line 63 & 71 depending on where you have Wen book on bar. 

local API = require("api")
local UTILS = require("utils")
local GUI = require("gui")

local lootWindowKey = 0x77 -- https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
local inventoryKey = 0x70
local dinoBoneID = 48075
local damagedDinoBoneID = 56881
local notePaperID = 30372
local ELVEN_SHARD = 43358
local excaliburID = 36619
local penancePowderID = 52806
local warRetreatBank = 114750
local warAltar = 114748
local portal = 119701
local elderOverloads = { 49039, 49037, 49035, 49033, 49031, 49029 }
local pouchID = 52825 -- Holy scarab 

--AREAS
-- The X1,X2,Y1,Y2 coords of the rectangle that we consider to be the area
local warsRetreat = WPOINT.new(3296,10127,0)
local entrance = WPOINT.new(3930,9867,0)



local function quickPrayerOn()
    if not API.GetQuickPray() then -- Checks if Quick Prayer is enabled 
        print("Turn on quick prayers")
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1430,16,-1,API.OFF_ACT_GeneralInterface_route) -- Clicks Quick Pray
        UTILS.countTicks(math.random(1,4))
    end
end

local function quickPrayerOff()
    if API.GetQuickPray() then -- Checks if Quick Prayer is enabled 
        print("Turn off quick prayers")
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1430,16,-1,API.OFF_ACT_GeneralInterface_route) -- Clicks Quick Pray
        UTILS.countTicks(math.random(1,4))
    end
end

local function verifyOVL()
    if not API.Buffbar_GetIDstatus(49039).found then
        for _, pot in ipairs(elderOverloads) do
            if API.InvItemcount_1(pot) > 0 then
                print("Drinking Overload!")
                API.DoAction_Inventory1(pot, 0, 1, API.OFF_ACT_GeneralInterface_route)
                break
            end
        end
        UTILS.countTicks(math.random(1,3))
    end
end

local function turnOnWenBook()
    if not API.Buffbar_GetIDstatus(52117).found then
        print("Turn on Wen book")
        API.DoAction_Interface(0x2e,0xcb95,1,1672,79,-1,API.OFF_ACT_GeneralInterface_route) -- Wen Book from bar.
        UTILS.countTicks(math.random(1,4))
    end
end

local function turnOffWenBook()
    if API.Buffbar_GetIDstatus(52117).found then
        print("Turn off Wen book")
        API.DoAction_Interface(0x2e,0xcb95,1,1672,79,-1,API.OFF_ACT_GeneralInterface_route) -- Wen Book from bar.
        UTILS.countTicks(math.random(1,4))
    end
end

local function verifyDarkness()
    if not API.Buffbar_GetIDstatus(30122).found then
        print("Use darkness")
        --API.DoAction_Interface(0x2e,0xffffffff,1,1430,220,-1,API.OFF_ACT_GeneralInterface_route) -- Darkness from ability bar
        API.DoAction_Ability("Darkness", 1, API.OFF_ACT_GeneralInterface_route) -- Darkness from ability bar
        UTILS.countTicks(math.random(1,4))
    end
end

local function hasElvenRitualShard()
    return API.InvItemcount_1(ELVEN_SHARD) > 0
end

local function useElvenRitualShard()
    if not hasElvenRitualShard() then return end
    local elvenCD = API.DeBuffbar_GetIDstatus(43358, false)
    if not elvenCD.found then
        print("Using Elven Shard")
        if API.InventoryInterfaceCheckvarbit() then
            API.DoAction_Inventory1(ELVEN_SHARD,0,1,API.OFF_ACT_GeneralInterface_route) -- elven shard in inventory
            UTILS.countTicks(math.random(1,4)) 
        else 
            API.KeyboardPress2(inventoryKey, 50, 200)
            API.RandomSleep2(300,200,600)
            API.DoAction_Inventory1(ELVEN_SHARD,0,1,API.OFF_ACT_GeneralInterface_route) -- elven shard in inventory
            UTILS.countTicks(math.random(1,4)) 
        end  
    end
end

local function hasExcalibur()
    return API.InvItemcount_1(excaliburID) > 0
end

local function useExcalibur()
    if not hasExcalibur() then return end
    local excaliburCD = API.DeBuffbar_GetIDstatus(14632, false)
    if not excaliburCD.found then
        print("Using Ecalibur")
        if API.InventoryInterfaceCheckvarbit() then
            API.DoAction_Inventory1(excaliburID,0,1,API.OFF_ACT_GeneralInterface_route) -- excalibur in inventory
            UTILS.countTicks(math.random(1,4)) 
        else 
            API.KeyboardPress2(inventoryKey, 50, 200)
            API.RandomSleep2(300,200,600)
            API.DoAction_Inventory1(excaliburID,0,1,API.OFF_ACT_GeneralInterface_route) -- excalibur in inventory
            UTILS.countTicks(math.random(1,4)) 
            UTILS.countTicks(math.random(1,4)) 
        end        
    end
end

local function hasPenancePowder()
    return API.InvItemcount_1(penancePowderID) > 0
end

local function usePenancePowder()
    if not hasPenancePowder() then return end
    local penanceCD = API.Buffbar_GetIDstatus(52806, false)
    if not penanceCD.found then
        print("Using penance powder")
        API.DoAction_Inventory1(52806 ,0,1,API.OFF_ACT_GeneralInterface_route) -- penance powder in inventory
        UTILS.countTicks(math.random(1,4))
    end
end

local function hasLoot()
    return API.LootWindow_GetData()[1].itemid1 > 0 -- check if there is anything in the loot window
end

local function performLooting()
    if not API.InvFull_() then
        local lootWindowOpen = API.LootWindowOpen_2()
        if not lootWindowOpen then
            print("Loot interface not open. Opening now.")
            API.KeyboardPress2(lootWindowKey, 50, 200) -- Open loot interface
            UTILS.countTicks(math.random(1,6))
            if hasLoot() then
                API.DoAction_LootAll_Button()
            end
        else
            if hasLoot() then
                API.DoAction_LootAll_Button()
            end
        end
    end
    UTILS.countTicks(1)
end

local function deathCheck()
    local objList = {27299}
    local checkRange = 25
    local objectTypes = {1}
    local foundObjects = API.GetAllObjArray1(objList, checkRange, objectTypes)
    if foundObjects then
        for _, obj in ipairs(foundObjects) do
            if obj.Id == 27299 then
                return true
            end
        end
    end
    return false
end

local function osseusCheck()
    local objList = {30629}
    local checkRange = 25
    local objectTypes = {1}
    local foundObjects = API.GetAllObjArray1(objList, checkRange, objectTypes)
    if foundObjects then
        for _, obj in ipairs(foundObjects) do
            if obj.Id == 30629 then
                return true
            end
        end
    end
    return false
end

local instanceTimer = { { 861,0,-1,-1,0 }, { 861,2,-1,0,0 }, { 861,4,-1,2,0 }, { 861,8,-1,4,0 } }
local function hasInstanceEnded()
    local result = API.ScanForInterfaceTest2Get(false, instanceTimer)
    if #result > 0 then
        local inter = result[1]
        if inter.textids == "00:00" then
            print("Timer is at 00:00 Instance has ended")
            return true 
        end        
    else
        return false
    end
end

local function inMatriarchLobby()
    local objList = {119681}
    local checkRange = 15
    local objectTypes = {0}
    local foundObjects = API.GetAllObjArray1(objList, checkRange, objectTypes)
    if foundObjects then
        for _, obj in ipairs(foundObjects) do
            if obj.Id == 119681 then
                return true
            end
        end
    end
    return false
end

local function inOsseusLair()
    local objList = {129978}
    local checkRange = 7
    local objectTypes = {12}
    local foundObjects = API.GetAllObjArray1(objList, checkRange, objectTypes)
    if foundObjects then
        for _, obj in ipairs(foundObjects) do
            if obj.Id == 129978 then
                return true
            end
        end
    end
    return false
end

local function summonFamiliar()
    if not API.CheckFamiliar() then
        if API.InvItemcount_1(pouchID) > 0 then
            print("summoning familiar")
            API.DoAction_Inventory2({pouchID}, 0, 1, API.OFF_ACT_GeneralInterface_route)
            UTILS.countTicks(math.random(1,3))
        end        
    end
end

local function banking()
    if hasInstanceEnded() then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1461,1,205,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(4000,1000,3000) -- teleport to wars retreat from spellbook
    end
    if API.PInAreaW(warsRetreat, 30) then
        print("At wars")
        API.RandomSleep2(1500,300,900)  
        API.DoAction_Object1(0x33,API.OFF_ACT_GeneralObject_route3,{ warRetreatBank },50); -- load last preset
        API.WaitUntilMovingEnds()   
        UTILS.countTicks(math.random(1,3))
        API.DoAction_Object1(0x3d,API.OFF_ACT_GeneralObject_route0,{ warAltar },50); -- use war altar
        API.WaitUntilMovingEnds()  
        UTILS.countTicks(math.random(1,3))
        API.DoAction_Tile(WPOINT.new(3293 + math.random(1,3),10141 + math.random(1,3) ,0)) -- walk near portal
        API.RandomSleep2(1000,400,1200)
        API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ portal },50); -- use the portal
        API.WaitUntilMovingEnds()       
    end
    if API.PInAreaW(entrance, 10) then
        print("Instanced encounter")
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route2,{ 119688 },50); -- instanced encounter
        API.RandomSleep2(1500,100,500)
    end
    if API.Compare2874Status(18) then
        print("Start instance")
        API.DoAction_Interface(0x24,0xffffffff,1,1591,60,-1,API.OFF_ACT_GeneralInterface_route) --start instance
        UTILS.countTicks(math.random(1,3))
    end
    if inMatriarchLobby() then
        print("Teleportation device")
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 119681 },50);
        API.WaitUntilMovingEnds()  
        UTILS.countTicks(math.random(3,6))
    end
    if inOsseusLair then
        print("Move to combat position")
        local entryPosition = API.PlayerCoord()
        local combatPosX = entryPosition.x + 9
        local combatPosY = entryPosition.y + 9
        local combatPosZ = entryPosition.z 
        API.RandomSleep2(500,100,500)
        API.DoAction_Tile(WPOINT.new(combatPosX, combatPosY, combatPosZ))
        API.WaitUntilMovingEnds()  
    end
end

local function combatChecks()
    if API.LocalPlayer_IsInCombat_() then
        verifyOVL()
        quickPrayerOn()
        turnOnWenBook()
        verifyDarkness()
        useElvenRitualShard()
        useExcalibur()
        usePenancePowder()
        summonFamiliar()
        API.RandomSleep2(1500,300,900)        
    end
end

API.Write_LoopyLoop(true)
while API.Read_LoopyLoop() do 
    if osseusCheck() then
        combatChecks()
    else
        turnOffWenBook()
        quickPrayerOff()
        if deathCheck() then
            print("You're in deaths office, something has gone wrong! Stopping script.")
            API.Write_LoopyLoop(false)
        end
        performLooting()
        if hasInstanceEnded() then
            banking()
        end
        if API.InvItemFound2(dinoBoneID) and API.InvItemFound2(notePaperID) then
            UTILS.NoteItem(dinoBoneID)
            API.RandomSleep2(1400,200,2000)                
        end
        if API.InvItemFound2(damagedDinoBoneID) and API.InvItemFound2(notePaperID) then
            UTILS.NoteItem(damagedDinoBoneID)
            API.RandomSleep2(1400,200,2000)                
        end
        if API.InvItemFound2(1631) and API.InvItemFound2(notePaperID) then --notes uncut dragonstones to remove inventory clutter
            UTILS.NoteItem(1631)
            API.RandomSleep2(1400,200,2000)                
        end 
        UTILS:antiIdle()
        API.DoRandomEvents()
    end
end

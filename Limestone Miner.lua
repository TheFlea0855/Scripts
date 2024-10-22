-- mine limestone and make into bricks

local API = require('api')
local UTILS = require("utils")
local CreationInterface = require("CreationInterface")


local inventoryKey = 0x70 -- F1 SET HOTKEY FOR OPEN INV https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
-- Areas 
local limestoneMine = WPOINT.new(3375, 3500, 0)
local depositBox = WPOINT.new(3361, 3480, 0 )

-- Objects
local depositBoxID = 90261 


local function mineLimestone()
    local hoverProgress = API.LocalPlayer_HoverProgress()
    math.randomseed(os.time())
    if hoverProgress < 60 + math.random(30, 60) or not API.CheckAnim(20) then
        API.DoAction_Object_string1(0x3a, API.OFF_ACT_GeneralObject_route0, { "Limestone rock" }, 50, true)
        UTILS.countTicks(2)
        API.WaitUntilMovingEnds()
    end
end

local function openInventory()
    if not Inventory:IsOpen() then
        API.KeyboardPress2(inventoryKey, 50, 200)
    end
end

MAX_IDLE_TIME_MINUTES = 5
startTime, afk  = os.time(), os.time()

local function checkXpIncrease() 
    local newXp = API.GetSkillXP("MINING")
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

local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

local trips = 0
local stone = 0

local function halloweenStuff()
    if Inventory:Contains(57605)  then -- double token
        API.DoAction_Inventory1(57605,0,2,API.OFF_ACT_GeneralInterface_route)
    end
    if Inventory:Contains(57604)  then -- triple token
        API.DoAction_Inventory1(57604,0,2,API.OFF_ACT_GeneralInterface_route)
    end
    if Inventory:Contains(57591)  then -- clan confections
        if API.DoAction_Inventory1(57591,0,8,API.OFF_ACT_GeneralInterface_route2) then
            if API.VB_FindPSett(2874, 1).state == 28 then
                API.KeyboardPress("y")
                API.RandomSleep2(600,600,1200)
            end
        end
    end
end


API.SetDrawTrackedSkills(true)
API.SetDrawLogs(true)
API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    local elapsedMinutes = (os.time() - startTime) / 60
    local TripsPH = round((trips * 60) / elapsedMinutes)
    local stonePH = round((stone * 60) / elapsedMinutes)
    local price = API.GetExchangePrice(3420)
    local gold = round(stone * price)
    local goldPH = round(stonePH * price)
    local metrics = {
        {"Script","Limestone miner by The Flea"},
        {"Trips:", formatNumber(trips)},
        {"Trips/H:",formatNumber(TripsPH)},
        {"Limestone:",formatNumber(stone)},
        {"Limestone/H:",formatNumber(stonePH)},
        {"GP:",formatNumber(gold)},
        {"GP/H:",formatNumber(goldPH)},
        }
    API.DrawTable(metrics)
    API.DoRandomEvents()
    idleCheck()
    halloweenStuff()

    openInventory()
    if API.PInAreaW(limestoneMine, 8) and Inventory:FreeSpaces() >= 1 then
        mineLimestone()
    end
    if Inventory:IsFull() and Inventory:Contains(3211) and not API.isProcessing() then
        if CreationInterface.isOpen() then
            print("process")
            CreationInterface.process()
            API.RandomSleep2(3000,800,1000) 
        else
            print("chisel limestone")
            Inventory:DoAction(3211, 1, API.OFF_ACT_GeneralInterface_route)
            UTILS.countTicks(2)
        end
    end
    if Inventory:IsFull() and Inventory:Contains(3420) and not Inventory:Contains(3211) then
        if API.Check_Dialog_Open() then
            API.KeyboardPress("4")
            trips = trips +  1
            stone = stone +  28
            UTILS.countTicks(math.random(1,3))
        end
        if API.PInAreaW(depositBox, 10) then
            print("select item")
            if API.DoAction_Inventory1(3420,0,0,API.OFF_ACT_Bladed_interface_route) then
                UTILS.countTicks(math.random(1,4))
                print("deposit")
                API.DoAction_Object1(0x24,API.OFF_ACT_GeneralObject_route00,{ depositBoxID },50);
                UTILS.countTicks(math.random(1,4))
            end
        else
            if not API.ReadPlayerMovin() then
                API.DoAction_WalkerW(depositBox)
            end
        end
    end
    if not Inventory:IsFull() and not API.PInAreaW(limestoneMine, 8) then
        if not API.ReadPlayerMovin() then
            API.DoAction_WalkerW(limestoneMine)
        end
    end
end
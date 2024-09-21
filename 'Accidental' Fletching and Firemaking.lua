--[[
'Accidental' Fletching and Firemaking by The Flea.
Select which task you want to do from the GUI.
If using dive & surge make sure they're on your action bar somewhere!
]]


local API = require("api")
local GUI = require("gui")
local inventoryKey = 0x70 -- F1 SET HOTKEY FOR OPEN INV https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

-- objects
local incubatorID = 123386
local eggPileID = 123383
local compostBinID = 123389
local stormBarn = 123400
local rootyTrough = 123409
local beanyTrough = 123405
local berryTrough = 123403
local cerealyTrough = 123407

-- items
local goodEgg = 53099
local badEgg = 53100
local fertiliser = 53078
local propellant = 53073
local tummisaurus = 56281
local rootlesaurus = 53082
local beanasaurus = 53080
local berrisaurus = 53079

-- Areas 
local eggPile = WPOINT.new(5221, 2348, 0)
local CompostBin = WPOINT.new(5230, 2327, 0)
local incubator = WPOINT.new(5209, 2351, 0)
local careStylingArea = WPOINT.new(5234, 2328, 0)
local stormBarnArea = WPOINT.new(5304, 2277, 0)
local rootyArea = WPOINT.new(5287, 2258, 0)
local beanyArea = WPOINT.new(5313, 2307, 0)
local berryArea = WPOINT.new(5332, 2292, 0)
local cerealyArea = WPOINT.new(5330, 2271, 0)

-- GUI Initialization with specified order and an "Idle" option
local TASK_OPTIONS = {
    "Idle", "Seggregation", "Eggsperimentation", "Carestyling"
}

-- Add GUI components
GUI.AddBackground("MainBackground", 1, 1, ImColor.new(0, 0, 0, 180))
GUI.AddLabel("Title", "    'Accidental' Fletching and Firemaking by The Flea", ImColor.new(255, 255, 255))
GUI.AddComboBox("TaskSelector", "Select Task", TASK_OPTIONS)
GUI.AddCheckbox("DiveSurgeBox", "Use dive / Surge?")


MAX_IDLE_TIME_MINUTES = 3
startTime, afk = os.time(), os.time()

local function getSelectedTask()
    return GUI.GetComponentValue("TaskSelector")
end

local function useDive()
    return GUI.GetComponentValue("DiveSurgeBox")
end

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
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

local first = true
local function eggIncubation()
    if API.InvFull_() and API.PInAreaW(eggPile, 4) then
        print("click incubator")
        API.DoAction_Object1(0x41,API.OFF_ACT_GeneralObject_route0,{ 123386 },50);
        API.WaitUntilMovingEnds()     
    end
    if API.PInAreaW(incubator, 4) and API.InvItemcount_1(goodEgg) == 0 then
        print("compost")
        if useDive() then
            API.DoAction_Dive_Tile(WPOINT.new(5220 + math.random(-2,2), 2341 + math.random(-2,2), 0))
            API.RandomSleep2(400,100,300)
            API.DoAction_Ability_check("Surge", 1, API.OFF_ACT_GeneralInterface_route, true, true)
            API.RandomSleep2(900,100,1000)
        end
        API.DoAction_Object1(0x41,API.OFF_ACT_GeneralObject_route0,{ compostBinID },50);
        API.WaitUntilMovingEnds() 
    end
    if API.PInAreaW(CompostBin, 4) and API.InvItemcount_1(badEgg) == 0 then
        print("get more eggs")
        API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,{ eggPileID },50);
        API.RandomSleep2(1000,100,600)
    end
    if API.ReadPlayerMovin2() and API.PInAreaW(WPOINT.new(5228, 2334, 0), 2) and useDive() then
        API.DoAction_Dive_Tile(WPOINT.new(5221 + math.random(-1,0), 2348 + math.random(-1,0), 0)) 
        API.RandomSleep2(600,100,600)           
        API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,{ eggPileID },50);
    end
    if API.Invfreecount_() > 0 and API.PInAreaW(eggPile, 10) and first == true then
        API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,{ eggPileID },50);
        first = false
        API.RandomSleep2(1000,100,600)
        API.WaitUntilMovingEnds() 
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

local function dinoPropellant()
    if first == true then
        if API.PInAreaW(stormBarnArea, 10) and API.Invfreecount_() > 0 and findThing(stormBarn, 20, 0) then
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ stormBarn },50);
            API.WaitUntilMovingEnds()
            first = false            
        elseif API.PInAreaW(rootyArea, 5) and API.InvItemcount_1(tummisaurus) > 0 and findThing(rootyTrough, 20, 0) then
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ rootyTrough },50);
            API.WaitUntilMovingEnds()
            first = false            
        elseif API.PInAreaW(beanyArea, 5) and API.InvItemcount_1(rootlesaurus) > 0 and findThing(beanyTrough, 20, 0) then
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ beanyTrough },50);
            API.WaitUntilMovingEnds()
            first = false            
        elseif API.PInAreaW(berryArea, 5) and API.InvItemcount_1(beanasaurus) > 0 and findThing(berryTrough, 20, 0) then
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ berryTrough },50);
            API.WaitUntilMovingEnds()
            first = false            
        elseif API.PInAreaW(cerealyArea, 5) and API.InvItemcount_1(berrisaurus) > 0 and findThing(cerealyTrough, 20, 0) then
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ cerealyTrough },50);
            API.WaitUntilMovingEnds()
            first = false            
        elseif API.InvItemcount_1(fertiliser) > 0 then
            API.DoAction_Inventory1(fertiliser, 0, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(1000,100,600)
            first = false 
        end        
    end
    if API.InvItemcount_1(fertiliser) >= 26 then
        API.RandomSleep2(1600,100,2400)  
        print("click fertiliser")
        API.DoAction_Inventory1(fertiliser, 0, 1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(6000,100,1000)
    elseif API.InvItemcount_1(berrisaurus) >= 26 then
        API.RandomSleep2(1600,100,2400)  
        print("27 berrisaurus")
        if findThing(cerealyTrough, 25, 0) then
            print("click cerealy trough")
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ cerealyTrough },50);
            API.RandomSleep2(12000,1000,6000)
        end        
    elseif API.InvItemcount_1(beanasaurus) >= 26 then
        API.RandomSleep2(1600,100,2400)  
        print("27 beanasaurus")
        if useDive() then
            API.DoAction_Dive_Tile(WPOINT.new(5327 + math.random(-2,2), 2290 + math.random(-2,2), 0))
            API.RandomSleep2(300,100,300)
            API.DoAction_Ability_check("Surge", 1, API.OFF_ACT_GeneralInterface_route, true, true)
            API.RandomSleep2(1800,100,600)
        end
        if findThing(berryTrough, 40, 0) then
            print("click berry trough")
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ berryTrough },50);
            API.RandomSleep2(8000,100,1000)
        end       
    elseif API.InvItemcount_1(rootlesaurus) >= 26 then
        API.RandomSleep2(1600,100,2400)  
        print("27 rootlesaurus")
        if API.PInAreaW(WPOINT.new(5289, 2259, 0), 5) and useDive() then 
            API.DoAction_Dive_Tile(WPOINT.new(5301 + math.random(-2,2), 2281 + math.random(-3,3), 0))
            API.RandomSleep2(400,200,300)
            API.DoAction_Ability_check("Surge", 1, API.OFF_ACT_GeneralInterface_route, true, true)
            API.RandomSleep2(600,100,700)
        end
        API.DoAction_Tile(WPOINT.new(5312 + math.random(-2,2), 2308 + math.random(-2,2), 0))
        API.RandomSleep2(2500,100,1000)
        if findThing(beanyTrough, 25, 0) then
            print("click beany trough")
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ beanyTrough },50);
            API.RandomSleep2(9000,100,1000)
        end  
    elseif API.InvItemcount_1(tummisaurus) >= 26 then
        API.RandomSleep2(1600,100,1000)  
        print("27 tummisaurus")
        if API.PInAreaW(WPOINT.new(5304,2276, 0), 5) and useDive() then 
            API.DoAction_Dive_Tile(WPOINT.new(5289 + math.random(-2,2), 2259 + math.random(0,2), 0))
            API.RandomSleep2(300,100,300)
            API.DoAction_Ability_check("Surge", 1, API.OFF_ACT_GeneralInterface_route, true, true)
            API.RandomSleep2(800,200,800)
        end
        if findThing(rootyTrough, 25, 0) then
            print("click rooty trough")
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ rootyTrough },50);
            API.RandomSleep2(7000,100,1000)
        end
    elseif API.Invfreecount_() > 25 and API.InvItemcount_1(fertiliser) == 0 then
        API.RandomSleep2(600,100,2400)  
        print("27 free spaces")
        if findThing(stormBarn, 40, 0) then
            print("click storm barn")
            API.DoAction_Object1(0x2f,API.OFF_ACT_GeneralObject_route0,{ stormBarn },50);
            API.RandomSleep2(13000,100,2000)
        end
    end
end

local function careStyling()
    if not API.PInAreaW(careStylingArea, 10) then
        print("not in the care styling area. Stopping script.")
        API.Write_LoopyLoop(false)
    elseif findThing(28978, 10, 1) then
        if not API.CheckAnim(100) then 
            print("Click scruffy")
            API.DoAction_NPC(0xcd,API.OFF_ACT_InteractNPC_route,{ 28978 },50)
            API.WaitUntilMovingEnds() 
            API.RandomSleep2(1000,100,1000)
        end
    end
end

API.SetDrawTrackedSkills(true)
API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    GUI.Draw()
    API.DoRandomEvents()
    idleCheck()
    applyBoosts()
    if not API.OpenInventoryInterface2() then
        API.KeyboardPress2(inventoryKey, 50, 200)
    end
    if getSelectedTask() == "Seggregation" then
        eggIncubation()
    elseif getSelectedTask() == "Carestyling" then
        careStyling()
    elseif getSelectedTask() == "Eggsperimentation" then
        dinoPropellant()
    elseif getSelectedTask() == "Idle" then
        print("Please select a task.")
        API.RandomSleep2(3000,1000,1000)
    end
end

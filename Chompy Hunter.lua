--[[
    @name Chompy Hunter
    @author The Flea
    @version 1
]]
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--     Start at fairy ring BKP. 
--     Have oldak coil + cannonballs in inv. 
--    Equip comp ogre bow + ogre arrows.
--    Revolution bar with ricochet as first ability.   
--    Recommend at least 5 ogre bellows in inventory.
--    Place empty ogre bellows on action bar somewhere.
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

local API = require("api")
local UTILS = require("utils")

local targetKC = 4000

local swampToadID = 1013
local bloatedToadID = 1014
local deadChompyID = 1016
local chompyID = 1550
local oldakCoilINV = 37408
local fillSpot = WPOINT.new(2394, 3045, 0)

local L1T1 = WPOINT.new(2392, 3046, 0)
local L1T2 = WPOINT.new(2391, 3046, 0)
local L1T3 = WPOINT.new(2390, 3046, 0)
local L2T1 = WPOINT.new(2392, 3045, 0)
local L2T2 = WPOINT.new(2391, 3045, 0)
local L2T3 = WPOINT.new(2390, 3045, 0)
local L3T1 = WPOINT.new(2392, 3044, 0)
local L3T2 = WPOINT.new(2391, 3044, 0)
local L3T3 = WPOINT.new(2390, 3044, 0)

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
--Spectre's clue hunter
local function IsPlayerAtCoords(x, y, z)
    local coord = API.PlayerCoord()
    if x == coord.x and y == coord.y and z == coord.z then
        return true
    else
        return false
    end
end

--Spectre's clue hunter
local function IsPlayerInArea(x, y, z, radius)
    local coord = API.PlayerCoord()
    local dx = math.abs(coord.x - x)
    local dy = math.abs(coord.y - y)
    if dx <= radius and dy <= radius and coord.z == z then
        return true
    else
        return false
    end
end

--Spectre's clue hunter
local function MoveTo(X, Y, Z, Tolerance)
    API.DoAction_WalkerW(WPOINT.new(X + math.random(-Tolerance, Tolerance),Y + math.random(-Tolerance, Tolerance),Z))
    local startTimer = os.clock()
    while API.Read_LoopyLoop() and not IsPlayerInArea(X, Y, Z, Tolerance + 1) do
        UTILS.randomSleep(300)
        if os.clock() - startTimer > 5 then

            break -- Exit after 5 seconds
        end
    end
    return true
end

local function checkCannon()
    local cannonDEBUFF = API.DeBuffbar_GetIDstatus(2, false)
    if cannonDEBUFF.found and cannonDEBUFF.conv_text > 0 and cannonDEBUFF.conv_text < 3 then
        API.DoAction_Object1(0xa9,API.OFF_ACT_GeneralObject_route0,{ 102687 },50); -- click oldak coil
        UTILS.randomSleep(1500)
        API.WaitUntilMovingEnds(10, 2)
    end
end


local function placeCoil()
    local cannonDEBUFF = API.DeBuffbar_GetIDstatus(2, false)
    if cannonDEBUFF.found then
        return
    else
        if Inventory:Contains(oldakCoilINV) then
            print("Place oldak coil")
            MoveTo(2387, 3043, 0 ,0)
            UTILS.randomSleep(1000)    
            API.DoAction_Inventory1(37408,0,1,API.OFF_ACT_GeneralInterface_route)
            UTILS.randomSleep(3000)
            Interact:Object("Oldak coil", "Load", 20)
            UTILS.randomSleep(2000)
        end
    end
end

local function fillBellows()
    if not IsPlayerAtCoords(fillSpot.x, fillSpot.y, fillSpot.z) then
        MoveTo(fillSpot.x, fillSpot.y, fillSpot.z, 0)
        UTILS.randomSleep(1500)
        API.WaitUntilMovingEnds(10, 2)
    else
        while API.Read_LoopyLoop() and Inventory:GetItemAmount(2871) > 0 and IsPlayerAtCoords(fillSpot.x, fillSpot.y, fillSpot.z) do
            local bellowsFull = API.GetABs_name1("Ogre bellows")
            if bellowsFull.enabled  then
                API.DoAction_Ability("Ogre bellows", 1, API.OFF_ACT_GeneralInterface_route)
                UTILS.randomSleep(500)
            end
        end
    end
end

local function fillToads()
    if not Inventory:IsFull() then
        if findThing(swampToadID, 20, 1) then
            API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route,{ swampToadID },50)
            UTILS.randomSleep(800)
            API.WaitUntilMovingEnds(10, 2)
        end
    end
end

local function findObjectOnTile(ID, tile)
    local range = 20
    local objectTypes = {1}

    local objects = API.GetAllObjArray1({ID}, range, objectTypes)

    for _, obj in ipairs(objects) do
        if obj.Tile_XYZ then
            -- Round or floor the object's x and y to get tile grid coords
            local ox = math.floor(obj.Tile_XYZ.x)
            local oy = math.floor(obj.Tile_XYZ.y)

            if ox == tile.x and oy == tile.y then
                return true
            end
        end
    end

    return false
end

local function checkAndPlaceToads()
    if findObjectOnTile(bloatedToadID, L1T1) or findObjectOnTile(bloatedToadID, L1T2) or findObjectOnTile(bloatedToadID, L1T3) then
        print("lane 1 tiles is occupied")
        goto check2
    else
        MoveTo(L1T1.x, L1T1.y, 0, 0)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        goto continue
    end
    ::check2::
    if findObjectOnTile(bloatedToadID, L2T1) or findObjectOnTile(bloatedToadID, L2T2) or findObjectOnTile(bloatedToadID, L2T3) then
        print("lane 2 tiles is occupied")
        goto check3
    else
        MoveTo(L2T1.x, L2T1.y, 0, 0)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        goto continue
    end
    ::check3::
    if findObjectOnTile(bloatedToadID, L3T1) or findObjectOnTile(bloatedToadID, L3T2) or findObjectOnTile(bloatedToadID, L3T3) then
        print("lane 3 tiles is occupied")
        goto continue
    else
        MoveTo(L3T1.x, L3T1.y, 0, 0)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        API.DoAction_Inventory1(2875,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1200)
        goto continue
    end
    ::continue::
end

local function pluckAndLootChompy()
    if API.LootWindowOpen_2() then
        print("loot window open")
        API.DoAction_Loot_w({2876}, 15, API.PlayerCoordfloat(), 5)
        UTILS.randomSleep(600)
    end
    if findThing(2876, 20, 3) then
        print("chompy on floor")
        API.DoAction_G_Items1(0x2d,{ 2876 },50);
        UTILS.randomSleep(600)
        API.WaitUntilMovingEnds(10,2)
        API.DoAction_Loot_w({2876}, 15, API.PlayerCoordfloat(), 5)
    end
    if findThing(deadChompyID, 20, 1) then
        print("pluck dead chompy")
        local chompytoPluck = API.GetAllObjArray1( { deadChompyID }, 20, {1})
        API.DoAction_NPC__Direct(0x29, API.OFF_ACT_InteractNPC_route3, chompytoPluck[1])
        UTILS.randomSleep(2000)
        API.WaitUntilMovingEnds(10,2)
    end
end

local function attackChompy()
    if not API.IsTargeting() then
        if findThing(chompyID, 40, 1) then
            if API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route,{ chompyID },50) then
                UTILS.randomSleep(3500)
            end
        end
    end
end

local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

local startKills = API.VB_FindPSettinOrder(2773).state
startTime = os.time()
API.SetMaxIdleTime(10)
API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    local currentKills = API.VB_FindPSettinOrder(2773).state
    local killedThisSession = currentKills - startKills
    local elapsedMinutes = (os.time() - startTime) / 60
    local killsPH = round((killedThisSession * 60) / elapsedMinutes)
    local metrics = {
        {"Total chompy birds killed:", killedThisSession},
        {"Chompy kills per hour:", killsPH},
    }
    API.DrawTable(metrics)
    API.DoRandomEvents()

    if currentKills >= targetKC then
        API.Write_LoopyLoop(false)
    end
    placeCoil()
    attackChompy()
    pluckAndLootChompy()
    if Inventory:GetItemAmount(2875) == 3 then -- bloated toad
        checkAndPlaceToads()
        goto here
    else
        if Inventory:GetItemAmount(2872) > 0 or Inventory:GetItemAmount(2873) > 0 or Inventory:GetItemAmount(2874) > 0 then
            print("Fill Toads")
            fillToads()
        else
            print("Fill bellows")
            fillBellows()
        end
    end


    checkCannon()
    UTILS.randomSleep(1000)
    ::here::
end
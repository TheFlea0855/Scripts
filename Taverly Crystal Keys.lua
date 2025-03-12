--[[
    @name Taverly Crystal Keys
    @author The Flea
    @version 1
]]
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--     ENSURE NOTED CRYSTAL KEYS ARE IN YOUR INVENTORY AND START NEAR THE CHEST.    --
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

local API = require("api")

local IDs = {
    crystalChest = 172,
    pikkupstix = 6988,
    crystalKey = 989,
    notedCrystalKey = 990,
}

local shopInterface = {InterfaceComp5.new( 1265,7,-1,0 )}
local chestInterface = {InterfaceComp5.new( 168,0,-1,0)}

local rewardValueInterface = {
    InterfaceComp5.new( 168,0,-1,0),
    InterfaceComp5.new( 168,2,-1,0),
    InterfaceComp5.new( 168,33,-1,0 ),
}

local totalLoot = 0
local keysUsed = 0
local costPerKey = API.GetExchangePrice(IDs.crystalKey)

MAX_IDLE_TIME_MINUTES = 5
startTime, afk = os.time(), os.time()

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

local function isInterfacePresent(INTERFACENAME)
    local result = API.ScanForInterfaceTest2Get(true, INTERFACENAME)
    if #result > 0 then
        return true
    else return false end
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
    end
end

local function useShop()
    if isInterfacePresent(shopInterface) then
        print("Buying and selling from the shop")
        API.DoAction_Interface(0x24,0xffffffff,1,1265,32,-1,API.OFF_ACT_GeneralInterface_route) -- sell tab
        API.RandomSleep2(600, 500, 1000)
        API.DoAction_Interface(0xffffffff,0xffffffff,4,1265,20,0,API.OFF_ACT_GeneralInterface_route) -- sell 10
        API.RandomSleep2(600, 500, 500)
        API.DoAction_Interface(0xffffffff,0xffffffff,4,1265,20,0,API.OFF_ACT_GeneralInterface_route) -- sell 10
        API.RandomSleep2(600, 500, 500)
        API.DoAction_Interface(0xffffffff,0xffffffff,3,1265,20,0,API.OFF_ACT_GeneralInterface_route) -- sell 5
        API.RandomSleep2(1000, 500, 500)
        API.DoAction_Interface(0x24,0xffffffff,1,1265,41,-1,API.OFF_ACT_GeneralInterface_route) --buy tab
        API.RandomSleep2(600, 500, 500)
        API.DoAction_Interface(0xffffffff,0xffffffff,7,1265,20,12,API.OFF_ACT_GeneralInterface_route2) -- buy all
    end
end


API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()

    if isInterfacePresent(chestInterface) then
        local valueInterface = API.ScanForInterfaceTest2Get(false, rewardValueInterface)
        local text = valueInterface[1].textids
        local reward = text:match("(%d[%d,]*)")
        if reward then    
            local clean_reward = reward:gsub(",", "")
            local numeric_reward = tonumber(clean_reward)
            if numeric_reward then
                print(numeric_reward) 
                totalLoot = totalLoot + numeric_reward
            end
        end
        print("click bank all")
        if API.DoAction_Interface(0x24,0xffffffff,1,168,27,-1,API.OFF_ACT_GeneralInterface_route) then -- bank all
            keysUsed = keysUsed + 1
        end 
    elseif Inventory:Contains(IDs.crystalKey) then
        if findThing(IDs.crystalChest, 20, 12) then
            print("Have crystal key in inventory. Opening chest.")
            Interact:Object("Crystal chest", "Open", 20)
        end   
    elseif Inventory:Contains(IDs.notedCrystalKey) then
        if isInterfacePresent(shopInterface) then
            print("Shop open")
            useShop()
        elseif findThing(IDs.pikkupstix, 20, 1) then
            print("Trade pikkupstix")
            Interact:NPC("Pikkupstix", "Trade", 20)
        end
    else
        print("No crystal keys found. Stopping script.")
        API.Write_LoopyLoop(false)
    end
    
    local runtime = API.ScriptRuntimeString()
    local profit = (totalLoot - (costPerKey * keysUsed))
    local elapsedMinutes = (os.time() - startTime) / 60
    local keysPH = round((keysUsed * 60) / elapsedMinutes)
    local profitPH = round((profit * 60)/ elapsedMinutes)
    local metrics = {
        {"Runtime:", (runtime)},
        {"Crystal Keys used:", formatNumber(keysUsed)},
        {"Crystal Keys per hour:", formatNumber(keysPH)},
        {"Total Reward:", formatNumber(totalLoot)},
        {"Total Profit:",formatNumber(profit)},
        {"Profit per hour:",formatNumber(profitPH)},
        }
    API.DrawTable(metrics)

        
    API.RandomSleep2(600, 1200, 1200)
end
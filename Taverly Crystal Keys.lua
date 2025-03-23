--[[
    @name Taverly Crystal Keys
    @author The Flea
    @version 1.1
]]
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--     ENSURE NOTED CRYSTAL KEYS ARE IN YOUR INVENTORY AND START NEAR THE CHEST.    --
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

local API = require("api")
local bankPin = 1234  -- set bank pin here

Interact:SetSleep(600, 600, 1000)

local IDs = {
    crystalChest = 172,
    pikkupstix = 6988,
    crystalKey = 989,
    notedCrystalKey = 990,
}

local shopInterface = {InterfaceComp5.new( 1265,7,-1,0 )}
local BankpinInterface = {InterfaceComp5.new(759,5,-1,-1)}

local chestPosition = WPOINT.new(2917, 3451, 0)

local totalLoot = 0
local keysUsed = 0
local costPerKey = API.GetExchangePrice(IDs.crystalKey)

API.SetMaxIdleTime(6)

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
        API.RandomSleep2(1200, 900, 1300)
        if isInterfacePresent(BankpinInterface) then
            API.DoBankPin(bankPin)
            API.RandomSleep2(600, 500, 500)
        end
    end
end

local function readLootFromContainer()
    local loot = {}
    local data = API.Container_Get_all(893)
    for i = 1, #data, 1 do
        local item = data[i]
        if(item.item_id > -1) then
            table.insert(loot,{item.item_id, item.item_stack})
        end
    end
    return loot
end

local function getTotalLootValue()
    local totalValue = 0
    local loot = readLootFromContainer() -- Get the loot table
    for i = 1, #loot do
        local item_id = loot[i][1] -- Extract item ID
        local item_stack = loot[i][2] -- Extract item stack count
        
        local item_value
        if item_id == 995 then
            item_value = item_stack -- Gold coins, use stack size directly
        else
            item_value = API.GetExchangePrice(item_id) * item_stack
        end

        totalValue = totalValue + item_value -- Add to total value
    end
    return totalValue
end


API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()

    if API.Compare2874Status(18) and API.PInAreaW(chestPosition, 1) then
        local totalLootValue = getTotalLootValue()
        totalLoot = totalLoot + totalLootValue
        print("Total Loot Value: " .. totalLootValue)
        print("click bank all")
        if API.DoAction_Interface(0x24,0xffffffff,1,168,27,-1,API.OFF_ACT_GeneralInterface_route) then -- bank all
            keysUsed = keysUsed + 1
        end 
    elseif Inventory:Contains(IDs.crystalKey) then
        if findThing(IDs.crystalChest, 20, 12) then
            print("Have crystal key in inventory. Opening chest.")
            Interact:Object("Crystal chest", "Open", 20)
            if not API.PInAreaW(chestPosition, 1) then
                print("Not infront of chest")
                API.RandomSleep2(1200,300,600)
            end
        end   
    elseif Inventory:Contains(IDs.notedCrystalKey) then
        if isInterfacePresent(shopInterface) then
            print("Shop open")
            useShop()
        elseif findThing(IDs.pikkupstix, 20, 1) then
            print("Trade pikkupstix")
            Interact:NPC("Pikkupstix", "Trade", 20)
            API.RandomSleep2(2000, 500, 500)
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
    API.RandomSleep2(600, 600, 1200)
end

local API = require("api")
local UTILS = require("utils")
API.Write_fake_mouse_do(false)

local POTIONS = { 32753, 32755, 32757, 32759 }
local torstolID = 47715
local logsID = 58250
local bankChestID = 106235
local pouchID = 12021 -- beaver
local restorePot = {3024, 3026, 3028, 3030}
local eternalMagicBranchID = 58147
local heediID = 31499

-- Areas 
local trees = WPOINT.new(2330, 3586, 0)
local bankArea = WPOINT.new(2280, 3558, 0)


API.SetMaxIdleTime(10)
startTime, afk  = os.time(), os.time() 


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

local function checkXpIncrease() 
    local timeDiff = os.difftime(os.time(), afk)
    local checkTime = 500
    if timeDiff > checkTime then
        afk = os.time()
        local newXp = API.GetSkillXP("WOODCUTTING")
        if newXp == startXp then 
            API.logError("no xp increase")
            API.Write_LoopyLoop(false)
        else
            startXp = newXp
        end
    end
end

local function takeWoodcuttingPot()
    if API.Buffbar_GetIDstatus(32757).conv_text > 1 then
        return
    end

    for _, pot in ipairs(POTIONS) do
        if API.InvItemcount_1(pot) > 0 then
            print("Drinking potion!")
            API.DoAction_Inventory1(pot, 0, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(800,1800,2400)
            break
        end
    end
end

local function summonFamiliar()
    if not API.CheckFamiliar() then
        if API.InvItemcount_1(pouchID) > 0 then
            for _, restores in ipairs(restorePot) do
                if API.InvItemcount_1(restores) > 0 then
                    print("Drinking restore potion")
                    UTILS.countTicks(math.random(3,5))
                    if API.DoAction_Inventory1(restores, 0, 1, API.OFF_ACT_GeneralInterface_route) then
                        print("summoning familiar")
                        API.DoAction_Inventory2({pouchID}, 0, 1, API.OFF_ACT_GeneralInterface_route)
                        UTILS.countTicks(math.random(1,3))
                        break
                    end
                end
            end
        end        
    end
end

local function highlights()
    local highlight = API.GetAllObjArray1({ 8447 }, 25, {4})
    if highlight and #highlight > 0 then
        local hlTileX = (highlight[1].TileX / 512) - 1
        local hlTileY = (highlight[1].TileY / 512) - 1
        if not API.PInAreaW(WPOINT.new(hlTileX, hlTileY, 0), 2) then
            local walkToTile = WPOINT.new(hlTileX, hlTileY, 0)
            print("HL found walking there: " .. hlTileX .. " " .. hlTileY)
            API.RandomSleep2(800,1800,2400)
            if API.DoAction_Tile(walkToTile) then
                API.RandomSleep2(1200, 2000, 3000)
            end
        end
    end
end

local function ChopTree()
    if not API.CheckAnim(20) then
        local success = API.DoAction_Object_valid1(0x3b,API.OFF_ACT_GeneralObject_route0,{131907},50,true)
        if success then
            print("chopping tree")
            API.WaitUntilMovingandAnimEnds(10,2)
            if not API.CheckAnim(20) then
                local newTreeSuccess = API.DoAction_Object_valid1(0x3b,API.OFF_ACT_GeneralObject_route0,{131907},50,true)
                if newTreeSuccess then
                    print("Found a new tree to chop.")
                    API.WaitUntilMovingandAnimEnds(5,1)
                else
                    print("No more trees found nearby.")
                end
            end
        else
            print("Failed to initiate chopping action. Retrying...")
        end
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

local function getWoodBoxItemCount(itemId)
    local containerItems = API.Container_Get_all(937) -- Retrieves all items in the box
    local itemCount = 0
    for _, itemData in pairs(containerItems) do
        if itemData.item_id == itemId then
            itemCount = itemCount + itemData.item_stack
        end
    end
    return itemCount
end

local function bank()
    print("banking")
    if not API.PInAreaW(bankArea, 8) then
        print("Go to bank")
        API.DoAction_WalkerW(WPOINT.new(bankArea.x + math.random(-2, 1),bankArea.y + math.random(-3, 0), 0))
        API.RandomSleep2(8000,2000,3000)
        API.WaitUntilMovingEnds(6, 4)
    else
        if API.DoAction_Inventory1(58253,0,0,API.OFF_ACT_Bladed_interface_route) then
            print("used box")
            API.RandomSleep2(1000,1600,1900)
            if API.DoAction_Object1(0x24,API.OFF_ACT_GeneralObject_route00,{ bankChestID },50) then
                print("on bank")
                API.RandomSleep2(2000,1600,1900)
                API.DoAction_Object1(0x33,API.OFF_ACT_GeneralObject_route3,{ bankChestID },50);
                API.RandomSleep2(2000,1600,1900)
            end
        end
    end
end

local function returnToTrees()
    if not API.PInAreaW(trees, 20) then
        print("Return to trees")
        API.DoAction_WalkerW(WPOINT.new(trees.x + math.random(-5, 5),trees.y + math.random(-5, 5), 0))
        API.RandomSleep2(6000,2000,3000)
    end
end

local heediInterface = {
    InterfaceComp5.new( 847,0,-1,0),
    InterfaceComp5.new( 847,33,-1,0)
  }
  local function isHeediInterfacePresent()
    local result = API.ScanForInterfaceTest2Get(true, heediInterface)
    if #result > 0 then
        return true
    else return false end
  end

local eternalMagicBranchAmount = 0
local function eternalMagicBranch()
    if API.InvItemcount_1(eternalMagicBranchID) > 0 and API.PInAreaW(trees, 20) then
        if isHeediInterfacePresent() then
            print("Offer branches interface open")
            API.RandomSleep2(600,1200,1400)
            API.DoAction_Interface(0xffffffff,0xffffffff,0,847,22,-1,API.OFF_ACT_GeneralInterface_Choose_option)
            eternalMagicBranchAmount = eternalMagicBranchAmount + 1 
            API.RandomSleep2(800,1200,3000)
        else
            print("interact with Heedi")
            API.DoAction_NPC(0x3b,API.OFF_ACT_InteractNPC_route2,{ heediID },50)
            API.RandomSleep2(800,1200,3000)
        end
    end
end

API.SetDrawTrackedSkills(true)
while (API.Read_LoopyLoop()) do
    if API.GetGameState2() ~= 3 or not API.PlayerLoggedIn() then
        print("Bad game state, exiting.")
        break
    end

    API.DoRandomEvents()
    applyBoosts()
    takeWoodcuttingPot()
    summonFamiliar()
    checkXpIncrease()
    if API.InvItemcount_1(eternalMagicBranchID) > 0 and API.PInAreaW(trees, 20) then
        eternalMagicBranch()
    elseif API.InvFull_() then
        API.RandomSleep2(2000,5000,7000)
        if getWoodBoxItemCount(logsID) < 310 then
            print("fill wood box")
            Inventory:DoAction(58253, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(600,1200,1800)
        else
            bank()
        end
    else
        returnToTrees()
        highlights()
        ChopTree()
    end
end
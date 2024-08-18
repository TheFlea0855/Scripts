local API = require("api")

--[[
    Name: Lunar Fire Urns
    Description: Fires Urns using the lunar spell book. 
    Author: The Flea
    Version: 1.0
    INSTRUCTIONS: Have the last loaded preset containing unfired urns, and a rune pouch with required runes equipped. 
                  Set the BANK ID (Line 13) unfired urn ID (Line 14) 
                  Ensure Fire Urn is on the ability bar
]]

local bankID = 125115
local unfiredID = 40876

API.SetDrawTrackedSkills(true)

local function hasUnfired()
    if API.InvItemcount_1(unfiredID) > 0 then
        return true
    else
        return false
    end
end

local function craftingInterfaceOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 1310738 or 40
end

local function nearBank()
    local objList = {bankID}
    local checkRange = 10
    local objectTypes = {0}
    local foundObjects = API.GetAllObjArray1(objList, checkRange, objectTypes)
    if foundObjects then
        for _, obj in ipairs(foundObjects) do
            if obj.Id == bankID then
                return true
            end
        end
    end
    return false
end

local function loadLastPreset()
    if nearBank() then
        API.DoAction_Object1(0x33,API.OFF_ACT_GeneralObject_route3,{ bankID },50);
        API.WaitUntilMovingEnds() 
        API.RandomSleep2(1000,100,600)
    end
end

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    if hasUnfired() then
        API.RandomSleep2(1000,100,600)
        if API.isAbilityAvailable("Fire Urn") then
            if not API.isProcessing() then
                API.DoAction_Ability("Fire Urn", 1, API.OFF_ACT_GeneralInterface_route)
                API.RandomSleep2(400,400,1000)
                if craftingInterfaceOpen() then
                    API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,API.OFF_ACT_GeneralInterface_Choose_option)  
                    API.RandomSleep2(400,400,1000)        
                 end
            end
        end
    else
        loadLastPreset()    
    end
end

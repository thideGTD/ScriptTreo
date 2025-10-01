local SeedWaitRoll = 200000
local SeedStopRoll = 200000
local _wait = task.wait

-- Wait for game to load
local success, err = pcall(function()
    repeat _wait() until game:IsLoaded()
end)
if not success then
    warn("Error waiting for game to load:", err)
    return
end

-- Initialize services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for GUI elements
local success, logicRoot = pcall(function()
    return player:WaitForChild("PlayerGui"):WaitForChild("LogicHolder")
end)
if not success then
    warn("Error accessing PlayerGui.LogicHolder:", logicRoot)
    return
end

local success, modulesDir = pcall(function()
    return logicRoot:WaitForChild("ClientLoader"):WaitForChild("Modules")
end)
if not success then
    warn("Error accessing Modules directory:", modulesDir)
    return
end

-- Load ClientDataHandler
local success, ClientDataHandler = pcall(function()
    return require(modulesDir:WaitForChild("ClientDataHandler"))
end)
if not success then
    warn("Error loading ClientDataHandler:", ClientDataHandler)
    return
end

-- Initialize remotes
local success, deleteRemote = pcall(function()
    return ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("DeleteUnit")
end)
if not success then
    warn("Error accessing DeleteUnit remote:", deleteRemote)
    return
end

-- Load external script
local success, externalResult = pcall(function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/thideGTD/ScriptTreo/refs/heads/main/TNGHIA.lua"))()
    end)
end)
if not success then
    warn("Error loading external script:", externalResult)
end

-- Function to convert Seeds to number
local function convertToNumber(value)
    local success, result = pcall(function()
        local strValue = tostring(value)
        if strValue:match("[kK]") then
            return tonumber(strValue:gsub("[kK]", "")) * 1000
        elseif strValue:match("[mM]") then
            return tonumber(strValue:gsub("[mM]", "")) * 1000000
        elseif strValue:match("[bB]") then
            return tonumber(strValue:gsub("[bB]", "")) * 1000000000
        else
            return tonumber(strValue:gsub(",", ""))
        end
    end)
    if not success then
        warn("Error converting Seeds value:", result)
        return nil
    end
    return result
end

-- Roll function
local function Roll()
    local success, result = pcall(function()
        local args = { "ub_anime", 10 }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
    end)
    if not success then
        warn("Error in Roll function:", result)
    end
end

-- RemoveUnit function
local function RemoveUnit()
    local success, result = pcall(function()
        local inventory = ClientDataHandler.GetValue("Inventory")
        local toDelete = {}
        local kept = {}
        for uniqueId, unitData in pairs(inventory or {}) do
            local itemId = unitData.ItemData and unitData.ItemData.ID
            local rarityConfig = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(itemId))
            if rarityConfig.Rarity == "ra_godly" or rarityConfig.Rarity == "ra_exclusive" or unitData.Equipped == true then
                kept[itemId] = true
            elseif not kept[itemId] then
                kept[itemId] = true
            else
                table.insert(toDelete, uniqueId)
            end
        end
        if #toDelete > 0 then
            print("🗑️ Deleting", #toDelete, "units...")
            local deleteSuccess, deleteResult = pcall(function()
                deleteRemote:InvokeServer(toDelete)
            end)
            if not deleteSuccess then
                warn("Error deleting units:", deleteResult)
            end
        else
            print("✅ Không có unit nào cần xoá.")
        end
    end)
    if not success then
        warn("Error in RemoveUnit function:", result)
    end
end

-- StartRoll function
local function StartRoll()
    local success, result = pcall(function()
        while StartRolls do
            local SeedHave = convertToNumber(player.leaderstats.Seeds.Value)
            if not SeedHave then
                warn("Failed to get SeedHave, stopping rolls")
                StartRolls = false
                break
            end
            if SeedHave <= SeedStopRoll then
                StartRolls = false
                print("Seeds below threshold, stopping rolls")
                break
            end
            Roll()
            task.spawn(RemoveUnit)
            _wait(2)
        end
    end)
    if not success then
        warn("Error in StartRoll function:", result)
        StartRolls = false
    end
end

-- Main loop
local StartRolls = false
while true do
    local success, result = pcall(function()
        local SeedHave = convertToNumber(player.leaderstats.Seeds.Value)
        if not SeedHave then
            warn("Failed to get SeedHave in main loop")
            return
        end
        if SeedHave >= SeedWaitRoll and player.AccountAge > 12 then
            StartRolls = true
            StartRoll()
        end
    end)
    if not success then
        warn("Error in main loop:", result)
    end
    _wait(5)
end

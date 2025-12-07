local SeedWaitRoll = 4501
local SeedStopRoll = 4501
local CandyWaitRoll = 1800
local CandyStopRoll = 1800
local _wait = task.wait

repeat _wait() until game:IsLoaded()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local logicRoot = player:WaitForChild("PlayerGui"):WaitForChild("LogicHolder")
local modulesDir = logicRoot:WaitForChild("ClientLoader"):WaitForChild("Modules")
local ClientDataHandler = require(modulesDir:WaitForChild("ClientDataHandler"))
local deleteRemote = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("DeleteUnit")
local VirtualUser = game:GetService("VirtualUser")
local StartRolls = false
local Load = false
task.wait(5)

local function WH(message, typee)
    local url = "https://discord.com/api/webhooks/1329788152465981451/DgZ0MkE2_dAxKou-GsHwAMcDquiUVCEXj6rcA1iOjb2OamkiNpB2DOR-0vz3HO8V6PQS"
    local http = game:GetService("HttpService")
    
    local headers = {
        ["Content-Type"] = "application/json"
    }
    
    local embed = {
        title = "New Notification",
        description = message,
        color = 3447003,
        author = {
            name = "Error Bot",
            icon_url = "https://i.imgur.com/4A3TGlT.png"
        },
        fields = {
            {name = "Status", value = typee, inline = true}
        }
    }
    
    local data = {
        ["embeds"] = {embed}
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end

-- Roll (đã bảo vệ)
local function Roll()
    pcall(function()
        local args1 = { "ub_sun", 10 }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args1))
        task.wait(0.5)
        local args = {"ub_christmas",10}
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
    end)
end

-- Xóa unit (đã bảo vệ + giữ lại logic giữ godly/exclusive)
local function RemoveUnit()
    pcall(function()
        local inventory = ClientDataHandler.GetValue("Inventory")
        local toDelete = {}
        local kept = {}

        for uniqueId, unitData in pairs(inventory or {}) do
            local itemId = unitData.ItemData and unitData.ItemData.ID
            local rarity = "ra_godly"

            local config = player.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(tostring(itemId))
            if config then
                rarity = require(config).Rarity
            else
                rarity = nil
            end

            if rarity ~= nil and rarity == "ra_godly" or rarity == "ra_exclusive" or itemId == "unit_tomato_plant" or itemId == "unit_rafflesia" or itemId == "unit_lawnmower" then
                kept[itemId] = true
            elseif not kept[itemId] then
                kept[itemId] = true
            else
                print(uniqueId, itemId)
                table.insert(toDelete, uniqueId)
            end
        end
        if #toDelete > 0 then
            print("🗑️ Deleting", #toDelete, "units...")
            deleteRemote:InvokeServer(toDelete)
        else
            print("✅ Không có unit nào cần xoá.")
        end
    end)
end

-- Vòng lặp xóa unit định kỳ (đã bảo vệ)
local function CheckRemove()
    while true do
        local success, err = pcall(RemoveUnit)
        if not success then
            WH(tostring(err), "error Roll")
            warn("Lỗi trong RemoveUnit:", err)
        end
        task.wait(10)
    end
end

-- Vòng lặp Roll khi đủ tài nguyên (đã bảo vệ)
local function StartRoll()
    while StartRolls do
        local success, err = pcall(function()

            local data = ClientDataHandler.GetData()
            local SeedHave = tonumber(data.Seeds)
            local ChrisHave = tonumber(data.ChristmasGifts)

            if SeedHave <= SeedStopRoll and ChrisHave <= CandyStopRoll then
                StartRolls = false
                return
            end

            print('ROLLL')
            Roll()
            _wait()
        end)

        if not success then
            WH(tostring(err), "error Roll")
            warn("Lỗi trong StartRoll:", err)
            task.wait(1) -- Đợi 1 giây trước khi thử lại
        end
    end
end

-- === KHỞI ĐỘNG ===
task.spawn(CheckRemove)

while true do
    local success, err = pcall(function()
        local data = ClientDataHandler.GetData()
        local SeedHave = tonumber(data.Seeds)
        local ChrisHave = tonumber(data.ChristmasGifts)

        if SeedHave >= SeedWaitRoll or ChrisHave >= CandyWaitRoll then
            print('ENOUGH - Bắt đầu Roll!')
            StartRolls = true
            task.spawn(StartRoll)
        else
            if Load == false then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/thideGTD/ScriptTreo/refs/heads/main/FarmLoad.lua"))()
                Load = true
            end
        end
        _wait(5)
    end)

    if not success then
		WH(tostring(err), "error Roll")
        warn("Lỗi trong vòng lặp chính:", err)
        task.wait(5) -- Đợi rồi thử lại
    end
end




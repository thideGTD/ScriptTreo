local _wait = task.wait
repeat
    _wait()
until game:IsLoaded()
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("GameGui")
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.Stats.Items.Frame.ScrollingFrame:WaitForChild("GamesWon")
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.Stats.Items.Frame.ScrollingFrame.GamesWon.Items.Items.Val
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
GuiService.AutoSelectGuiEnabled = true
-- task.wait(5)
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local function AutoSkip()
    while true do
        local SkipGui = game:GetService("Players").LocalPlayer.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.AutoSkip
        if SkipGui.Title.Text ~= "Auto Skip: On" and not game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.DifficultyVote.Visible then
            GuiService.SelectedObject = SkipGui
            task.wait()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end
        task.wait(2)
    end
end
-- local function CheckHave()
--     local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
--     local inventory = ClientDataHandler.GetValue("Inventory")
--     local Share = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData)
--     local unithave = {}
--     for uniqueId, unitData in pairs(inventory or {}) do
--         local itemId = unitData.ItemData and unitData.ItemData.ID
--         local rarity = Share.GetItem(itemId).Rarity
--         if itemId == "unit_pineapple" or itemId == "unit_tomato_plant" then
--             table.insert(unithave, itemId)
--         end
--     end
--     if table.find(unithave, "unit_pineapple") and table.find(unithave, "unit_tomato_plant") then
--         return true
--     else
--         return false
--     end
-- end

local function CheckHave()
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
    local inventory = ClientDataHandler.GetValue("Inventory")
    local Share = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData)
    local unithave = {}
    for uniqueId, unitData in pairs(inventory or {}) do
        local itemId = unitData.ItemData and unitData.ItemData.ID
        local rarity = Share.GetItem(itemId).Rarity
        if itemId == "unit_tomato_plant" then
            table.insert(unithave, itemId)
        end
    end
    if table.find(unithave, "unit_tomato_plant") then
        return true
    else
        return false
    end
end

local function RemoveUnit()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local deleteRemote = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("DeleteUnit")
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
	local inventory = ClientDataHandler.GetValue("Inventory")
	local toDelete = {}
	local kept = {}

	for uniqueId, unitData in pairs(inventory or {}) do
		local itemId = unitData.ItemData and unitData.ItemData.ID
		local rarity = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(itemId))

		if rarity.Rarity == "ra_godly" or itemId == "unit_tomato_plant" or itemId == "unit_pineapple" or rarity.Rarity == "ra_exclusive" then
			kept[itemId] = true
			continue
		end
		if not kept[itemId] then
			kept[itemId] = true
		else
			table.insert(toDelete, uniqueId)
		end
	end
	if #toDelete > 0 then
		print("🗑️ Deleting", #toDelete, "units...")
		pcall(function()
			deleteRemote:InvokeServer(toDelete)
		end)
	else
		print("✅ Không có unit nào cần xoá.")
	end
end

local function ReturnForLobby()
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
    local inventory = ClientDataHandler.GetValue("Inventory")
    local Share = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData)
    local unithave = {}
    for uniqueId, unitData in pairs(inventory or {}) do
        local itemId = unitData.ItemData and unitData.ItemData.ID
        local rarity = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(itemId))
        print(uniqueId, itemId)
        RemoveUnit()
        -- if itemId == "unit_pineapple" or itemId == "unit_tomato_plant" then
        if itemId == "unit_tomato_plant" then
            local args = {
                tostring(uniqueId),
                true
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("SetUnitEquipped"):InvokeServer(
                unpack(args)
            )
            table.insert(unithave, itemId)
        elseif unitData.Equipped == true then
            local args = {
                tostring(uniqueId),
                false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("SetUnitEquipped"):InvokeServer(unpack(args))
        end
    end
    if table.find(unithave, "unit_pineapple") and table.find(unithave, "unit_tomato_plant") then
        return true
    else
        return false
    end
end

local function UpgradeU()
    for i,v in pairs(workspace.Map.Entities:GetChildren()) do
        if v.name == "unit_pineapple" or v.name == "unit_tomato_plant" then
            if string.format("%.2f",v.OwnedIndicator.Size.X) ~= "0.30" then
                if (v.OwnedIndicator) then
                    local args = {
	                    tonumber(v:GetAttribute("ID"))
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(unpack(args))
                    task.wait(0.3)
                end
            end
            task.wait()
        end
    end
end

local function PlayLose()
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.DifficultyVote.Visible then
        local args = {
            "dif_hard"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
    end
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.TickSpeed.Items["2"].ImageColor3 ~= Color3.fromRGB(115, 230, 0) then
        local args = {
            2
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeTickSpeed"):InvokeServer(unpack(args))
    end
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.GameEnd.Visible then
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("RestartGame"):InvokeServer()
    end
    game.Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-1.561105728149414 + math.random(-10, 10), 3.16474986076355, 309.835235595703 + math.random(-10, 10)))
    -- if not workspace.Map.Entities:FindFirstChild("unit_pineapple") then
    --     local args = {
	--         "unit_pineapple",
	--         {
	-- 	        Valid = true,
	-- 	        Rotation = 180, 
	-- 	        CF = CFrame.new(-1.561105728149414 , 3.16474986076355, 309.8352355957031 , -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
	-- 	        Position = vector.create(-1.561105728149414, 3.16474986076355, 309.8352355957031)
	--         }
    --     }
    --     game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer(unpack(args))
    --     task.wait(1)
    -- end
    local PosTomato = {
        Vector3.new(-845.7227783203125, 61.93030548095703, -144.72146606445312),
        Vector3.new(-848.307861328125, 61.93030548095703, -144.35543823242188),
        Vector3.new(-850.9990844726562, 61.93030548095703, -144.6051788330078),
        Vector3.new(-853.8358764648438, 61.93030548095703, -144.49789428710938),
        Vector3.new(-856.7615966796875, 61.93030548095703, -144.4781951904297),
    }
    local radishCount = 0
    for _, child in ipairs(workspace.Map.Entities:GetChildren()) do
        if child.Name == "unit_tomato_plant" then
            radishCount = radishCount + 1
        end
    end
    if radishCount < 5 then
        for i,v in pairs(PosTomato) do
        local args = {
	        "unit_tomato_plant",
	        {
		        Valid = true,
		        Rotation = 180,
		        CF = CFrame.new(v),
		        Position = v
	        }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer(unpack(args))
        end
        task.wait(1)
    end
    if game:GetService("Players").LocalPlayer:GetAttribute("Cash") > 125 then
        UpgradeU()
    end
    task.wait()
end
local function RedeemCode()
    local codes = {"PLAZA", "MYSTERY", "SLIME", "WASTE"}
    for _, code in ipairs(codes) do
        local args = { code }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("RedeemCode"):InvokeServer(unpack(args))
    end
end
local function PlayWin()
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.DifficultyVote.Visible then
        local args = {
            "dif_easy"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
    end
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.TickSpeed.Items["2"].ImageColor3 ~= Color3.fromRGB(115, 230, 0) then
        local args = {
            2
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeTickSpeed"):InvokeServer(unpack(args))
    end
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.GameEnd.Visible then
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("RestartGame"):InvokeServer()
    end
    local radishCount = 0
    for _, child in ipairs(workspace.Map.Entities:GetChildren()) do
        if child.Name == "unit_tomato_plant" then
            radishCount = radishCount + 1
        end
    end
    game.Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-331.64239501953125 + math.random(-10, 10), 62.522750854492188, -133.88951110839844 + math.random(-10, 10)))
    if radishCount < 20 then
        game.Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-331.64239501953125 + math.random(-10, 10), 62.703956604003906, -133.88951110839844 + math.random(-10, 10)))
        local PosList = {
            Vector3.new(-331.8759460449219, 61.68030548095703, -133.99546813964844),
    Vector3.new(-332.016123533156, 61.68030548095703, -134.5545200157285),
    Vector3.new(-332.3565999003606, 61.68030548095703, -128.5559697558592),
    Vector3.new(-332.2016925112094, 61.68030548095703, -127.094663829623),
    Vector3.new(-332.2054676047219, 61.68030548095703, -122.0740662109938),
    Vector3.new(-332.9232448526259, 61.68030548095703, -123.2687144832766),
    Vector3.new(-325.8667907714844, 61.68030548095703, -134.03594970703125),
    Vector3.new(-328.054382926495, 61.68030548095703, -130.1342447262252),
    Vector3.new(-338.61767578125, 61.68030548095703, -138.088214111328),
    Vector3.new(-338.882080078125, 61.68030548095703, -135.490478515625),
    Vector3.new(-338.56524658203125, 61.68030548095703, -132.91220092773438),
    Vector3.new(-338.749267578125, 61.68030548095703, -130.12046813964844),
    Vector3.new(-338.684765625, 61.68030548095703, -126.75885772705078),
    Vector3.new(-338.406538055394, 61.68030548095703, -123.78707122802734),
    Vector3.new(-330.932601235, 61.68030548095703, -134.55035400390625),
    Vector3.new(-330.5810546875, 61.68030548095703, -140.61495971679688),
    Vector3.new(-335.964074589844, 61.68030548095703, -136.7258875720215),
    Vector3.new(-333.433417769375, 61.68030548095703, -140.59902954101562),
    Vector3.new(-327.9202575683594, 61.68030548095703, -140.52308274875),
    Vector3.new(-325.2404479980469, 61.68030548095703, -140.63665771484375)
        }
        local pos = PosList[math.random(1, #PosList)]
        print('LAY')
        if game:GetService("Players").LocalPlayer:GetAttribute("Cash") > 100 then
            local args = {
                "unit_tomato_plant",
                {
                    Valid = true,
                    Rotation = 180,
                    CF = CFrame.new(pos),
                    Position = pos
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer(unpack(args))
        end
    end
    if game:GetService("Players").LocalPlayer:GetAttribute("Cash") > 135 then
        UpgradeU()
    end
end

local function CheckOut()
    task.spawn(function()
        while true do
            task.wait(300)
            if game:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions") then
                game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
            else
                game:shutdown()
            end
        end
    end)
end

local function PlayMap(map)
    CheckOut()
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.DifficultyVote.Visible then
        local args = {
            "dif_insane"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
    end
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.TickSpeed.Items["2"].ImageColor3 ~= Color3.fromRGB(115, 230, 0) then
        local args = {
            2
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeTickSpeed"):InvokeServer(unpack(args))
    end
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.GameEnd.Visible then
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("RestartGame"):InvokeServer()
    end
    local radishCount = 0
    for _, child in ipairs(workspace.Map.Entities:GetChildren()) do
        if child.Name == "unit_tomato_plant" then
            radishCount = radishCount + 1
        end
    end
    -- game.Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-331.64239501953125 + math.random(-10, 10), 62.522750854492188, -133.88951110839844 + math.random(-10, 10)))
    if radishCount < 1 then
        -- game.Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-331.64239501953125 + math.random(-10, 10), 62.703956604003906, -133.88951110839844 + math.random(-10, 10)))
        local PosMap = {
            map_farm = Vector3.new(-308.6241760253906, 61.68030548095703, -140.83070373535156),
            map_jungle = Vector3.new(-338.59210205078125, 61.68030548095703, -114.04462432861328),
            map_island = Vector3.new(-73.45323181152344, -30.6875, 132.98800659179688),
            map_toxic = Vector3.new(-3.2117342948913574, 1.9999998807907104, 322.42962646484375)
        }
        print('LAY')
        if game:GetService("Players").LocalPlayer:GetAttribute("Cash") > 100 then
            local args = {
                "unit_tomato_plant",
                {
                    Valid = true,
                    Rotation = 180,
                    CF = CFrame.new(PosMap[map]),
                    Position = PosMap[map]
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer(unpack(args))
        end
    end
    -- if game:GetService("Players").LocalPlayer:GetAttribute("Cash") > 135 then
    --     UpgradeU()
    -- end
end



local function AntiLag()
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    local Lighting = game:GetService("Lighting")
    local RunService = game:GetService("RunService")
    local Settings = settings()

    -- Tối ưu Terrain (nước)
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0

    -- Tối ưu Lighting (ánh sáng)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9

    -- Giảm chất lượng đồ họa
    Settings.Rendering.QualityLevel = 1

    -- Tối ưu toàn bộ vật thể trong game
    for _, v in pairs(game:GetDescendants()) do
        if
            v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or
                v:IsA("TrussPart")
         then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        end
    end

    -- Tắt hiệu ứng hậu kỳ trong Lighting
    for _, v in pairs(Lighting:GetDescendants()) do
        if
            v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or
                v:IsA("DepthOfFieldEffect")
         then
            v.Enabled = false
        end
    end

    -- Tự động xóa các hiệu ứng khi xuất hiện mới
    workspace.DescendantAdded:Connect(
        function(child)
            task.spawn(
                function()
                    if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") then
                        RunService.Heartbeat:Wait()
                        child:Destroy()
                    end
                end
            )
        end
    )
end
local function LowCpu()
    for _, v in pairs(workspace.Map:GetChildren()) do
        if v.Name ~= "LobbiesFarm" and v.Name ~= "BackGarden" and v.Name ~= "Model" then
            v:Destroy()
        end
    end
    if workspace.Map:FindFirstChild("Model") then
        for _, v in pairs(workspace.Map.Model:GetChildren()) do
            if v.Name ~= "Floor" then
                v:Destroy()
            end
        end
    else
        warn("Model not found in workspace.Map")
    end
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name ~= game.Players.LocalPlayer.Name and v:IsA("Model") then
            v:Destroy()
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local JobId = game.JobId
local ApiURL = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=20"
local function hopServer()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = HttpService:JSONDecode(req)

    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
    else
        return notify("Serverhop", "Couldn't find a server.")
    end
end
local function AntiAfk2()
    task.spawn(
        function()
            while true do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(5)
            end
        end
    )
end
-- local function CheckBackPack()
--     if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Pineapple Cannon") and game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Tomato") then
--         return true
--     else
--         return false
--     end
-- end
local function CheckBackPack()
    if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Tomato") then
        return true
    else
        return false
    end
end
task.spawn(function()
    while true do
        if game.PlaceId == 108533757090220 then
            local Have = CheckHave()
            local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
            local SeedHave = Seeds:find("[Kk]") and Seeds:gsub("[Kk]", "") * 1000 or Seeds:gsub(",", "")
            if (not Have and tonumber(SeedHave) > 2000) then
                print('Nothinh')
            else
                task.wait(300)
                hopServer()
            end
        else
            break
        end
        task.wait(1)
    end
end)

task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local gui = player.PlayerGui.GameGui.Screen.Middle.GameEnd
    local startTime = nil

    while true do
        if gui.Visible or game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.DifficultyVote.Visible then
            if not startTime then
                startTime = os.clock()
            elseif os.clock() - startTime > 60 then
                print("GameEnd GUI has been visible for more than 20 seconds! Kicking player...")
                if game:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions") then
                    game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
                else
                    game:shutdown()
                end
                startTime = os.clock()
            end
        else
            startTime = nil -- Reset timer when GUI is not visible
        end
        task.wait() -- Yield to avoid freezing
    end
end)
task.spawn(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lastSeedValue, timeSinceLastChange = nil, 0
    local timedelay = 0
    if workspace:GetAttribute("MapId") == "map_farm" then
        timedelay = 500
    else
        timedelay = 500
    end
    while true do
        local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
        local SeedHave = Seeds:find("[Kk]") and Seeds:gsub("[Kk]", "") * 1000 or Seeds:gsub(",", "")
        SeedHave = tonumber(SeedHave)

        if lastSeedValue and SeedHave ~= lastSeedValue then
            timeSinceLastChange = 0
            lastSeedValue = SeedHave
        elseif lastSeedValue then
            timeSinceLastChange = timeSinceLastChange + 1
            if timeSinceLastChange >= timedelay + 30 then
                game:shutdown()
            end
            if timeSinceLastChange >= timedelay then
                print("No change in SeedHave for 3 minutes: " .. SeedHave)
                if ReplicatedStorage:FindFirstChild("RemoteFunctions") then
                    game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
                else
                    game:shutdown()
                end
                timeSinceLastChange = 0
            end
        else
            lastSeedValue = SeedHave
        end
        task.wait(1)
    end
end)
local function CheckAnotherPlayer()
    local Players = game:GetService("Players")
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            return true -- Có người chơi khác trong game
        end
    end
    return false -- Không có người chơi khác
end
local function isAnyPlayerNearby(maxDistance, cframe)
    local targetCFrame = cframe
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character and character.PrimaryPart then
                local distance = (character.PrimaryPart.Position - targetCFrame.Position).Magnitude
                if distance <= maxDistance then
                    return false -- Có người chơi gần đó
                end
            end
        end
    end
    return true -- Không có người chơi nào gần đó
end
local StartRolls = false
local function Roll()
    while StartRolls do
        local Have = CheckHave()
        local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
        local SeedHave = Seeds:find("[Kk]") and Seeds:gsub("[Kk]", "") * 1000 or Seeds:gsub(",", "")
        if (tonumber(SeedHave) <= 399) or Have then
            StartRolls = false
            break
        end
        local args = {
            "ub_classic_v4",
            1
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))

        local args = {
	        "ub_classic_v5",
	        1
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
        RemoveUnit()
        task.wait(0.5)
    end
end
task.spawn(function()
    while true do
        if game:GetService("CoreGui").RobloxPromptGui.promptOverlay.Active then
            game:shutdown()
        end
        task.wait(10)
    end
end)
-- task.spawn(function()
--     while true do
--         task.wait(7200)
--         if ame:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions") then
--             game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
--         else
--             game:shutdown()
--         end
--     end
-- end)
local function ClearUnity()
    task.spawn(
        function()
            while true do
                local entities = workspace.Map.Entities
                for _, model in pairs(entities:GetChildren()) do
                    if model:IsA("Model") and string.match(model.Name, "^enemy") then
                        model:Destroy()
                    end
                end
                task.wait(0.5)
            end
        end
    )
end

local function JoinMap(maps)
    local parttouch = workspace.Map.LobbiesFarm
    for map, world in pairs(parttouch:GetChildren()) do
        local maxDistance = 7 -- Khoảng cách tối đa (studs)
        if world:GetAttribute("MaxPlayers") == 1 then
            if isAnyPlayerNearby(maxDistance, world.Cage.Part.CFrame) then
                -- game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("StartLobby_1"):InvokeServer()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = world.Cage.Part.CFrame
                local args = {
                    tostring(maps)
                }
                for i = 6, 9 do
                    print(tostring(maps))
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild(
                        "LobbySetMap_" .. i
                    ):InvokeServer(unpack(args))
                    local args2 = {
                        1
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild(
                        "LobbySetMaxPlayers_" .. i
                    ):InvokeServer(unpack(args2))

                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild(
                        "StartLobby_" .. i
                    ):InvokeServer()
                    task.wait()
                end
            else
                hopServer()
            end
        end
    end
end

task.spawn(ClearUnity)
local map = {
    map_farm = 0,
    map_jungle = 0,
    map_island = 0,
    map_toxic = 0
}
local MapWin = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
local function UpdateMapWin()
    for i,v in pairs(MapWin.GetData().MapProgress) do
        for a,b in pairs(v) do
            map[i] = b
        end
    end
end
local Wins = game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.Stats.Items.Frame.ScrollingFrame.GamesWon.Items.Items.Val
local function main()
    if game.PlaceId == 108533757090220 then
        LowCpu()
        if game:GetService("ReplicatedStorage").RemoteFunctions:FindFirstChild("ClientSetFlag") then
            game:GetService("ReplicatedStorage").RemoteFunctions.ClientSetFlag:Destroy() 
        end
        while true do
            game:GetService("RunService"):Set3dRenderingEnabled(false)
            RedeemCode()
            setfpscap(8)
            local Have = CheckHave()
            local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
            local SeedHave = Seeds:find("[Kk]") and Seeds:gsub("[Kk]", "") * 1000 or Seeds:gsub(",", "")
            local maxDistance = 7 -- Khoảng cách tối đa (studs)
            UpdateMapWin()
            if (not Have and tonumber(SeedHave) > 400) then
                StartRolls = true
                Roll()
            elseif Have and not CheckBackPack() then
                ReturnForLobby()
            elseif Have or tonumber(SeedHave) < 400 then
                local args = {
                    "unique_1",
                    true
                }
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("SetUnitEquipped"):InvokeServer(unpack(args))
                if map["map_farm"] < 5 then
                    JoinMap("map_farm")
                elseif map["map_farm"] >= 5 and map["map_jungle"] < 5 then
                    JoinMap("map_jungle")
                elseif map["map_jungle"] >= 5 and map["map_island"] < 5 then
                    JoinMap("map_island")
                elseif map["map_jungle"] >= 5 and map["map_toxic"] < 5 then
                    JoinMap("map_toxic")
                elseif tonumber(Wins.Text) < 25 then
                    local parttouch = workspace.Map.LobbiesFarm
                    for map,world in pairs(parttouch:GetChildren()) do
                        if world:GetAttribute("MaxPlayers") == 1 then
                            if isAnyPlayerNearby(maxDistance, world.Cage.Part.CFrame) then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = world.Cage.Part.CFrame
                                local args = {
	                                "map_farm"
                                }
                                for i = 6, 9 do
                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_" .. i):InvokeServer(unpack(args))
                                    local args2 = {
	                                    1
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_" .. i):InvokeServer(unpack(args2))

                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("StartLobby_" .. i):InvokeServer()
                                    task.wait()
                                end
                                -- game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("StartLobby_1"):InvokeServer()
                            else
                                hopServer()
                            end
                        end
                    end
                else
                    local parttouch = workspace.Map.BackGarden
                    for map,world in pairs(parttouch:GetChildren()) do
                        if world:GetAttribute("MaxPlayers") == 1 then
                            if isAnyPlayerNearby(maxDistance, world.Cage.Part.CFrame) then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = world.Cage.Part.CFrame
                                for i = 14, 18 do
                                    local args2 = {
	                                    1
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_" .. i):InvokeServer(unpack(args2))

                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("StartLobby_" .. i):InvokeServer()
                                    task.wait()
                                end
                                -- game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("StartLobby_1"):InvokeServer()
                            else
                                hopServer()
                            end
                        end
                    end
                end
                task.wait(2)
            end
            task.wait()
        end
    else
        game:GetService("RunService"):Set3dRenderingEnabled(false)
        task.spawn(AutoSkip)
        task.spawn(AntiLag)
        AntiAfk2()
        while true do
            if CheckAnotherPlayer() then
                print('Have another player')
                game:shutdown()
            end
            UpdateMapWin()
            Wins = game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.Stats.Items.Frame.ScrollingFrame.GamesWon.Items.Items.Val
            local SeedValue = game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value
            local Seed = SeedValue:find("[Kk]") and SeedValue:gsub("[Kk]", "") * 1000 or SeedValue:gsub(",", "")
            if map[workspace:GetAttribute("MapId")] < 5 then
                PlayMap(workspace:GetAttribute("MapId"))
                if map[workspace:GetAttribute("MapId")] > 5 then
                    game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
                end
            elseif tonumber(Wins.Text) >= 25 then
                if workspace:GetAttribute("MapId") == "map_farm" then
                    game:shutdown()
                elseif workspace:GetAttribute("MapId") == "map_back_garden" and CheckBackPack() then
                    PlayLose()
                    setfpscap(8)
                elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Tomato") then
                    PlayLose()
                end
            else
                if workspace:GetAttribute("MapId") == "map_farm" and tonumber(Wins.Text) < 25 then
                    print('PlayWin')
                    setfpscap(15)
                    PlayWin()
                elseif tonumber(Seed) < 2000 and not CheckBackPack() then
                    print('PlayLose')
                    setfpscap(8)
                    PlayLose()
                elseif tonumber(Seed) >= 2000 and not CheckBackPack() then
                    game:shutdown()
                elseif tonumber(Wins.Text) >= 25 then
                    game:shutdown()
                end
            end
            task.wait(0.4)
        end
    end
end

local function runScript()
    local errorCount = 0
    while true do
        local success, errorMessage = pcall(main)
        if not success then
            errorCount = errorCount + 1
            print("Error occurred: " .. tostring(errorMessage))
            if errorCount >= 5 then
                print("Script has errored 5 times consecutively!")
                game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
            end
            print("Restarting script in 5 seconds...")
            task.wait(5)
        else
            errorCount = 0 -- Reset error count on success
            break
        end
        task.wait()
    end
end

-- Chạy script
runScript()

local _wait = task.wait
repeat _wait() until game:IsLoaded()
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("GameGui")
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.Stats.Items.Frame.ScrollingFrame:WaitForChild("GamesWon")
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.Stats.Items.Frame.ScrollingFrame.GamesWon.Items.Items.Val
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler
repeat _wait() until game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
GuiService.AutoSelectGuiEnabled = true
task.wait(5)
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
local function AutoUnEquip()
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
    local inventory = ClientDataHandler.GetValue("Inventory")
    local Share = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData)
    for uniqueId, unitData in pairs(inventory or {}) do
        local itemId = unitData.ItemData and unitData.ItemData.ID
        if unitData.Equipped and itemId ~= "unit_tomato_plant" and itemId ~= "unit_deathesia" then
            local args = {
                tostring(uniqueId),
                false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("SetUnitEquipped"):InvokeServer(
                unpack(args)
            )
        end
    end
end
local function CheckHave()
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
    local inventory = ClientDataHandler.GetValue("Inventory")
    local Share = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData)
    local unithave = {}
    for uniqueId, unitData in pairs(inventory or {}) do
        local itemId = unitData.ItemData and unitData.ItemData.ID
        if itemId == "unit_tomato_plant" or itemId == "unit_deathesia" then
            table.insert(unithave, itemId)
        end
    end
    if table.find(unithave, "unit_tomato_plant") and table.find(unithave, "unit_deathesia") then
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
	local rarity = "ra_godly"
	for uniqueId, unitData in pairs(inventory or {}) do
		local itemId = unitData.ItemData and unitData.ItemData.ID
        if game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(tostring(itemId)) then
		    rarity = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(tostring(itemId))).Rarity
        else
            rarity = nil
        end
		print(itemId, rarity)
		if rarity and (rarity == "ra_godly" or itemId == "unit_tomato_plant" or itemId == "unit_deathesia" or itemId == "unit_lawnmower" or rarity == "ra_exclusive") then
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
        task.wait()
	else
		print("✅ Không có unit nào cần xoá.")
	end
end

local function ReturnForLobby()
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
    local inventory = ClientDataHandler.GetValue("Inventory")
    local Share = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData)
    local unithave = {}
    local rarity = "ra_godly"
    for uniqueId, unitData in pairs(inventory or {}) do
        local itemId = unitData.ItemData and unitData.ItemData.ID
        if game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(tostring(itemId)) then
		    rarity = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(tostring(itemId))).Rarity
        else
            rarity = nil
        end
        print(uniqueId, itemId)
        AutoUnEquip()
        RemoveUnit()
        -- if itemId == "unit_pineapple" or itemId == "unit_tomato_plant" then
        if itemId == "unit_tomato_plant" or itemId == "unit_deathesia" then
            local args = {
                tostring(uniqueId),
                true
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("SetUnitEquipped"):InvokeServer(
                unpack(args)
            )
            table.insert(unithave, itemId)
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
    print('PlayLose')
    if game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.DifficultyVote.Visible then
        local args = {
            "dif_impossible"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
    end
    local PosTomato = {
        Vector3.new(-846.1151733398438, 61.93030548095703, -172.1573486328125),
        Vector3.new(-849.0693359375, 61.93030548095703, -172.46189880371094),
        Vector3.new(-852.2924194335938, 61.93030548095703, -172.45553588867188),
        Vector3.new(-856.2924194335938, 61.93030548095703, -172.45553588867188),
        Vector3.new(-860.2924194335938, 61.93030548095703, -172.45553588867188),
        Vector3.new(-838.7306518554688, 61.93030548095703, -172.34014892578125),
        Vector3.new(-834.1480102539062, 61.93030548095703, -172.638671875),
        Vector3.new(-831.00244140625, 61.93030548095703, -172.3264617919922),
        Vector3.new(-827.00244140625, 61.93030548095703, -172.3264617919922),
        Vector3.new(-823.00244140625, 61.93030548095703, -172.3264617919922),
        Vector3.new(-819.00244140625, 61.93030548095703, -172.3264617919922),
        Vector3.new(-838.8464965820312, 61.93030548095703, -165.3662872314453),
        Vector3.new(-835.9508666992188, 61.93030548095703, -165.5133514404297),
        Vector3.new(-831.9508666992188, 61.93030548095703, -165.5133514404297),
        Vector3.new(-827.9508666992188, 61.93030548095703, -165.5133514404297),

        Vector3.new(-846.1100463867188, 61.93030548095703, -165.47726440429688),
        Vector3.new(-845.9807739257812, 61.93030548095703, -162.56747436523438),
        Vector3.new(-846.1572875976562, 61.93030548095703, -159.85137939453125),
        Vector3.new(-846.1466064453125, 61.93030548095703, -156.9246826171875),

        Vector3.new(-839.2479248046875, 61.93030548095703, -165.4300537109375),
        Vector3.new(-839.9807739257812, 61.93030548095703, -162.56747436523438),
        Vector3.new(-839.1572875976562, 61.93030548095703, -159.85137939453125),
        Vector3.new(-839.1466064453125, 61.93030548095703, -156.9246826171875)
    }
    if PosTomato then
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
            task.wait()
        end
        task.wait()
    end
    task.wait()
end

local hasSend = false
local hasSend2 = false

local RunService = game:GetService("RunService")

local function waitForTime(seconds)
    local start = tick()
    while tick() - start < seconds do
        RunService.Heartbeat:Wait()
    end
end

local function PlayV2()
    print('PlayV2')
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- 1. Xử lý bỏ phiếu độ khó (Difficulty Vote)
    if LocalPlayer.PlayerGui.GameGui.Screen.Middle.DifficultyVote.Visible then
        print('Vote')
        local args = {
            "dif_apocalypse"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
    end

    -- 2. Xử lý thay đổi tốc độ TickSpeed
    local a = require(LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
    if a.GetData().GamePasses.gp_gamespeed_3 then
        if LocalPlayer.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.TickSpeed.Items["3"].ImageColor3 ~= Color3.fromRGB(115, 230, 0) then
            local args = {
                3
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeTickSpeed"):InvokeServer(unpack(args))
        end
    else
        if LocalPlayer.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.TickSpeed.Items["2"].ImageColor3 ~= Color3.fromRGB(115, 230, 0) then
            local args = {
                2
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeTickSpeed"):InvokeServer(unpack(args))
        end
    end

    if LocalPlayer.PlayerGui.GameGui.Screen.Middle.GameEnd.Visible then
        -- game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("RestartGame"):InvokeServer()
    end



    local AllPositions = {
        {110.74224090576172 + math.random(0,0.5), 2.244499921798706 + math.random(0,0.5), -98.66590118408203 + math.random(0,0.5)}, -- Vị trí 2 
        {113.36101531982422 + math.random(0,0.5), 2.244499921798706 + math.random(0,0.5), 112.03187561035156 + math.random(0,0.5)}, -- Vị trí 1
        {-95.7408447265625 + math.random(0,0.5), 2.24399995803833 + math.random(0,0.5), 89.54883575439453 + math.random(0,0.5)},  -- Vị trí 4
        {-76.21514892578125 + math.random(0,0.5), 2.24399995803833 + math.random(0,0.5), -120.4250259399414 + math.random(0,0.5)} -- Vị trí 3
    }


    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end

    table.sort(playerNames)


    local playerIndex = -1
    for i, name in ipairs(playerNames) do
        if name == LocalPlayer.Name then
            playerIndex = i
            break
        end
    end

    local selectedPos = nil
    if playerIndex ~= -1 and playerIndex <= #AllPositions then
        selectedPos = AllPositions[playerIndex]
    end

    if selectedPos then
        local posVector = vector.create(selectedPos[1], selectedPos[2], selectedPos[3])
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(posVector)
        print(posVector)
        task.wait(1)
        local args = {
            "unit_deathesia",
            {
                Valid = true,
                PathIndex = playerIndex,
                Position = posVector,
                DistanceAlongPath = 4.855037463782116,
                CF = CFrame.new(posVector),
                Rotation = 180
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer(unpack(args))
        print('Đã đặt đơn vị tại vị trí cho Player Index:', playerIndex)
    else
        print('Không tìm thấy vị trí phù hợp (Có thể server quá đông hoặc lỗi index).')
    end

end
-- local function RedeemCode()
--     local codes = {"PLAZA", "MYSTERY", "SLIME", "WASTE"}
--     for _, code in ipairs(codes) do
--         local args = { code }
--         game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("RedeemCode"):InvokeServer(unpack(args))
--     end
-- end
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
        -- game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
        task.wait(10)
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
    task.wait(2)
end

-- local function CheckOut()
--     task.spawn(function()
--         while true do
--             task.wait(300)
--             if game:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions") then
--                 game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
--             else
--                 game.Players.LocalPlayer:Kick("Kick Fail")
--             end
--         end
--     end)
-- end

local function PlayMap(map)
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
    task.wait(10)
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
-- local function LowCpu()
--     for _, v in pairs(workspace.Map:GetChildren()) do
--         if v.Name ~= "Garden" and v.Name ~= "BackGarden" and v.Name ~= "Model" then
--             v:Destroy()
--         end
--     end
--     if workspace.Map:FindFirstChild("Model") then
--         for _, v in pairs(workspace.Map.Model:GetChildren()) do
--             if v.Name ~= "Floor" then
--                 v:Destroy()
--             end
--         end
--     else
--         warn("Model not found in workspace.Map")
--     end
--     for _, v in pairs(workspace:GetChildren()) do
--         if v.Name ~= game.Players.LocalPlayer.Name and v:IsA("Model") then
--             v:Destroy()
--         end
--     end
-- end

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
    if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Tomato") and game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Deathesia") then
        return true
    else
        return false
    end
end
-- task.spawn(function()
--     while true do
--         if game.PlaceId == 108533757090220 then
--             local Have = CheckHave()
--             local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
--             local SeedHave = Seeds:find("[Kk]") and Seeds:gsub("[Kk]", "") * 1000 or Seeds:gsub(",", "")
--             if (not Have and tonumber(SeedHave) > 2000) then
--                 print('Nothinh')
--             else
--                 task.wait(300)
--                 hopServer()
--             end
--         else
--             break
--         end
--         task.wait(1)
--     end
-- end)

-- 

-- task.spawn(function()
--     local Players = game:GetService("Players")
--     local ReplicatedStorage = game:GetService("ReplicatedStorage")
--     local lastSeedValue, timeSinceLastChange = nil, 0
--     local timedelay = 500
--     while true do
--         local player = game:GetService("Players").LocalPlayer
--         local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
--         local SeedHave = tonumber(tostring(player.leaderstats.Seeds.Value):match("[kK]") and tostring(player.leaderstats.Seeds.Value):gsub("[kK]", "") * 1000 or tostring(player.leaderstats.Seeds.Value):match("[mM]") and tostring(player.leaderstats.Seeds.Value):gsub("[mM]", "") * 1000000 or tostring(player.leaderstats.Seeds.Value):match("[bB]") and tostring(player.leaderstats.Seeds.Value):gsub("[bB]", "") * 1000000000 or tostring(player.leaderstats.Seeds.Value):gsub(",", ""))

--         if lastSeedValue and SeedHave ~= lastSeedValue then
--             timeSinceLastChange = 0
--             lastSeedValue = SeedHave
--         elseif lastSeedValue then
--             timeSinceLastChange = timeSinceLastChange + 1
--             if timeSinceLastChange >= timedelay + 30 then
--                 game.Players.LocalPlayer:Kick("Kick Fail")
--             end
--             if timeSinceLastChange >= timedelay then
--                 print("No change in SeedHave for 3 minutes: " .. SeedHave)
--                 if ReplicatedStorage:FindFirstChild("RemoteFunctions") then
--                     game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
--                 else
--                     game.Players.LocalPlayer:Kick("Kick Fail")
--                 end
--                 timeSinceLastChange = 0
--             end
--         else
--             lastSeedValue = SeedHave
--         end
--         task.wait(1)
--     end
-- end)
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
        local player = game:GetService("Players").LocalPlayer
        local Have = CheckHave()
        local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
        local SeedHave = tonumber(tostring(player.leaderstats.Seeds.Value):match("[kK]") and tostring(player.leaderstats.Seeds.Value):gsub("[kK]", "") * 1000 or tostring(player.leaderstats.Seeds.Value):match("[mM]") and tostring(player.leaderstats.Seeds.Value):gsub("[mM]", "") * 1000000 or tostring(player.leaderstats.Seeds.Value):match("[bB]") and tostring(player.leaderstats.Seeds.Value):gsub("[bB]", "") * 1000000000 or tostring(player.leaderstats.Seeds.Value):gsub(",", ""))
        if (tonumber(SeedHave) <= 3599) or Have then
            StartRolls = false
            break
        end
        local args = {
            "ub_tropical",
            10
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
        RemoveUnit()
        task.wait(0.5)
    end
end
-- task.spawn(function()
--     while true do
--         if game:GetService("CoreGui").RobloxPromptGui.promptOverlay.Active then
--             game.Players.LocalPlayer:Kick("Kick Fail")
--         end
--         task.wait(10)
--     end
-- end)
-- task.spawn(function()
--     while true do
--         task.wait(7200)
--         if ame:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions") then
--             game:GetService("ReplicatedStorage").RemoteFunctions.BackToMainLobby:InvokeServer()
--         else
--             game.Players.LocalPlayer:Kick("Kick Fail")
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
    local parttouch = workspace.Map.Teleporter.LobbiesEndless
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
    map_toxic = 0,
    map_back_garden = 0,
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
local function scanmap()
    local parttouch = workspace.Map.Teleporter.LobbiesEndless
    for map,world in pairs(parttouch:GetChildren()) do
        if world:GetAttribute("MapId") == "map_christmas" then
            return true
        end
    end
end
task.spawn(function()
    local parttouch = workspace.Map.Teleporter.LobbiesEndless
    for map,world in pairs(parttouch:GetChildren()) do
        if world:GetAttribute("LobbyId") ~= "25" then
            world:Destroy()
        end
    end
end)
task.spawn(function()
    while true do
        local a = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
        if not a.GetData().GamePasses.gp_gamespeed_3 and not scanmap() then
            for i = 24, 25 do
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LeaveLobby_" .. i):InvokeServer()
            end
            task.wait(25)
        end
        local parttouch = workspace.Map.Teleporter.LobbiesEndless
        for map,world in pairs(parttouch:GetChildren()) do
            if world:GetAttribute("MaxPlayers") == 4 and world:GetAttribute("Players") < 4 and world:GetAttribute("StartTime") ~= "inf" and world:GetAttribute("StartTime") - os.time() < 10 then
                for i = 24, 25 do
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LeaveLobby_" .. i):InvokeServer()
                end
            elseif world:GetAttribute("MaxPlayers") ~= 4 then
                for i = 24, 25 do
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LeaveLobby_" .. i):InvokeServer()
                end
            end
        end
        task.wait(1)
    end
end)
task.spawn(function()
    while true do
        local a = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
        if not a.GetData().GamePasses.gp_gamespeed_3 then
            for i = 24, 25 do
                local args2 = {
                    2
                }
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_" .. i):InvokeServer(unpack(args2))
            end
        end
        task.wait(1)
    end
end)
local function main()
    if game.PlaceId == 108533757090220 then
        -- LowCpu()
        if game:GetService("ReplicatedStorage").RemoteFunctions:FindFirstChild("ClientSetFlag") then
            game:GetService("ReplicatedStorage").RemoteFunctions.ClientSetFlag:Destroy() 
        end
        while true do
            game:GetService("RunService"):Set3dRenderingEnabled(false)
            setfpscap(8)
            local Have = CheckHave()
            local Seeds = tostring(game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value)
            local SeedHave = Seeds:find("[Kk]") and Seeds:gsub("[Kk]", "") * 1000 or Seeds:gsub(",", "")
            local maxDistance = 7 -- Khoảng cách tối đa (studs)
            local a = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
            if a.GetData().GamePasses.gp_gamespeed_3 then
                if (not Have and tonumber(SeedHave) > 3600) then
                    StartRolls = true
                    Roll()
                elseif Have and not CheckBackPack() then
                    ReturnForLobby()
                else
                    if Have and #Players:GetPlayers() > 3 then
                        local parttouch = workspace.Map.Teleporter.LobbiesEndless
                        for map,world in pairs(parttouch:GetChildren()) do
                            if world:GetAttribute("MaxPlayers") > 0 then
                                if world:GetAttribute("Players") == 0 then
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = world.Cage.Part.CFrame
                                end
                                for i = 24, 25 do
                                    local args2 = {
                                        4
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_" .. i):InvokeServer(unpack(args2))
                                    if world:GetAttribute("Players") >= 4 then
                                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("StartLobby_" .. i):InvokeServer()
                                    end
                                    task.wait()
                                end
                                task.wait(0.2)
                            end
                        end
                    end
                end
                task.wait()
            else
                if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Tomato") or not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Deathesia") then
                    ReturnForLobby()
                elseif #Players:GetPlayers() > 0 then
                    local parttouch = workspace.Map.Teleporter.LobbiesEndless
                    for map,world in pairs(parttouch:GetChildren()) do
                        if world:GetAttribute("Players") >= 1 and world:GetAttribute("MaxPlayers") == 4 then
                            if world then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = world.Cage.Part.CFrame
                                -- game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("StartLobby_1"):InvokeServer()
                            else
                                hopServer()
                            end
                        end
                    end
                end
            end
            task.wait()
        end
    else
        game:GetService("RunService"):Set3dRenderingEnabled(false)
        task.spawn(AutoSkip)
        task.spawn(AntiLag)
        AntiAfk2()
        local CheckBack = CheckBackPack()
        local Have = CheckHave()
        while true do
			setfpscap(8)
            Wins = game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.Middle.Stats.Items.Frame.ScrollingFrame.GamesWon.Items.Items.Val
            local player = game:GetService("Players").LocalPlayer
            local SeedValue = game:GetService("Players").LocalPlayer.leaderstats.Seeds.Value
            local Seed = tonumber(tostring(player.leaderstats.Seeds.Value):match("[kK]") and tostring(player.leaderstats.Seeds.Value):gsub("[kK]", "") * 1000 or tostring(player.leaderstats.Seeds.Value):match("[mM]") and tostring(player.leaderstats.Seeds.Value):gsub("[mM]", "") * 1000000 or tostring(player.leaderstats.Seeds.Value):match("[bB]") and tostring(player.leaderstats.Seeds.Value):gsub("[bB]", "") * 1000000000 or tostring(player.leaderstats.Seeds.Value):gsub(",", ""))
            -- if not CheckBack then
            --     CheckBack = CheckBackPack()
            --     if not Have then
            --         Have = CheckHave()
            --         if Seed > 3600 then
            --             local args = {"ub_tropical",10}
            --             game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
            --         end
            --     end
            --     ReturnForLobby()
            -- end
            if #Players:GetPlayers() < 4 then
                game.Players.LocalPlayer:Kick("Kick Fail")
            end
            if tonumber(Wins.Text) >= 25 then
                local a = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
                if workspace:GetAttribute("MapId") == "map_christmas" and CheckBackPack() and a.GetData().GamePasses.gp_gamespeed_3 then
                    PlayV2()
                    setfpscap(8)
                elseif workspace:GetAttribute("MapId") == "map_christmas" and game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Deathesia") then
                    PlayV2()
                    task.wait(1)
                end
            end
            task.wait()
        end
    end
end
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
local function runScript()
    local errorCount = 0
    while true do
        local success, errorMessage = pcall(main)
        if not success then
            errorCount = errorCount + 1
            print("Error occurred: " .. tostring(errorMessage))
            if errorCount >= 5 then
                print("Script has errored 5 times consecutively!")
                WH(tostring(errorMessage), "error")
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

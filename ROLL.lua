local SeedWaitRoll = 4500
local SeedStopRoll = 4500
local CandyWaitRoll = 900
local CandyStopRoll = 900
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
local function AutoUnEquip()
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
    local inventory = ClientDataHandler.GetValue("Inventory")
    local Share = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.SharedItemData)
    for uniqueId, unitData in pairs(inventory or {}) do
        local itemId = unitData.ItemData and unitData.ItemData.ID
        local rarity = Share.GetItem(itemId).Rarity
        if unitData.Equipped then
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
AntiAfk2()
local function Roll()
    -- local args = {
	   --  "ub_tropical",
	   --  10
    -- }
    -- game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
	local args = {
	     "ub_sun",
	     10  
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
	task.wait(0.5)
	local args = {
		"ub_halloween",
		10
	}
	game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
	-- task.wait(0.5)
	--  local args = {
	--     "ub_sun",
	--     10
 --    }
 --    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
	-- task.wait(0.5)
 --    local args = {
	--     "ub_bee",
	--     10
 --    }
 --    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))

end

local function RemoveUnit()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local deleteRemote = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("DeleteUnit")
    local ClientDataHandler = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
	local inventory = ClientDataHandler.GetValue("Inventory")
	local toDelete = {}
	local kept = {}
	for uniqueId, unitData in pairs(inventory or {}) do
		local rarity = "ra_godly"
		local itemId = unitData.ItemData and unitData.ItemData.ID
        if game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(tostring(itemId)) then
		    rarity = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(tostring(itemId))).Rarity
        else
            rarity = nil
        end
		print(itemId, rarity)
		if rarity and (rarity == "ra_godly" or itemId == "unit_tomato_plant" or itemId == "unit_rafflesia" or itemId == "unit_lawnmower" or rarity == "ra_exclusive") then
			kept[itemId] = true
			continue
		end
		if not kept[itemId] then
			print('Delete Unit')
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
RemoveUnit()

local function CheckRemove()
	while true do
		print('DELETEDELETE')
		RemoveUnit()
		task.wait(5)
	end
end
local function StartRoll()
	while StartRolls do
		setfpscap(8)
	    game:GetService("RunService"):Set3dRenderingEnabled(false)
		local a = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
		local SeedHave = tonumber(a.GetData().Seeds)
		local CandyHave = tonumber(a.GetData().CandyCorns)
		if SeedHave <= SeedStopRoll and CandyHave <= CandyStopRoll then
			StartRolls = false
			break
		end
		print('ROLLL')
		Roll()
		_wait()
	end
end
task.spawn(CheckRemove)
while true do
	setfpscap(8)
	game:GetService("RunService"):Set3dRenderingEnabled(false)
	local a = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
	local SeedHave = tonumber(a.GetData().Seeds)
	local CandyHave = tonumber(a.GetData().CandyCorns)
	if SeedHave >= SeedWaitRoll or CandyHave >= CandyWaitRoll then
		print('ENOUGH')
		StartRolls = true
		StartRoll()
	end
	_wait(5)
end

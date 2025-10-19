local SeedWaitRoll = 3600
local SeedStopRoll = 3600
local _wait = task.wait

repeat _wait() until game:IsLoaded()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local logicRoot = player:WaitForChild("PlayerGui"):WaitForChild("LogicHolder")
local modulesDir = logicRoot:WaitForChild("ClientLoader"):WaitForChild("Modules")
local ClientDataHandler = require(modulesDir:WaitForChild("ClientDataHandler"))
local deleteRemote = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("DeleteUnit")
local StartRolls = false

task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/thideGTD/ScriptTreo/refs/heads/main/TNGHIA.lua"))()
end)

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

local function Roll()
    -- local args = {
	   --  "ub_tropical",
	   --  10
    -- }
    -- game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
	local args = {
	     "ub_tropical",
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
		local itemId = unitData.ItemData and unitData.ItemData.ID
		local rarity = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs:FindFirstChild(itemId))

		if rarity.Rarity == "ra_godly" or itemId == "unit_tomato_plant" or itemId == "unit_rafflesia" or itemId == "unit_lawnmower" or rarity.Rarity == "ra_exclusive" then
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

local function StartRoll()
	while StartRolls do
		local player = game:GetService("Players").LocalPlayer
		local Seeds = tostring(player.leaderstats.Seeds.Value)
		local SeedHave = tonumber(tostring(player.leaderstats.Seeds.Value):match("[kK]") and tostring(player.leaderstats.Seeds.Value):gsub("[kK]", "") * 1000 or tostring(player.leaderstats.Seeds.Value):match("[mM]") and tostring(player.leaderstats.Seeds.Value):gsub("[mM]", "") * 1000000 or tostring(player.leaderstats.Seeds.Value):match("[bB]") and tostring(player.leaderstats.Seeds.Value):gsub("[bB]", "") * 1000000000 or tostring(player.leaderstats.Seeds.Value):gsub(",", ""))
		if SeedHave <= SeedStopRoll then
			StartRolls = false
			break
		end
		print('ROLLL')
		Roll()
		task.spawn(RemoveUnit)
		task.spawn(AutoUnEquip)
		_wait(2)
	end
end

while true do
	local player = game:GetService("Players").LocalPlayer
	local Seeds = tostring(player.leaderstats.Seeds.Value)
	local SeedHave = tonumber(tostring(player.leaderstats.Seeds.Value):match("[kK]") and tostring(player.leaderstats.Seeds.Value):gsub("[kK]", "") * 1000 or tostring(player.leaderstats.Seeds.Value):match("[mM]") and tostring(player.leaderstats.Seeds.Value):gsub("[mM]", "") * 1000000 or tostring(player.leaderstats.Seeds.Value):match("[bB]") and tostring(player.leaderstats.Seeds.Value):gsub("[bB]", "") * 1000000000 or tostring(player.leaderstats.Seeds.Value):gsub(",", ""))
	local a = require(game:GetService("Players").LocalPlayer.PlayerGui.LogicHolder.ClientLoader.Modules.ClientDataHandler)
	if SeedHave >= SeedWaitRoll then
		print('ENOUGH')
		StartRolls = true
		StartRoll()
	end
	_wait(5)
end


























--Size Again

local player = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlrName = Players.LocalPlayer.Name
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RunService = game:GetService("RunService")

-- Important: str is SIZE, not actual strength
local str = game:GetService("Players").LocalPlayer.leaderstats.Strength -- This is SIZE
local Strength = game:GetService("ReplicatedStorage").Data[PlrName].Strength -- This is actual STRENGTH

-- Load ZayHub Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Criptism/ZayHub/refs/heads/main/library.lua"))()

-- Notification System
local lastNotification = 0
local notificationCooldown = 2 -- seconds between notifications

local function Notify(title, message, duration)
	local currentTime = tick()
	if currentTime - lastNotification < notificationCooldown then
		return -- Don't spam notifications
	end
	lastNotification = currentTime
	
	-- Create notification
	game.StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = message,
		Duration = duration or 3,
		Icon = "rbxassetid://7733658504"
	})
end

-- Initialize Window
local Window = Library:Init({
	Name = "Doggy Hub V3 | Private Farm"
})

-- Global variables
_G.Equip = false
_G.Farm = false
_G.dupeRunning = false
_G.dupeTarget = 777
_G.AutoFarmEnabled = false
_G.WeightThreshold = 777
_G.MaxPing = 25000
_G.ResumePing = 1000
_G.FarmingActive = false

-- Utility Functions
local function getPing()
	local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	return math.floor(ping)
end

local function formatNumber(num)
	if num >= 1e12 then
		return string.format("%.2fT", num / 1e12)
	elseif num >= 1e9 then
		return string.format("%.2fB", num / 1e9)
	elseif num >= 1e6 then
		return string.format("%.2fM", num / 1e6)
	elseif num >= 1e3 then
		return string.format("%.2fK", num / 1e3)
	else
		return tostring(num)
	end
end

local function getTotalInventoryCount()
	local total = 0
	for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			total = total + 1
		end
	end
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("Tool") then
			total = total + 1
		end
	end
	return total
end

local function getDoubleWeightCount()
	local num = 0
	for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v.Name == "Double Weight" then
			num = num + 1
		end
	end
	for i, v in pairs(character:GetChildren()) do
		if v.Name == "Double Weight" then
			num = num + 1
		end
	end
	return num
end

-- Farming Tab
local FarmingTab = Window:CreateTab("Farming")

FarmingTab:AddLabel("--- Farming Options ---")

FarmingTab:AddToggle("Equip Weight", false, function(state)
	_G.Equip = state
	if state then
		print("✅ Equipping Weight...")
		spawn(function()
			while _G.Equip do
				wait()
				for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.Name == "Double Weight" then
						v.Parent = game.Players.LocalPlayer.Character
					end
				end
			end
		end)
	else
		print("❌ Stopped Equipping Weight")
	end
end)

FarmingTab:AddToggle("Farm Weight", false, function(state)
	_G.Farm = state
	if state then
		print("✅ Farming Weight...")
		spawn(function()
			while _G.Farm do
				wait(0.5)
				for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
					if v.Name == "Double Weight" then
						v:Activate()
					end
				end
			end
		end)
	else
		print("❌ Stopped Farming Weight")
	end
end)

FarmingTab:AddToggle("Lock Player", false, function(state)
	if state then
		for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v:IsA('MeshPart') then
				v.Anchored = true
			end
		end
		print("🔒 Player Locked")
	else
		for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v:IsA('MeshPart') then
				v.Anchored = false
			end
		end
		print("🔓 Player Unlocked")
	end
end)

FarmingTab:AddLabel("--- Extra Options ---")

FarmingTab:AddButton("Ultimate FPS & Clean (All-in-One)", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local vu = game:GetService("VirtualUser")

    -- Anti-AFK
    player.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)

    -- Set nighttime
    Lighting.ClockTime = 23.5

    -- Hide inventory
    loadstring(game:HttpGet("https://pastebin.com/raw/8W1draqT", true))()

    -- Delete TourneyQ safely
    pcall(function()
        if ReplicatedFirst:FindFirstChild("TourneyQ") then
            ReplicatedFirst.TourneyQ:Destroy()
        end
    end)

    -- Delete Clouds & unnecessary LocalScripts
    pcall(function()
        if workspace:FindFirstChild("Clouds") then
            workspace.Clouds:Destroy()
        end
        for _, v in pairs(player.PlayerScripts:GetChildren()) do
            if v:IsA("LocalScript") then
                v:Destroy()
            end
        end
    end)

    -- Teleport 15,000 studs up and create platform
    local skyHeight = 15000
    local skyPos = hrp.Position + Vector3.new(0, skyHeight, 0)

    local platform = Instance.new("Part")
    platform.Name = "DontDeleteMe"
    platform.Size = Vector3.new(50, 2, 50)
    platform.Position = skyPos - Vector3.new(0, 3, 0)
    platform.Anchored = true
    platform.Transparency = 1
    platform.CanCollide = true
    platform.Parent = workspace

    hrp.CFrame = CFrame.new(skyPos)

    -- Camera & visual optimizations
    player.CameraMaxZoomDistance = 1500
    Lighting.FogEnd = 100000
    if Lighting:FindFirstChildOfClass("Atmosphere") then
        Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
    end

    -- Destroy HUD
    if player.PlayerGui:FindFirstChild("HUD") then
        player.PlayerGui.HUD:Destroy()
    end

    -- Workspace cleanup (keep character & whitelisted objects)
    local whitelistNames = { ["Baseplate"] = true, ["DontDeleteMe"] = true }
    local keepObjects = {}
    for _, desc in ipairs(character:GetDescendants()) do keepObjects[desc] = true end
    keepObjects[character] = true

    local function isWhitelisted(obj)
        while obj do
            if whitelistNames[obj.Name] then return true end
            obj = obj.Parent
        end
        return false
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if not keepObjects[obj] and obj ~= workspace.CurrentCamera and not obj:IsDescendantOf(workspace.CurrentCamera) and not isWhitelisted(obj) then
            pcall(function() obj:Destroy() end)
        end
    end

    Notify("Ultimate Clean", "Anti-AFK, Hide Inventory, Max FPS, Deleted Objects, Sky TP!", 5)
end)


-- Duping Tab
local DupingTab = Window:CreateTab("Duping")

DupingTab:AddLabel("--- Duping System ---")

-- Weight counter label
local DupeWeightLabel = DupingTab:AddLabel("Weights: Loading...")

-- Update weight label
spawn(function()
	while wait(1) do
		pcall(function()
			local doubleWeights = getDoubleWeightCount()
			DupeWeightLabel:Set("Weights: " .. doubleWeights)
		end)
	end
end)

local function runDupeLoop()
	while _G.dupeRunning do
		local currentWeights = getDoubleWeightCount()
		
		if currentWeights >= _G.dupeTarget then
			_G.dupeRunning = false
			print("✅ Target reached! (" .. currentWeights .. "/" .. _G.dupeTarget .. ")")
			break
		end
		
		local MarketplaceService = game:GetService("MarketplaceService")
		local localPlayer = game.Players.LocalPlayer
		
		local function simulatePurchase(gamePassId)
			MarketplaceService:SignalPromptGamePassPurchaseFinished(localPlayer, gamePassId, true)
		end

		simulatePurchase(5949054)
		wait(0.65)
	end
end

DupingTab:AddButton("Auto Dupe 777 DW", function()
	if not _G.dupeRunning then
		_G.dupeTarget = 777
		_G.dupeRunning = true
		print("🔄 Auto Dupe Started - Target: 777 Weights")
		spawn(runDupeLoop)
	else
		print("⚠️ Dupe already running!")
	end
end)

DupingTab:AddButton("Auto Dupe 85 DW", function()
	if not _G.dupeRunning then
		_G.dupeTarget = 85
		_G.dupeRunning = true
		print("🔄 Auto Dupe Started - Target: 85 Weights")
		spawn(runDupeLoop)
	else
		print("⚠️ Dupe already running!")
	end
end)

DupingTab:AddButton("Stop Auto Dupe", function()
	_G.dupeRunning = false
	print("❌ Dupe Stopped")
end)

DupingTab:AddLabel("--- Auto Farm ---")

DupingTab:AddToggle("Auto Farm", false, function(state)
	_G.AutoFarmEnabled = state
	if state then
		print("🚀 Smart Auto Farm Started!")
		print("⏳ Waiting for 777+ items in inventory...")
		spawn(function()
			while _G.AutoFarmEnabled do
				wait(0.5)
				
				local totalItems = getTotalInventoryCount()
				local doubleWeights = getDoubleWeightCount()
				local currentPing = getPing()
				
				local shouldFarm = (totalItems >= _G.WeightThreshold or doubleWeights >= _G.WeightThreshold) and currentPing < _G.MaxPing
				
				if currentPing >= _G.MaxPing then
					if _G.FarmingActive then
						print("🔴 PING TOO HIGH! (" .. currentPing .. "ms) - Pausing farm...")
						_G.FarmingActive = false
					end
					
					repeat
						wait(2)
						currentPing = getPing()
						if currentPing < _G.ResumePing and _G.AutoFarmEnabled then
							print("🟢 Ping restored (" .. currentPing .. "ms)")
						end
					until currentPing < _G.ResumePing or not _G.AutoFarmEnabled
				end
				
				if shouldFarm and not _G.FarmingActive and _G.AutoFarmEnabled then
					print("✅ Conditions met!")
					print("   Total Items: " .. totalItems)
					print("   Double Weights: " .. doubleWeights)
					print("   Ping: " .. currentPing .. "ms")
					print("🚀 Starting farm...")
					
					_G.FarmingActive = true
					
					spawn(function()
						while _G.AutoFarmEnabled and _G.FarmingActive do
							wait()
							for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
								if v.Name == "Double Weight" then
									v.Parent = LocalPlayer.Character
									break
								end
							end
						end
					end)
					
					spawn(function()
						while _G.AutoFarmEnabled and _G.FarmingActive do
							wait(0.5)
							for i, v in pairs(LocalPlayer.Character:GetChildren()) do
								if v.Name == "Double Weight" then
									v:Activate()
								end
							end
						end
					end)
				
				elseif not shouldFarm and _G.FarmingActive then
					if totalItems < _G.WeightThreshold and doubleWeights < _G.WeightThreshold then
						print("⏸️ Items below threshold - Pausing farm")
						print("   Total: " .. totalItems .. "/" .. _G.WeightThreshold)
					end
					_G.FarmingActive = false
				end
			end
			
			print("❌ Auto Farm Disabled")
			_G.FarmingActive = false
		end)
	else
		print("❌ Auto Farm Stopped")
		_G.FarmingActive = false
	end
end)

-- Information Tab
local InfoTab = Window:CreateTab("Info")

InfoTab:AddLabel("--- Real-Time Statistics ---")

local StrengthLabel = InfoTab:AddLabel("Strength: Loading...")
local GainedLabel = InfoTab:AddLabel("Gained: Loading...")
local SizeLabel = InfoTab:AddLabel("Size: Loading...")
local WeightLabel = InfoTab:AddLabel("Weight: Loading...")
local PingLabel = InfoTab:AddLabel("Ping: Loading...")

InfoTab:AddLabel("--- More Info Coming Soon ---")

-- Statistics Tab (Detailed Stats)
local StatsTab = Window:CreateTab("Stats")

StatsTab:AddLabel("--- Current Stats ---")

local StatStrengthLabel = StatsTab:AddLabel("Strength: Loading...")
local StatSizeLabel = StatsTab:AddLabel("Size: Loading...")
local StatGainedLabel = StatsTab:AddLabel("Gained: Loading...")

StatsTab:AddLabel("--- Rate Statistics ---")

local SPSLabel = StatsTab:AddLabel("SPS: Loading...")
local SPMLabel = StatsTab:AddLabel("SPM: Loading...")
local SPHLabel = StatsTab:AddLabel("SPH: Loading...")
local SPDLabel = StatsTab:AddLabel("SPD: Loading...")
local SPWLabel = StatsTab:AddLabel("SPW: Loading...")
local SPMOLabel = StatsTab:AddLabel("SPMO: Loading...")

StatsTab:AddLabel("--- Session Info ---")

local SessionTimeLabel = StatsTab:AddLabel("Session Time: 0s")

-- ================================
-- SPS / RATE TRACKING (REPLACED)
-- ================================

local lastStrength = Strength.Value
local totalGained = 0
local sessionStart = tick()

-- Update rates every 1 second
spawn(function()
	while true do
		wait(1)  -- sample every 1 second
		pcall(function()
			local now = tick()
			local currentStrength = Strength.Value
			local deltaStrength = currentStrength - lastStrength
			local deltaTime = 1 -- fixed 1 second interval

			if deltaStrength > 0 then
				totalGained += deltaStrength
			end

			-- Calculate rates per second, minute, hour, day, week, month
			local sps = deltaStrength / deltaTime
			local spm = sps * 60
			local sph = sps * 3600
			local spd = sps * 86400
			local spw = sps * 604800
			local spmo = sps * 2592000

			SPSLabel:Set("SPS: " .. formatNumber(math.floor(sps)))
			SPMLabel:Set("SPM: " .. formatNumber(math.floor(spm)))
			SPHLabel:Set("SPH: " .. formatNumber(math.floor(sph)))
			SPDLabel:Set("SPD: " .. formatNumber(math.floor(spd)))
			SPWLabel:Set("SPW: " .. formatNumber(math.floor(spw)))
			SPMOLabel:Set("SPMO: " .. formatNumber(math.floor(spmo)))

			-- Update shared labels
			local formattedStrength = formatNumber(currentStrength)
			local formattedGained = formatNumber(totalGained)

			StrengthLabel:Set("Strength: " .. formattedStrength)
			GainedLabel:Set("Gained: " .. formattedGained)

			StatStrengthLabel:Set("Strength: " .. formattedStrength .. " | " .. tonumber(currentStrength))
			StatGainedLabel:Set("Gained: " .. formattedGained)

			-- Session time
			local t = now - sessionStart
			local h = math.floor(t / 3600)
			local m = math.floor((t % 3600) / 60)
			local s = math.floor(t % 60)
			SessionTimeLabel:Set(string.format("Session Time: %02d:%02d:%02d", h, m, s))

			-- Update lastStrength for next tick
			lastStrength = currentStrength
		end)
	end
end)

-- Update Weight (every second is fine)
spawn(function()
	while wait(1) do
		pcall(function()
			local totalItems = getTotalInventoryCount()
			local doubleWeights = getDoubleWeightCount()
			WeightLabel:Set("Items: " .. totalItems .. " | Weights: " .. doubleWeights)
		end)
	end
end)

-- Update Size (Real-time with Heartbeat)
RunService.Heartbeat:Connect(function()
	pcall(function()
		SizeLabel:Set("Size: " .. str.Value)
        StatSizeLabel:Set("Size: " .. str.Value)
	end)
end)

-- Update Ping
spawn(function()
	while wait(1) do
		pcall(function()
			local currentPing = getPing()
			local pingColor = currentPing < _G.ResumePing and "🟢" or (currentPing < _G.MaxPing and "🟡" or "🔴")
			PingLabel:Set("Ping: " .. pingColor .. " " .. currentPing .. "ms")
		end)
	end
end)

-- Credits Tab
local CreditsTab = Window:CreateTab("Credits")

CreditsTab:AddLabel("--- Credits ---")
CreditsTab:AddLabel("Main Developer: Auberon_Altas")
CreditsTab:AddLabel("UI Library: ZayHub, by Criptism aka me")
CreditsTab:AddLabel("")
CreditsTab:AddLabel("Thank you for using Doggy Hub V3!")

print("✅ Doggy Hub V3 Loaded Successfully!")
Notify("Doggy Hub V3", "Loaded Successfully! Enjoy farming!", 5)

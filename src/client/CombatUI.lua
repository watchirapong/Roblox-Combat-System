--[[
	CombatUI - แสดง Skill Bar และ Mana Bar
	วางเป็น LocalScript ใน StarterPlayerScripts หรือใน StarterGui
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local configMod = ReplicatedStorage:FindFirstChild("CombatConfig")
if not configMod then
	warn("[CombatUI] ไม่พบ CombatConfig — Skill Bar จะไม่แสดง")
	return
end
local CombatConfig = require(configMod)
if CombatConfig.EnableSkillUI == false then return end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- เก็บ cooldown ฝั่ง Client (ประมาณ)
local skillCooldownEnd = {}

-- ฟังก์ชันแปลง KeyCode เป็น string แสดง
local function keyToString(keyCode)
	local map = {
		[Enum.KeyCode.One] = "1",
		[Enum.KeyCode.Two] = "2",
		[Enum.KeyCode.Three] = "3",
		[Enum.KeyCode.Four] = "4",
		[Enum.KeyCode.F] = "F",
		[Enum.KeyCode.Q] = "Q",
		[Enum.KeyCode.E] = "E",
		[Enum.KeyCode.R] = "R",
	}
	return map[keyCode] or tostring(keyCode):gsub("Enum.KeyCode.", "")
end

-- สร้าง UI หลัก
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Frame หลัก Skill Bar (center ใช้ Scale 0.5 + AnchorPoint 0.5,0)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "SkillBar"
mainFrame.Size = UDim2.new(0, 320, 0, 70)
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.Position = UDim2.new(0.5, 0, 1, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- สร้างปุ่มสกิลแต่ละอัน
local skillOrder = {}
for skillId, skill in CombatConfig.Skills do
	table.insert(skillOrder, { id = skillId, skill = skill })
end
table.sort(skillOrder, function(a, b) return a.skill.Keybind.Value < b.skill.Keybind.Value end)

for i, data in skillOrder do
	local skillId = data.id
	local skill = data.skill

	local slot = Instance.new("Frame")
	slot.Name = skillId
	slot.Size = UDim2.new(0, 60, 0, 60)
	slot.Position = UDim2.new(0, 25 + (i - 1) * 70, 0, 5)
	slot.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	slot.BorderSizePixel = 0
	slot.Parent = mainFrame

	local slotCorner = Instance.new("UICorner")
	slotCorner.CornerRadius = UDim.new(0, 6)
	slotCorner.Parent = slot

	-- คีย์
	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.new(1, 0, 0, 22)
	keyLabel.Position = UDim2.new(0, 0, 0, 0)
	keyLabel.BackgroundTransparency = 1
	keyLabel.Text = keyToString(skill.Keybind)
	keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	keyLabel.TextSize = 14
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.Parent = slot

	-- ชื่อสกิล
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -4, 0, 18)
	nameLabel.Position = UDim2.new(0, 2, 0, 24)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = skill.DisplayName or skillId
	nameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	nameLabel.TextSize = 11
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = slot

	-- โอเวอร์เลย์ cooldown (สีดำทับเมื่อ cooldown)
	local overlay = Instance.new("Frame")
	overlay.Name = "CooldownOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.6
	overlay.BorderSizePixel = 0
	overlay.Visible = false
	overlay.ZIndex = 2
	overlay.Parent = slot

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(0, 6)
	overlayCorner.Parent = overlay

	-- ตัวเลข countdown ( optional )
	local timeLabel = Instance.new("TextLabel")
	timeLabel.Name = "Time"
	timeLabel.Size = UDim2.new(1, 0, 1, 0)
	timeLabel.Position = UDim2.new(0, 0, 0, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = ""
	timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timeLabel.TextSize = 18
	timeLabel.Font = Enum.Font.GothamBold
	timeLabel.ZIndex = 3
	timeLabel.Visible = false
	timeLabel.Parent = slot
end

-- Mana Bar (เมื่อ UseMana = true)
local manaFrame = nil
local manaBar = nil
if CombatConfig.UseMana then
	manaFrame = Instance.new("Frame")
	manaFrame.Name = "ManaBar"
	manaFrame.Size = UDim2.new(0, 200, 0, 20)
	manaFrame.AnchorPoint = Vector2.new(0.5, 0)
	manaFrame.Position = UDim2.new(0.5, 0, 1, -120)
	manaFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	manaFrame.BorderSizePixel = 0
	manaFrame.Parent = screenGui

	local manaCorner = Instance.new("UICorner")
	manaCorner.CornerRadius = UDim.new(0, 4)
	manaCorner.Parent = manaFrame

	local manaBg = Instance.new("Frame")
	manaBg.Size = UDim2.new(1, -4, 1, -4)
	manaBg.Position = UDim2.new(0, 2, 0, 2)
	manaBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	manaBg.BorderSizePixel = 0
	manaBg.Parent = manaFrame

	manaBar = Instance.new("Frame")
	manaBar.Name = "Fill"
	manaBar.Size = UDim2.new(1, 0, 1, 0)
	manaBar.Position = UDim2.new(0, 0, 0, 0)
	manaBar.AnchorPoint = Vector2.new(0, 0)
	manaBar.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
	manaBar.BorderSizePixel = 0
	manaBar.Parent = manaBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = manaBar
end

-- อัปเดต cooldown overlay
local function updateCooldownUI()
	local now = tick()
	for i, data in skillOrder do
		local skillId = data.id
		local skill = data.skill
		local slot = mainFrame:FindFirstChild(skillId)
		if not slot then continue end

		local overlay = slot:FindFirstChild("CooldownOverlay")
		local timeLabel = slot:FindFirstChild("Time")
		if not overlay or not timeLabel then continue end

		local endTime = skillCooldownEnd[skillId] or 0
		if now < endTime then
			local remaining = endTime - now
			overlay.Visible = true
			timeLabel.Visible = true
			timeLabel.Text = string.format("%.1f", remaining)
		else
			overlay.Visible = false
			timeLabel.Visible = false
		end
	end
end

-- ฟังเมื่อใช้สกิล (CombatInput จะ Fire ตอนกดสกิล)
local skillUsedEvent = ReplicatedStorage:FindFirstChild("SkillUsedClient")
if not skillUsedEvent then
	skillUsedEvent = Instance.new("BindableEvent")
	skillUsedEvent.Name = "SkillUsedClient"
	skillUsedEvent.Parent = ReplicatedStorage
end
skillUsedEvent.Event:Connect(function(skillId, cooldown)
	if skillId and cooldown then
		skillCooldownEnd[skillId] = tick() + cooldown
	end
end)

-- Mana: ฝั่ง Client ไม่รู้ค่า mana จริง (อยู่ Server) เลยซ่อนหรือแสดง 100% ถ้า UseMana
-- ถ้าต้องการ Mana sync ต้องมี RemoteFunction/RemoteEvent จาก Server
if manaBar then
	manaBar.Size = UDim2.new(1, 0, 1, 0)
end

-- Loop อัปเดต UI
game:GetService("RunService").RenderStepped:Connect(updateCooldownUI)

if CombatConfig.EnableDebug then
	local dbg = ReplicatedStorage:FindFirstChild("CombatDebug")
	if dbg then dbg:FireServer("CombatUI โหลดแล้ว — Skill Bar แสดงด้านล่างจอ") end
end

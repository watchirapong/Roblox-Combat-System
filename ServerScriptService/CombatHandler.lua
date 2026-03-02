--[[
	CombatHandler - Server
	ตรวจสอบและคำนวณความเสียหาย สกิล cooldown
	วางใน ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- สร้าง RemoteEvent ก่อน ให้ Client ไม่ค้าง
for _, name in {"UseSkill", "BasicAttack", "CombatDebug"} do
	if not ReplicatedStorage:FindFirstChild(name) then
		local e = Instance.new("RemoteEvent")
		e.Name = name
		e.Parent = ReplicatedStorage
		print("[Combat] สร้าง " .. name .. " แล้ว")
	end
end

local CombatConfig = require(ReplicatedStorage:WaitForChild("CombatConfig"))

local VFXMod = ReplicatedStorage:FindFirstChild("VFXModule")
local VFXModule = VFXMod and require(VFXMod) or { PlaySkillEffect = function() end }
if not VFXMod and CombatConfig.EnableDebug then
	warn("[Combat] ไม่พบ VFXModule — สร้าง ModuleScript ใน ReplicatedStorage จาก ReplicatedStorage/VFXModule.lua")
end

local combatDebugEvent = ReplicatedStorage:FindFirstChild("CombatDebug")
if combatDebugEvent and CombatConfig.EnableDebug then
	combatDebugEvent.OnServerEvent:Connect(function(plr, msg)
		print("[Combat Debug Client] " .. (plr and plr.Name or "?") .. ": " .. tostring(msg))
	end)
	print("[Combat Debug] เปิด Debug — ข้อความจาก Client จะแสดงที่นี่")
end

-- เก็บ cooldown แต่ละคน
local playerCooldowns = {}
local playerMana = {}

local function getCooldowns(player)
	if not playerCooldowns[player.UserId] then
		playerCooldowns[player.UserId] = {}
	end
	return playerCooldowns[player.UserId]
end

local function getMana(player)
	if not playerMana[player.UserId] then
		playerMana[player.UserId] = 100
	end
	return playerMana[player.UserId]
end

local function setMana(player, amount)
	playerMana[player.UserId] = math.clamp(amount, 0, 100)
end

local function canUseSkill(player, skillId)
	local skill = CombatConfig.Skills[skillId]
	if not skill then
		if CombatConfig.EnableDebug then
			warn("[Combat] ไม่มีสกิล '" .. tostring(skillId) .. "'")
		end
		return false, "ไม่มีสกิลนี้"
	end

	local cooldowns = getCooldowns(player)
	local lastUsed = cooldowns[skillId]
	if lastUsed and tick() - lastUsed < skill.Cooldown then
		if CombatConfig.EnableDebug then
			warn("[Combat] สกิล '" .. (skill.DisplayName or skillId) .. "' ยัง Cooldown")
		end
		return false, "ยัง Cooldown อยู่"
	end

	if CombatConfig.UseMana then
		local mana = getMana(player)
		if mana < skill.ManaCost then
			if CombatConfig.EnableDebug then
				warn("[Combat] แมนาไม่พอ: ต้องการ " .. skill.ManaCost .. " มี " .. mana)
			end
			return false, "แมนาไม่พอ"
		end
	end

	return true
end

-- Hitbox: หา Humanoids ทั้งหมดในกล่องด้านหน้าผู้ใช้สกิล
local function getTargetsInHitbox(caster, length, width, height)
	local root = caster and caster:FindFirstChild("HumanoidRootPart")
	if not root then return {} end

	local cf = root.CFrame
	local boxCF = cf + cf.LookVector * (length / 2)
	local size = Vector3.new(width, height, length)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { caster }

	local parts = workspace:GetPartBoundsInBox(boxCF, size, overlapParams)
	local hit = {}
	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model ~= caster and not hit[model] then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				hit[model] = humanoid
			end
		end
	end
	return hit
end

-- สร้างกล่อง Hitbox Debug (ไม่พึ่ง VFXModule)
local function showHitboxDebugBox(cframe, size, duration)
	if CombatConfig.ShowHitboxDebug == false then return end

	local box = Instance.new("Part")
	box.Name = "HitboxDebug"
	box.Anchored = true
	box.CanCollide = false
	box.CanQuery = false
	box.CanTouch = false
	box.Transparency = 0.5
	box.Color = Color3.fromRGB(255, 80, 80)
	box.Material = Enum.Material.ForceField
	box.Size = size
	box.CFrame = cframe
	box.Parent = workspace

	Debris:AddItem(box, duration or 0.8)
end

local useSkillEvent = ReplicatedStorage:WaitForChild("UseSkill")
local basicAttackEvent = ReplicatedStorage:WaitForChild("BasicAttack")

-- รับจาก Client: ใช้สกิล (Hitbox)
useSkillEvent.OnServerEvent:Connect(function(player, skillId)
	if CombatConfig.EnableDebug then
		print("[Combat Debug Server] รับสกิล: " .. tostring(skillId) .. " จาก " .. (player and player.Name or "nil"))
	end

	if not player or not player.Character then
		if CombatConfig.EnableDebug then warn("[Combat Debug Server] ไม่มี player หรือ Character") end
		return
	end

	local skill = CombatConfig.Skills[skillId]
	if not skill then
		if CombatConfig.EnableDebug then warn("[Combat Debug Server] สกิลไม่รู้จัก: " .. tostring(skillId)) end
		return
	end

	local canUse = canUseSkill(player, skillId)
	if not canUse then return end

	local length = skill.Range or 10
	local width = skill.HitboxWidth or 8
	local height = skill.HitboxHeight or 8

	local boxCF = (player.Character.HumanoidRootPart.CFrame) + (player.Character.HumanoidRootPart.CFrame.LookVector * (length / 2))
	local boxSize = Vector3.new(width, height, length)

	local hitTargets = getTargetsInHitbox(player.Character, length, width, height)

	showHitboxDebugBox(boxCF, boxSize, 0.8)

	-- บันทึก cooldown
	local cooldowns = getCooldowns(player)
	cooldowns[skillId] = tick()

	if CombatConfig.UseMana then
		setMana(player, getMana(player) - skill.ManaCost)
	end

	for model, humanoid in pairs(hitTargets) do
		humanoid:TakeDamage(skill.Damage)
		if CombatConfig.EnableDebug then
			print("[Combat Debug Server] Hitbox: " .. player.Name .. " -> " .. model.Name .. " ความเสียหาย " .. skill.Damage)
		end
	end
	if CombatConfig.EnableVFX then
		VFXModule.PlaySkillEffect(player.Character, skillId, Vector3.zero)
	end
end)

-- รับจาก Client: โจมตีธรรมดา (Hitbox)
basicAttackEvent.OnServerEvent:Connect(function(player)
	if CombatConfig.EnableDebug then
		print("[Combat Debug Server] รับโจมตีธรรมดา จาก " .. (player and player.Name or "nil"))
	end

	if not player or not player.Character then
		if CombatConfig.EnableDebug then warn("[Combat Debug Server] Basic: ไม่มี player/Character") end
		return
	end

	local cooldowns = getCooldowns(player)
	local lastBasic = cooldowns["__basic"] or 0
	if tick() - lastBasic < CombatConfig.BasicAttackCooldown then
		if CombatConfig.EnableDebug then
			warn("[Combat Debug Server] Basic: ยัง Cooldown")
		end
		return
	end

	cooldowns["__basic"] = tick()

	local length = CombatConfig.BasicAttackRange or 8
	local width = CombatConfig.BasicAttackHitboxWidth or 6
	local height = CombatConfig.BasicAttackHitboxHeight or 6

	local hitTargets = getTargetsInHitbox(player.Character, length, width, height)

	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local boxCF = root.CFrame + root.CFrame.LookVector * (length / 2)
		showHitboxDebugBox(boxCF, Vector3.new(width, height, length), 0.6)
	end

	for model, humanoid in pairs(hitTargets) do
		humanoid:TakeDamage(CombatConfig.BasicAttackDamage)
		if CombatConfig.EnableDebug then
			print("[Combat Debug Server] Basic Hitbox: " .. player.Name .. " -> " .. model.Name)
		end
	end
end)


local function regenerateMana()
	if not CombatConfig.UseMana then return end
	local list = Players:GetPlayers()
	for i = 1, #list do
		local plr = list[i]
		if plr and plr.Parent then
			local cur = getMana(plr)
			if cur < 100 then
				setMana(plr, cur + 0.05)
			end
		end
	end
end
game:GetService("RunService").Heartbeat:Connect(regenerateMana)

-- ล้างข้อมูลเมื่อออก
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
	playerMana[player.UserId] = nil
end)

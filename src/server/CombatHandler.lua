--[[
	CombatHandler - Server
	ตรวจสอบและคำนวณความเสียหาย สกิล cooldown
	วางใน ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
	warn("[Combat] ไม่พบ VFXModule — สร้าง ModuleScript ใน ReplicatedStorage จาก src/shared/VFXModule.lua")
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

local function validateDistance(caster, target, range)
	if not caster or not target then return false end
	local cRoot = caster:FindFirstChild("HumanoidRootPart")
	local tRoot = target:FindFirstChild("HumanoidRootPart")
	if not cRoot or not tRoot then return false end
	return (cRoot.Position - tRoot.Position).Magnitude <= range
end

local useSkillEvent = ReplicatedStorage:WaitForChild("UseSkill")
local basicAttackEvent = ReplicatedStorage:WaitForChild("BasicAttack")

-- รับจาก Client: ใช้สกิล
useSkillEvent.OnServerEvent:Connect(function(player, skillId, target)
	if CombatConfig.EnableDebug then
		print("[Combat Debug Server] รับสกิล: " .. tostring(skillId) .. " จาก " .. (player and player.Name or "nil"))
	end

	if not player or not player.Character then
		if CombatConfig.EnableDebug then
			warn("[Combat Debug Server] ไม่มี player หรือ Character")
		end
		return
	end

	local skill = CombatConfig.Skills[skillId]
	if not skill then
		if CombatConfig.EnableDebug then
			warn("[Combat Debug Server] สกิลไม่รู้จัก: " .. tostring(skillId))
		end
		return
	end

	local canUse, err = canUseSkill(player, skillId)
	if not canUse then return end

	local targetPlayer = type(target) == "Instance" and target or Players:GetPlayerByUserId(target)
	local targetChar = targetPlayer and targetPlayer.Character
	if not targetChar then
		if CombatConfig.EnableDebug then
			warn("[Combat Debug Server] ไม่มีเป้า (target หายหรือไม่มี Character)")
		end
		return
	end

	if not validateDistance(player.Character, targetChar, skill.Range) then
		if CombatConfig.EnableDebug then
			local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
			local d = tRoot and (player.Character.HumanoidRootPart.Position - tRoot.Position).Magnitude or 0
			warn("[Combat Debug Server] ไกลเกินไป: ระยะ=" .. math.floor(d) .. " ต้องไม่เกิน " .. skill.Range)
		end
		return
	end

	local targetHumanoid = targetChar:FindFirstChild("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then
		if CombatConfig.EnableDebug then
			warn("[Combat Debug Server] เป้าตายหรือไม่มี Humanoid")
		end
		return
	end

	-- บันทึก cooldown
	local cooldowns = getCooldowns(player)
	cooldowns[skillId] = tick()

	-- หักแมนา (ถ้าเปิดระบบแมนา)
	if CombatConfig.UseMana then
		setMana(player, getMana(player) - skill.ManaCost)
	end

	-- ทำความเสียหาย
	targetHumanoid:TakeDamage(skill.Damage)

	if CombatConfig.EnableDebug then
		print("[Combat Debug Server] สำเร็จ: " .. player.Name .. " -> " .. targetPlayer.Name .. " ความเสียหาย " .. skill.Damage)
	end

	-- แจ้ง Client ให้เล่น VFX (ถ้าเปิดอยู่)
	VFXModule.PlaySkillEffect(player.Character, skillId, targetChar:FindFirstChild("HumanoidRootPart") and targetChar.HumanoidRootPart.Position or Vector3.zero)
end)

-- รับจาก Client: โจมตีธรรมดา
basicAttackEvent.OnServerEvent:Connect(function(player, target)
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
			warn("[Combat Debug Server] Basic: ยัง Cooldown (รอ " .. string.format("%.1f", CombatConfig.BasicAttackCooldown - (tick() - lastBasic)) .. "s)")
		end
		return
	end

	cooldowns["__basic"] = tick()

	local targetPlayer = type(target) == "Instance" and target or Players:GetPlayerByUserId(target)
	local targetChar = targetPlayer and targetPlayer.Character
	if not targetChar then
		if CombatConfig.EnableDebug then warn("[Combat Debug Server] Basic: ไม่มีเป้า") end
		return
	end

	if not validateDistance(player.Character, targetChar, 8) then
		if CombatConfig.EnableDebug then
			local d = (player.Character.HumanoidRootPart.Position - targetChar.HumanoidRootPart.Position).Magnitude
			warn("[Combat Debug Server] Basic: ไกลเกินไป ระยะ=" .. math.floor(d))
		end
		return
	end

	local targetHumanoid = targetChar:FindFirstChild("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then
		if CombatConfig.EnableDebug then warn("[Combat Debug Server] Basic: เป้าตาย") end
		return
	end

	targetHumanoid:TakeDamage(CombatConfig.BasicAttackDamage)
	if CombatConfig.EnableDebug then
		print("[Combat Debug Server] Basic สำเร็จ: " .. player.Name .. " -> " .. targetPlayer.Name)
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

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfig = require(ReplicatedStorage:WaitForChild("CombatConfig"))

local debugEvent = ReplicatedStorage:FindFirstChild("CombatDebug")
local function debugLog(msg)
	if CombatConfig.EnableDebug and msg then
		print("[Combat Debug] " .. tostring(msg))
		if debugEvent then
			debugEvent:FireServer(tostring(msg))
		end
	end
end

local function safeRequire(name, stub)
	local mod = ReplicatedStorage:FindFirstChild(name)
	if mod then return require(mod) end
	warn("[Combat] ไม่พบ " .. name .. " ใน ReplicatedStorage — ระบบยังทำงานได้แต่ไม่มี " .. name)
	return stub or {}
end

local VFXModule = safeRequire("VFXModule", { IsEnabled = function() return false end, PlaySkillEffect = function() end })
local AnimationModule = safeRequire("AnimationModule", { PlaySkillAnimation = function() end, PlayBasicAttackAnimation = function() end })

local useSkillEvent = ReplicatedStorage:WaitForChild("UseSkill")
local basicAttackEvent = ReplicatedStorage:WaitForChild("BasicAttack")

local player = Players.LocalPlayer

debugLog("CombatInput โหลดแล้ว — กด 1,2,3,4,F (ปิด Chat ก่อนกด)")

local function getNearestEnemy(maxDistance, debugReason)
	local character = player.Character
	if not character then
		if debugReason then debugLog("ไม่มี Character") end
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		if debugReason then debugLog("ไม่มี HumanoidRootPart") end
		return nil
	end

	local nearest = nil
	local nearestDist = maxDistance or 50
	local allPlayers = Players:GetPlayers()

	if debugReason and #allPlayers < 2 then
		debugLog("ผู้เล่นน้อยกว่า 2 คน (" .. #allPlayers .. ") — เปิดเกมแบบ 2+ Players เพื่อทดสอบ")
	end

	for _, other in allPlayers do
		if other ~= player and other.Character then
			local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = other.Character:FindFirstChild("Humanoid")
			if otherRoot and humanoid and humanoid.Health > 0 then
				local dist = (root.Position - otherRoot.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearest = other
				end
			end
		end
	end

	if debugReason and not nearest then
		debugLog("ไม่มีศัตรูในระยะ " .. (maxDistance or 50) .. " studs")
	end

	return nearest
end

local function onSkillInput(skillId)
	local skill = CombatConfig.Skills[skillId]
	if not skill then
		debugLog("ไม่มีสกิล '" .. tostring(skillId) .. "' ใน Config")
		return
	end

	local target = getNearestEnemy(skill.Range, true)
	if not target then
		debugLog("มีสกิลแต่ไม่มีเป้า — ต้องมีผู้เล่น 2 คนขึ้นไป หรือให้ศัตรูอยู่ในระยะ " .. skill.Range)
		return
	end

	debugLog("ยิงสกิล " .. (skill.DisplayName or skillId) .. " -> " .. target.Name)

	useSkillEvent:FireServer(skillId, target)

	local skillUsedEvent = ReplicatedStorage:FindFirstChild("SkillUsedClient")
	if skillUsedEvent then
		skillUsedEvent:Fire(skillId, skill.Cooldown)
	end

	if player.Character then
		AnimationModule.PlaySkillAnimation(player.Character, skillId)
	end

	if VFXModule.IsEnabled() and player.Character then
		local targetPos = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Position
		VFXModule.PlaySkillEffect(player.Character, skillId, targetPos or Vector3.zero)
	end
end

local function onBasicAttack()
	local target = getNearestEnemy(8, true)
	if not target then
		debugLog("กด F แต่ไม่มีเป้า")
		return
	end
	debugLog("โจมตีธรรมดา -> " .. target.Name)
	if player.Character then
		AnimationModule.PlayBasicAttackAnimation(player.Character)
	end
	basicAttackEvent:FireServer(target)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		local skillKeys = {"One","Two","Three","Four","F","Q","E","R"}
		if table.find(skillKeys, input.KeyCode.Name) then
			debugLog("กดปุ่มแล้วแต่ gameProcessed=true — ปิด Chat ก่อนกดสกิล")
		end
		return
	end

	for skillId, skill in CombatConfig.Skills do
		if input.KeyCode == skill.Keybind then
			debugLog("กดปุ่ม " .. (skill.DisplayName or skillId))
			onSkillInput(skillId)
			return
		end
	end

	if input.KeyCode == Enum.KeyCode.F then
		debugLog("กดปุ่ม F (โจมตีธรรมดา)")
		onBasicAttack()
	end
end)

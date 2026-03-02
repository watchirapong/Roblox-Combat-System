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

local function onSkillInput(skillId)
	local skill = CombatConfig.Skills[skillId]
	if not skill then
		debugLog("ไม่มีสกิล '" .. tostring(skillId) .. "' ใน Config")
		return
	end

	debugLog("ยิงสกิล " .. (skill.DisplayName or skillId))

	useSkillEvent:FireServer(skillId)

	local skillUsedEvent = ReplicatedStorage:FindFirstChild("SkillUsedClient")
	if skillUsedEvent then
		skillUsedEvent:Fire(skillId, skill.Cooldown)
	end

	if player.Character then
		AnimationModule.PlaySkillAnimation(player.Character, skillId)
	end

	if VFXModule.IsEnabled() and player.Character then
		VFXModule.PlaySkillEffect(player.Character, skillId, Vector3.zero)
	end
end

local function onBasicAttack()
	debugLog("โจมตีธรรมดา")
	if player.Character then
		AnimationModule.PlayBasicAttackAnimation(player.Character)
	end
	basicAttackEvent:FireServer()
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

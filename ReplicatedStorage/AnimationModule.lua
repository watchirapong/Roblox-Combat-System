--[[
	AnimationModule - เล่น Animation ตอนใช้สกิล/โจมตี
	ใส่ AnimationId ใน CombatConfig แล้วจะเล่นอัตโนมัติ
]]

local CombatConfig = require(script.Parent.CombatConfig)

local AnimationModule = {}

local function playAnimation(character, animId)
	if not character then return nil end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return nil end

	local animIdStr = type(animId) == "string" and animId or "rbxassetid://" .. tostring(animId)
	if animIdStr == "rbxassetid://0" or animIdStr == "" then return nil end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = animIdStr
	local track = animator:LoadAnimation(anim)
	track:Play()
	return track
end

function AnimationModule.PlaySkillAnimation(character, skillId)
	local skill = CombatConfig.Skills[skillId]
	if not skill then return nil end
	return playAnimation(character, skill.AnimationId)
end

function AnimationModule.PlayBasicAttackAnimation(character)
	local ids = CombatConfig.BasicAttackAnimationIds
	if ids and type(ids) == "table" and #ids > 0 then
		local animId = ids[math.random(1, #ids)]
		return playAnimation(character, animId)
	end
	-- รองรับแบบเดิม (BasicAttackAnimationId เดียว)
	local animId = CombatConfig.BasicAttackAnimationId
	if animId then return playAnimation(character, animId) end
	return nil
end

return AnimationModule

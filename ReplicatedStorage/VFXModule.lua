--[[
	VFXModule - จัดการเอฟเฟกต์ต่างๆ
	รองรับการเปิด/ปิดจาก CombatConfig
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local CombatConfig = require(script.Parent.CombatConfig)

local VFXModule = {}

function VFXModule.IsEnabled()
	return CombatConfig.EnableVFX
end

-- สร้าง ParticleEmitter ชั่วคราว
function VFXModule.SpawnParticle(parent, assetId, duration)
	if not CombatConfig.EnableVFX then return end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Parent = parent

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = assetId ~= "" and assetId or "rbxassetid://108158443"
	emitter.Rate = 20
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Speed = NumberRange.new(5, 15)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = part

	Debris:AddItem(part, duration or 2)
	return part
end

-- แสดงเอฟเฟกต์ที่ตำแหน่ง
function VFXModule.PlayAtPosition(position, effectType, duration)
	if not CombatConfig.EnableVFX then return end

	duration = duration or 1.5

	local attachment = Instance.new("Attachment")
	attachment.Position = position

	local container = Instance.new("Part")
	container.Anchored = true
	container.CanCollide = false
	container.Transparency = 1
	container.Size = Vector3.new(0.1, 0.1, 0.1)
	container.CFrame = CFrame.new(position)
	container.Parent = workspace

	attachment.Parent = container

	if effectType == "hit" then
		local sparkles = Instance.new("Sparkles")
		sparkles.Parent = container
	elseif effectType == "slash" then
		local att0 = Instance.new("Attachment")
		local att1 = Instance.new("Attachment")
		att1.Position = Vector3.new(3, 0, 0)
		att0.Parent = container
		att1.Parent = container
		local beam = Instance.new("Beam")
		beam.Attachment0 = att0
		beam.Attachment1 = att1
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 100, 100))
		beam.Width0 = 0.5
		beam.Width1 = 0
		beam.Parent = container
	end

	Debris:AddItem(container, duration)
end

-- แสดงเอฟเฟกต์สกิล
function VFXModule.PlaySkillEffect(caster, skillId, targetPosition)
	if not CombatConfig.EnableVFX then return end

	local skillConfig = CombatConfig.Skills[skillId]
	if not skillConfig then return end

	if skillConfig.VFXId and skillConfig.VFXId ~= "rbxassetid://0" then
		-- ถ้ามี VFX เฉพาะของสกิล ให้เล่นตรงนี้
		-- ปรับแต่งตาม asset ที่ใช้จริง
	end

	-- เอฟเฟกต์พื้นฐาน: วงแสงที่เท้าคนใช้สกิล
	local root = caster:FindFirstChild("HumanoidRootPart")
	if root then
		VFXModule.PlayAtPosition(root.Position, "hit", 0.8)
	end
end

return VFXModule

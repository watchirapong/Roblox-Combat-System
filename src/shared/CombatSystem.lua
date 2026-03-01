--[[
	CombatSystem - โมดูลหลักของระบบ Combat และ Skill
	ใช้ทั้งฝั่ง Server และ Client
]]

local CombatConfig = require(script.Parent.CombatConfig)
local VFXMod = script.Parent:FindFirstChild("VFXModule")
local VFXModule = VFXMod and require(VFXMod) or { IsEnabled = function() return false end }

local CombatSystem = {}

function CombatSystem.GetConfig()
	return CombatConfig
end

function CombatSystem.GetSkill(skillId)
	return CombatConfig.Skills[skillId]
end

function CombatSystem.GetAllSkills()
	return CombatConfig.Skills
end

function CombatSystem.ShouldShowVFX()
	return VFXModule.IsEnabled()
end

function CombatSystem.GetVFXModule()
	return VFXModule
end

return CombatSystem

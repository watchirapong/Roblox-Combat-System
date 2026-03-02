--[[
	CombatConfig - ค่าปรับแต่งระบบ Combat และ Skill
	แก้ไขไฟล์นี้ได้ตามต้องการ

	วิธีเพิ่มสกิลใหม่:
		1. Copy block ด้านล่าง (ตั้งแต่ ["ชื่อId"] = { ถึง },)
		2. วางใน Skills = { ... }
		3. เปลี่ยน "ชื่อId" เป็น key ไม่ซ้ำ (ภาษาอังกฤษ เช่น "Fireball")
		4. เปลี่ยน DisplayName, Keybind, Cooldown, Damage, Range, ManaCost, CastTime, VFXId
		5. Keybind ต้องไม่ซ้ำกับสกิลอื่น (Enum.KeyCode.One ถึง Four, Q, E, R ฯลฯ)
]]

return {
	-- เปิด/ปิด VFX (เอฟเฟกต์แสง อนุภาค)
	-- true = มี VFX, false = ไม่มี VFX
	EnableVFX = true,

	-- เปิด Debug = แสดงข้อความใน Output เมื่อใช้สกิล (ตั้ง true เวลาแก้ปัญหา)
	EnableDebug = true,

	-- แสดงกล่อง Hitbox สีโปร่งใสเมื่อใช้สกิล/โจมตี (ใช้ตอนดีบักเพื่อดูพื้นที่โจมตี)
	ShowHitboxDebug = true,

	-- ใช้ระบบแมนาไหม (true = หักแมนาตอนใช้สกิล, false = ไม่ใช้แมนาเลย)
	UseMana = false,

	-- แสดง Skill Bar ด้านล่างจอ (true = แสดง, false = ซ่อน)
	EnableSkillUI = true,

	-- ช่วงเวลา cooldown หลังโจมตีธรรมดา (วินาที)
	BasicAttackCooldown = 0.5,

	-- ความเสียหายโจมตีธรรมดา
	BasicAttackDamage = 10,

	BasicAttackAnimationId = "rbxassetid://0",

	-- Hitbox โจมตีธรรมดา (studs)
	BasicAttackRange = 8,
	BasicAttackHitboxWidth = 6,
	BasicAttackHitboxHeight = 6,

	-- รายการสกิลทั้งหมด
	Skills = {
		["HeavyStrike"] = {
			DisplayName = "ทุบแรง",
			Keybind = Enum.KeyCode.One,
			Cooldown = 3,
			Damage = 35,
			Range = 12,
			HitboxWidth = 8,
			HitboxHeight = 8,
			ManaCost = 15,
			CastTime = 0.2,
			VFXId = "rbxassetid://0",
			AnimationId = "rbxassetid://0",
		},

		["BlinkStrike"] = {
			DisplayName = "วาร์ปโจมตี",
			Keybind = Enum.KeyCode.Two,
			Cooldown = 5,
			Damage = 45,
			Range = 25,
			HitboxWidth = 10,
			HitboxHeight = 10,
			ManaCost = 25,
			CastTime = 0,
			VFXId = "rbxassetid://0",
			AnimationId = "rbxassetid://0",
		},

		["SpinSlash"] = {
			DisplayName = "หมุนตัด",
			Keybind = Enum.KeyCode.Three,
			Cooldown = 6,
			Damage = 55,
			Range = 10,
			HitboxWidth = 12,
			HitboxHeight = 10,
			ManaCost = 30,
			CastTime = 0.3,
			VFXId = "rbxassetid://0",
			AnimationId = "rbxassetid://0",
		},

		["Ultimate"] = {
			DisplayName = "สกิลสุดท้าย",
			Keybind = Enum.KeyCode.Four,
			Cooldown = 30,
			Damage = 150,
			Range = 15,
			HitboxWidth = 12,
			HitboxHeight = 12,
			ManaCost = 100,
			CastTime = 0.5,
			VFXId = "rbxassetid://0",
			AnimationId = "rbxassetid://0",
		},
	},
}

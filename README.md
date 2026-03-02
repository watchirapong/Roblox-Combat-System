# Roblox Combat System + สกิล

ระบบต่อสู้พร้อมสกิลหลายแบบ รองรับ Hitbox, แอนิเมชันโจมตีธรรมดาหลายแบบ, VFX และ Debug

---

## 1. โครงสร้างโฟลเดอร์ (Structure Folder)

```
Roblox Combat System/
├── ReplicatedStorage/
│   ├── CombatConfig.lua      -- ตั้งค่าทั้งหมด (Damage, สกิล, แอนิเมชัน)
│   ├── VFXModule.lua         -- เอฟเฟกต์แสง อนุภาค
│   ├── AnimationModule.lua   -- เล่นแอนิเมชันตอนโจมตี/ใช้สกิล
│   └── CombatSystem.lua      -- โมดูลหลัก
│
├── ServerScriptService/
│   └── CombatHandler.lua     -- Server ตรวจสอบความเสียหาย Cooldown
│
└── StarterPlayer/
    └── StarterPlayerScripts/
        ├── CombatInput.lua   -- รับ Input คลิกซ้าย/F และกด 1-4
        └── CombatUI.lua      -- Skill Bar แสดงด้านล่างจอ
```

โฟลเดอร์นี้ต้องตรงกับโครงสร้างใน **Roblox Explorer** เมื่อ Copy โค้ดเข้า Studio

---

## 2. วิธีเอาโค้ดจาก GitHub มาใส่ใน Roblox (ทีละขั้นตอน สำหรับคนที่ไม่เคยทำเลย)

### ขั้นตอนที่ 1: ดาวน์โหลดโค้ดจาก GitHub

1. เปิดเว็บ **github.com** แล้วไปที่ Repository ของโปรเจกต์นี้
2. กดปุ่มสีเขียว **Code** แล้วเลือก **Download ZIP**
3. แตกไฟล์ ZIP (Unzip) แล้วเปิดโฟลเดอร์ จะเห็นโฟลเดอร์ย่อย เช่น `Roblox-Combat-System-master` หรือชื่ออื่น
4. เปิดโฟลเดอร์จนเห็นไฟล์ `.lua` เช่น `CombatConfig.lua`, `CombatHandler.lua` เป็นต้น

*(ถ้าใช้ Git: เปิด Terminal/CMD รัน `git clone <URL>`)*

### ขั้นตอนที่ 2: เปิด Roblox Studio และสร้าง Place

1. เปิด **Roblox Studio**
2. สร้างเกมใหม่ (File > New) หรือเปิดเกมที่มีอยู่
3. บันทึก Place ของคุณ (File > Save to Roblox / Save As)

### ขั้นตอนที่ 3: สร้างโครงสร้างและ Copy โค้ด

ทำตามลำดับนี้ทุกครั้ง ไม่สับสน:

#### ส่วนที่ 1: ReplicatedStorage (ModuleScript 4 ตัว)

1. คลิกขวาที่ **ReplicatedStorage** ใน Explorer → **Insert Object** → **ModuleScript**
2. เปลี่ยนชื่อ ModuleScript เป็น **CombatConfig**
3. ดับเบิลคลิกเปิด Script ใน Explorer
4. เปิดไฟล์ `ReplicatedStorage/CombatConfig.lua` จากโฟลเดอร์ที่ดาวน์โหลดมา
5. กด Ctrl+A เลือกโค้ดทั้งหมดในไฟล์นั้น แล้ว Ctrl+C Copy
6. กลับไปที่ Roblox Studio ลบโค้ดเดิมใน CombatConfig แล้ว Ctrl+V วาง
7. ทำซ้ำสำหรับ:
   - **VFXModule** ← โค้ดจาก `ReplicatedStorage/VFXModule.lua`
   - **AnimationModule** ← โค้ดจาก `ReplicatedStorage/AnimationModule.lua`
   - **CombatSystem** ← โค้ดจาก `ReplicatedStorage/CombatSystem.lua`

#### ส่วนที่ 2: ServerScriptService (Script 1 ตัว)

1. คลิกขวาที่ **ServerScriptService** → **Insert Object** → **Script**
2. เปลี่ยนชื่อเป็น **CombatHandler**
3. Copy โค้ดจาก `ServerScriptService/CombatHandler.lua` แล้ววางแทนโค้ดเดิม

#### ส่วนที่ 3: StarterPlayerScripts (LocalScript 2 ตัว)

1. ใน Explorer ไปที่ **StarterPlayer** → **StarterPlayerScripts**
2. คลิกขวา **StarterPlayerScripts** → **Insert Object** → **LocalScript**
3. เปลี่ยนชื่อเป็น **CombatInput**
4. Copy โค้ดจาก `StarterPlayer/StarterPlayerScripts/CombatInput.lua` แล้ววาง
5. สร้าง LocalScript อีกตัวชื่อ **CombatUI**
6. Copy โค้ดจาก `StarterPlayer/StarterPlayerScripts/CombatUI.lua` แล้ววาง

### ขั้นตอนที่ 4: ตรวจสอบและทดสอบ

1. ตรวจสอบว่าไม่มี Script ตัวใดพิมพ์ผิดหรือชื่อไม่ตรง
2. กด **Play** (F5) ทดสอบเกม
3. ถ้ามี Error ขึ้นสีแดงใน Output ให้อ่านข้อความแล้วดูหัวข้อ **5. วิธีแก้ไขปัญหา**

---

## 3. วิธีแก้ไข Animation ต่อย และ Damage การต่อย

แก้ไขทั้งหมดใน **CombatConfig** (ReplicatedStorage)

### Damage โจมตีธรรมดา

```lua
BasicAttackDamage = 10,   -- เปลี่ยนตัวเลขเป็นค่าที่ต้องการ
```

### แอนิเมชันต่อย (โจมตีธรรมดา)

ใส่ **AnimationId** หนึ่งอันหรือหลายอัน (ถ้าหลายอันจะสุ่มเล่น):

```lua
BasicAttackAnimationIds = {
	"rbxassetid://123456789",   -- แอนิเมชันต่อยที่ 1
	"rbxassetid://987654321",   -- แอนิเมชันต่อยที่ 2
	"rbxassetid://111222333",   -- แอนิเมชันต่อยที่ 3
},
```

- ใส่ `"rbxassetid://0"` = ไม่เล่นแอนิเมชัน
- หา AnimationId ได้จาก **Creator** > **Tools** > **Animation Editor** หรือ Catalog

### ความเร็วการต่อย (Cooldown)

```lua
BasicAttackCooldown = 0.5,   -- วินาที ระหว่างการต่อยแต่ละครั้ง
```

### ขนาด Hitbox การต่อย (ระยะและความกว้าง-สูง)

```lua
BasicAttackRange = 8,            -- ระยะโจมตี (studs)
BasicAttackHitboxWidth = 6,      -- ความกว้างกล่อง Hitbox
BasicAttackHitboxHeight = 6,     -- ความสูงกล่อง Hitbox
```

---

## 4. วิธีหา Dummy ใน Roblox Toolbox เพื่อทดสอบ Damage

Dummy คือ Model ที่มี Humanoid ใช้ทดสอบความเสียหายได้

### ขั้นตอน

1. ใน Roblox Studio กด **View** (เมนูบน) → เลือก **Toolbox** เพื่อเปิดแท็บ Toolbox
2. ในช่องค้นหา (Search) พิมพ์คำค้น เช่น:
   - `R15 Dummy` หรือ `R15 Rig`
   - `R6 Dummy` หรือ `R6 Rig`
   - `Training Dummy`
3. เลือก Model ที่มีคำว่า Dummy หรือ Rig จากรายการ
4. คลิกที่ Model แล้วลากวางใน **Workspace** ด้านหน้าตัวละคร
5. กด **Play** แล้วเดินเข้าใกล้ Dummy
6. คลิกซ้ายหรือกด **F** เพื่อโจมตีธรรมดา หรือกด **1, 2, 3, 4** เพื่อใช้สกิล

### หมายเหตุ

- Dummy ต้องมี **Humanoid** และ **HumanoidRootPart** ถึงจะโดนโจมตีได้
- ถ้า Dummy ไม่ลดเลือด เช็คว่า Dummy อยู่ใน **Workspace** และหันหน้าเข้าหาตัวละคร

---

## 5. วิธีแก้ไขปัญหา และ เปิดหน้า Output เพื่อดู Debug

### เปิด Output (หน้าต่าง Debug)

1. ใน Roblox Studio กด **View** (เมนูบน)
2. เลือก **Output**
3. หน้าต่าง Output จะแสดงด้านล่างหรือด้านข้าง
4. เลือกแท็บ **All** หรือ **Server** เพื่อดูข้อความ Debug

### เปิด Debug ในระบบ Combat

ใน **CombatConfig** ตั้งค่า:

```lua
EnableDebug = true,       -- แสดงข้อความเมื่อใช้สกิล/โจมตี
ShowHitboxDebug = true,  -- แสดงกล่อง Hitbox สีแดงเมื่อโจมตี (ใช้ตอนทดสอบ)
```

เมื่อกด Play แล้วใช้สกิลหรือโจมตี ข้อความจะแสดงใน Output

### ตารางข้อความ Debug และวิธีแก้

| ข้อความ Debug | สาเหตุ | วิธีแก้ |
|---------------|--------|---------|
| `กดปุ่มแล้วแต่ gameProcessed=true` | กดสกิลตอนพิมพ์/คลิก UI | ปิด Chat (กด ESC) ก่อนกด 1–4 หรือคลิกซ้าย |
| `ไม่มี Character` | ตัวละครยังไม่โหลด | รอสักครู่หลังกด Play |
| `Infinite yield on VFXModule` | ไม่มี VFXModule ใน ReplicatedStorage | สร้าง ModuleScript ชื่อ `VFXModule` แล้ว Copy โค้ด |
| `ไม่พบ CombatConfig` | ไม่มี CombatConfig | สร้าง ModuleScript ชื่อ `CombatConfig` ใน ReplicatedStorage |
| `Skill Bar จะไม่แสดง` | CombatConfig หายหรือผิดที่ | เช็ค CombatConfig ตามขั้นตอนที่ 2 |
| Server: `ยัง Cooldown` | กดสกิลก่อนจบ cooldown | รอเวลาตาม Cooldown |
| Server: `แมนาไม่พอ` | แมนาไม่เพียงพอ | รอให้แมนาเพิ่ม หรือตั้ง `UseMana = false` |
| `กด F แต่ไม่มีเป้า` | ไม่มีศัตรูในระยะ | เดินเข้าใกล้ Dummy หรือผู้เล่น — หรือใช้ได้เลย (ไม่บังคับมีเป้า) |

### ถ้า Debug ไม่ขึ้นเลย

1. เช็ค `EnableDebug = true` ใน CombatConfig
2. เช็ค CombatInput อยู่ใน **StarterPlayer** > **StarterPlayerScripts** (เป็น LocalScript)
3. กด 1 หรือคลิกซ้ายตอน **ปิด Chat**
4. เช็ค Output เลือกแท็บ **Server** หรือ **All**

---

## 6. วิธีแก้ไขและสร้าง Skill

### ตารางคีย์และการกระทำ

| คีย์ | การกระทำ |
|------|----------|
| **คลิกซ้าย** / **F** | โจมตีธรรมดา |
| **1** | สกิลที่ 1 – ทุบแรง |
| **2** | สกิลที่ 2 – วาร์ปโจมตี |
| **3** | สกิลที่ 3 – หมุนตัด |
| **4** | สกิล Ulti |

### แก้ไขสกิลเดิม

เปิด **CombatConfig** แล้วหาตาราง `Skills` แก้ไขค่าต่างๆ ในแต่ละสกิล:

```lua
["HeavyStrike"] = {
	DisplayName = "ทุบแรง",      -- ชื่อที่แสดง
	Keybind = Enum.KeyCode.One,  -- ปุ่มกด
	Cooldown = 3,                -- วินาทีรอใช้ซ้ำ
	Damage = 35,                  -- ความเสียหาย
	Range = 12,                   -- ระยะโจมตี (studs)
	HitboxWidth = 8,              -- ความกว้าง Hitbox
	HitboxHeight = 8,             -- ความสูง Hitbox
	ManaCost = 15,                -- แมนาที่ใช้ (ถ้า UseMana = true)
	CastTime = 0.2,
	VFXId = "rbxassetid://0",
	AnimationId = "rbxassetid://0",
},
```

### สร้างสกิลใหม่

1. Copy block ด้านล่างไปวางใน `Skills = { ... }`
2. เปลี่ยนค่าตามต้องการ

```lua
["ชื่อId"] = {
	DisplayName = "ชื่อที่แสดง",
	Keybind = Enum.KeyCode.Q,   -- Q, E, R ได้
	Cooldown = 5,
	Damage = 50,
	Range = 15,
	HitboxWidth = 8,
	HitboxHeight = 8,
	ManaCost = 20,
	CastTime = 0.3,
	VFXId = "rbxassetid://0",
	AnimationId = "rbxassetid://0",
},
```

**กฎสำคัญ**

- **ชื่อId** ใช้ภาษาอังกฤษ ไม่ซ้ำกัน
- **Keybind** ห้ามซ้ำกันระหว่างสกิล
- ลบสกิล = ลบทั้ง block ออก

---

## 7. วิธีเพิ่ม VFX

### ตั้งค่าใน CombatConfig

```lua
EnableVFX = true,   -- เปิดเอฟเฟกต์ (false = ปิด)
```

ใส่ `VFXId` ในแต่ละสกิล:

```lua
["HeavyStrike"] = {
	-- ...
	VFXId = "rbxassetid://123456789",   -- ไอดี Effect จาก Catalog
},
```

### หา VFX / Effect ใน Roblox

1. ไปที่ **Create** > **Toolbox** หรือใช้ **Marketplace**
2. ค้นหา "Effect", "Particle", "Slash" ฯลฯ
3. ใช้ Asset ที่มี AssetId แล้วใส่ในรูปแบบ `"rbxassetid://xxxxx"`

### แก้ไข Logic VFX เอง

ถ้าต้องการลูกเล่นพิเศษ แก้ใน **VFXModule.lua** (ReplicatedStorage):

- ฟังก์ชัน `PlaySkillEffect(caster, skillId, targetPosition)` — เล่นเอฟเฟกต์เมื่อใช้สกิล
- ฟังก์ชัน `PlayAtPosition(position, effectType, duration)` — แสดงเอฟเฟกต์ที่จุดใดจุดหนึ่ง
- ฟังก์ชัน `ShowHitboxBox` — แสดงกล่อง Hitbox ตอน Debug (ถ้าเปิด)

---

## หมายเหตุ

- รองรับทั้ง **Player** และ **Dummy/NPC** (Model ใน Workspace ที่มี Humanoid) เป็นเป้า
- ระบบใช้ **Hitbox** โจมตีด้านหน้าตัวละคร ไม่ต้อง lock-on เป้า
- แมนาเพิ่มอัตโนมัติ ~0.05 ต่อวินาที แก้ได้ที่ `CombatHandler.lua` บรรทัด `setMana(plr, cur + 0.05)`

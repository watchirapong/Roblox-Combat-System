# Roblox Combat System + สกิล

ระบบต่อสู้พร้อมสกิลหลายแบบ มี Option ให้เปิด-ปิด VFX ได้ตามชอบ

---

## การติดตั้ง

### โครงสร้างโฟลเดอร์ (เหมือน Roblox Explorer)

```
ReplicatedStorage/
├── CombatConfig.lua
├── VFXModule.lua
├── AnimationModule.lua
└── CombatSystem.lua

ServerScriptService/
└── CombatHandler.lua

StarterPlayer/
└── StarterPlayerScripts/
    ├── CombatInput.lua
    └── CombatUI.lua
```

### วิธี Copy เข้า Roblox Studio

1. สร้าง **ModuleScript** ใน **ReplicatedStorage** 4 ตัว:
   - `CombatConfig` → โค้ดจาก `ReplicatedStorage/CombatConfig.lua`
   - `VFXModule` → โค้ดจาก `ReplicatedStorage/VFXModule.lua`
   - `AnimationModule` → โค้ดจาก `ReplicatedStorage/AnimationModule.lua`
   - `CombatSystem` → โค้ดจาก `ReplicatedStorage/CombatSystem.lua`

2. สร้าง **Script** ใน **ServerScriptService**:
   - `CombatHandler` → โค้ดจาก `ServerScriptService/CombatHandler.lua`

3. สร้าง **LocalScript** ใน **StarterPlayer** > **StarterPlayerScripts** 2 ตัว:
   - `CombatInput` → โค้ดจาก `StarterPlayer/StarterPlayerScripts/CombatInput.lua`
   - `CombatUI` → โค้ดจาก `StarterPlayer/StarterPlayerScripts/CombatUI.lua`

---

## วิธีใส่ Animation และ VFX ให้กับสกิล

คุณสามารถกำหนด Animation กับ VFX สำหรับแต่ละสกิลในไฟล์ `CombatConfig.lua` ได้เลย โดยกำหนด `AnimationId` และ `VFXId` ในแต่ละสกิล เช่น:

```lua
["MySkill"] = {
    DisplayName = "หมัดสายฟ้า",
    Keybind = Enum.KeyCode.Q,
    Cooldown = 5,
    Damage = 80,
    Range = 10,
    ManaCost = 20,
    CastTime = 0.3,
    VFXId = "rbxassetid://1234567", -- ไอดี Effect (Particle/Asset อื่น)
    AnimationId = "rbxassetid://7654321", -- ไอดี Animation
},
```

### วิธีเพิ่ม Animation

1. อัปโหลด Animation เข้า Roblox เพื่อรับ AssetId (`rbxassetid://...`)  
2. ใส่ค่า `AnimationId` ในแต่ละสกิลตามตัวอย่างด้านบน

`AnimationModule.lua` ใน `ReplicatedStorage` จะรับผิดชอบเปลี่ยน Animation เมื่อตัวละครใช้สกิล  
ไฟล์นี้รองรับฟังก์ชัน `PlaySkillAnimation(character, skillId)` และ `PlayBasicAttackAnimation(character)`  
แค่ใส่ `AnimationId` ให้แต่ละสกิลใน `CombatConfig.lua` แล้วระบบจะเล่นอัตโนมัติเมื่อใช้สกิล

### วิธีเพิ่ม VFX (Effects)

1. สร้างหรือหา Effect ที่ต้องการ แล้วอัปโหลด/วางใน Assets เพื่อรับ `rbxassetid://...`
2. ใส่ค่า `VFXId` ให้แต่ละสกิลเหมือนตัวอย่างบน

`VFXModule.lua` ใน `ReplicatedStorage` จะรับผิดชอบเล่น Effect  
ฟังก์ชันหลักคือ `PlaySkillEffect(character, skillId, targetPos)`  
ถ้าใส่/เปลี่ยน `VFXId` ใน Config ก็จะเล่น Effect ตามนั้นอัตโนมัติ

#### หมายเหตุ:
- ไฟล์ตัวอย่าง (`VFXModule.lua`, `AnimationModule.lua`) ต้องปรับเองให้รองรับ AssetId ด้วย
- ระบบนี้แยก Load/Cache Animation, Effect ให้อยู่แล้ว แค่ใส่ Id ลงใน `CombatConfig.lua` สำหรับแต่ละสกิลก็ใช้งานได้ทันที
- ในโค้ดสามารถเพิ่ม/แก้ไขการเล่น Animation หรือ Effect เพิ่มเติมได้เองหากต้องการลูกเล่นพิเศษ




## การตั้งค่า

เปิด `CombatConfig.lua`:

```lua
EnableVFX = true,    -- เปิด/ปิดเอฟเฟกต์
EnableDebug = true,  -- แสดงข้อความใน Output (ตั้ง false ตอนปล่อยเกม)
UseMana = false,     -- false = ไม่ใช้แมนา, true = หักแมนาตอนใช้สกิล
EnableSkillUI = true,  -- แสดง Skill Bar ด้านล่างจอ
```

---

## การใช้งาน

| คีย์ | การกระทำ |
|------|----------|
| **1** | สกิลที่ 1 – ทุบแรง |
| **2** | สกิลที่ 2 – วาร์ปโจมตี |
| **3** | สกิลที่ 3 – หมุนตัด |
| **4** | สกิล Ulti |
| **F** | โจมตีธรรมดา |

ระบบจะโจมตีศัตรูที่อยู่ใกล้ที่สุดอัตโนมัติ

---

## สกิล

### สร้างสกิลใหม่

ไปที่ `CombatConfig.lua` ในตาราง `Skills` — Copy block นี้ไปวางแล้วเปลี่ยนค่า:

```lua
["ชื่อId"] = {
    DisplayName = "ชื่อที่แสดง",
    Keybind = Enum.KeyCode.Q,
    Cooldown = 5,
    Damage = 50,
    Range = 15,
    ManaCost = 20,
    CastTime = 0.3,
    VFXId = "rbxassetid://0",
    AnimationId = "rbxassetid://0",
},
```

ตัวอย่าง:

```lua
["Fireball"] = {
    DisplayName = "ลูกไฟ",
    Keybind = Enum.KeyCode.Q,
    Cooldown = 4,
    Damage = 40,
    Range = 20,
    ManaCost = 25,
    CastTime = 0.2,
    VFXId = "rbxassetid://0",
    AnimationId = "rbxassetid://0",
},
```

- **ชื่อId** ต้องไม่ซ้ำ ใช้ภาษาอังกฤษ
- **Keybind** ห้ามซ้ำกัน
- ลบสกิล = ลบทั้ง block ออก

### Animation

- **BasicAttackAnimationId** — แอนิเมชันโจมตีธรรมดา (กด F)
- **AnimationId** — แอนิเมชันตอนใช้สกิล (ในแต่ละสกิล)

ใส่ ID จาก Roblox Catalog เช่น `"rbxassetid://123456789"`  
ใส่ `"rbxassetid://0"` = ไม่เล่นแอนิเมชัน

### แมนา

ใช้ได้เมื่อ `UseMana = true`  
แมนาเพิ่มทีละนิด (ประมาณ 0.05 ต่อวินาที) สูงสุด 100  
แก้ไข rate ได้ที่ `CombatHandler.lua` บรรทัด `setMana(player, current + 0.05)`

---

## Debug + แก้ปัญหา

ตั้ง `EnableDebug = true` แล้วกด Play — เปิด **Output** (View > Output) ข้อความจะแสดงที่แท็บ **Server**

### ข้อความที่เจอและวิธีแก้

| ข้อความ Debug | สาเหตุ | วิธีแก้ |
|---------------|--------|---------|
| `กดปุ่มแล้วแต่ gameProcessed=true` | กดสกิลตอนพิมพ์อยู่ | ปิด Chat (กด ESC หรือคลิกนอกช่องพิมพ์) ก่อนกด 1–4 หรือ F |
| `ผู้เล่นน้อยกว่า 2 คน (1)` | เล่นคนเดียว | เปิด Test > Players = 2 ขึ้นไป หรือให้คนอื่นเข้าเกม |
| `ไม่มีศัตรูในระยะ X studs` | ศัตรูอยู่ไกลเกินไป | เดินเข้าไปให้ใกล้ศัตรูก่อนใช้สกิล |
| `มีสกิลแต่ไม่มีเป้า` | ไม่มีผู้เล่นอื่นหรือศัตรู | ต้องมีผู้เล่น 2 คนขึ้นไป และให้ศัตรูอยู่ใน Range ของสกิล |
| `กด F แต่ไม่มีเป้า` | เหมือนด้านบน | เดินเข้าใกล้ศัตรู หรือเช็คว่ามีผู้เล่นอื่นในเกม |
| `ไม่มี Character` | ตัวละครยังไม่โหลด | รอสักครู่หลังกด Play แล้วลองใหม่ |
| `Infinite yield on VFXModule` | ยังไม่มี VFXModule ใน ReplicatedStorage | สร้าง ModuleScript ชื่อ `VFXModule` แล้ววางโค้ดจาก `src/shared/VFXModule.lua` |
| `ไม่พบ CombatConfig` | ยังไม่มี CombatConfig | สร้าง ModuleScript ชื่อ `CombatConfig` ใน ReplicatedStorage |
| `Skill Bar จะไม่แสดง` | CombatConfig หายหรือผิดที่ | สร้าง CombatConfig ตามขั้นตอนการติดตั้ง |
| Server: `ไกลเกินไป ระยะ=X ต้องไม่เกิน Y` | ศัตรูไกลเกิน Range ของสกิล | เดินเข้าใกล้ขึ้น |
| Server: `ยัง Cooldown` | กดสกิลก่อนจบ cooldown | รอเวลาตาม Cooldown ของสกิล |
| Server: `แมนาไม่พอ` | แมนาไม่เพียงพอ | รอให้แมนาเพิ่ม หรือตั้ง `UseMana = false` ใน Config |
| Server: `เป้าตาย` | เป้ากำลังตายหรือตายแล้ว | เลือกเป้าอื่น |

### ถ้า Debug ไม่ขึ้นเลย

1. เช็ค `EnableDebug = true` ใน CombatConfig
2. เช็คว่า CombatInput อยู่ใน **StarterPlayer** > **StarterPlayerScripts** (เป็น LocalScript)
3. เช็คว่ากด 1 ตอน **ปิด Chat** (ไม่มีการพิมพ์ในช่องข้อความ)
4. เช็ค Output ว่าเลือกแท็บ **Server** หรือ **All**

---

## หมายเหตุ

- เกมต้องมี Players มากกว่า 1 คน ถึงจะโจมตีได้
- VFX แบบพื้นฐาน — ถ้าอยากใส่ Particle หรือ Effect เฉพาะ แก้ใน `VFXModule.lua` ได้

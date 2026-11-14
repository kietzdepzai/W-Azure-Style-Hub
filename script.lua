--// W-Azure Style Hub - Optimized Attack Speed
-- Tele trên đầu quái + chọn vũ khí + đánh siêu nhanh

getgenv().AutoFarm = false
getgenv().BringMob = true
getgenv().SelectedWeapon = "Melee" -- Melee, Sword, Fruit, Gun
getgenv().FarmHeight = 18
getgenv().AttackSpeed = 0.015     -- Rất nhanh

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "W-Azure Style Hub",
    SubTitle = "Optimized Attack",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 420),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Main Farm", Icon = "swords" })
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "user" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

local Options = Fluent.Options

-- Services
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Tìm quái gần nhất còn sống
local function GetClosestMob()
    local root = GetRoot()
    if not root then return nil end

    local closest, minDist = nil, math.huge
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    for _, mob in ipairs(enemies:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local dist = (root.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = mob
            end
        end
    end
    return closest
end

-- Equip vũ khí theo loại đã chọn
local function EquipWeapon()
    local char = GetCharacter()
    if not char then return end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    local weaponType = getgenv().SelectedWeapon

    local function isCorrectType(tool)
        if not tool:IsA("Tool") then return false end
        local name = tool.Name:lower()

        if weaponType == "Melee" then
            return name:find("combat") or name:find("melee") or name:find("fist") or name == "combat"
        elseif weaponType == "Sword" then
            return tool:FindFirstChild("Sword") or name:find("sword") or name:find("blade") or name:find("cutlass") or name:find("katana")
        elseif weaponType == "Fruit" then
            return tool:FindFirstChild("Fruit") or name:find("fruit") or name:find("power")
        elseif weaponType == "Gun" then
            return tool:FindFirstChild("Gun") or name:find("gun") or name:find("pistol") or name:find("rifle")
        end
        return false
    end

    local current = char:FindFirstChildOfClass("Tool")
    if current and isCorrectType(current) then return end

    for _, tool in ipairs(backpack:GetChildren()) do
        if isCorrectType(tool) then
            pcall(function()
                GetHumanoid():EquipTool(tool)
            end)
            return
        end
    end
end

-- ==================== FAST ATTACK TỐI ƯU ====================
local attacking = false

local function StartFastAttack()
    if attacking then return end
    attacking = true

    task.spawn(function()
        while getgenv().AutoFarm and attacking do
            local char = GetCharacter()
            local tool = char and char:FindFirstChildOfClass("Tool")

            if tool then
                -- Spam Activate nhiều lần
                for i = 1, 3 do
                    pcall(function()
                        tool:Activate()
                    end)
                end
            end

            -- Click backup
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end)

            task.wait(getgenv().AttackSpeed)
        end
        attacking = false
    end)
end

local function StopFastAttack()
    attacking = false
end

-- ==================== MAIN FARM ====================
MainTab:AddParagraph({
    Title = "Farm kiểu W-Azure",
    Content = "Bay trên đầu quái + chọn vũ khí + đánh siêu nhanh"
})

MainTab:AddDropdown("WeaponType", {
    Title = "Chọn vũ khí",
    Values = {"Melee", "Sword", "Fruit", "Gun"},
    Multi = false,
    Default = "Melee"
}):OnChanged(function(Value)
    getgenv().SelectedWeapon = Value
end)

MainTab:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
}):OnChanged(function(Value)
    getgenv().AutoFarm = Value

    if Value then
        StartFastAttack() -- Bật spam đánh riêng

        task.spawn(function()
            while getgenv().AutoFarm do
                local root = GetRoot()
                local mob = GetClosestMob()

                if root and mob and mob:FindFirstChild("HumanoidRootPart") then
                    local mobHRP = mob.HumanoidRootPart
                    local mobHum = mob:FindFirstChildOfClass("Humanoid")

                    if mobHum and mobHum.Health > 0 then
                        EquipWeapon()

                        -- Gom quái
                        if getgenv().BringMob then
                            pcall(function()
                                mobHRP.CFrame = root.CFrame * CFrame.new(0, -getgenv().FarmHeight + 2.5, 0)
                                mobHRP.AssemblyLinearVelocity = Vector3.zero
                                mobHRP.AssemblyAngularVelocity = Vector3.zero
                            end)
                        end

                        -- Bay trên đầu quái
                        root.CFrame = mobHRP.CFrame * CFrame.new(0, getgenv().FarmHeight, 0)
                    end
                end

                task.wait(0.03) -- Vòng lặp vị trí
            end
            StopFastAttack()
        end)
    else
        StopFastAttack()
    end
end)

MainTab:AddToggle("BringMob", {
    Title = "Gom Quái (Bring Mob)",
    Default = true
}):OnChanged(function(Value)
    getgenv().BringMob = Value
end)

-- ==================== SETTINGS ====================
SettingsTab:AddSlider("FarmHeight", {
    Title = "Độ cao bay trên đầu quái",
    Default = 18,
    Min = 6,
    Max = 35,
    Rounding = 0
}):OnChanged(function(Value)
    getgenv().FarmHeight = Value
end)

SettingsTab:AddSlider("AttackSpeed", {
    Title = "Tốc độ đánh (càng nhỏ càng nhanh)",
    Default = 0.015,
    Min = 0.005,
    Max = 0.08,
    Rounding = 3
}):OnChanged(function(Value)
    getgenv().AttackSpeed = Value
end)

-- ==================== PLAYER ====================
PlayerTab:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0
}):OnChanged(function(Value)
    pcall(function()
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = Value end
    end)
end)

PlayerTab:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 250,
    Rounding = 0
}):OnChanged(function(Value)
    pcall(function()
        local hum = GetHumanoid()
        if hum then hum.JumpPower = Value end
    end)
end)

Fluent:Notify({
    Title = "W-Azure Style Hub",
    Content = "Đã tối ưu tốc độ đánh!",
    Duration = 4
})

print("[W-Azure Style] Optimized Attack loaded")

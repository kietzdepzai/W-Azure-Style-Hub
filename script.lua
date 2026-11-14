--// W-Azure Style Hub - Improved Farm
-- Tele trên đầu quái + chọn vũ khí + đánh nhanh

getgenv().AutoFarm = false
getgenv().BringMob = true
getgenv().SelectedWeapon = "Melee" -- Melee, Sword, Fruit, Gun
getgenv().FarmHeight = 20          -- Độ cao bay trên đầu quái
getgenv().AttackSpeed = 0.03      -- Càng nhỏ càng đánh nhanh

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "W-Azure Style Hub",
    SubTitle = "Improved Farm",
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

    -- Ưu tiên tìm tool đang cầm hoặc trong backpack
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

    -- Nếu đang cầm đúng loại rồi thì thôi
    local current = char:FindFirstChildOfClass("Tool")
    if current and isCorrectType(current) then return end

    -- Tìm trong backpack
    for _, tool in ipairs(backpack:GetChildren()) do
        if isCorrectType(tool) then
            pcall(function()
                GetHumanoid():EquipTool(tool)
            end)
            return
        end
    end
end

-- Đánh siêu nhanh
local function FastAttack()
    pcall(function()
        local char = GetCharacter()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        -- Backup click
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end

-- ==================== MAIN FARM ====================
MainTab:AddParagraph({
    Title = "Farm kiểu W-Azure",
    Content = "Bay trên đầu quái + chọn vũ khí + đánh nhanh"
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
        task.spawn(function()
            while getgenv().AutoFarm do
                local root = GetRoot()
                local mob = GetClosestMob()

                if root and mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChildOfClass("Humanoid") then
                    local mobHRP = mob.HumanoidRootPart
                    local mobHum = mob:FindFirstChildOfClass("Humanoid")

                    if mobHum.Health > 0 then
                        -- Equip vũ khí đã chọn
                        EquipWeapon()

                        -- Gom quái (kéo về gần dưới chân)
                        if getgenv().BringMob then
                            pcall(function()
                                mobHRP.CFrame = root.CFrame * CFrame.new(0, -getgenv().FarmHeight + 3, 0)
                                mobHRP.AssemblyLinearVelocity = Vector3.zero
                                mobHRP.AssemblyAngularVelocity = Vector3.zero
                            end)
                        end

                        -- Bay lên trên đầu quái
                        root.CFrame = mobHRP.CFrame * CFrame.new(0, getgenv().FarmHeight, 0)

                        -- Đánh nhanh
                        FastAttack()
                    end
                end

                task.wait(getgenv().AttackSpeed)
            end
        end)
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
    Default = 20,
    Min = 8,
    Max = 40,
    Rounding = 0
}):OnChanged(function(Value)
    getgenv().FarmHeight = Value
end)

SettingsTab:AddSlider("AttackSpeed", {
    Title = "Tốc độ đánh (càng nhỏ càng nhanh)",
    Default = 0.03,
    Min = 0.01,
    Max = 0.15,
    Rounding = 2
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
    Content = "Đã cập nhật Farm kiểu trên đầu quái!",
    Duration = 5
})

print("[W-Azure Style] Improved Farm loaded")

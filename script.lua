--// W-Azure Style Hub - Hitbox Expander
getgenv().AutoFarm = false
getgenv().BringMob = true
getgenv().SelectedWeapon = "Melee"
getgenv().FarmHeight = 10
getgenv().AttackSpeed = 0.02
getgenv().HitboxSize = 8          -- Kích thước hitbox
getgenv().EnableHitbox = true

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "W-Azure Style Hub",
    SubTitle = "Hitbox + Farm",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Main Farm", Icon = "swords" })
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "user" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

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

-- Equip vũ khí
local function EquipWeapon()
    local char = GetCharacter()
    local hum = GetHumanoid()
    if not char or not hum then return end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    local weaponType = getgenv().SelectedWeapon

    local function match(tool)
        if not tool:IsA("Tool") then return false end
        local n = tool.Name:lower()
        if weaponType == "Melee" then
            return n:find("combat") or n == "combat" or n:find("fist") or n:find("melee")
        elseif weaponType == "Sword" then
            return tool:FindFirstChild("Sword") or n:find("sword") or n:find("blade") or n:find("cutlass") or n:find("katana") or n:find("saber")
        elseif weaponType == "Fruit" then
            return tool:FindFirstChild("Fruit") or n:find("fruit") or n:find("power") or n:find("bomb") or n:find("flame") or n:find("ice") or n:find("light") or n:find("dark") or n:find("magma") or n:find("quake") or n:find("buddha") or n:find("phoenix") or n:find("dragon")
        elseif weaponType == "Gun" then
            return tool:FindFirstChild("Gun") or n:find("gun") or n:find("pistol") or n:find("rifle") or n:find("cannon")
        end
        return false
    end

    local holding = char:FindFirstChildOfClass("Tool")
    if holding and match(holding) then return true end

    for _, tool in ipairs(backpack:GetChildren()) do
        if match(tool) then
            pcall(function()
                hum:EquipTool(tool)
            end)
            return true
        end
    end
    return false
end

-- Tăng hitbox vũ khí
local function ExpandHitbox()
    if not getgenv().EnableHitbox then return end

    local char = GetCharacter()
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local size = getgenv().HitboxSize

    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.Size = Vector3.new(size, size, size)
                part.Transparency = 1
                part.CanCollide = false
                part.Massless = true
            end)
        end
    end
end

-- Hàm đánh
local function DoAttack()
    local char = GetCharacter()
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function()
            tool:Activate()
        end)
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end

-- ==================== UI ====================
MainTab:AddParagraph({
    Title = "Farm + Hitbox",
    Content = "Bay trên đầu + tăng hitbox + tự động đánh"
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

                if root and mob then
                    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                    local mobHum = mob:FindFirstChildOfClass("Humanoid")

                    if mobHRP and mobHum and mobHum.Health > 0 then
                        EquipWeapon()
                        ExpandHitbox()

                        local height = getgenv().FarmHeight

                        -- Bay trên đầu
                        root.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, height, 0))
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero

                        -- Gom quái
                        if getgenv().BringMob then
                            pcall(function()
                                mobHRP.CFrame = CFrame.new(root.Position.X, root.Position.Y - height + 1, root.Position.Z)
                                mobHRP.AssemblyLinearVelocity = Vector3.zero
                                mobHRP.AssemblyAngularVelocity = Vector3.zero
                            end)
                        end

                        DoAttack()
                    end
                end

                task.wait(0.03)
            end
        end)

        -- Spam đánh
        task.spawn(function()
            while getgenv().AutoFarm do
                DoAttack()
                task.wait(getgenv().AttackSpeed)
            end
        end)
    end
end)

MainTab:AddToggle("BringMob", {
    Title = "Gom Quái",
    Default = true
}):OnChanged(function(Value)
    getgenv().BringMob = Value
end)

MainTab:AddToggle("EnableHitbox", {
    Title = "Tăng Hitbox",
    Default = true
}):OnChanged(function(Value)
    getgenv().EnableHitbox = Value
end)

-- Settings
SettingsTab:AddSlider("FarmHeight", {
    Title = "Độ cao trên đầu quái",
    Default = 10,
    Min = 4,
    Max = 25,
    Rounding = 0
}):OnChanged(function(Value)
    getgenv().FarmHeight = Value
end)

SettingsTab:AddSlider("HitboxSize", {
    Title = "Kích thước Hitbox",
    Default = 8,
    Min = 3,
    Max = 25,
    Rounding = 0
}):OnChanged(function(Value)
    getgenv().HitboxSize = Value
end)

SettingsTab:AddSlider("AttackSpeed", {
    Title = "Tốc độ đánh (càng nhỏ càng nhanh)",
    Default = 0.02,
    Min = 0.008,
    Max = 0.1,
    Rounding = 3
}):OnChanged(function(Value)
    getgenv().AttackSpeed = Value
end)

-- Player
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
    Content = "Đã thêm Tăng Hitbox",
    Duration = 4
})

print("[W-Azure Style] Hitbox Expander loaded")

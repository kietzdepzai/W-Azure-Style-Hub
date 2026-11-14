--// W-Azure Style Hub - Stable Rewrite
-- Fix: quái không còn bị kéo bay lên trời

getgenv().AutoFarm = false
getgenv().BringMob = true
getgenv().SelectedWeapon = "Melee"
getgenv().FarmHeight = 10
getgenv().AttackSpeed = 0.025

local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not Fluent then
    warn("[W-Azure Style] Không load được UI")
    return
end

local Window = Fluent:CreateWindow({
    Title = "W-Azure Style Hub",
    SubTitle = "Stable Farm",
    TabWidth = 150,
    Size = UDim2.fromOffset(480, 400),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Main Farm", Icon = "swords" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local function GetChar()
    return LocalPlayer.Character
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetClosestMob()
    local root = GetRoot()
    if not root then return nil end

    local closest, dist = nil, math.huge
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end

    for _, mob in ipairs(folder:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local d = (root.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                closest = mob
            end
        end
    end
    return closest
end

local function EquipWeapon()
    local char = GetChar()
    local hum = GetHum()
    if not char or not hum then return end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    local wtype = getgenv().SelectedWeapon

    local function isMatch(tool)
        if not tool:IsA("Tool") then return false end
        local n = string.lower(tool.Name)
        if wtype == "Melee" then
            return n:find("combat") or n == "combat"
        elseif wtype == "Sword" then
            return n:find("sword") or n:find("blade") or n:find("cutlass") or n:find("katana") or n:find("saber") or tool:FindFirstChild("Sword")
        elseif wtype == "Fruit" then
            return n:find("fruit") or tool:FindFirstChild("Fruit")
        elseif wtype == "Gun" then
            return n:find("gun") or n:find("pistol") or n:find("rifle") or tool:FindFirstChild("Gun")
        end
        return false
    end

    local holding = char:FindFirstChildOfClass("Tool")
    if holding and isMatch(holding) then return end

    for _, t in ipairs(backpack:GetChildren()) do
        if isMatch(t) then
            pcall(function() hum:EquipTool(t) end)
            break
        end
    end
end

local function Attack()
    local char = GetChar()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end

-- ==================== UI ====================
MainTab:AddParagraph({
    Title = "Stable Farm",
    Content = "Bay trên đầu quái + gom đúng cách"
})

MainTab:AddDropdown("Weapon", {
    Title = "Vũ khí",
    Values = {"Melee", "Sword", "Fruit", "Gun"},
    Multi = false,
    Default = "Melee"
}):OnChanged(function(v)
    getgenv().SelectedWeapon = v
end)

MainTab:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
}):OnChanged(function(Value)
    getgenv().AutoFarm = Value

    if not Value then return end

    -- Vòng di chuyển + vị trí
    task.spawn(function()
        while getgenv().AutoFarm do
            local root = GetRoot()
            local mob = GetClosestMob()

            if root and mob then
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                local hum = mob:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    EquipWeapon()

                    local height = getgenv().FarmHeight
                    local mobPos = hrp.Position

                    -- 1. Đặt nhân vật trên đầu quái (dùng vị trí gốc của quái)
                    local playerPos = Vector3.new(mobPos.X, mobPos.Y + height, mobPos.Z)
                    root.CFrame = CFrame.new(playerPos)
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero

                    -- 2. Kéo quái về dưới chân (giữ Y gần bằng Y gốc của quái)
                    if getgenv().BringMob then
                        pcall(function()
                            local underPos = Vector3.new(playerPos.X, mobPos.Y, playerPos.Z)
                            hrp.CFrame = CFrame.new(underPos)
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end)
                    end
                end
            end

            task.wait(0.03)
        end
    end)

    -- Vòng đánh riêng
    task.spawn(function()
        while getgenv().AutoFarm do
            Attack()
            task.wait(getgenv().AttackSpeed)
        end
    end)
end)

MainTab:AddToggle("BringMob", {
    Title = "Gom Quái",
    Default = true
}):OnChanged(function(v)
    getgenv().BringMob = v
end)

-- Settings
SettingsTab:AddSlider("Height", {
    Title = "Độ cao trên đầu",
    Default = 10,
    Min = 5,
    Max = 20,
    Rounding = 0
}):OnChanged(function(v)
    getgenv().FarmHeight = v
end)

SettingsTab:AddSlider("Speed", {
    Title = "Tốc độ đánh",
    Default = 0.025,
    Min = 0.01,
    Max = 0.08,
    Rounding = 3
}):OnChanged(function(v)
    getgenv().AttackSpeed = v
end)

Fluent:Notify({
    Title = "W-Azure Style",
    Content = "Stable version loaded",
    Duration = 4
})

print("[W-Azure Style] Stable Rewrite loaded")

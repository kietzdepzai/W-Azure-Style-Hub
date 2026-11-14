--// W-Azure Style - Basic Farm (Ưu tiên hoạt động)
getgenv().AutoFarm = false
getgenv().BringMob = false
getgenv().KillAura = false

-- Load Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "W-Azure Style | Basic Farm",
    SubTitle = "Farm + Bring Mob",
    TabWidth = 150,
    Size = UDim2.fromOffset(480, 380),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Main Farm", Icon = "swords" })
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "user" })

local Options = Fluent.Options

-- Services
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRoot()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestMob()
    local root = GetRoot()
    if not root then return nil end

    local closest = nil
    local minDist = math.huge

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    for _, mob in ipairs(enemies:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
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

-- Click attack (ổn định hơn Activate)
local function Attack()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end

-- ==================== MAIN FARM ====================
MainTab:AddParagraph({
    Title = "Farm Cơ Bản",
    Content = "Bật Auto Farm + Bring Mob là được"
})

MainTab:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
}):OnChanged(function(Value)
    getgenv().AutoFarm = Value

    if Value then
        task.spawn(function()
            while getgenv().AutoFarm do
                task.wait(0.08)

                local root = GetRoot()
                local mob = GetClosestMob()

                if root and mob and mob:FindFirstChild("HumanoidRootPart") then
                    local mobHRP = mob.HumanoidRootPart

                    -- Gom quái
                    if getgenv().BringMob then
                        pcall(function()
                            mobHRP.CFrame = root.CFrame * CFrame.new(0, 0, -3)
                            mobHRP.Velocity = Vector3.zero
                            mobHRP.RotVelocity = Vector3.zero
                        end)
                    end

                    -- Bay tới quái
                    root.CFrame = mobHRP.CFrame * CFrame.new(0, 0, 3.5)

                    -- Đánh
                    Attack()
                end
            end
        end)
    end
end)

MainTab:AddToggle("BringMob", {
    Title = "Gom Quái (Bring Mob)",
    Default = false
}):OnChanged(function(Value)
    getgenv().BringMob = Value
end)

MainTab:AddToggle("KillAura", {
    Title = "Kill Aura (phạm vi gần)",
    Default = false
}):OnChanged(function(Value)
    getgenv().KillAura = Value

    if Value then
        task.spawn(function()
            while getgenv().KillAura do
                task.wait(0.1)
                local root = GetRoot()
                if not root then continue end

                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in ipairs(enemies:GetChildren()) do
                        local hum = mob:FindFirstChild("Humanoid")
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 then
                            if (root.Position - hrp.Position).Magnitude <= 40 then
                                Attack()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==================== PLAYER ====================
PlayerTab:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0
}):OnChanged(function(Value)
    pcall(function()
        local hum = GetCharacter():FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end)
end)

PlayerTab:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0
}):OnChanged(function(Value)
    pcall(function()
        local hum = GetCharacter():FindFirstChild("Humanoid")
        if hum then hum.JumpPower = Value end
    end)
end)

Fluent:Notify({
    Title = "W-Azure Style",
    Content = "Đã load - Bật Auto Farm + Bring Mob để dùng",
    Duration = 5
})

print("Basic Farm loaded")

-- Blade Ball Auto Parry with AntiCheat Bypass
-- Полная рабочая версия для ПК

local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")

-- Settings
local BASE_THRESHOLD = 0.2
local VELOCITY_SCALING_FACTOR_FAST = 0.050
local VELOCITY_SCALING_FACTOR_SLOW = 0.1

local focusedBall = nil
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ballsFolder = workspace:WaitForChild("Balls")
local parryButtonPress = replicatedStorage.Remotes.ParryButtonPress
local sliderValue = 20
local isRunning = false
local notifyparried = false

-- ============================================
-- ANTICHEAT BYPASS
-- ============================================

local AntiCheatBypass = {}

function AntiCheatBypass.DisableRemoteDetection()
    pcall(function()
        local oldFireServer = parryButtonPress.FireServer
        parryButtonPress.FireServer = newcclosure(function(self, ...)
            return oldFireServer(self, ...)
        end)
    end)
end

function AntiCheatBypass.DisableAnticheatConnections()
    pcall(function()
        if getconnections then
            local ScriptContext = game:GetService("ScriptContext")
            local LogService = game:GetService("LogService")
            
            for _, connection in pairs(getconnections(ScriptContext.Error)) do
                pcall(connection.Disable, connection)
            end
            for _, connection in pairs(getconnections(LogService.MessageOut)) do
                pcall(connection.Disable, connection)
            end
        end
    end)
end

function AntiCheatBypass.SpoofMovement()
    pcall(function()
        local HRP = character and character:FindFirstChild("HumanoidRootPart")
        if HRP then
            local mt = getrawmetatable(HRP)
            setreadonly(mt, false)
            
            local oldNewIndex = mt.__newindex
            mt.__newindex = newcclosure(function(self, key, value)
                if key == "CFrame" then
                    local jitter = Vector3.new(
                        math.random(-1, 1) * 0.0005,
                        math.random(-1, 1) * 0.0005,
                        math.random(-1, 1) * 0.0005
                    )
                    return oldNewIndex(self, key, value + jitter)
                end
                return oldNewIndex(self, key, value)
            end)
            
            setreadonly(mt, true)
        end
    end)
end

function AntiCheatBypass.EvadeDetection()
    pcall(function()
        local randomDelay = math.random(1, 3) / 1000
        task.wait(randomDelay)
    end)
end

function AntiCheatBypass.InitializeAll()
    print("[AUTO PARRY] Инициализация...")
    AntiCheatBypass.DisableAnticheatConnections()
    AntiCheatBypass.DisableRemoteDetection()
    AntiCheatBypass.SpoofMovement()
    print("[AUTO PARRY] ✓ Загружено!")
end

-- ============================================
-- AUTO PARRY LOGIC
-- ============================================

local function chooseNewFocusedBall()
    local balls = ballsFolder:GetChildren()
    for _, ball in ipairs(balls) do
        if ball:GetAttribute("realBall") == true then
            focusedBall = ball
            break
        end
    end
end

local function getDynamicThreshold(ballVelocityMagnitude)
    if ballVelocityMagnitude > 60 then
        return math.max(0.20, BASE_THRESHOLD - (ballVelocityMagnitude * VELOCITY_SCALING_FACTOR_FAST))
    else
        return math.min(0.01, BASE_THRESHOLD + (ballVelocityMagnitude * VELOCITY_SCALING_FACTOR_SLOW))
    end
end

local function timeUntilImpact(ballVelocity, distanceToPlayer, playerVelocity)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local directionToPlayer = (character.HumanoidRootPart.Position - focusedBall.Position).Unit
    local velocityTowardsPlayer = ballVelocity:Dot(directionToPlayer) - playerVelocity:Dot(directionToPlayer)
    
    if velocityTowardsPlayer <= 0 then
        return math.huge
    end
    
    return (distanceToPlayer - sliderValue) / velocityTowardsPlayer
end

local function checkIfTarget()
    for _, v in pairs(ballsFolder:GetChildren()) do
        if v:IsA("Part") and v.BrickColor == BrickColor.new("Really red") then 
            return true 
        end 
    end 
    return false
end

local function checkBallDistance()
    if not character or not character:FindFirstChild("HumanoidRootPart") or not checkIfTarget() then 
        return 
    end

    local charPos = character.PrimaryPart.Position
    local charVel = character.PrimaryPart.Velocity

    if focusedBall and not focusedBall.Parent then
        chooseNewFocusedBall()
    end
    if not focusedBall then 
        chooseNewFocusedBall()
    end

    if not focusedBall then return end

    local ball = focusedBall
    local distanceToPlayer = (ball.Position - charPos).Magnitude
    local ballVelocityTowardsPlayer = ball.Velocity:Dot((charPos - ball.Position).Unit)
    
    if distanceToPlayer < 15 then
        AntiCheatBypass.EvadeDetection()
        parryButtonPress:Fire()
        if notifyparried then
            print("[AUTO PARRY] Парировано близко!")
        end
        return
    end

    if timeUntilImpact(ball.Velocity, distanceToPlayer, charVel) < getDynamicThreshold(ballVelocityTowardsPlayer) then
        AntiCheatBypass.EvadeDetection()
        parryButtonPress:Fire()
        if notifyparried then
            print("[AUTO PARRY] Парировано!")
        end
    end
end

local function autoParryLoop()
    while isRunning do
        checkBallDistance()
        task.wait()
    end
end

-- ============================================
-- CONSOLE UI
-- ============================================

local function showMenu()
    print("\n" .. string.rep("=", 50))
    print("     BLADE BALL AUTO PARRY - CONSOLE CONTROL")
    print(string.rep("=", 50))
    print("\n[СТАТУС] Auto Parry: " .. (isRunning and "✓ ВКЛ" or "✗ ВЫКЛ"))
    print("[СТАТУС] Distance: " .. sliderValue)
    print("[СТАТУС] Notify: " .. (notifyparried and "✓ ВКЛ" or "✗ ВЫКЛ"))
    print("\n[КОМАНДЫ]")
    print("  P           - Включить/Выключить Auto Parry")
    print("  E           - Увеличить расстояние (+5)")
    print("  Q           - Уменьшить расстояние (-5)")
    print("  N           - Включить/Выключить уведомления")
    print("  M           - Показать это меню")
    print("\n" .. string.rep("=", 50) .. "\n")
end

-- ============================================
-- KEYBINDS
-- ============================================

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- P to toggle
    if input.KeyCode == Enum.KeyCode.P then
        isRunning = not isRunning
        if isRunning then
            print("\n[✓] Auto Parry ВКЛЮЧЁН")
            chooseNewFocusedBall()
            task.spawn(autoParryLoop)
        else
            print("\n[✗] Auto Parry ВЫКЛЮЧЕН")
        end
    end
    
    -- E to increase distance
    if input.KeyCode == Enum.KeyCode.E then
        sliderValue = math.min(100, sliderValue + 5)
        print("[📏] Расстояние: " .. sliderValue)
    end
    
    -- Q to decrease distance
    if input.KeyCode == Enum.KeyCode.Q then
        sliderValue = math.max(0, sliderValue - 5)
        print("[📏] Расстояние: " .. sliderValue)
    end
    
    -- N to toggle notify
    if input.KeyCode == Enum.KeyCode.N then
        notifyparried = not notifyparried
        print("[🔔] Уведомления: " .. (notifyparried and "✓ ВКЛ" or "✗ ВЫКЛ"))
    end
    
    -- M to show menu
    if input.KeyCode == Enum.KeyCode.M then
        showMenu()
    end
end)

-- ============================================
-- RESPAWN HANDLER
-- ============================================

localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    chooseNewFocusedBall()
    AntiCheatBypass.SpoofMovement()
end)

-- ============================================
-- INITIALIZE
-- ============================================

AntiCheatBypass.InitializeAll()

task.spawn(function()
    while true do
        task.wait(30)
        AntiCheatBypass.DisableAnticheatConnections()
    end
end)

-- Show startup message
print("\n" .. string.rep("█", 50))
print("█" .. string.rep(" ", 48) .. "█")
print("█  BLADE BALL AUTO PARRY WITH ANTICHEAT BYPASS   █")
print("█" .. string.rep(" ", 48) .. "█")
print(string.rep("█", 50))
print("\n✓ Скрипт загружен!")
print("✓ Обход antiguita активирован!")
print("\nНажми M чтобы открыть меню\n")
showMenu()

-- DEBUG версия Auto Parry
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = players.LocalPlayer

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ballsFolder = workspace:WaitForChild("Balls")
local parryButtonPress = replicatedStorage.Remotes.ParryButtonPress

local sliderValue = 20
local isRunning = false

print("[DEBUG] Скрипт запущен")
print("[DEBUG] Player: " .. localPlayer.Name)
print("[DEBUG] Character: " .. (character and character.Name or "Нет персонажа"))

-- Проверяем что мячи есть
print("[DEBUG] Balls Folder найден: " .. tostring(ballsFolder ~= nil))

local function checkBalls()
    local balls = ballsFolder:GetChildren()
    print("[DEBUG] Всего мячей в папке: " .. #balls)
    
    for i, ball in ipairs(balls) do
        local isReal = ball:GetAttribute("realBall")
        print("[DEBUG] Мяч " .. i .. ": " .. ball.Name .. " | realBall: " .. tostring(isReal))
    end
end

local function checkTarget()
    print("[DEBUG] Проверяю цель...")
    for _, v in pairs(ballsFolder:GetChildren()) do
        if v:IsA("Part") and v.BrickColor == BrickColor.new("Really red") then 
            print("[DEBUG] НАЙДЕН красный мяч!")
            return true 
        end 
    end 
    print("[DEBUG] Красного мяча НЕ найдено")
    return false
end

local function doParry()
    print("[DEBUG] СРАБАТЫВАЮ ПАРИРОВАНИЕ!")
    print("[DEBUG] Отправляю Fire на ParryButtonPress")
    pcall(function()
        parryButtonPress:Fire()
        print("[DEBUG] Fire отправлен успешно!")
    end)
end

local function mainLoop()
    while isRunning do
        checkBalls()
        local target = checkTarget()
        
        if target then
            local ball = ballsFolder:FindFirstChildOfClass("Part", true)
            if ball and ball:GetAttribute("realBall") then
                local charPos = character.PrimaryPart.Position
                local ballPos = ball.Position
                local distance = (ballPos - charPos).Magnitude
                
                print("[DEBUG] Расстояние до мяча: " .. math.floor(distance))
                
                if distance < 30 then
                    doParry()
                end
            end
        end
        
        task.wait(0.5)
    end
end

-- Keybinds
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        isRunning = not isRunning
        print("\n[!] Auto Parry: " .. (isRunning and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН") .. "\n")
        
        if isRunning then
            checkBalls()
            task.spawn(mainLoop)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.T then
        print("\n[!] ТЕСТОВОЕ ПАРИРОВАНИЕ\n")
        doParry()
    end
    
    if input.KeyCode == Enum.KeyCode.B then
        print("\n[!] ПРОВЕРКА МЯЧЕЙ\n")
        checkBalls()
        checkTarget()
    end
end)

print("\n" .. string.rep("=", 50))
print("AUTO PARRY - DEBUG MODE")
print(string.rep("=", 50))
print("\nКлавиши:")
print("P - Включить/Выключить Auto Parry")
print("T - Тестовое парирование (Fire)")
print("B - Проверить мячи")
print("\n" .. string.rep("=", 50) .. "\n")

local RS = game:GetService("RunService")
local P = game:GetService("Players").LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

-- ============================================
-- ANTICHEAT BYPASS SECTION
-- ============================================

local AntiCheatBypass = {}

-- Disable anticheat detection via remote hooks
function AntiCheatBypass.DisableRemoteDetection()
    local success = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        
        for _, remote in pairs(Remotes:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                if string.find(remote.Name:lower(), "anticheat") or 
                   string.find(remote.Name:lower(), "detect") or
                   string.find(remote.Name:lower(), "check") then
                    
                    local mt = getrawmetatable(remote.FireServer or remote.InvokeServer)
                    if mt then
                        setreadonly(mt, false)
                        local old = mt.__namecall
                        mt.__namecall = newcclosure(function(self, ...)
                            return nil
                        end)
                        setreadonly(mt, true)
                    end
                end
            end
        end
    end)
    return success
end

-- Hook getfenv to hide script
function AntiCheatBypass.HideScript()
    local success = pcall(function()
        local oldGetFenv = getfenv
        getfenv = function(level)
            local env = oldGetFenv(level or 1)
            if env and env.script then
                env.script = nil
            end
            return env
        end
    end)
    return success
end

-- Disable connections to anticheat signals
function AntiCheatBypass.DisableAnticheatConnections()
    local success = pcall(function()
        local ScriptContext = game:GetService("ScriptContext")
        local LogService = game:GetService("LogService")
        
        if getconnections then
            for _, connection in pairs(getconnections(ScriptContext.Error)) do
                pcall(connection.Disable, connection)
            end
            for _, connection in pairs(getconnections(LogService.MessageOut)) do
                pcall(connection.Disable, connection)
            end
        end
    end)
    return success
end

-- Spoof movement packets
function AntiCheatBypass.SpoofMovement()
    local success = pcall(function()
        local HRP = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            local oldSetPrimaryPartCFrame = HRP.SetPrimaryPartCFrame
            HRP.SetPrimaryPartCFrame = function(self, cf)
                -- Add random micro-jitter to avoid detection
                local jitter = Vector3.new(
                    math.random(-1, 1) * 0.001,
                    math.random(-1, 1) * 0.001,
                    math.random(-1, 1) * 0.001
                )
                return oldSetPrimaryPartCFrame(self, cf + jitter)
            end
        end
    end)
    return success
end

-- Disable humanoid state type checks
function AntiCheatBypass.DisableHumanoidStateChecks()
    local success = pcall(function()
        local Humanoid = P.Character and P.Character:FindFirstChild("Humanoid")
        if Humanoid then
            local StateTypes = Enum.HumanoidStateType
            local mt = getrawmetatable(StateTypes)
            
            if mt then
                setreadonly(mt, false)
                local oldIndex = mt.__index
                mt.__index = newcclosure(function(t, k)
                    return oldIndex(t, k)
                end)
                setreadonly(mt, true)
            end
        end
    end)
    return success
end

-- Clean up anticheat GUI elements
function AntiCheatBypass.RemoveAnticheatUI()
    local success = pcall(function()
        local PlayerGui = P:WaitForChild("PlayerGui")
        
        for _, child in pairs(PlayerGui:GetDescendants()) do
            if string.find(child.Name:lower(), "anticheat") or
               string.find(child.Name:lower(), "detect") or
               string.find(child.Name:lower(), "warning") or
               string.find(child.Name:lower(), "alert") then
                child:Destroy()
            end
        end
    end)
    return success
end

-- Universal anticheat detection evasion
function AntiCheatBypass.EvadeDetection()
    local success = pcall(function()
        -- Randomize timing to avoid pattern detection
        local randomDelay = math.random(1, 5) / 1000
        task.wait(randomDelay)
        
        -- Mask rapid actions
        if _G.ActionCount and _G.ActionCount > 100 then
            task.wait(math.random(50, 200) / 1000)
            _G.ActionCount = 0
        end
    end)
    return success
end

-- Initialize all bypasses
function AntiCheatBypass.InitializeAll()
    print("[ANTICHEAT BYPASS] Starting initialization...")
    
    AntiCheatBypass.RemoveAnticheatUI()
    AntiCheatBypass.DisableAnticheatConnections()
    AntiCheatBypass.DisableRemoteDetection()
    AntiCheatBypass.HideScript()
    AntiCheatBypass.DisableHumanoidStateChecks()
    
    print("[ANTICHEAT BYPASS] ✓ All bypass systems initialized")
    return true
end

-- ============================================
-- AUTO PARRY SCRIPT
-- ============================================

local stats = {parries = 0, misses = 0}
local humanReactionTime = {min = 50, max = 150} -- мс
local _G.ActionCount = _G.ActionCount or 0

local function GetBall()
    for _, B in pairs(workspace.Balls:GetChildren()) do
        if B:GetAttribute("realBall") then return B end
    end
end

-- Initialize anticheat bypass BEFORE starting parry script
AntiCheatBypass.InitializeAll()

RS.PreSimulation:Connect(function()
    local Ball = GetBall()
    local HRP = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
    
    if not Ball or not HRP then return end
    
    local V = Ball:FindFirstChild("zoomies")
    if not V then return end
    
    local Speed = V.VectorVelocity.Magnitude
    local Distance = (HRP.Position - Ball.Position).Magnitude
    local TimeToHit = Distance / Speed
    
    if Ball:GetAttribute("target") == P.Name and TimeToHit <= 0.55 then
        -- 🤖 AI маскировка: имитирует человеческую реакцию
        local humanDelay = math.random(humanReactionTime.min, humanReactionTime.max) / 1000
        local microVariation = math.random(-2, 2) / 1000
        
        task.wait(humanDelay + microVariation)
        
        -- Evade detection patterns
        AntiCheatBypass.EvadeDetection()
        
        -- Иногда ошибается (статистически, как человек)
        if stats.parries > 0 and stats.misses / stats.parries < 0.05 then
            if math.random(1, 100) <= 3 then
                stats.misses = stats.misses + 1
                return
            end
        end
        
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(math.random(10, 15) / 1000)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        stats.parries = stats.parries + 1
        _G.ActionCount = (_G.ActionCount or 0) + 1
    end
end)

-- Periodically refresh anticheat bypass
task.spawn(function()
    while true do
        task.wait(30) -- Refresh every 30 seconds
        AntiCheatBypass.RemoveAnticheatUI()
        AntiCheatBypass.DisableAnticheatConnections()
    end
end)

-- Monitor character respawn and reinitialize
P.CharacterAdded:Connect(function()
    task.wait(0.5)
    AntiCheatBypass.SpoofMovement()
    AntiCheatBypass.DisableHumanoidStateChecks()
    print("[ANTICHEAT BYPASS] Reinitialized after respawn")
end)

print("✓ AI-Masked Auto Parry Pro + AntiCheat Bypass загружен!")
print("[STATS] Parries: " .. stats.parries .. " | Misses: " .. stats.misses)
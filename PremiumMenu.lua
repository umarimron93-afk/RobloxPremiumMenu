local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration
local Config = {
	MenuSize = UDim2.new(0, 300, 0, 400),
	MenuPosition = UDim2.new(0, 50, 0, 50),
	BackgroundColor = Color3.fromRGB(40, 40, 45),
	AccentColor = Color3.fromRGB(60, 60, 70),
	TextColor = Color3.fromRGB(220, 220, 220),
	ToggleKeyCode = Enum.KeyCode.Insert,
	BorderColor = Color3.fromRGB(80, 80, 90),
}

-- Menu State
local MenuState = {
	IsOpen = false,
	IsDragging = false,
	DragOffset = Vector2.new(0, 0),
	Functions = {},
}

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Menu Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = Config.MenuSize
MainFrame.Position = Config.MenuPosition
MainFrame.BackgroundColor3 = Config.BackgroundColor
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Top Bar (Draggable)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Config.AccentColor
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Top Bar Border
local TopBarBorder = Instance.new("Frame")
TopBarBorder.Name = "TopBarBorder"
TopBarBorder.Size = UDim2.new(1, 0, 0, 2)
TopBarBorder.Position = UDim2.new(0, 0, 1, 0)
TopBarBorder.BackgroundColor3 = Config.BorderColor
TopBarBorder.BorderSizePixel = 0
TopBarBorder.Parent = TopBar

-- Menu Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Config.TextColor
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "PREMIUM MENU"
TitleLabel.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Config.AccentColor
CloseButton.BorderSizePixel = 0
CloseButton.TextColor3 = Config.TextColor
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.Parent = TopBar

CloseButton.MouseButton1Click:Connect(function()
	MenuState.IsOpen = false
	MainFrame.Visible = false
end)

-- Scroll Frame for Functions
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.BackgroundColor3 = Config.BackgroundColor
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Config.BorderColor
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

-- UIListLayout for Auto-Arrangement
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 0)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.Parent = ScrollFrame

ScrollFrame.ChildAdded:Connect(function()
	UIListLayout:ApplyLayout()
end)

-- Function to create a toggle button
local function CreateToggleButton(FunctionName, Description, InitialState)
	local Container = Instance.new("Frame")
	Container.Name = FunctionName
	Container.Size = UDim2.new(1, 0, 0, 90)
	Container.BackgroundColor3 = Config.BackgroundColor
	Container.BorderSizePixel = 0
	Container.Parent = ScrollFrame

	-- Item Background
	local ItemBg = Instance.new("Frame")
	ItemBg.Name = "ItemBg"
	ItemBg.Size = UDim2.new(1, -10, 1, -5)
	ItemBg.Position = UDim2.new(0, 5, 0, 2.5)
	ItemBg.BackgroundColor3 = Config.AccentColor
	ItemBg.BorderSizePixel = 0
	ItemBg.Parent = Container

	-- Item Border
	local ItemBorder = Instance.new("Frame")
	ItemBorder.Name = "ItemBorder"
	ItemBorder.Size = UDim2.new(1, 0, 1, 0)
	ItemBorder.Position = UDim2.new(0, 0, 0, 0)
	ItemBorder.BackgroundTransparency = 1
	ItemBorder.BorderSizePixel = 1
	ItemBorder.BorderColor3 = Config.BorderColor
	ItemBorder.Parent = ItemBg

	-- Function Name
	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "NameLabel"
	NameLabel.Size = UDim2.new(1, -80, 0, 25)
	NameLabel.Position = UDim2.new(0, 10, 0, 10)
	NameLabel.BackgroundTransparency = 1
	NameLabel.TextColor3 = Config.TextColor
	NameLabel.TextSize = 14
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Text = FunctionName
	NameLabel.Parent = ItemBg

	-- Description
	local DescLabel = Instance.new("TextLabel")
	DescLabel.Name = "DescLabel"
	DescLabel.Size = UDim2.new(1, -20, 0, 35)
	DescLabel.Position = UDim2.new(0, 10, 0, 35)
	DescLabel.BackgroundTransparency = 1
	DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	DescLabel.TextSize = 11
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left
	DescLabel.TextYAlignment = Enum.TextYAlignment.Top
	DescLabel.TextWrapped = true
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.Text = Description
	DescLabel.Parent = ItemBg

	-- Toggle Switch Background
	local SwitchBg = Instance.new("Frame")
	SwitchBg.Name = "SwitchBg"
	SwitchBg.Size = UDim2.new(0, 50, 0, 20)
	SwitchBg.Position = UDim2.new(1, -65, 0, 10)
	SwitchBg.BackgroundColor3 = InitialState and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 110)
	SwitchBg.BorderSizePixel = 0
	SwitchBg.Parent = ItemBg

	-- Toggle Knob
	local SwitchKnob = Instance.new("Frame")
	SwitchKnob.Name = "SwitchKnob"
	SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
	SwitchKnob.Position = InitialState and UDim2.new(0, 32, 0, 2) or UDim2.new(0, 2, 0, 2)
	SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SwitchKnob.BorderSizePixel = 0
	SwitchKnob.Parent = SwitchBg

	-- State Variable
	local IsEnabled = InitialState

	-- Toggle Click
	SwitchBg.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			IsEnabled = not IsEnabled

			-- Animate switch
			if IsEnabled then
				SwitchBg.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
				SwitchKnob:TweenPosition(UDim2.new(0, 32, 0, 2), "Out", "Quad", 0.2, true)
			else
				SwitchBg.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
				SwitchKnob:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.2, true)
			end

			-- Store state
			MenuState.Functions[FunctionName] = IsEnabled
		end
	end)

	SwitchBg.MouseEnter:Connect(function()
		SwitchBg.BackgroundColor3 = IsEnabled and Color3.fromRGB(86, 185, 90) or Color3.fromRGB(110, 110, 120)
	end)

	SwitchBg.MouseLeave:Connect(function()
		SwitchBg.BackgroundColor3 = IsEnabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 110)
	end)

	MenuState.Functions[FunctionName] = IsEnabled
	return Container
end

-- Add Test Function
CreateToggleButton("Test Function", "This is a test toggle button to demonstrate the menu functionality", false)
CreateToggleButton("Feature One", "Enable or disable the first feature of your menu system", false)
CreateToggleButton("Feature Two", "Toggle the second feature for advanced operations", true)

-- Destroy GUI Button
local DestroyButtonContainer = Instance.new("Frame")
DestroyButtonContainer.Name = "DestroyButtonContainer"
DestroyButtonContainer.Size = UDim2.new(1, 0, 0, 50)
DestroyButtonContainer.BackgroundColor3 = Config.BackgroundColor
DestroyButtonContainer.BorderSizePixel = 0
DestroyButtonContainer.Parent = ScrollFrame

local DestroyButton = Instance.new("TextButton")
DestroyButton.Name = "DestroyButton"
DestroyButton.Size = UDim2.new(1, -20, 1, -10)
DestroyButton.Position = UDim2.new(0, 10, 0, 5)
DestroyButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
DestroyButton.BorderSizePixel = 1
DestroyButton.BorderColor3 = Config.BorderColor
DestroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyButton.TextSize = 14
DestroyButton.Font = Enum.Font.GothamBold
DestroyButton.Text = "DESTROY GUI"
DestroyButton.Parent = DestroyButtonContainer

DestroyButton.MouseEnter:Connect(function()
	DestroyButton.BackgroundColor3 = Color3.fromRGB(230, 63, 79)
end)

DestroyButton.MouseLeave:Connect(function()
	DestroyButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
end)

DestroyButton.MouseButton1Click:Connect(function()
	-- Disable all functions
	for FunctionName, _ in pairs(MenuState.Functions) do
		MenuState.Functions[FunctionName] = false
	end

	-- Destroy GUI
	ScreenGui:Destroy()
end)

-- Dragging Logic
local DragConnection
TopBar.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuState.IsDragging = true
		local MousePosition = UserInputService:GetMouseLocation()
		MenuState.DragOffset = Vector2.new(
			MousePosition.X - MainFrame.AbsolutePosition.X,
			MousePosition.Y - MainFrame.AbsolutePosition.Y
		)

		DragConnection = RunService.RenderStepped:Connect(function()
			if MenuState.IsDragging then
				local MousePosition = UserInputService:GetMouseLocation()
				MainFrame.Position = UDim2.new(0, MousePosition.X - MenuState.DragOffset.X, 0, MousePosition.Y - MenuState.DragOffset.Y)
			end
		end)
	end
end)

TopBar.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuState.IsDragging = false
		if DragConnection then
			DragConnection:Disconnect()
		end
	end
end)

-- Toggle Menu with Insert Key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Config.ToggleKeyCode then
		MenuState.IsOpen = not MenuState.IsOpen
		MainFrame.Visible = MenuState.IsOpen
	end
end)

-- Update ScrollFrame Canvas Size
UIListLayout.Changed:Connect(function()
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

print("Premium Menu Loaded - Press INSERT to toggle")
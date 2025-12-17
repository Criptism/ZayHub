local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Mobile Detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Theme
local Theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(28, 28, 33),
	Accent = Color3.fromRGB(88, 101, 242),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(180, 180, 190),
	Border = Color3.fromRGB(45, 45, 50)
}

-- Utility
local function Tween(obj, props, duration)
	TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then obj[k] = v end
	end
	obj.Parent = props.Parent
	return obj
end

-- Main
function Library:Init(config)
	config = config or {}
	config.Name = config.Name or "UI Library"
	
	local Window = {
		Tabs = {},
		CurrentTab = nil
	}
	
	-- ScreenGui
	local ScreenGui = Create("ScreenGui", {
		Name = "Library",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = game:GetService("CoreGui")
	})
	
	-- Main Frame
	local Main = Create("Frame", {
		Name = "Main",
		Size = IsMobile and UDim2.new(0, 420, 0, 340) or UDim2.new(0, 580, 0, 380),
		Position = UDim2.new(0.5, IsMobile and -170 or -290, 0.5, IsMobile and -180 or -190),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = ScreenGui
	})
	
	Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})
	
	-- iOS Drag Bar (for mobile)
	if IsMobile then
		local DragBar = Create("Frame", {
			Name = "DragBar",
			Size = UDim2.new(0, 40, 0, 5),
			Position = UDim2.new(0.5, -20, 0, 8),
			BackgroundColor3 = Color3.fromRGB(100, 100, 110),
			BorderSizePixel = 0,
			Parent = Main
		})
		
		Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = DragBar})
	end
	
	-- Topbar
	local Topbar = Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, IsMobile and 50 or 45),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main
	})
	
	Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Topbar})
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Topbar
	})
	
	-- Title
	local Title = Create("TextLabel", {
		Text = config.Name,
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0, IsMobile and 5 or 0),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Text,
		TextSize = IsMobile and 15 or 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Topbar
	})
	
	-- Close Button
	local CloseBtn = Create("TextButton", {
		Text = "×",
		Size = UDim2.new(0, IsMobile and 40 or 35, 0, IsMobile and 40 or 35),
		Position = UDim2.new(1, IsMobile and -45 or -40, 0, IsMobile and 5 or 5),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		TextColor3 = Theme.Text,
		TextSize = IsMobile and 26 or 24,
		Font = Enum.Font.GothamBold,
		Parent = Topbar
	})
	
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseBtn})
	
	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)
	
	-- Tab Container
	local TabContainer = Create("ScrollingFrame", {
		Name = "TabContainer",
		Size = IsMobile and UDim2.new(1, -20, 0, 45) or UDim2.new(0, 140, 1, -55),
		Position = IsMobile and UDim2.new(0, 10, 0, 55) or UDim2.new(0, 10, 0, 50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = Main
	})
	
	local TabLayout = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		FillDirection = IsMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		Parent = TabContainer
	})
	
	TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if IsMobile then
			TabContainer.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X, 0, 0)
		else
			TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
		end
	end)
	
	-- Content Container
	local ContentContainer = Create("Frame", {
		Name = "ContentContainer",
		Size = IsMobile and UDim2.new(1, -20, 1, -110) or UDim2.new(1, -160, 1, -55),
		Position = IsMobile and UDim2.new(0, 10, 0, 105) or UDim2.new(0, 155, 0, 50),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main
	})
	
	Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ContentContainer})
	
	-- Dragging
	local dragging, dragInput, dragStart, startPos
	
	local DragArea = Topbar
	
	DragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	DragArea.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	-- Tab Functions
	function Window:CreateTab(name)
		local Tab = {
			Name = name,
			Active = false
		}
		
		-- Tab Button
		local TabBtn = Create("TextButton", {
			Name = name,
			Size = IsMobile and UDim2.new(0, 85, 1, 0) or UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Theme.Border,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = TabContainer
		})
		
		Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})
		
		local TabLabel = Create("TextLabel", {
			Text = name,
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Theme.TextDark,
			TextSize = IsMobile and 12 or 14,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = IsMobile and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
			TextScaled = IsMobile,
			Parent = TabBtn
		})
		
		-- Tab Content
		local TabContent = Create("ScrollingFrame", {
			Name = name.."Content",
			Size = UDim2.new(1, -20, 1, -20),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Accent,
			Visible = false,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = ContentContainer
		})
		
		local ContentLayout = Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
			Parent = TabContent
		})
		
		ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
		end)
		
		-- Tab Click
		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Window.Tabs) do
				t.Button.BackgroundColor3 = Theme.Border
				t.Label.TextColor3 = Theme.TextDark
				t.Content.Visible = false
			end
			
			TabBtn.BackgroundColor3 = Theme.Accent
			TabLabel.TextColor3 = Theme.Text
			TabContent.Visible = true
			Window.CurrentTab = Tab
		end)
		
		-- Hover
		TabBtn.MouseEnter:Connect(function()
			if TabBtn.BackgroundColor3 ~= Theme.Accent then
				Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(Theme.Border.R * 255 + 10, Theme.Border.G * 255 + 10, Theme.Border.B * 255 + 10)}, 0.15)
			end
		end)
		
		TabBtn.MouseLeave:Connect(function()
			if TabBtn.BackgroundColor3 ~= Theme.Accent then
				Tween(TabBtn, {BackgroundColor3 = Theme.Border}, 0.15)
			end
		end)
		
		Tab.Button = TabBtn
		Tab.Label = TabLabel
		Tab.Content = TabContent
		
		table.insert(Window.Tabs, Tab)
		
		-- Auto-select first tab
		if #Window.Tabs == 1 then
			TabBtn.BackgroundColor3 = Theme.Accent
			TabLabel.TextColor3 = Theme.Text
			TabContent.Visible = true
			Window.CurrentTab = Tab
		end
		
		-- Element Functions
		function Tab:AddButton(name, callback)
			local Btn = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, IsMobile and 32 or 36),
				BackgroundColor3 = Theme.Border,
				BorderSizePixel = 0,
				Text = "",
				Parent = TabContent
			})
			
			Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Btn})
			
			local BtnLabel = Create("TextLabel", {
				Text = name,
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Theme.Text,
				TextSize = IsMobile and 12 or 14,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = IsMobile,
				Parent = Btn
			})
			
			Btn.MouseEnter:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.Accent}, 0.2)
			end)
			
			Btn.MouseLeave:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.Border}, 0.2)
			end)
			
			Btn.MouseButton1Click:Connect(function()
				callback()
			end)
			
			return Btn
		end
		
		function Tab:AddToggle(name, default, callback)
			local toggled = default or false
			
			local ToggleFrame = Create("Frame", {
				Size = UDim2.new(1, 0, 0, IsMobile and 32 or 36),
				BackgroundColor3 = Theme.Border,
				BorderSizePixel = 0,
				Parent = TabContent
			})
			
			Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleFrame})
			
			local ToggleLabel = Create("TextLabel", {
				Text = name,
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Theme.Text,
				TextSize = IsMobile and 11 or 14,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = IsMobile,
				Parent = ToggleFrame
			})
			
			local ToggleBtn = Create("TextButton", {
				Size = IsMobile and UDim2.new(0, 36, 0, 18) or UDim2.new(0, 42, 0, 22),
				Position = IsMobile and UDim2.new(1, -40, 0.5, -9) or UDim2.new(1, -47, 0.5, -11),
				BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(50, 50, 55),
				BorderSizePixel = 0,
				Text = "",
				Parent = ToggleFrame
			})
			
			Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBtn})
			
			local Indicator = Create("Frame", {
				Size = IsMobile and UDim2.new(0, 16, 0, 16) or UDim2.new(0, 18, 0, 18),
				Position = toggled and (IsMobile and UDim2.new(1, -18, 0.5, -8) or UDim2.new(1, -20, 0.5, -9)) or UDim2.new(0, 2, 0.5, IsMobile and -8 or -9),
				BackgroundColor3 = Theme.Text,
				BorderSizePixel = 0,
				Parent = ToggleBtn
			})
			
			Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Indicator})
			
			ToggleBtn.MouseButton1Click:Connect(function()
				toggled = not toggled
				Tween(ToggleBtn, {BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(50, 50, 55)}, 0.2)
				Tween(Indicator, {Position = toggled and (IsMobile and UDim2.new(1, -18, 0.5, -8) or UDim2.new(1, -20, 0.5, -9)) or UDim2.new(0, 2, 0.5, IsMobile and -8 or -9)}, 0.2)
				callback(toggled)
			end)
			
			return ToggleFrame
		end
		
		function Tab:AddSlider(name, min, max, default, callback)
			local value = default or min
			
			local SliderFrame = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 52),
				BackgroundColor3 = Theme.Border,
				BorderSizePixel = 0,
				Parent = TabContent
			})
			
			Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderFrame})
			
			local SliderLabel = Create("TextLabel", {
				Text = name..": "..value,
				Size = UDim2.new(1, -20, 0, 20),
				Position = UDim2.new(0, 10, 0, 6),
				BackgroundTransparency = 1,
				TextColor3 = Theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = SliderFrame
			})
			
			local SliderBar = Create("Frame", {
				Size = UDim2.new(1, -20, 0, 6),
				Position = UDim2.new(0, 10, 1, -12),
				BackgroundColor3 = Color3.fromRGB(40, 40, 45),
				BorderSizePixel = 0,
				Parent = SliderFrame
			})
			
			Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBar})
			
			local SliderFill = Create("Frame", {
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
				Parent = SliderBar
			})
			
			Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
			
			local dragging = false
			
			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mouse = UserInputService:GetMouseLocation()
					local percent = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
					value = math.floor(min + (max - min) * percent)
					
					SliderLabel.Text = name..": "..value
					SliderFill.Size = UDim2.new(percent, 0, 1, 0)
					callback(value)
				end
			end)
			
			return SliderFrame
		end
		
		function Tab:AddTextbox(name, placeholder, callback)
			local TextboxFrame = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.Border,
				BorderSizePixel = 0,
				Parent = TabContent
			})
			
			Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TextboxFrame})
			
			local TextboxLabel = Create("TextLabel", {
				Text = name,
				Size = UDim2.new(0.5, -10, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = Theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = TextboxFrame
			})
			
			local Textbox = Create("TextBox", {
				Size = UDim2.new(0.5, -20, 0, 26),
				Position = UDim2.new(0.5, 10, 0, 5),
				BackgroundColor3 = Color3.fromRGB(35, 35, 40),
				BorderSizePixel = 0,
				Text = "",
				PlaceholderText = placeholder,
				TextColor3 = Theme.Text,
				PlaceholderColor3 = Theme.TextDark,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				Parent = TextboxFrame
			})
			
			Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Textbox})
			
			Textbox.FocusLost:Connect(function(enter)
				if enter then
					callback(Textbox.Text)
				end
			end)
			
			return TextboxFrame
		end
		
		function Tab:AddLabel(text)
			local Label = Create("TextLabel", {
				Text = text,
				Size = UDim2.new(1, 0, 0, IsMobile and 24 or 28),
				BackgroundTransparency = 1,
				TextColor3 = Theme.TextDark,
				TextSize = IsMobile and 11 or 14,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = IsMobile,
				Parent = TabContent
			})
			
			Create("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = Label})
			
			local LabelFunctions = {}
			function LabelFunctions:Set(newText)
				Label.Text = newText
			end
			
			return LabelFunctions
		end
		
		return Tab
	end
	
	return Window
end

return Library

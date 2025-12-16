-- ===== Library =====
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(28, 28, 33),
	Accent = Color3.fromRGB(88, 101, 242),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(180, 180, 190),
	Border = Color3.fromRGB(45, 45, 50)
}

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

function Library:Init(config)
	config = config or {}
	config.Name = config.Name or "UI Library"

	local Window = {Tabs = {}, CurrentTab = nil}

	local ScreenGui = Create("ScreenGui", {
		Name = "Library",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = game:GetService("CoreGui")
	})

	local Main = Create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 500, 0, 350),
		Position = UDim2.new(0.5, -250, 0.5, -175),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = ScreenGui
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})

	local Topbar = Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Topbar})
	local Title = Create("TextLabel", {
		Text = config.Name,
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Topbar
	})
	local CloseBtn = Create("TextButton", {
		Text = "×",
		Size = UDim2.new(0, 35, 0, 35),
		Position = UDim2.new(1, -40, 0, 2),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		TextColor3 = Theme.Text,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		Parent = Topbar
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseBtn})
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

	local TabContainer = Create("ScrollingFrame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 120, 1, -50),
		Position = UDim2.new(0, 10, 0, 45),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = Main
	})
	local TabLayout = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = TabContainer})
	TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
	end)

	local ContentContainer = Create("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, -140, 1, -50),
		Position = UDim2.new(0, 135, 0, 45),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ContentContainer})

	-- Drag
	local dragging, dragInput, dragStart, startPos
	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
	Topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- ===== Tabs =====
	function Window:CreateTab(name)
		local Tab = {Name = name, Active = false}
		local TabBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Text = "", Parent = TabContainer})
		Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})
		local TabLabel = Create("TextLabel", {
			Text = name,
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Theme.TextDark,
			TextSize = 14,
			Font = Enum.Font.GothamSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = TabBtn
		})
		local TabContent = Create("ScrollingFrame", {Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent, Visible = false, CanvasSize = UDim2.new(0,0,0,0), Parent = ContentContainer})
		local ContentLayout = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = TabContent})
		ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
		end)

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

		function Tab:AddLabel(text)
			local Label = Create("TextLabel", {Text=text, Size=UDim2.new(1,0,0,28), BackgroundTransparency=1, TextColor3=Theme.TextDark, TextSize=14, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left, Parent=TabContent})
			Create("UIPadding",{PaddingLeft=UDim.new(0,10),Parent=Label})
			function Label:Set(newText) self.Text=newText end
			return Label
		end

		function Tab:AddButton(name,callback)
			local Btn = Create("TextButton",{Size=UDim2.new(1,0,0,36), BackgroundColor3=Theme.Border, BorderSizePixel=0, Text="", Parent=TabContent})
			Create("UICorner",{CornerRadius=UDim.new(0,6), Parent=Btn})
			local BtnLabel = Create("TextLabel",{Text=name, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=Theme.Text, TextSize=14, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left, Parent=Btn})
			Btn.MouseEnter:Connect(function() Tween(Btn,{BackgroundColor3=Theme.Accent},0.2) end)
			Btn.MouseLeave:Connect(function() Tween(Btn,{BackgroundColor3=Theme.Border},0.2) end)
			Btn.MouseButton1Click:Connect(callback)
			return Btn
		end

		function Tab:AddToggle(name, default, callback)
			local ToggleFrame = Create("Frame",{Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=TabContent})
			local ToggleBtn = Create("TextButton",{Size=UDim2.new(1,0,1,0), BackgroundColor3=Theme.Border, BorderSizePixel=0, Text="", Parent=ToggleFrame})
			Create("UICorner",{CornerRadius=UDim.new(0,6), Parent=ToggleBtn})
			local Label = Create("TextLabel",{Text=name, Size=UDim2.new(1,-40,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=Theme.Text, TextSize=14, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left, Parent=ToggleBtn})
			local Status = default
			local Indicator = Create("Frame",{Size=UDim2.new(0,24,0,24), Position=UDim2.new(1,-28,0,6), BackgroundColor3=Status and Theme.Accent or Theme.Secondary, Parent=ToggleBtn})
			Create("UICorner",{CornerRadius=UDim.new(0,4), Parent=Indicator})
			ToggleBtn.MouseButton1Click:Connect(function()
				Status = not Status
				Indicator.BackgroundColor3 = Status and Theme.Accent or Theme.Secondary
				callback(Status)
			end)
			return ToggleBtn
		end

		function Tab:AddSlider(name,min,max,default,callback)
			local SliderFrame = Create("Frame",{Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=TabContent})
			local SliderBar = Create("Frame",{Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,0.5,-4), BackgroundColor3=Theme.Border, Parent=SliderFrame})
			Create("UICorner",{CornerRadius=UDim.new(0,4), Parent=SliderBar})
			local Fill = Create("Frame",{Size=UDim2.new(0,0,1,0), BackgroundColor3=Theme.Accent, Parent=SliderBar})
			Create("UICorner",{CornerRadius=UDim.new(0,4), Parent=Fill})
			local ValueLabel = Create("TextLabel",{Text=name.." "..default, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, TextColor3=Theme.Text, TextSize=14, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left, Parent=SliderFrame})
			local dragging = false
			SliderBar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
			SliderBar.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
					local relative = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X,0,SliderBar.AbsoluteSize.X)
					local val = math.floor(min + (relative/SliderBar.AbsoluteSize.X)*(max-min))
					Fill.Size=UDim2.new(relative/SliderBar.AbsoluteSize.X,0,1,0)
					ValueLabel.Text=name.." "..val
					callback(val)
				end
			end)
			return SliderFrame
		end

		function Tab:AddTextbox(name,placeholder,callback)
			local TextBox = Create("TextBox",{Size=UDim2.new(1,0,0,28), Text=placeholder, BackgroundColor3=Theme.Border, TextColor3=Theme.Text, Font=Enum.Font.GothamSemibold, TextSize=14, ClearTextOnFocus=false, Parent=TabContent})
			Create("UICorner",{CornerRadius=UDim.new(0,6), Parent=TextBox})
			TextBox.FocusLost:Connect(function(enter) if enter then callback(TextBox.Text) end end)
			return TextBox
		end

		table.insert(Window.Tabs,Tab)
		if #Window.Tabs==1 then TabBtn.BackgroundColor3=Theme.Accent; TabLabel.TextColor3=Theme.Text; TabContent.Visible=true; Window.CurrentTab=Tab end
		return Tab
	end

	return Window
end

return Library

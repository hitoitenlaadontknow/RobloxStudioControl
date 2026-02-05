# RobloxStudioControl
Roblox Studio
 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/GameCreationSimulator.lua b/GameCreationSimulator.lua
new file mode 100644
index 0000000000000000000000000000000000000000..81522aec2c95a55756c626ecbadf71fe849e4e9c
--- /dev/null
+++ b/GameCreationSimulator.lua
@@ -0,0 +1,371 @@
+-- Roblox Studio Fly GUI Script (Single Script)
+-- GUI đẹp, kéo thả tự do, chỉnh tốc độ bay, bật/tắt bay, và các nút điều khiển cửa sổ.
+
+local Players = game:GetService("Players")
+local UserInputService = game:GetService("UserInputService")
+local RunService = game:GetService("RunService")
+
+local player = Players.LocalPlayer
+local playerGui = player:WaitForChild("PlayerGui")
+
+local flyEnabled = false
+local flySpeed = 50
+local flyConnection
+local bodyVelocity
+local bodyGyro
+
+local function cleanupFly()
+	if flyConnection then
+		flyConnection:Disconnect()
+		flyConnection = nil
+	end
+	if bodyVelocity then
+		bodyVelocity:Destroy()
+		bodyVelocity = nil
+	end
+	if bodyGyro then
+		bodyGyro:Destroy()
+		bodyGyro = nil
+	end
+end
+
+local function updateFlySpeed(inputText)
+	local value = tonumber(inputText)
+	if value and value > 0 then
+		flySpeed = math.clamp(value, 10, 200)
+	end
+end
+
+local function setFlyState(enabled)
+	flyEnabled = enabled
+	local character = player.Character
+	if not character then
+		cleanupFly()
+		return
+	end
+
+	local humanoid = character:FindFirstChildOfClass("Humanoid")
+	local rootPart = character:FindFirstChild("HumanoidRootPart")
+	if not humanoid or not rootPart then
+		cleanupFly()
+		return
+	end
+
+	cleanupFly()
+
+	if not enabled then
+		humanoid.PlatformStand = false
+		return
+	end
+
+	humanoid.PlatformStand = true
+
+	bodyVelocity = Instance.new("BodyVelocity")
+	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
+	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
+	bodyVelocity.Parent = rootPart
+
+	bodyGyro = Instance.new("BodyGyro")
+	bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
+	bodyGyro.CFrame = rootPart.CFrame
+	bodyGyro.Parent = rootPart
+
+	flyConnection = RunService.RenderStepped:Connect(function()
+		local camera = workspace.CurrentCamera
+		if not camera or not rootPart then
+			return
+		end
+
+		local moveVector = Vector3.new(0, 0, 0)
+		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
+			moveVector = moveVector + camera.CFrame.LookVector
+		end
+		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
+			moveVector = moveVector - camera.CFrame.LookVector
+		end
+		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
+			moveVector = moveVector - camera.CFrame.RightVector
+		end
+		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
+			moveVector = moveVector + camera.CFrame.RightVector
+		end
+		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
+			moveVector = moveVector + Vector3.new(0, 1, 0)
+		end
+		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
+			moveVector = moveVector - Vector3.new(0, 1, 0)
+		end
+
+		if moveVector.Magnitude > 0 then
+			moveVector = moveVector.Unit
+		end
+
+		bodyVelocity.Velocity = moveVector * flySpeed
+		bodyGyro.CFrame = camera.CFrame
+	end)
+end
+
+local screenGui = Instance.new("ScreenGui")
+screenGui.Name = "FlyControlGui"
+screenGui.ResetOnSpawn = false
+screenGui.IgnoreGuiInset = true
+screenGui.Parent = playerGui
+
+local mainFrame = Instance.new("Frame")
+mainFrame.Name = "MainFrame"
+mainFrame.Size = UDim2.new(0, 360, 0, 240)
+mainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
+mainFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
+mainFrame.BorderSizePixel = 0
+mainFrame.Active = true
+mainFrame.Draggable = true
+mainFrame.Parent = screenGui
+
+local corner = Instance.new("UICorner")
+corner.CornerRadius = UDim.new(0, 12)
+corner.Parent = mainFrame
+
+local shadow = Instance.new("UIStroke")
+shadow.Color = Color3.fromRGB(45, 48, 60)
+shadow.Thickness = 2
+shadow.Parent = mainFrame
+
+local titleBar = Instance.new("Frame")
+titleBar.Name = "TitleBar"
+titleBar.Size = UDim2.new(1, 0, 0, 36)
+titleBar.BackgroundColor3 = Color3.fromRGB(36, 38, 48)
+titleBar.BorderSizePixel = 0
+titleBar.Parent = mainFrame
+
+local titleCorner = Instance.new("UICorner")
+titleCorner.CornerRadius = UDim.new(0, 12)
+titleCorner.Parent = titleBar
+
+local titleLabel = Instance.new("TextLabel")
+titleLabel.Size = UDim2.new(1, -120, 1, 0)
+titleLabel.Position = UDim2.new(0, 16, 0, 0)
+titleLabel.BackgroundTransparency = 1
+titleLabel.Text = "Fly Control"
+titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
+titleLabel.Font = Enum.Font.GothamBold
+titleLabel.TextSize = 16
+titleLabel.TextXAlignment = Enum.TextXAlignment.Left
+titleLabel.Parent = titleBar
+
+local minimizeButton = Instance.new("TextButton")
+minimizeButton.Name = "MinimizeButton"
+minimizeButton.Size = UDim2.new(0, 26, 0, 26)
+minimizeButton.Position = UDim2.new(1, -96, 0, 5)
+minimizeButton.BackgroundColor3 = Color3.fromRGB(56, 60, 74)
+minimizeButton.Text = "-"
+minimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
+minimizeButton.Font = Enum.Font.GothamBold
+minimizeButton.TextSize = 16
+minimizeButton.Parent = titleBar
+
+local maximizeButton = Instance.new("TextButton")
+maximizeButton.Name = "MaximizeButton"
+maximizeButton.Size = UDim2.new(0, 26, 0, 26)
+maximizeButton.Position = UDim2.new(1, -64, 0, 5)
+maximizeButton.BackgroundColor3 = Color3.fromRGB(56, 60, 74)
+maximizeButton.Text = "⬜"
+maximizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
+maximizeButton.Font = Enum.Font.GothamBold
+maximizeButton.TextSize = 14
+maximizeButton.Parent = titleBar
+
+local restoreButton = Instance.new("TextButton")
+restoreButton.Name = "RestoreButton"
+restoreButton.Size = UDim2.new(0, 26, 0, 26)
+restoreButton.Position = UDim2.new(1, -64, 0, 5)
+restoreButton.BackgroundColor3 = Color3.fromRGB(56, 60, 74)
+restoreButton.Text = "◽"
+restoreButton.TextColor3 = Color3.fromRGB(230, 230, 230)
+restoreButton.Font = Enum.Font.GothamBold
+restoreButton.TextSize = 14
+restoreButton.Visible = false
+restoreButton.Parent = titleBar
+
+local closeButton = Instance.new("TextButton")
+closeButton.Name = "CloseButton"
+closeButton.Size = UDim2.new(0, 26, 0, 26)
+closeButton.Position = UDim2.new(1, -32, 0, 5)
+closeButton.BackgroundColor3 = Color3.fromRGB(196, 74, 74)
+closeButton.Text = "❌"
+closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
+closeButton.Font = Enum.Font.GothamBold
+closeButton.TextSize = 14
+closeButton.Parent = titleBar
+
+local contentFrame = Instance.new("Frame")
+contentFrame.Name = "ContentFrame"
+contentFrame.Size = UDim2.new(1, -32, 1, -64)
+contentFrame.Position = UDim2.new(0, 16, 0, 48)
+contentFrame.BackgroundTransparency = 1
+contentFrame.Parent = mainFrame
+
+local instructionLabel = Instance.new("TextLabel")
+instructionLabel.Size = UDim2.new(1, 0, 0, 24)
+instructionLabel.BackgroundTransparency = 1
+instructionLabel.Text = "bấm 'F' để bay"
+instructionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
+instructionLabel.Font = Enum.Font.Gotham
+instructionLabel.TextSize = 14
+instructionLabel.TextXAlignment = Enum.TextXAlignment.Left
+instructionLabel.Parent = contentFrame
+
+local speedLabel = Instance.new("TextLabel")
+speedLabel.Size = UDim2.new(0, 120, 0, 24)
+speedLabel.Position = UDim2.new(0, 0, 0, 40)
+speedLabel.BackgroundTransparency = 1
+speedLabel.Text = "Tốc độ bay"
+speedLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
+speedLabel.Font = Enum.Font.GothamMedium
+speedLabel.TextSize = 14
+speedLabel.TextXAlignment = Enum.TextXAlignment.Left
+speedLabel.Parent = contentFrame
+
+local speedInput = Instance.new("TextBox")
+speedInput.Size = UDim2.new(0, 140, 0, 28)
+speedInput.Position = UDim2.new(0, 0, 0, 68)
+speedInput.BackgroundColor3 = Color3.fromRGB(46, 49, 62)
+speedInput.PlaceholderText = "Nhập số (10-200)"
+speedInput.Text = tostring(flySpeed)
+speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
+speedInput.Font = Enum.Font.Gotham
+speedInput.TextSize = 14
+speedInput.ClearTextOnFocus = false
+speedInput.Parent = contentFrame
+
+local speedCorner = Instance.new("UICorner")
+speedCorner.CornerRadius = UDim.new(0, 6)
+speedCorner.Parent = speedInput
+
+local applyButton = Instance.new("TextButton")
+applyButton.Name = "ApplyButton"
+applyButton.Size = UDim2.new(0, 120, 0, 28)
+applyButton.Position = UDim2.new(0, 150, 0, 68)
+applyButton.BackgroundColor3 = Color3.fromRGB(85, 148, 255)
+applyButton.Text = "Áp dụng"
+applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
+applyButton.Font = Enum.Font.GothamBold
+applyButton.TextSize = 14
+applyButton.Parent = contentFrame
+
+local applyCorner = Instance.new("UICorner")
+applyCorner.CornerRadius = UDim.new(0, 6)
+applyCorner.Parent = applyButton
+
+local toggleButton = Instance.new("TextButton")
+toggleButton.Name = "ToggleFlyButton"
+toggleButton.Size = UDim2.new(0, 270, 0, 36)
+toggleButton.Position = UDim2.new(0, 0, 0, 116)
+toggleButton.BackgroundColor3 = Color3.fromRGB(72, 190, 122)
+toggleButton.Text = "Bật fly"
+toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
+toggleButton.Font = Enum.Font.GothamBold
+toggleButton.TextSize = 16
+toggleButton.Parent = contentFrame
+
+local toggleCorner = Instance.new("UICorner")
+toggleCorner.CornerRadius = UDim.new(0, 8)
+toggleCorner.Parent = toggleButton
+
+local hintLabel = Instance.new("TextLabel")
+hintLabel.Size = UDim2.new(1, 0, 0, 24)
+hintLabel.Position = UDim2.new(0, 0, 0, 170)
+hintLabel.BackgroundTransparency = 1
+hintLabel.Text = "WASD bay, Space lên, Ctrl xuống"
+hintLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
+hintLabel.Font = Enum.Font.Gotham
+hintLabel.TextSize = 12
+hintLabel.TextXAlignment = Enum.TextXAlignment.Left
+hintLabel.Parent = contentFrame
+
+local function setToggleVisual()
+	if flyEnabled then
+		toggleButton.Text = "Tắt fly"
+		toggleButton.BackgroundColor3 = Color3.fromRGB(220, 88, 88)
+	else
+		toggleButton.Text = "Bật fly"
+		toggleButton.BackgroundColor3 = Color3.fromRGB(72, 190, 122)
+	end
+end
+
+local function maximize()
+	mainFrame.Position = UDim2.new(0, 0, 0, 0)
+	mainFrame.Size = UDim2.new(1, 0, 1, 0)
+	maximizeButton.Visible = false
+	restoreButton.Visible = true
+end
+
+local function restore()
+	mainFrame.Size = UDim2.new(0, 360, 0, 240)
+	mainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
+	restoreButton.Visible = false
+	maximizeButton.Visible = true
+end
+
+local minimized = false
+local function setMinimized(state)
+	minimized = state
+	contentFrame.Visible = not state
+	if state then
+		mainFrame.Size = UDim2.new(0, 360, 0, 36)
+	else
+		restore()
+	end
+end
+
+minimizeButton.MouseButton1Click:Connect(function()
+	setMinimized(not minimized)
+end)
+
+maximizeButton.MouseButton1Click:Connect(function()
+	setMinimized(false)
+	maximize()
+end)
+
+restoreButton.MouseButton1Click:Connect(function()
+	restore()
+end)
+
+closeButton.MouseButton1Click:Connect(function()
+	cleanupFly()
+	screenGui:Destroy()
+end)
+
+applyButton.MouseButton1Click:Connect(function()
+	updateFlySpeed(speedInput.Text)
+	speedInput.Text = tostring(flySpeed)
+end)
+
+speedInput.FocusLost:Connect(function(enterPressed)
+	if enterPressed then
+		updateFlySpeed(speedInput.Text)
+		speedInput.Text = tostring(flySpeed)
+	end
+end)
+
+toggleButton.MouseButton1Click:Connect(function()
+	setFlyState(not flyEnabled)
+	setToggleVisual()
+end)
+
+UserInputService.InputBegan:Connect(function(input, gameProcessed)
+	if gameProcessed then
+		return
+	end
+	if input.KeyCode == Enum.KeyCode.F then
+		setFlyState(not flyEnabled)
+		setToggleVisual()
+	end
+end)
+
+player.CharacterAdded:Connect(function()
+	if flyEnabled then
+		setFlyState(true)
+	end
+end)
+
+setToggleVisual()
 
EOF
)

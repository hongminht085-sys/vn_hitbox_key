local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local SAVE_FILE_NAME = "vn_hitbox_secure_data.json"
local WEB_GETKEY_URL = "https://hongminht085-sys.github.io/vn_hitbox_key/"
local CORRECT_KEY = "vn-test"

local function GetDeviceHWID()
    local success, hwid = pcall(function()
        if gethwid then
            return gethwid()
        elseif RbxAnalyticsService and RbxAnalyticsService.GetClientId then
            return RbxAnalyticsService:GetClientId()
        end
    end)
    if success and hwid and hwid ~= "" then
        return hwid
    end
    return Player.Name "_" .. tostring(game.GameId)
end

local function LoadKeyData()
    if readfile and pcall(readfile, SAVE_FILE_NAME) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE_NAME))
        end)
        if success and data then
            return data
        end
    end
    return nil
end

local function SaveKeyData(keyStr, hwidStr)
    if writefile then
        local data = { Key = keyStr, HWID = hwidStr, Permanent = true }
        pcall(function()
            writefile(SAVE_FILE_NAME, HttpService:JSONEncode(data))
        end)
    end
end

local function loadHitboxMenu(currentKey)
    local hitboxSize = 3
    local flySpeed = 50
    local isHitboxEnabled = false
    local isFlyEnabled = false
    local script_running = true
    local menuVisible = true
    local originalSizes = {}

    local selectedTarget = nil
    local isTeleEnabled = false

    local flyBodyVelocity = nil
    local flyBodyGyro = nil

    local function ResetAllHitboxes()
        for p, hrp in pairs(originalSizes) do
            if p and p.Character then
                if hrp and hrp.Parent then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                    hrp.CFrame = CFrame.new(hrp.Position)
                end
            end
        end
        originalSizes = {}
    end

    local function UpdateHitboxes()
        if not isHitboxEnabled then
            ResetAllHitboxes()
            return
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local char = p.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    if not originalSizes[p] then
                        originalSizes[p] = hrp.Size
                    end

                    local currentPos = hrp.Position
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.CFrame = CFrame.new(currentPos)
                    hrp.CanCollide = false
                    hrp.Transparency = 0.5
                    hrp.Color = Color3.fromRGB(255, 40, 40)
                else
                    if originalSizes[p] then
                        hrp.Size = originalSizes[p]
                        hrp.Transparency = 1
                        originalSizes[p] = nil
                    end
                end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if not script_running then return end
        UpdateHitboxes()

        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            -- Sửa tính năng Bay hoàn chỉnh lên/xuống trời bằng Camera và phím
            if isFlyEnabled and hrp and humanoid then
                humanoid.PlatformStand = true
                if not flyBodyVelocity or not flyBodyVelocity.Parent then
                    flyBodyVelocity = Instance.new("BodyVelocity")
                    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    flyBodyVelocity.Parent = hrp
                end
                if not flyBodyGyro or not flyBodyGyro.Parent then
                    flyBodyGyro = Instance.new("BodyGyro")
                    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
                    flyBodyGyro.Parent = hrp
                end

                local cam = workspace.CurrentCamera
                flyBodyGyro.CFrame = cam.CFrame

                local moveDirection = Vector3.new(0, 0, 0)
                local camLook = cam.CFrame.LookVector
                local camRight = cam.CFrame.RightVector

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camLook end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camLook end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camRight end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camRight end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                    moveDirection = moveDirection + Vector3.new(0, 1, 0) 
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                    moveDirection = moveDirection - Vector3.new(0, 1, 0) 
                end

                if humanoid.MoveDirection.Magnitude > 0 and moveDirection.Magnitude == 0 then
                    moveDirection = humanoid.MoveDirection
                end

                flyBodyVelocity.Velocity = moveDirection * flySpeed
            else
                if humanoid then humanoid.PlatformStand = false end
                if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
                if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            end

            -- Logic Teleport toàn map theo yêu cầu: Dưới vực -> tele lên trời đứng im; Chết -> tắt tele; Lên mặt đất -> tele tiếp
            if isTeleEnabled and selectedTarget then
                local targetChar = selectedTarget.Character
                local targetHumanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

                if not targetChar or not targetHumanoid or targetHumanoid.Health <= 0 then
                    isTeleEnabled = false
                elseif targetHrp then
                    if targetHrp.Position.Y < -5 then
                        hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 25, 0))
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    else
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        if originalSizes[p] then originalSizes[p] = nil end
        if selectedTarget == p then selectedTarget = nil; isTeleEnabled = false end
    end)

    pcall(function() PlayerGui.VN_Hitbox_Menu:Destroy() end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "VN_Hitbox_Menu"
    gui.Parent = PlayerGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    -- Thay nút tròn bằng lá cờ Việt Nam (🇻🇳)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = gui
    ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    ToggleBtn.Text = "🇻🇳"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 24
    ToggleBtn.Active = true
    ToggleBtn.Draggable = true
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 9999
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Parent = ToggleBtn
    toggleStroke.Color = Color3.fromRGB(0, 243, 255)
    toggleStroke.Thickness = 2

    local main = Instance.new("ScrollingFrame")
    main.Parent = gui
    main.Size = UDim2.new(0, 310, 0, 420)
    main.Position = UDim2.new(0.5, -155, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = false
    main.Visible = true
    main.ZIndex = 8888
    main.CanvasSize = UDim2.new(0, 0, 0, 620)
    main.ScrollBarThickness = 6
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Parent = main
    mainStroke.Color = Color3.fromRGB(0, 243, 255)
    mainStroke.Thickness = 1.2
    mainStroke.Transparency = 0.2

    local TopBar = Instance.new("Frame")
    TopBar.Parent = main
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Active = true
    TopBar.ZIndex = 9000
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel")
    Title.Parent = TopBar
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ [ vn hitbox ] // PANEL"
    Title.TextColor3 = Color3.fromRGB(0, 243, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 9001

    local draggingMenu = false
    local dragInputMenu, mousePosMenu, framePosMenu

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMenu = true
            mousePosMenu = input.Position
            framePosMenu = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingMenu = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInputMenu = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputMenu and draggingMenu then
            local delta = input.Position - mousePosMenu
            main.Position = UDim2.new(framePosMenu.X.Scale, framePosMenu.X.Offset + delta.X, framePosMenu.Y.Scale, framePosMenu.Y.Offset + delta.Y)
        end
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TopBar
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -33, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Active = true
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 9002
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    CloseBtn.MouseButton1Click:Connect(function()
        script_running = false
        isHitboxEnabled = false
        isFlyEnabled = false
        isTeleEnabled = false
        ResetAllHitboxes()
        gui:Destroy()
    end)

    local toggleHitboxBtn = Instance.new("TextButton")
    toggleHitboxBtn.Parent = main
    toggleHitboxBtn.Size = UDim2.new(0.44, 0, 0, 32)
    toggleHitboxBtn.Position = UDim2.new(0.04, 0, 0.08, 0)
    toggleHitboxBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
    toggleHitboxBtn.Text = "HITBOX: TẮT"
    toggleHitboxBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
    toggleHitboxBtn.Font = Enum.Font.Code
    toggleHitboxBtn.TextSize = 11
    toggleHitboxBtn.Active = true
    toggleHitboxBtn.AutoButtonColor = false
    toggleHitboxBtn.ZIndex = 9000
    Instance.new("UICorner", toggleHitboxBtn).CornerRadius = UDim.new(0, 6)

    local toggleHitboxStroke = Instance.new("UIStroke")
    toggleHitboxStroke.Parent = toggleHitboxBtn
    toggleHitboxStroke.Color = Color3.fromRGB(255, 80, 110)
    toggleHitboxStroke.Thickness = 1

    toggleHitboxBtn.MouseButton1Click:Connect(function()
        isHitboxEnabled = not isHitboxEnabled
        if isHitboxEnabled then
            toggleHitboxBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 25)
            toggleHitboxBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
            toggleHitboxStroke.Color = Color3.fromRGB(0, 255, 150)
            toggleHitboxBtn.Text = "HITBOX: BẬT"
        else
            toggleHitboxBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
            toggleHitboxBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
            toggleHitboxStroke.Color = Color3.fromRGB(255, 80, 110)
            toggleHitboxBtn.Text = "HITBOX: TẮT"
            ResetAllHitboxes()
        end
    end)

    local toggleFlyBtn = Instance.new("TextButton")
    toggleFlyBtn.Parent = main
    toggleFlyBtn.Size = UDim2.new(0.44, 0, 0, 32)
    toggleFlyBtn.Position = UDim2.new(0.52, 0, 0.08, 0)
    toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
    toggleFlyBtn.Text = "BAY: TẮT"
    toggleFlyBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
    toggleFlyBtn.Font = Enum.Font.Code
    toggleFlyBtn.TextSize = 11
    toggleFlyBtn.Active = true
    toggleFlyBtn.AutoButtonColor = false
    toggleFlyBtn.ZIndex = 9000
    Instance.new("UICorner", toggleFlyBtn).CornerRadius = UDim.new(0, 6)

    local toggleFlyStroke = Instance.new("UIStroke")
    toggleFlyStroke.Parent = toggleFlyBtn
    toggleFlyStroke.Color = Color3.fromRGB(255, 80, 110)
    toggleFlyStroke.Thickness = 1

    toggleFlyBtn.MouseButton1Click:Connect(function()
        isFlyEnabled = not isFlyEnabled
        if isFlyEnabled then
            toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 25)
            toggleFlyBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
            toggleFlyStroke.Color = Color3.fromRGB(0, 255, 150)
            toggleFlyBtn.Text = "BAY: BẬT"
        else
            toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
            toggleFlyBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
            toggleFlyStroke.Color = Color3.fromRGB(255, 80, 110)
            toggleFlyBtn.Text = "BAY: TẮT"
        end
    end)

    local speedTextBox = Instance.new("TextBox")
    speedTextBox.Parent = main
    speedTextBox.Size = UDim2.new(0.92, 0, 0, 32)
    speedTextBox.Position = UDim2.new(0.04, 0, 0.15, 0)
    speedTextBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    speedTextBox.Text = "TỐC ĐỘ BAY (HIỆN TẠI: 50)"
    speedTextBox.TextColor3 = Color3.fromRGB(0, 243, 255)
    speedTextBox.Font = Enum.Font.Code
    speedTextBox.TextSize = 11
    speedTextBox.Active = true
    speedTextBox.ZIndex = 9000
    Instance.new("UICorner", speedTextBox).CornerRadius = UDim.new(0, 6)

    speedTextBox.FocusLost:Connect(function()
        local val = tonumber(speedTextBox.Text)
        if val and val > 0 then
            flySpeed = math.clamp(val, 1, 500)
            speedTextBox.Text = "TỐC ĐỘ BAY: " .. tostring(flySpeed)
        else
            speedTextBox.Text = "TỐC ĐỘ BAY (HIỆN TẠI: " .. tostring(flySpeed) .. ")"
        end
    end)

    local sizeTextBox = Instance.new("TextBox")
    sizeTextBox.Parent = main
    sizeTextBox.Size = UDim2.new(0.92, 0, 0, 32)
    sizeTextBox.Position = UDim2.new(0.04, 0, 0.22, 0)
    sizeTextBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    sizeTextBox.Text = "KÍCH THƯỚC HITBOX (HIỆN TẠI: 3)"
    sizeTextBox.TextColor3 = Color3.fromRGB(0, 243, 255)
    sizeTextBox.Font = Enum.Font.Code
    sizeTextBox.TextSize = 11
    sizeTextBox.Active = true
    sizeTextBox.ZIndex = 9000
    Instance.new("UICorner", sizeTextBox).CornerRadius = UDim.new(0, 6)

    sizeTextBox.FocusLost:Connect(function()
        local val = tonumber(sizeTextBox.Text)
        if val and val > 0 then
            hitboxSize = math.clamp(val, 1, 50)
            sizeTextBox.Text = "KÍCH THƯỚC HITBOX: " .. tostring(hitboxSize)
        else
            sizeTextBox.Text = "KÍCH THƯỚC HITBOX (HIỆN TẠI: " .. tostring(hitboxSize) .. ")"
        end
    end)

    local resetServerBtn = Instance.new("TextButton")
    resetServerBtn.Parent = main
    resetServerBtn.Size = UDim2.new(0.92, 0, 0, 28)
    resetServerBtn.Position = UDim2.new(0.04, 0, 0.29, 0)
    resetServerBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 15)
    resetServerBtn.Text = "🔄 QUÉT FULL MAP / REFRESH DANH SÁCH"
    resetServerBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
    resetServerBtn.Font = Enum.Font.Code
    resetServerBtn.TextSize = 10
    resetServerBtn.Active = true
    resetServerBtn.AutoButtonColor = false
    resetServerBtn.ZIndex = 9000
    Instance.new("UICorner", resetServerBtn).CornerRadius = UDim.new(0, 6)

    local listTitle = Instance.new("TextLabel")
    listTitle.Parent = main
    listTitle.Size = UDim2.new(0.92, 0, 0, 22)
    listTitle.Position = UDim2.new(0.04, 0, 0.35, 0)
    listTitle.BackgroundTransparency = 1
    listTitle.Text = " DANH SÁCH MỤC TIÊU TELEPORT:"
    listTitle.TextColor3 = Color3.fromRGB(150, 160, 190)
    listTitle.Font = Enum.Font.Code
    listTitle.TextSize = 11
    listTitle.TextXAlignment = Enum.TextXAlignment.Left
    listTitle.ZIndex = 9000

    local isListExpanded = true
    local toggleExpandBtn = Instance.new("TextButton")
    toggleExpandBtn.Parent = main
    toggleExpandBtn.Size = UDim2.new(0, 24, 0, 20)
    toggleExpandBtn.Position = UDim2.new(0.92, -24, 0.35, 0)
    toggleExpandBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    toggleExpandBtn.Text = "▲" -- Mũi tên lên xuống để ẩn/hiện danh sách
    toggleExpandBtn.TextColor3 = Color3.fromRGB(0, 243, 255)
    toggleExpandBtn.Font = Enum.Font.Code
    toggleExpandBtn.TextSize = 11
    toggleExpandBtn.Active = true
    toggleExpandBtn.AutoButtonColor = false
    toggleExpandBtn.ZIndex = 9500
    Instance.new("UICorner", toggleExpandBtn).CornerRadius = UDim.new(0, 4)

    local playerListContainer = Instance.new("ScrollingFrame")
    playerListContainer.Parent = main
    playerListContainer.Size = UDim2.new(0.92, 0, 0, 130)
    playerListContainer.Position = UDim2.new(0.04, 0, 0.39, 0)
    playerListContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    playerListContainer.BorderSizePixel = 0
    playerListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerListContainer.ScrollBarThickness = 4
    playerListContainer.ZIndex = 9000
    Instance.new("UICorner", playerListContainer).CornerRadius = UDim.new(0, 6)

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = playerListContainer
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 4)

    -- Hàm tự động thay đổi vị trí các nút bên dưới khi ẩn/hiện danh sách tele
    local teleToggleBtn = Instance.new("TextButton")
    teleToggleBtn.Parent = main
    teleToggleBtn.Size = UDim2.new(0.92, 0, 0, 35)
    teleToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    teleToggleBtn.Text = "TELEPORT DÍNH MỤC TIÊU: TẮT"
    teleToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
    teleToggleBtn.Font = Enum.Font.Code
    teleToggleBtn.TextSize = 11
    teleToggleBtn.Active = true
    teleToggleBtn.AutoButtonColor = false
    teleToggleBtn.ZIndex = 9000
    Instance.new("UICorner", teleToggleBtn).CornerRadius = UDim.new(0, 6)

    local teleStroke = Instance.new("UIStroke")
    teleStroke.Parent = teleToggleBtn
    teleStroke.Color = Color3.fromRGB(255, 80, 110)
    teleStroke.Thickness = 1

    local function UpdateLayoutPositions()
        if isListExpanded then
            playerListContainer.Visible = true
            playerListContainer.Size = UDim2.new(0.92, 0, 0, 130)
            toggleExpandBtn.Text = "▲"
            teleToggleBtn.Position = UDim2.new(0.04, 0, 0.75, 0)
            main.CanvasSize = UDim2.new(0, 0, 0, 620)
        else
            playerListContainer.Visible = false
            toggleExpandBtn.Text = "▼"
            teleToggleBtn.Position = UDim2.new(0.04, 0, 0.44, 0)
            main.CanvasSize = UDim2.new(0, 0, 0, 450)
        end
    end

    toggleExpandBtn.MouseButton1Click:Connect(function()
        isListExpanded = not isListExpanded
        UpdateLayoutPositions()
    end)

    local function PopulatePlayerList()
        for _, child in pairs(playerListContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local count = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player then
                count = count + 1
                local pBtn = Instance.new("TextButton")
                pBtn.Parent = playerListContainer
                pBtn.Size = UDim2.new(1, -6, 0, 32)
                pBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
                pBtn.Text = "  " .. p.Name
                pBtn.TextColor3 = (selectedTarget == p) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(220, 220, 240)
                pBtn.Font = Enum.Font.Code
                pBtn.TextSize = 11
                pBtn.TextXAlignment = Enum.TextXAlignment.Left
                pBtn.ZIndex = 9001
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

                pBtn.MouseButton1Click:Connect(function()
                    selectedTarget = p
                    PopulatePlayerList()
                    if isTeleEnabled then
                        teleToggleBtn.Text = "TELEPORT: ĐANG BẬT (" .. selectedTarget.Name .. ")"
                    end
                end)
            end
        end
        playerListContainer.CanvasSize = UDim2.new(0, 0, 0, count * 36)
    end

    PopulatePlayerList()
    resetServerBtn.MouseButton1Click:Connect(PopulatePlayerList)
    Players.PlayerAdded:Connect(PopulatePlayerList)
    Players.PlayerRemoving:Connect(PopulatePlayerList)

    -- Nút bấm Teleport bật/tắt thủ công chuẩn xác
    teleToggleBtn.MouseButton1Click:Connect(function()
        if selectedTarget then
            isTeleEnabled = not isTeleEnabled
            if isTeleEnabled then
                teleToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 25)
                teleToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
                teleStroke.Color = Color3.fromRGB(0, 255, 150)
                teleToggleBtn.Text = "TELEPORT: ĐANG BẬT (" .. selectedTarget.Name .. ")"
            else
                teleToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
                teleToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
                teleStroke.Color = Color3.fromRGB(255, 80, 110)
                teleToggleBtn.Text = "TELEPORT DÍNH MỤC TIÊU: TẮT"
            end
        else
            teleToggleBtn.Text = "[!] HÃY CHỌN MỤC TIÊU TRÊN DANH SÁCH"
            task.wait(1.5)
            teleToggleBtn.Text = "TELEPORT DÍNH MỤC TIÊU: TẮT"
        end
    end)

    local isDraggingToggle = false
    local dragStartPosition = nil

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingToggle = false
            dragStartPosition = input.Position
        end
    end)

    ToggleBtn.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragStartPosition then
            if (input.Position - dragStartPosition).Magnitude > 6 then
                isDraggingToggle = true
            end
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        if not isDraggingToggle then
            menuVisible = not menuVisible
            main.Visible = menuVisible
        end
        isDraggingToggle = false
        dragStartPosition = nil
    end)
end

local currentHWID = GetDeviceHWID()
local savedData = LoadKeyData()

if savedData and savedData.Key == CORRECT_KEY and savedData.HWID == currentHWID then
    pcall(function()
        if delfile then
            delfile(SAVE_FILE_NAME)
        end
    end)
end

if PlayerGui:FindFirstChild("VN_KeyGui") then
    PlayerGui.VN_KeyGui:Destroy()
end

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "VN_KeyGui"
keyGui.Parent = PlayerGui
keyGui.ResetOnSpawn = false
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.IgnoreGuiInset = true

local keyMain = Instance.new("Frame")
keyMain.Parent = keyGui
keyMain.Size = UDim2.new(0, 320, 0, 225)
keyMain.Position = UDim2.new(0.5, -160, 0.4, -112)
keyMain.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
keyMain.BorderColor3 = Color3.fromRGB(0, 243, 255)
keyMain.BorderSizePixel = 1
keyMain.Active = true
keyMain.Draggable = true
keyMain.ZIndex = 9999
Instance.new("UICorner", keyMain).CornerRadius = UDim.new(0, 8)

local keyGlow = Instance.new("UIStroke")
keyGlow.Parent = keyMain
keyGlow.Color = Color3.fromRGB(0, 243, 255)
keyGlow.Thickness = 1.5
keyGlow.Transparency = 0.3

local keyTitle = Instance.new("TextLabel")
keyTitle.Parent = keyMain
keyTitle.Size = UDim2.new(1, 0, 0, 40)
keyTitle.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
keyTitle.Text = "⚡ [ vn hitbox ] // AUTH"
keyTitle.TextColor3 = Color3.fromRGB(0, 243, 255)
keyTitle.Font = Enum.Font.Code
keyTitle.TextSize = 12
keyTitle.ZIndex = 10000
Instance.new("UICorner", keyTitle).CornerRadius = UDim.new(0, 8)

local keyBox = Instance.new("TextBox")
keyBox.Parent = keyMain
keyBox.Size = UDim2.new(0.85, 0, 0, 38)
keyBox.Position = UDim2.new(0.075, 0, 0.25, 0)
keyBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
keyBox.PlaceholderText = "> Nhập key vào đây..."
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(0, 255, 150)
keyBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 120)
keyBox.Font = Enum.Font.Code
keyBox.TextSize = 12
keyBox.Active = true
keyBox.ZIndex = 10000
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)

local keyBoxStroke = Instance.new("UIStroke")
keyBoxStroke.Parent = keyBox
keyBoxStroke.Color = Color3.fromRGB(40, 40, 70)
keyBoxStroke.Thickness = 1

local errorLabel = Instance.new("TextLabel")
errorLabel.Parent = keyMain
errorLabel.Size = UDim2.new(0.85, 0, 0, 20)
errorLabel.Position = UDim2.new(0.075, 0, 0.44, 0)
errorLabel.BackgroundTransparency = 1
errorLabel.Text = ""
errorLabel.TextColor3 = Color3.fromRGB(255, 60, 90)
errorLabel.Font = Enum.Font.Code
errorLabel.TextSize = 10
errorLabel.ZIndex = 10000

local submitBtn = Instance.new("TextButton")
submitBtn.Parent = keyMain
submitBtn.Size = UDim2.new(0.85, 0, 0, 36)
submitBtn.Position = UDim2.new(0.075, 0, 0.55, 0)
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
submitBtn.Text = "XÁC NHẬN KEY"
submitBtn.TextColor3 = Color3.fromRGB(10, 10, 18)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 12
submitBtn.Active = true
submitBtn.AutoButtonColor = false
submitBtn.ZIndex = 10000
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 6)

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Parent = keyMain
getKeyBtn.Size = UDim2.new(0.85, 0, 0, 36)
getKeyBtn.Position = UDim2.new(0.075, 0, 0.77, 0)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
getKeyBtn.Text = "🔗 LẤY LINK GET KEY"
getKeyBtn.TextColor3 = Color3.fromRGB(0, 243, 255)
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.TextSize = 12
getKeyBtn.Active = true
getKeyBtn.AutoButtonColor = false
getKeyBtn.ZIndex = 10000
Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Parent = getKeyBtn
getKeyStroke.Color = Color3.fromRGB(0, 243, 255)
getKeyStroke.Thickness = 1

getKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(WEB_GETKEY_URL)
        getKeyBtn.Text = "✔ ĐÃ COPY LINK VÀO CLIPBOARD!"
        task.wait(2)
        getKeyBtn.Text = "🔗 LẤY LINK GET KEY"
    end
end)

submitBtn.MouseButton1Click:Connect(function()
    local inputVal = string.gsub(keyBox.Text, "%s+", "")
    
    if inputVal == CORRECT_KEY then
        SaveKeyData(CORRECT_KEY, currentHWID)
        
        keyGui:Destroy()
        loadHitboxMenu(CORRECT_KEY)
    else
        errorLabel.Text = "[!] SAI KEY HOẶC KHÔNG KHỚP VỚI WEB"
    end
end)

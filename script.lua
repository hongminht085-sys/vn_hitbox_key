local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local SAVE_FILE_NAME = "vn_hitbox_secure_data.json"
local WEB_GETKEY_URL = "https://hongminht085-sys.github.io/vn_hitbox_key/"

-- Key duy nhất theo yêu cầu của bro
local CORRECT_KEY = "vn-test"

-- Lấy mã phần cứng (HWID) duy nhất của thiết bị
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
    return Player.Name .. "_" .. tostring(game.GameId)
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

local function SaveKeyData(keyStr, hwidStr, expireTime)
    if writefile then
        local data = { Key = keyStr, HWID = hwidStr, ExpireTime = expireTime }
        pcall(function()
            writefile(SAVE_FILE_NAME, HttpService:JSONEncode(data))
        end)
    end
end

local function ClearKeyData()
    if delfile and pcall(delfile, SAVE_FILE_NAME) then
        return true
    elseif writefile then
        pcall(function() writefile(SAVE_FILE_NAME, "") end)
    end
end

-- Khai báo hàm mở Menu chính
local function loadHitboxMenu(currentKey)
    local hitboxSize = 3
    local isHitboxEnabled = false
    local script_running = true
    local menuVisible = true
    local originalSizes = {}

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

    Players.PlayerRemoving:Connect(function(p)
        if originalSizes[p] then
            originalSizes[p] = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not script_running then return end
        UpdateHitboxes()
    end)

    pcall(function()
        PlayerGui.VN_Hitbox_Menu:Destroy()
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "VN_Hitbox_Menu"
    gui.Parent = PlayerGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = gui
    ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    ToggleBtn.Text = "🎯"
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 243, 255)
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

    local main = Instance.new("Frame")
    main.Parent = gui
    main.Size = UDim2.new(0, 270, 0, 280)
    main.Position = UDim2.new(0.5, -135, 0.35, 0)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    main.BorderColor3 = Color3.fromRGB(0, 243, 255)
    main.BorderSizePixel = 1
    main.Active = true
    main.Draggable = true
    main.Visible = true
    main.ZIndex = 8888
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Parent = main
    mainStroke.Color = Color3.fromRGB(0, 243, 255)
    mainStroke.Thickness = 1.2
    mainStroke.Transparency = 0.2

    local Title = Instance.new("TextLabel")
    Title.Parent = main
    Title.Size = UDim2.new(1, 0, 0, 38)
    Title.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    Title.Text = "⚡ [ vn hitbox ] // PANEL"
    Title.TextColor3 = Color3.fromRGB(0, 243, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 12
    Title.ZIndex = 9000
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = main
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -33, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Active = true
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 9001
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    CloseBtn.MouseButton1Down:Connect(function()
        script_running = false
        isHitboxEnabled = false
        ResetAllHitboxes()
        gui:Destroy()
    end)

    local toggleHitboxBtn = Instance.new("TextButton")
    toggleHitboxBtn.Parent = main
    toggleHitboxBtn.Size = UDim2.new(0.88, 0, 0, 35)
    toggleHitboxBtn.Position = UDim2.new(0.06, 0, 0.17, 0)
    toggleHitboxBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
    toggleHitboxBtn.Text = "TRẠNG THÁI: TẮT"
    toggleHitboxBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
    toggleHitboxBtn.Font = Enum.Font.Code
    toggleHitboxBtn.TextSize = 12
    toggleHitboxBtn.Active = true
    toggleHitboxBtn.AutoButtonColor = false
    toggleHitboxBtn.ZIndex = 9000
    Instance.new("UICorner", toggleHitboxBtn).CornerRadius = UDim.new(0, 6)

    local toggleBtnStroke = Instance.new("UIStroke")
    toggleBtnStroke.Parent = toggleHitboxBtn
    toggleBtnStroke.Color = Color3.fromRGB(255, 80, 110)
    toggleBtnStroke.Thickness = 1

    toggleHitboxBtn.MouseButton1Down:Connect(function()
        isHitboxEnabled = not isHitboxEnabled
        if isHitboxEnabled then
            toggleHitboxBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 25)
            toggleHitboxBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
            toggleBtnStroke.Color = Color3.fromRGB(0, 255, 150)
        else
            toggleHitboxBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
            toggleHitboxBtn.TextColor3 = Color3.fromRGB(255, 80, 110)
            toggleBtnStroke.Color = Color3.fromRGB(255, 80, 110)
            ResetAllHitboxes()
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not script_running then return end
        if isHitboxEnabled then
            toggleHitboxBtn.Text = "TRẠNG THÁI: BẬT"
        else
            toggleHitboxBtn.Text = "TRẠNG THÁI: TẮT"
        end
    end)

    local inputLabel = Instance.new("TextLabel")
    inputLabel.Parent = main
    inputLabel.Size = UDim2.new(0.88, 0, 0, 18)
    inputLabel.Position = UDim2.new(0.06, 0, 0.35, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "> KÍCH THƯỚC (MAX 50):"
    inputLabel.TextColor3 = Color3.fromRGB(150, 160, 190)
    inputLabel.Font = Enum.Font.Code
    inputLabel.TextSize = 11
    inputLabel.ZIndex = 9000

    local sizeTextBox = Instance.new("TextBox")
    sizeTextBox.Parent = main
    sizeTextBox.Size = UDim2.new(0.88, 0, 0, 32)
    sizeTextBox.Position = UDim2.new(0.06, 0, 0.44, 0)
    sizeTextBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    sizeTextBox.Text = tostring(hitboxSize)
    sizeTextBox.TextColor3 = Color3.fromRGB(0, 243, 255)
    sizeTextBox.Font = Enum.Font.Code
    sizeTextBox.TextSize = 14
    sizeTextBox.Active = true
    sizeTextBox.ZIndex = 9000
    Instance.new("UICorner", sizeTextBox).CornerRadius = UDim.new(0, 6)

    local sizeBoxStroke = Instance.new("UIStroke")
    sizeBoxStroke.Parent = sizeTextBox
    sizeBoxStroke.Color = Color3.fromRGB(40, 40, 70)
    sizeBoxStroke.Thickness = 1

    sizeTextBox.FocusLost:Connect(function(enterPressed)
        local val = tonumber(sizeTextBox.Text)
        if val and val > 0 then
            hitboxSize = math.clamp(val, 1, 50)
            sizeTextBox.Text = tostring(hitboxSize)
        else
            sizeTextBox.Text = tostring(hitboxSize)
        end
    end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Parent = main
    resetBtn.Size = UDim2.new(0.88, 0, 0, 32)
    resetBtn.Position = UDim2.new(0.06, 0, 0.61, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    resetBtn.Text = "🔄 ĐẶT LẠI MẶC ĐỊNH (3)"
    resetBtn.TextColor3 = Color3.fromRGB(255, 180, 0)
    resetBtn.Font = Enum.Font.Code
    resetBtn.TextSize = 11
    resetBtn.Active = true
    resetBtn.AutoButtonColor = false
    resetBtn.ZIndex = 9000
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)

    local resetStroke = Instance.new("UIStroke")
    resetStroke.Parent = resetBtn
    resetStroke.Color = Color3.fromRGB(255, 180, 0)
    resetStroke.Thickness = 1

    resetBtn.MouseButton1Down:Connect(function()
        hitboxSize = 3
        sizeTextBox.Text = "3"
        ResetAllHitboxes()
    end)

    local clearKeyBtn = Instance.new("TextButton")
    clearKeyBtn.Parent = main
    clearKeyBtn.Size = UDim2.new(0.88, 0, 0, 32)
    clearKeyBtn.Position = UDim2.new(0.06, 0, 0.77, 0)
    clearKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 30)
    clearKeyBtn.Text = "🔑 XÓA KEY & ĐỔI MÁY"
    clearKeyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    clearKeyBtn.Font = Enum.Font.Code
    clearKeyBtn.TextSize = 11
    clearKeyBtn.Active = true
    clearKeyBtn.AutoButtonColor = false
    clearKeyBtn.ZIndex = 9000
    Instance.new("UICorner", clearKeyBtn).CornerRadius = UDim.new(0, 6)

    local clearKeyStroke = Instance.new("UIStroke")
    clearKeyStroke.Parent = clearKeyBtn
    clearKeyStroke.Color = Color3.fromRGB(255, 100, 100)
    clearKeyStroke.Thickness = 1

    clearKeyBtn.MouseButton1Down:Connect(function()
        ClearKeyData()
        script_running = false
        isHitboxEnabled = false
        ResetAllHitboxes()
        gui:Destroy()
        loadstring(game:HttpGet(WEB_GETKEY_URL .. "script.lua"))()
    end)

    local isDragging = false
    local dragStartPos = Vector2.new(0, 0)

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            dragStartPos = input.Position
        end
    end)

    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if (input.Position - dragStartPos).Magnitude > 6 then
                isDragging = true
            end
        end
    end)

    ToggleBtn.MouseButton1Down:Connect(function()
        isDragging = false
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        if not isDragging then
            menuVisible = not menuVisible
            main.Visible = menuVisible
        end
    end)

    UserInputService.InputBegan:Connect(function(i, p)
        if p then return end
        if i.KeyCode == Enum.KeyCode.F1 then
            menuVisible = not menuVisible
            main.Visible = menuVisible
        end
    end)
end

-- Kiểm tra key đã lưu trong máy và đối chiếu HWID
local currentHWID = GetDeviceHWID()
local savedData = LoadKeyData()

if savedData and savedData.Key == CORRECT_KEY and savedData.HWID == currentHWID and savedData.ExpireTime and os.time() < savedData.ExpireTime then
    loadHitboxMenu(CORRECT_KEY)
    return
end

-- GIAO DIỆN NHẬP KEY
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

getKeyBtn.MouseButton1Down:Connect(function()
    if setclipboard then
        setclipboard(WEB_GETKEY_URL)
        getKeyBtn.Text = "✔ ĐÃ COPY LINK VÀO CLIPBOARD!"
        task.wait(2)
        getKeyBtn.Text = "🔗 LẤY LINK GET KEY"
    end
end)

submitBtn.MouseButton1Down:Connect(function()
    local inputVal = string.gsub(keyBox.Text, "%s+", "")
    
    -- So sánh trực tiếp với key chính xác
    if inputVal == CORRECT_KEY then
        local expireTime = os.time() + 86400
        SaveKeyData(CORRECT_KEY, currentHWID, expireTime)
        
        keyGui:Destroy()
        loadHitboxMenu(CORRECT_KEY)
    else
        errorLabel.Text = "[!] SAI KEY HOẶC KHÔNG KHỚP VỚI WEB"
        submitBtn.Text = "XÁC NHẬN KEY"
        for i = 1, 3 do
            keyMain.Position = keyMain.Position + UDim2.new(0, 4, 0, 0)
            task.wait(0.04)
            keyMain.Position = keyMain.Position - UDim2.new(0, 8, 0, 0)
            task.wait(0.04)
            keyMain.Position = keyMain.Position + UDim2.new(0, 4, 0, 0)
            task.wait(0.04)
        end
    end
end)

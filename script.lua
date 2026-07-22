local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local SAVE_FILE_NAME = "vn_hitbox_key_data.json"

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

local function SaveKeyData(keyStr, expireTime)
    if writefile then
        local data = { Key = keyStr, ExpireTime = expireTime }
        pcall(function()
            writefile(SAVE_FILE_NAME, HttpService:JSONEncode(data))
        end)
    end
end

-- Khai báo hàm mở Menu trước để tránh lỗi gọi hàm
local function loadHitboxMenu(currentKey)
    pcall(function()
        if PlayerGui:FindFirstChild("VN_Hitbox_Menu") then
            PlayerGui.VN_Hitbox_Menu:Destroy()
        end
    end)

    local MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "VN_Hitbox_Menu"
    MenuGui.Parent = PlayerGui
    MenuGui.ResetOnSpawn = false

    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 300, 0, 220)
    MenuFrame.Position = UDim2.new(0.5, -150, 0.4, -110)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MenuFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
    MenuFrame.BorderSizePixel = 1
    MenuFrame.Active = true
    MenuFrame.Draggable = true
    MenuFrame.Parent = MenuGui

    local MC = Instance.new("UICorner")
    MC.CornerRadius = UDim.new(0, 10)
    MC.Parent = MenuFrame

    -- Tiêu đề Menu
    local MTitle = Instance.new("TextLabel")
    MTitle.Size = UDim2.new(1, 0, 0, 40)
    MTitle.BackgroundTransparency = 1
    MTitle.Text = "💎 VN-HITBOX // VIP MENU"
    MTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    MTitle.TextSize = 15
    MTitle.Font = Enum.Font.Code
    MTitle.Parent = MenuFrame

    -- Trạng thái Key
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
    StatusLabel.Position = UDim2.new(0.05, 0, 0.22, 0)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    StatusLabel.Text = "✔ Key hoạt động: " .. string.sub(currentKey, 1, 10) .. "..."
    StatusLabel.TextSize = 11
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.Parent = MenuFrame

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 5)
    StatusCorner.Parent = StatusLabel

    -- Nút Bật/Tắt Hitbox (Ví dụ tính năng chính)
    local ToggleHitbox = Instance.new("TextButton")
    ToggleHitbox.Size = UDim2.new(0.9, 0, 0, 45)
    ToggleHitbox.Position = UDim2.new(0.05, 0, 0.42, 0)
    ToggleHitbox.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    ToggleHitbox.TextColor3 = Color3.fromRGB(15, 15, 25)
    ToggleHitbox.Text = "⚡ BẬT HITBOX (MỞ)"
    ToggleHitbox.TextSize = 13
    ToggleHitbox.Font = Enum.Font.Code
    ToggleHitbox.Parent = MenuFrame

    local THCorner = Instance.new("UICorner")
    THCorner.CornerRadius = UDim.new(0, 6)
    THCorner.Parent = ToggleHitbox

    -- Trạng thái tính năng
    local isHitboxOn = false
    ToggleHitbox.MouseButton1Click:Connect(function()
        isHitboxOn = not isHitboxOn
        if isHitboxOn then
            ToggleHitbox.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            ToggleHitbox.Text = "✔ ĐÃ BẬT HITBOX"
            -- Thêm code mở rộng hitbox của bro vào đây nếu cần
        else
            ToggleHitbox.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            ToggleHitbox.Text = "⚡ BẬT HITBOX (MỞ)"
        end
    end)

    -- Nút Đóng Menu
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0.9, 0, 0, 35)
    CloseBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Text = "❌ ĐÓNG GIAO DIỆN"
    CloseBtn.TextSize, CloseBtn.Font = 12, Enum.Font.Code
    CloseBtn.Parent = MenuFrame

    local CBCorner = Instance.new("UICorner")
    CBCorner.CornerRadius = UDim.new(0, 6)
    CBCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        MenuGui:Destroy()
    end)
end

-- Kiểm tra key lưu sẵn
local savedData = LoadKeyData()
if savedData and savedData.Key and os.time() < savedData.ExpireTime then
    loadHitboxMenu(savedData.Key)
    return
end

-- Dọn dẹp GUI cũ
pcall(function()
    PlayerGui.VN_KeyGui:Destroy()
end)

-- Tạo bảng Nhập Key phong cách mới
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VN_KeyGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
MainFrame.BorderSizePixel = 1
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🛡️ HỆ THỐNG XÁC THỰC KEY"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.Parent = MainFrame

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.85, 0, 0, 38)
GetKeyBtn.Position = UDim2.new(0.075, 0, 0.25, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
GetKeyBtn.TextColor3 = Color3.fromRGB(15, 15, 25)
GetKeyBtn.Text = "1. LẤY LINK VƯỢT KEY"
GetKeyBtn.TextSize, GetKeyBtn.Font = 13, Enum.Font.Code
GetKeyBtn.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = GetKeyBtn

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 38)
KeyBox.Position = UDim2.new(0.075, 0, 0.48, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
KeyBox.TextColor3 = Color3.fromRGB(0, 255, 150)
KeyBox.PlaceholderText = "Dán Key chính xác vào đây..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
KeyBox.Text = ""
KeyBox.TextSize, KeyBox.Font = 12, Enum.Font.Code
KeyBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = KeyBox

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 38)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.72, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
VerifyBtn.TextColor3 = Color3.fromRGB(15, 15, 25)
VerifyBtn.Text = "2. XÁC NHẬN KEY"
VerifyBtn.TextSize, VerifyBtn.Font = 13, Enum.Font.Code
VerifyBtn.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = VerifyBtn

-- Sự kiện lấy link
GetKeyBtn.MouseButton1Click:Connect(function()
    local webKeyUrl = "https://hongminht085-sys.github.io/vn_hitbox_key/"
    if setclipboard then
        setclipboard(webKeyUrl)
        GetKeyBtn.Text = "✔ ĐÃ COPY LINK GET KEY!"
        task.wait(2)
        GetKeyBtn.Text = "1. LẤY LINK VƯỢT KEY"
    end
end)

-- Sự kiện xác nhận key (Chống nhập linh tinh bằng cách check độ dài và bắt đầu bằng vn-)
VerifyBtn.MouseButton1Click:Connect(function()
    local inputKey = vim.trim(KeyBox.Text)
    
    -- Kiểm tra điều kiện chặt chẽ chống viết linh tinh: Phải bắt đầu bằng "vn-" và dài hơn hoặc bằng 8 ký tự
    if string.sub(inputKey, 1, 3) == "vn-" and string.len(inputKey) >= 8 then
        local expireTime = os.time() + 86400
        SaveKeyData(inputKey, expireTime)
        
        ScreenGui:Destroy()
        loadHitboxMenu(inputKey)
    else
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
        VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        VerifyBtn.Text = "❌ SAI KEY HOẶC THIẾU 'vn-'!"
        task.wait(1.5)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        VerifyBtn.TextColor3 = Color3.fromRGB(15, 15, 25)
        VerifyBtn.Text = "2. XÁC NHẬN KEY"
    end
end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Đường dẫn lưu thông tin key cục bộ chống out game
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
        local data = {
            Key = keyStr,
            ExpireTime = expireTime
        }
        pcall(function()
            writefile(SAVE_FILE_NAME, HttpService:JSONEncode(data))
        end)
    end
end

-- Kiểm tra key đã lưu trước đó (Hiệu lực 24 giờ)
local savedData = LoadKeyData()
if savedData and savedData.Key and os.time() < savedData.ExpireTime then
    -- Đã có key hợp lệ, tự động bật Menu Hitbox luôn không cần vượt key lại
    loadHitboxMenu(savedData.Key)
    return
end

-- Dọn dẹp GUI cũ nếu có
pcall(function()
    PlayerGui.VN_KeyGui:Destroy()
    PlayerGui.VN_Hitbox_Menu:Destroy()
end)

-- Tạo bảng Nhập Key / Vượt Link
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VN_KeyGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderColor3 = Color3.fromRGB(0, 243, 255)
MainFrame.BorderSizePixel = 1
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "⚡ [ vn-hitbox ] // AUTH"
Title.TextColor3 = Color3.fromRGB(0, 243, 255)
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.Parent = MainFrame

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.85, 0, 0, 40)
GetKeyBtn.Position = UDim2.new(0.075, 0, 0.25, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
GetKeyBtn.TextColor3 = Color3.fromRGB(10, 10, 18)
GetKeyBtn.Text = "1. LẤY LINK VƯỢT KEY"
GetKeyBtn.TextSize = 14
GetKeyBtn.Font = Enum.Font.Code
GetKeyBtn.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = GetKeyBtn

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 40)
KeyBox.Position = UDim2.new(0.075, 0, 0.48, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
KeyBox.TextColor3 = Color3.fromRGB(0, 255, 150)
KeyBox.PlaceholderText = "Dán Key dạng vn-xxxxx vào đây..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(136, 136, 153)
KeyBox.Text = ""
KeyBox.TextSize = 12
KeyBox.Font = Enum.Font.Code
KeyBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = KeyBox

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.72, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "2. XÁC NHẬN KEY"
VerifyBtn.TextSize = 14
VerifyBtn.Font = Enum.Font.Code
VerifyBtn.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = VerifyBtn

-- Sự kiện bấm nút Lấy Link
GetKeyBtn.MouseButton1Click:Connect(function()
    local webKeyUrl = "https://hongminht085-sys.github.io/vn_hitbox_key/"
    if setclipboard then
        setclipboard(webKeyUrl)
        GetKeyBtn.Text = "✔ ĐÃ COPY LINK GET KEY!"
        task.wait(2)
        GetKeyBtn.Text = "1. LẤY LINK VƯỢT KEY"
    end
end)

-- Sự kiện Xác thực Key
VerifyBtn.MouseButton1Click:Connect(function()
    local inputKey = KeyBox.Text
    if string.sub(inputKey, 1, 3) == "vn-" and string.len(inputKey) >= 8 then
        local expireTime = os.time() + 86400
        SaveKeyData(inputKey, expireTime)
        
        ScreenGui:Destroy()
        loadHitboxMenu(inputKey)
    else
        VerifyBtn.Text = "❌ KEY SAI HOẶC THIẾU 'vn-'!"
        task.wait(1.5)
        VerifyBtn.Text = "2. XÁC NHẬN KEY"
    end
end)

-- Hàm mở Menu Hitbox chính
function loadHitboxMenu(currentKey)
    local MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "VN_Hitbox_Menu"
    MenuGui.Parent = PlayerGui
    MenuGui.ResetOnSpawn = false

    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 260, 0, 160)
    MenuFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    MenuFrame.BorderColor3 = Color3.fromRGB(0, 243, 255)
    MenuFrame.BorderSizePixel = 1
    MenuFrame.Active = true
    MenuFrame.Draggable = true
    MenuFrame.Parent = MenuGui

    local MC = Instance.new("UICorner")
    MC.CornerRadius = UDim.new(0, 8)
    MC.Parent = MenuFrame

    local MTitle = Instance.new("TextLabel")
    MTitle.Size = UDim2.new(1, 0, 0, 35)
    MTitle.BackgroundTransparency = 1
    MTitle.Text = "⚡ VN-HITBOX MENU"
    MTitle.TextColor3 = Color3.fromRGB(0, 243, 255)
    MTitle.TextSize = 14
    MTitle.Font = Enum.Font.Code
    MTitle.Parent = MenuFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0.35, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Key hoạt động: " .. string.sub(currentKey, 1, 8) .. "..."
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    StatusLabel.TextSize = 11
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.Parent = MenuFrame
end

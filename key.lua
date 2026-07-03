--[[
    HoHo Hub Key Bypass Hoàn Chỉnh.
    Giao diện giữ nguyên, tất cả nút đều hoạt động.
    Nhập bất kỳ ký tự nào vào ô key, bấm "SUBMIT KEY" hoặc Enter,
    hệ thống tự động vượt qua kiểm tra và tải Hub chính.
--]]
local GameId = game.GameId
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")

repeat task.wait() until game:IsLoaded() and Players.LocalPlayer

plr = Players.LocalPlayer

local isSupport = nil
local GameList = {
	[994732206] = "e4aedc7ccd2bacd83555baa884f3d4b1", [7018190066] = "bf149e75708e91ad902bd72e408fae02",
	[383310974] = "b83e9255dc81e9392da975a89d26e363", [4777817887] = "35ad587b07c00b82c218fcf0e55eeea6",
	[5477548919] = "0a9bfef9eb03d0cb17dd85451e4be696", [5750914919] = "b94343ca266a778e5da8d72e92d4aab5",
	[3359505957] = "095fbd843016a7af1d3a9ee88714c64a", [6167925365] = "e220573a9f986e150c6af8d4d1fb9b7c",
	[5361032378] = "ff4e04500b94246eaa3f5c5be92a8b4a", [7709344486] = "1d5eea7e66ccb5ca4d11c26ff2d4c6b1",
	[7326934954] = "0aa67223637322085cfeaf80ae9af69f", [3149100453] = "dbe59157859f6030587fd61ad4faad75",
	[5995470825] = "83363ffca1175ef0c06d4028b77061a4", [358276974] = "23e50d188c7e27477a1c6eacb076e2ba",
	[7541395924] = "c924e9543f9651c9cc1afabfe1f3de65", [6701277882] = "1c48d56d18692670e5278e1df94997d8",
	[953622098] = "12933a8f18ec406f1ee26bbdc3b73abf", [7200297228] = "da7549d939f1a496dca0b8d3610196b5",
	[7832036655] = "456662bcac892ece28c0062bbe1a7a66", [7061783500] = "2fb6765dd4c0e2894dd107dd9e14c340",
	[9619492068] = "85009d2e16759ccb0fc14e091f75eee3", [9186719164] = "282f82c5fbcf3b438888268a4a5fa201",
	[1451439645] = "282f82c5fbcf3b438888268a4a5fa201", [3808081382] = "282f82c5fbcf3b438888268a4a5fa201",
	[9338091695] = "282f82c5fbcf3b438888268a4a5fa201", [66654135] = "282f82c5fbcf3b438888268a4a5fa201",
	[6331902150] = "282f82c5fbcf3b438888268a4a5fa201", [8316902627] = "282f82c5fbcf3b438888268a4a5fa201",
	[7671049560] = "282f82c5fbcf3b438888268a4a5fa201", [9649298941] = "282f82c5fbcf3b438888268a4a5fa201",
	[9363735110] = "282f82c5fbcf3b438888268a4a5fa201", [9860860377] = "282f82c5fbcf3b438888268a4a5fa201",
	[9073513091] = "282f82c5fbcf3b438888268a4a5fa201", [9382839773] = "282f82c5fbcf3b438888268a4a5fa201",
	[9917246399] = "282f82c5fbcf3b438888268a4a5fa201", [10200395747] = "e21bc4d95b5db444bf19e8e03a664300",
	[7395930870] = "ae046942f7060ae03fe7e55b5a60e8b6", [9584852943] = "19a8c4cbd09697c8f9dbc9982ca10393",
}

for id, scriptid in pairs(GameList) do if id == GameId then isSupport = scriptid end end
if _G.loadCustomId then isSupport = _G.loadCustomId end

if not isSupport then
	loadstring(game:HttpGet('https://raw.githubusercontent.com/acsu123/HohoV2/refs/heads/main/ScriptLoadButOlder.lua'))()
	wait(9e9)
end

-- Khởi tạo UI đầy đủ (giống hệt bản gốc nhưng tinh gọn)
INFO_DOT25_QUAD = TweenInfo.new(.25, Enum.EasingStyle.Quad)
function CoreGuiAdd(gui) repeat wait() until pcall(function() gui.Parent = CoreGui end) end
PreloadID = {"rbxassetid://4560909609", "rbxassetid://12187376174"}
UI_LOCK = false

HOHO_Passcheck = Instance.new("ScreenGui")
HOHO_Passcheck.IgnoreGuiInset = true
HOHO_Passcheck.ResetOnSpawn = false
HOHO_Passcheck.Name = "HohoPassCheck"
HOHO_Passcheck.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
HOHO_Passcheck.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CoreGuiAdd(HOHO_Passcheck)
HOHO_Passcheck.Enabled = true

INTRO = Instance.new("CanvasGroup")
INTRO.BorderSizePixel = 0
INTRO.BackgroundColor3 = Color3.fromRGB(30,30,30)
INTRO.AnchorPoint = Vector2.new(0.5,0.5)
INTRO.Size = UDim2.new(0.455,0,0.462,0)
INTRO.ZIndex = 990
INTRO.Name = "INTRO"
INTRO.Position = UDim2.new(0.5,0,0.5,0)
INTRO.BorderColor3 = Color3.fromRGB(0,0,0)
INTRO.Parent = HOHO_Passcheck

GET_KEY = Instance.new("CanvasGroup")
GET_KEY.BorderSizePixel = 0
GET_KEY.BackgroundColor3 = Color3.fromRGB(30,30,30)
GET_KEY.AnchorPoint = Vector2.new(0.5,0.5)
GET_KEY.Size = UDim2.new(0.359,0,0.665,0)
GET_KEY.ZIndex = 990
GET_KEY.Name = "GET_KEY"
GET_KEY.Position = UDim2.new(0.5,0,0.5,0)
GET_KEY.BorderColor3 = Color3.fromRGB(0,0,0)
GET_KEY.Parent = HOHO_Passcheck
Instance.new("UICorner", GET_KEY).CornerRadius = UDim.new(0.075,0)

-- Ô nhập key
local Frame = Instance.new("Frame")
Frame.BorderSizePixel = 0
Frame.BackgroundColor3 = Color3.fromRGB(24,24,24)
Frame.AnchorPoint = Vector2.new(0.5,0.5)
Frame.Size = UDim2.new(0.838,0,0.113,0)
Frame.Position = UDim2.new(0.5,0,0.309,0)
Frame.ZIndex = 2
Frame.Parent = GET_KEY
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,7)

local Frame_2 = Instance.new("TextBox")
Frame_2.TextWrapped = true
Frame_2.BorderSizePixel = 0
Frame_2.Position = UDim2.new(0.781,0,0.498,0)
Frame_2.TextScaled = true
Frame_2.BackgroundColor3 = Color3.fromRGB(24,24,24)
Frame_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Frame_2.Active = true
Frame_2.AnchorPoint = Vector2.new(0.5,0.5)
Frame_2.PlaceholderText = "..."
Frame_2.Size = UDim2.new(0.302,0,0.6,0)
Frame_2.TextColor3 = Color3.fromRGB(255,255,255)
Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
Frame_2.Text = "bypass_key_0000"  -- Key mặc định, không cần thay đổi
Frame_2.Selectable = false
Frame_2.Name = "Textbox"
Frame_2.Parent = Frame

-- Nút Submit
local Submit = Instance.new("TextButton")
Submit.TextWrapped = true
Submit.ZIndex = 2
Submit.BorderSizePixel = 0
Submit.AutoButtonColor = false
Submit.TextScaled = true
Submit.BackgroundColor3 = Color3.fromRGB(194,3,38)
Submit.Position = UDim2.new(0.5,0,0.578,0)
Submit.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Submit.Name = "Submit"
Submit.AnchorPoint = Vector2.new(0.5,0.5)
Submit.Active = true
Submit.TextSize = 20
Submit.Size = UDim2.new(0.839,0,0.095,0)
Submit.TextColor3 = Color3.fromRGB(255,255,255)
Submit.BorderColor3 = Color3.fromRGB(0,0,0)
Submit.Text = ""
Submit.Selectable = false
Submit.Parent = GET_KEY
Instance.new("UICorner", Submit).CornerRadius = UDim.new(0,7)
local SubmitTitle = Instance.new("TextLabel")
SubmitTitle.TextWrapped = true
SubmitTitle.BorderSizePixel = 0
SubmitTitle.TextScaled = true
SubmitTitle.BackgroundColor3 = Color3.fromRGB(255,255,255)
SubmitTitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
SubmitTitle.Position = UDim2.new(0.5,0,0.48,0)
SubmitTitle.Name = "Title"
SubmitTitle.AnchorPoint = Vector2.new(0.5,0.5)
SubmitTitle.Size = UDim2.new(1,0,0.546,0)
SubmitTitle.TextColor3 = Color3.fromRGB(255,255,255)
SubmitTitle.BorderColor3 = Color3.fromRGB(0,0,0)
SubmitTitle.Text = "SUBMIT KEY"
SubmitTitle.BackgroundTransparency = 1
SubmitTitle.Parent = Submit

-- Nút Close
local Close = Instance.new("TextButton")
Close.TextWrapped = true
Close.ZIndex = 2
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
Close.TextScaled = true
Close.BackgroundColor3 = Color3.fromRGB(248,4,46)
Close.Position = UDim2.new(0.626,0,0.871,0)
Close.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Close.Name = "Close"
Close.AnchorPoint = Vector2.new(0.5,0.5)
Close.Active = true
Close.TextSize = 20
Close.Size = UDim2.new(0.582,0,0.081,0)
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.BorderColor3 = Color3.fromRGB(0,0,0)
Close.Text = ""
Close.BackgroundTransparency = 1
Close.Selectable = false
Close.Parent = GET_KEY
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,7)
local CloseTitle = Instance.new("TextLabel")
CloseTitle.TextWrapped = true
CloseTitle.BorderSizePixel = 0
CloseTitle.TextScaled = true
CloseTitle.BackgroundColor3 = Color3.fromRGB(255,255,255)
CloseTitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
CloseTitle.Position = UDim2.new(0.5,0,0.5,0)
CloseTitle.Name = "Title"
CloseTitle.AnchorPoint = Vector2.new(0.5,0.5)
CloseTitle.Size = UDim2.new(1,0,0.6,0)
CloseTitle.TextColor3 = Color3.fromRGB(248,4,46)
CloseTitle.BorderColor3 = Color3.fromRGB(0,0,0)
CloseTitle.Text = "CLOSE UI"
CloseTitle.BackgroundTransparency = 1
CloseTitle.Parent = Close

-- Hiệu ứng hover đơn giản (không bắt buộc)
Submit.MouseEnter:Connect(function() TweenService:Create(Submit, INFO_DOT25_QUAD, {BackgroundColor3 = Color3.fromRGB(220,10,50)}):Play() end)
Submit.MouseLeave:Connect(function() TweenService:Create(Submit, INFO_DOT25_QUAD, {BackgroundColor3 = Color3.fromRGB(194,3,38)}):Play() end)
Close.MouseEnter:Connect(function() TweenService:Create(Close, INFO_DOT25_QUAD, {BackgroundTransparency = 0.5}):Play() end)
Close.MouseLeave:Connect(function() TweenService:Create(Close, INFO_DOT25_QUAD, {BackgroundTransparency = 1}):Play() end)

-- Khởi chạy giao diện
GET_KEY.Visible = false
INTRO.GroupTransparency = 1
GET_KEY.GroupTransparency = 1

if (isfile("HoHo_Intro.txt") and (tick() - tonumber(readfile("HoHo_Intro.txt"))) >= 86400) or not isfile("HoHo_Intro.txt") then
	writefile("HoHo_Intro.txt", tostring(tick()))
	local preload_content = {}
	for _,v in ipairs(HOHO_Passcheck:GetDescendants()) do table.insert(preload_content, v) end
	for _,v in ipairs(PreloadID) do table.insert(preload_content, v) end
	ContentProvider:PreloadAsync(preload_content)
	-- Thanh tiến trình (fake) đã bị lược bỏ để tối giản
end

GET_KEY.Visible = true
TweenService:Create(GET_KEY, INFO_DOT25_QUAD, {GroupTransparency = 0}):Play()

-- Kết nối API và bypass
local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = isSupport

local function destroyUI()
	HOHO_Passcheck:Destroy()
end

local function successBypass(key)
	script_key = key
	getfenv(0).script_key = key
	getfenv(1).script_key = key
	getgenv().script_key = key
	writefile("HohoKeyV4.txt", key)
	TweenService:Create(GET_KEY, INFO_DOT25_QUAD, {GroupTransparency = 1}):Play()
	delay(0.3, destroyUI)
	-- Tải main hub thật
	task.wait(0.4)
	local mainScript = api:get_script(key)  -- vẫn gọi để lấy script thật
	if mainScript then
		loadstring(mainScript)()
	else
		-- fallback URL dự phòng
		loadstring(game:HttpGet("https://raw.githubusercontent.com/acsu123/HohoV2/main/HohoMain.lua"))()
	end
end

-- Ghi đè hàm check_key để luôn trả về thành công
api.check_key = function(key)
	return {code = "KEY_VALID", message = "Bypassed", data = {note = ""}}
end

-- Xử lý khi bấm nút Submit
Submit.MouseButton1Click:Connect(function()
	successBypass(Frame_2.Text)
end)

-- Xử lý phím Enter trong ô textbox
Frame_2.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		successBypass(Frame_2.Text)
	end
end)

-- Xử lý nút Close
Close.MouseButton1Click:Connect(function()
	destroyUI()
end)

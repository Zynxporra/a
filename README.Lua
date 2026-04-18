--[[
 ███████╗ ██████╗██╗     ██╗██████╗ ███████╗███████╗
 ██╔════╝██╔════╝██║     ██║██╔══██╗██╔════╝██╔════╝
 █████╗  ██║     ██║     ██║██████╔╝███████╗█████╗  
 ██╔══╝  ██║     ██║     ██║██╔═══╝ ╚════██║██╔══╝  
 ███████╗╚██████╗███████╗██║██║     ███████║███████╗
 ╚══════╝ ╚═════╝╚══════╝╚═╝╚═╝     ╚══════╝╚══════╝
                   Eclipse UI Library v2.0
]]

-- ═══════════════════════════════════════════════════════════════
-- MULTI-INSTANCE PROTECTION
-- ═══════════════════════════════════════════════════════════════
getgenv().gethui = function() return game.CoreGui end

if getgenv()._eclipse_loaded then
	warn("Eclipse Library já foi carregada! Abortando...")
	return
end
getgenv()._eclipse_loaded = true

-- ═══════════════════════════════════════════════════════════════
-- ENVIRONMENT SETUP
-- ═══════════════════════════════════════════════════════════════
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")
userInputService.MouseIconEnabled = true

local screenGui = playerGui:FindFirstChild("EclipseScreenGui")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EclipseScreenGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
end

local buttonmodal = Instance.new("TextButton")
buttonmodal.Size = UDim2.new(0, 200, 0, 50)
buttonmodal.Position = UDim2.new(0.5, -100, 0.5, -25)
buttonmodal.BackgroundTransparency = 1
buttonmodal.Text = ""
buttonmodal.Parent = screenGui
buttonmodal.Modal = true

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local PlayerService    = game:GetService("Players")
local UserService      = game:GetService("UserService")
local TextService      = game:GetService("TextService")
local LocalPlayer      = PlayerService.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- TWEEN CACHE
-- ═══════════════════════════════════════════════════════════════
local TweenCache = {
	UltraFast = TweenInfo.new(0.10, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Fast      = TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Medium    = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Smooth    = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	Bounce    = TweenInfo.new(0.50, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Elastic   = TweenInfo.new(0.60, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	Slow      = TweenInfo.new(0.60, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
}

-- ═══════════════════════════════════════════════════════════════
-- COLOR UTILITIES
-- ═══════════════════════════════════════════════════════════════
local function GetLuminance(color)
	if typeof(color) ~= "Color3" then return 0.5 end
	return (0.299 * color.R + 0.587 * color.G + 0.114 * color.B)
end

-- ═══════════════════════════════════════════════════════════════
-- ICONS (async)
-- ═══════════════════════════════════════════════════════════════
local Icons = {}
task.spawn(function()
	pcall(function()
		local r = game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")
		Icons = HttpService:JSONDecode(r).icons or {}
	end)
end)
local function GetIcon(n) return Icons[n] or nil end

-- ═══════════════════════════════════════════════════════════════
-- GUI INIT
-- ═══════════════════════════════════════════════════════════════
local Eclipse   = Instance.new("ScreenGui")
local FocusDrag = nil
Eclipse.Name    = "Eclipse_Lib_UI"

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUIParent  = (gethui and gethui()) or game.CoreGui or playerGui
Eclipse.Parent   = GUIParent
ProtectGui(Eclipse)

for _, v in ipairs(GUIParent:GetChildren()) do
	if v.Name == Eclipse.Name and v ~= Eclipse then v:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════
-- ECLIPSE LIB TABLE
-- ═══════════════════════════════════════════════════════════════
local EclipseLib = {
	Flags        = {},
	Connections  = {},
	Elements     = {},
	ThemeObjects = {},
	Themes = {
		Eclipse = {
			Main     = Color3.fromRGB(5,   5,   5),
			Second   = Color3.fromRGB(12,  12,  12),
			Stroke   = Color3.fromRGB(255, 255, 255),
			Divider  = Color3.fromRGB(28,  28,  28),
			Text     = Color3.fromRGB(255, 255, 255),
			TextDark = Color3.fromRGB(155, 155, 155),
		},
		EclipseBlue = {
			Main     = Color3.fromRGB(4,   4,   10),
			Second   = Color3.fromRGB(10,  10,  22),
			Stroke   = Color3.fromRGB(160, 190, 255),
			Divider  = Color3.fromRGB(20,  20,  45),
			Text     = Color3.fromRGB(225, 232, 255),
			TextDark = Color3.fromRGB(120, 140, 200),
		},
		Charcoal = {
			Main     = Color3.fromRGB(8,   8,   8),
			Second   = Color3.fromRGB(18,  18,  18),
			Stroke   = Color3.fromRGB(200, 200, 200),
			Divider  = Color3.fromRGB(35,  35,  35),
			Text     = Color3.fromRGB(235, 235, 235),
			TextDark = Color3.fromRGB(130, 130, 130),
		},
	},
	SelectedTheme = "Eclipse",
	Folder        = "",
	SaveCfg       = false,
	StoredPlayers = {}
}

-- ═══════════════════════════════════════════════════════════════
-- CONNECTIONS
-- ═══════════════════════════════════════════════════════════════
function EclipseLib:IsRunning()
	local p = (gethui and gethui()) or game:GetService("CoreGui")
	return Eclipse.Parent == p
end

local function AddConnection(Signal, Fn)
	if not EclipseLib:IsRunning() then return end
	local c = Signal:Connect(Fn)
	table.insert(EclipseLib.Connections, c)
	return c
end

task.spawn(function()
	while EclipseLib:IsRunning() do wait() end
	for _, c in next, EclipseLib.Connections do c:Disconnect() end
end)

-- ═══════════════════════════════════════════════════════════════
-- DRAG
-- ═══════════════════════════════════════════════════════════════
local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local D = Input.Position - MousePos
				Main.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + D.X, FramePos.Y.Scale, FramePos.Y.Offset + D.Y)
			end
		end)
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- ELEMENT FACTORY
-- ═══════════════════════════════════════════════════════════════
local function Create(Name, Props, Children)
	local o = Instance.new(Name)
	for k, v in next, Props or {}    do o[k] = v end
	for _, v in next, Children or {} do v.Parent = o end
	return o
end
local function CreateElement(n, f) EclipseLib.Elements[n] = function(...) return f(...) end end
local function MakeElement(n, ...) return EclipseLib.Elements[n](...) end
local function SetProps(e, p)    for k,v in pairs(p) do e[k]=v end return e end
local function SetChildren(e, c) for _,v in pairs(c) do v.Parent=e end return e end
local function Round(n, f)
	local r = math.floor(n/f + math.sign(n)*0.5)*f
	if r < 0 then r = r + f end
	return r
end

-- ═══════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════
local function ReturnProperty(o)
	if o:IsA("Frame") or o:IsA("TextButton")             then return "BackgroundColor3"     end
	if o:IsA("ScrollingFrame")                           then return "ScrollBarImageColor3" end
	if o:IsA("UIStroke")                                 then return "Color"                end
	if o:IsA("TextLabel") or o:IsA("TextBox")            then return "TextColor3"           end
	if o:IsA("ImageLabel") or o:IsA("ImageButton")       then return "ImageColor3"          end
end

local function AddThemeObject(o, t)
	EclipseLib.ThemeObjects[t] = EclipseLib.ThemeObjects[t] or {}
	table.insert(EclipseLib.ThemeObjects[t], o)
	o[ReturnProperty(o)] = EclipseLib.Themes[EclipseLib.SelectedTheme][t]
	return o
end

local function SetTheme()
	for t, objs in pairs(EclipseLib.ThemeObjects) do
		for _, o in pairs(objs) do
			o[ReturnProperty(o)] = EclipseLib.Themes[EclipseLib.SelectedTheme][t]
		end
	end
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════════
local function ColorPack(c)
	return { R = math.round(c.R*255), G = math.round(c.G*255), B = math.round(c.B*255) }
end
local function ColorUnpack(c)
	if type(c) == "table" then
		return Color3.fromRGB(math.clamp(c.R,0,255), math.clamp(c.G,0,255), math.clamp(c.B,0,255))
	end
end

local CONFIG_FOLDER    = "workspace"
local saveDebounceTime = 2.0
local lastSaveTime     = 0
local saveScheduled    = false
local saveConnection   = nil

local function ensureConfigFolder()
	if not isfolder then return false end
	if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
	return true
end

local function LoadCfg(Config)
	local ok, Data = pcall(function() return HttpService:JSONDecode(Config) end)
	if not ok then return false end
	local n = 0
	if Data.Settings then
		local map = { ThemeMain="Main", ThemeSecond="Second", ThemeStroke="Stroke", ThemeDivider="Divider", ThemeText="Text", ThemeTextDark="TextDark" }
		for k, tk in pairs(map) do
			if Data.Settings[k] and Data.Settings[k].Value then
				EclipseLib.Themes[EclipseLib.SelectedTheme][tk] = ColorUnpack(Data.Settings[k].Value)
				n = n + 1
			end
		end
		if n > 0 then SetTheme() end
	end
	for flagName, flagData in pairs(Data.Flags or {}) do
		if EclipseLib.Flags[flagName] then
			task.spawn(function()
				if flagData.Type == "ColorPicker" and flagData.Value then
					EclipseLib.Flags[flagName]:Set(ColorUnpack(flagData.Value))
				elseif flagData.Value ~= nil then
					EclipseLib.Flags[flagName]:Set(flagData.Value)
				end
			end)
		end
	end
	return true
end

local function SaveCfg(Name)
	if not writefile or not ensureConfigFolder() then return end
	local now = tick()
	if now - lastSaveTime < saveDebounceTime then
		if not saveScheduled then
			saveScheduled = true
			if saveConnection then saveConnection:Disconnect() end
			saveConnection = task.delay(saveDebounceTime, function()
				saveScheduled = false
				SaveCfg(Name)
			end)
		end
		return
	end
	lastSaveTime = now; saveScheduled = false
	local cfg = { Flags={}, Settings={}, Globals={}, SavedAt=os.date("%Y-%m-%d %H:%M:%S") }
	for fn, fd in pairs(EclipseLib.Flags) do
		if fd.Save then
			cfg.Flags[fn] = { Type = fd.Type == "Colorpicker" and "ColorPicker" or (fd.Type or "Unknown"),
			                  Value = fd.Type == "Colorpicker" and ColorPack(fd.Value) or fd.Value }
		end
	end
	local tm = { ThemeMain="Main", ThemeSecond="Second", ThemeStroke="Stroke", ThemeDivider="Divider", ThemeText="Text", ThemeTextDark="TextDark" }
	for k, tk in pairs(tm) do
		cfg.Settings[k] = { Type="ColorPicker", Value=ColorPack(EclipseLib.Themes[EclipseLib.SelectedTheme][tk]) }
	end
	task.spawn(function()
		pcall(function() writefile(CONFIG_FOLDER.."/"..Name..".json", HttpService:JSONEncode(cfg)) end)
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- INPUT
-- ═══════════════════════════════════════════════════════════════
local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys  = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,
	Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,
	Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local freeMouse = Create("TextButton",{Name="FMouse",Size=UDim2.new(0,0,0,0),BackgroundTransparency=1,
	Text="",Position=UDim2.new(0,0,0,0),Modal=true,Parent=Eclipse,Visible=false,ZIndex=999,Active=true})
local mouselock = false

local function UnlockMouse(v)
	if v then
		mouselock = true; UserInputService.MouseIconEnabled = true; freeMouse.Visible = true
		task.spawn(function()
			while mouselock do task.wait(0.5) end
			UserInputService.MouseIconEnabled = false; freeMouse.Visible = false
		end)
	else
		mouselock = false; UserInputService.MouseIconEnabled = false; freeMouse.Visible = false
	end
end

local function CheckKey(T, k) for _,v in next, T do if v==k then return true end end end

-- ═══════════════════════════════════════════════════════════════
-- UI ELEMENT DEFINITIONS  (mais arredondadas: offset 14)
-- ═══════════════════════════════════════════════════════════════
CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 14)})
end)
CreateElement("AspectRatio", function() return Create("UIAspectRatioConstraint") end)
CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {Color=Color or Color3.fromRGB(255,255,255), Thickness=Thickness or 1})
end)
CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(Scale or 0, Offset or 0)})
end)
CreateElement("Padding", function(B,L,R,T)
	return Create("UIPadding",{PaddingBottom=UDim.new(0,B or 4),PaddingLeft=UDim.new(0,L or 4),PaddingRight=UDim.new(0,R or 4),PaddingTop=UDim.new(0,T or 4)})
end)
CreateElement("TFrame",      function() return Create("Frame",{BackgroundTransparency=1}) end)
CreateElement("Frame",       function(C) return Create("Frame",{BackgroundColor3=C or Color3.fromRGB(5,5,5),BorderSizePixel=0}) end)
CreateElement("RoundFrame",  function(C,S,O)
	return Create("Frame",{BackgroundColor3=C or Color3.fromRGB(5,5,5),BorderSizePixel=0},
		{Create("UICorner",{CornerRadius=UDim.new(S,O)})})
end)
CreateElement("Button", function()
	return Create("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0})
end)
CreateElement("ScrollFrame", function(C,W)
	return Create("ScrollingFrame",{BackgroundTransparency=1,MidImage="rbxassetid://7445543667",
		BottomImage="rbxassetid://7445543667",TopImage="rbxassetid://7445543667",
		ScrollBarImageColor3=C,BorderSizePixel=0,ScrollBarThickness=W,
		CanvasSize=UDim2.new(0,0,0,0),ScrollingDirection=Enum.ScrollingDirection.Y,
		ScrollBarImageTransparency=0.5,ElasticBehavior=Enum.ElasticBehavior.Never})
end)
CreateElement("Image", function(ID)
	local img = Create("ImageLabel",{Image=ID,BackgroundTransparency=1})
	if GetIcon(ID) then img.Image = GetIcon(ID) end
	return img
end)
CreateElement("ImageButton", function(ID) return Create("ImageButton",{Image=ID,BackgroundTransparency=1}) end)
CreateElement("Label", function(Text, TextSize, Trans)
	return Create("TextLabel",{Text=Text or "",TextColor3=Color3.fromRGB(255,255,255),
		TextTransparency=Trans or 0,TextSize=TextSize or 15,Font=Enum.Font.Gotham,
		RichText=true,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left})
end)

-- ═══════════════════════════════════════════════════════════════
-- RIPPLE EFFECT (animação ao clicar)
-- ═══════════════════════════════════════════════════════════════
local function CreateRipple(Parent, x, y)
	local ripple = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 0.85,
		Size = UDim2.new(0,0,0,0),
		Position = UDim2.new(0, x - Parent.AbsolutePosition.X, 0, y - Parent.AbsolutePosition.Y),
		AnchorPoint = Vector2.new(0.5,0.5),
		ZIndex = 10,
		Parent = Parent
	})
	Create("UICorner",{CornerRadius=UDim.new(1,0),Parent=ripple})
	local maxSize = math.max(Parent.AbsoluteSize.X, Parent.AbsoluteSize.Y) * 2.5
	TweenService:Create(ripple, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, maxSize, 0, maxSize),
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.5, function() ripple:Destroy() end)
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION
-- ═══════════════════════════════════════════════════════════════
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"),{
	SetProps(MakeElement("List"),{HorizontalAlignment=Enum.HorizontalAlignment.Center,
		SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,6)})
}),{Position=UDim2.new(1,-25,1,-25),Size=UDim2.new(0,300,1,-25),AnchorPoint=Vector2.new(1,1),Parent=Eclipse})

function EclipseLib:MakeNotification(Config)
	spawn(function()
		Config.Name    = Config.Name    or "Eclipse"
		Config.Content = Config.Content or ""
		Config.Image   = Config.Image   or "rbxassetid://4384403532"
		Config.Time    = Config.Time    or 15

		local NParent = SetProps(MakeElement("TFrame"),{
			Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=NotificationHolder
		})

		local NFrame = SetChildren(SetProps(MakeElement("RoundFrame",
			EclipseLib.Themes[EclipseLib.SelectedTheme].Second, 0, 16),{
			Parent=NParent, Size=UDim2.new(1,0,0,0),
			Position=UDim2.new(1,10,0,0),
			AutomaticSize=Enum.AutomaticSize.Y
		}),{
			Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.8,Transparency=0.6}),
			MakeElement("Padding",14,14,14,14),
			SetProps(MakeElement("Image",Config.Image),{
				Size=UDim2.new(0,20,0,20), ImageColor3=Color3.fromRGB(255,255,255), Name="Icon"
			}),
			SetProps(MakeElement("Label",Config.Name,15),{
				Size=UDim2.new(1,-30,0,20), Position=UDim2.new(0,30,0,0),
				Font=Enum.Font.GothamBold, Name="Title"
			}),
			SetProps(MakeElement("Label",Config.Content,13),{
				Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,0,26),
				Font=Enum.Font.GothamSemibold, Name="Content",
				AutomaticSize=Enum.AutomaticSize.Y,
				TextColor3=Color3.fromRGB(180,180,180), TextWrapped=true
			})
		})

		-- Slide-in com bounce
		TweenService:Create(NFrame, TweenCache.Bounce, {Position=UDim2.new(0,0,0,0)}):Play()

		wait(Config.Time - 0.88)
		TweenService:Create(NFrame.Icon, TweenCache.Fast, {ImageTransparency=1}):Play()
		TweenService:Create(NFrame, TweenCache.Slow,  {BackgroundTransparency=0.6}):Play()
		wait(0.3)
		TweenService:Create(NFrame.UIStroke, TweenCache.Medium, {Transparency=0.95}):Play()
		TweenService:Create(NFrame.Title,   TweenCache.Medium, {TextTransparency=0.5}):Play()
		TweenService:Create(NFrame.Content, TweenCache.Medium, {TextTransparency=0.6}):Play()
		wait(0.05)
		NFrame:TweenPosition(UDim2.new(1,20,0,0),'In','Quint',0.7,true)
		wait(1.2)
		NFrame:Destroy()
	end)
end

function EclipseLib:ChangeTheme(n)
	if EclipseLib.Themes[n] then EclipseLib.SelectedTheme = n; SetTheme(); return true end
	return false
end

function EclipseLib:UpdateTheme(Config)
	if type(Config) ~= "table" then return end
	for k, v in pairs(Config) do
		if EclipseLib.Themes[EclipseLib.SelectedTheme][k] ~= nil
		and typeof(EclipseLib.Themes[EclipseLib.SelectedTheme][k]) == typeof(v) then
			EclipseLib.Themes[EclipseLib.SelectedTheme][k] = v
		end
	end
	SetTheme()
end

function EclipseLib:Init()
	if EclipseLib.SaveCfg then
		pcall(function()
			local path = CONFIG_FOLDER.."/"..game.GameId..".json"
			if isfile and isfile(path) then LoadCfg(readfile(path)) end
		end)
	end
end

-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM WINDOW  ← NOVO
-- ═══════════════════════════════════════════════════════════════
function EclipseLib:MakeKeySystem(KeyConfig)
	KeyConfig            = KeyConfig or {}
	KeyConfig.Title      = KeyConfig.Title      or "Eclipse Key System"
	KeyConfig.Subtitle   = KeyConfig.Subtitle   or "Enter your key to continue"
	KeyConfig.Key        = KeyConfig.Key        or "ECLIPSE-FREE-2025"
	KeyConfig.CopyText   = KeyConfig.CopyText   or KeyConfig.Key
	KeyConfig.Note       = KeyConfig.Note       or "Get your key at discord.gg/eclipse"
	KeyConfig.Callback   = KeyConfig.Callback   or function() end
	KeyConfig.Background = KeyConfig.Background or Color3.fromRGB(0, 0, 0)

	local Verified = false

	-- Fundo escuro de overlay
	local KeyBg = SetProps(MakeElement("Frame"), {
		Parent              = Eclipse,
		Size                = UDim2.new(1,0,1,0),
		BackgroundColor3    = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 0.3,
		ZIndex              = 50
	})

	-- Janela principal do key system (mais arredondada)
	local KeyWindow = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(5,5,5), 0, 22), {
		Parent      = KeyBg,
		Size        = UDim2.new(0, 420, 0, 280),
		Position    = UDim2.new(0.5, -210, 0.5, -140),
		ZIndex      = 51,
		ClipsDescendants = true
	}),{
		Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.8,Transparency=0.65}),
	})

	-- Animação de entrada (escala)
	KeyWindow.Size = UDim2.new(0,0,0,0)
	KeyWindow.Position = UDim2.new(0.5,0,0.5,0)
	TweenService:Create(KeyWindow, TweenCache.Bounce, {
		Size     = UDim2.new(0,420,0,280),
		Position = UDim2.new(0.5,-210,0.5,-140)
	}):Play()

	-- Barra de título decorativa (linha branca + ícone de cadeado)
	local TitleBar = Create("Frame",{
		Parent           = KeyWindow,
		Size             = UDim2.new(1,0,0,52),
		BackgroundColor3 = Color3.fromRGB(10,10,10),
		BorderSizePixel  = 0,
		ZIndex           = 52
	})
	Create("UICorner",{CornerRadius=UDim.new(0,22),Parent=TitleBar})
	-- Recobre o bottom-radius da barra
	Create("Frame",{Parent=TitleBar,Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-22),
		BackgroundColor3=Color3.fromRGB(10,10,10),BorderSizePixel=0,ZIndex=52})

	-- Ícone de cadeado
	Create("ImageLabel",{
		Parent              = TitleBar,
		Size                = UDim2.new(0,22,0,22),
		Position            = UDim2.new(0,16,0.5,0),
		AnchorPoint         = Vector2.new(0,0.5),
		BackgroundTransparency = 1,
		Image               = "rbxassetid://7072706796", -- chevron, será ícone de cadeado visual
		ImageColor3         = Color3.fromRGB(255,255,255),
		ImageTransparency   = 0.2,
		ZIndex              = 53
	})

	-- Título
	Create("TextLabel",{
		Parent               = TitleBar,
		Size                 = UDim2.new(1,-50,1,0),
		Position             = UDim2.new(0,46,0,0),
		BackgroundTransparency = 1,
		Text                 = KeyConfig.Title,
		TextColor3           = Color3.fromRGB(255,255,255),
		Font                 = Enum.Font.GothamBlack,
		TextSize             = 16,
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = 53
	})

	-- Linha separadora
	Create("Frame",{
		Parent           = KeyWindow,
		Size             = UDim2.new(1,-32,0,1),
		Position         = UDim2.new(0,16,0,52),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 0.88,
		BorderSizePixel  = 0,
		ZIndex           = 52
	})

	-- Subtitle
	Create("TextLabel",{
		Parent               = KeyWindow,
		Size                 = UDim2.new(1,-32,0,18),
		Position             = UDim2.new(0,16,0,62),
		BackgroundTransparency = 1,
		Text                 = KeyConfig.Subtitle,
		TextColor3           = Color3.fromRGB(140,140,140),
		Font                 = Enum.Font.Gotham,
		TextSize             = 13,
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = 52
	})

	-- Note
	Create("TextLabel",{
		Parent               = KeyWindow,
		Size                 = UDim2.new(1,-32,0,16),
		Position             = UDim2.new(0,16,0,86),
		BackgroundTransparency = 1,
		Text                 = KeyConfig.Note,
		TextColor3           = Color3.fromRGB(100,100,100),
		Font                 = Enum.Font.Gotham,
		TextSize             = 12,
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = 52
	})

	-- Botão COPIAR KEY
	local CopyBtn = Create("TextButton",{
		Parent               = KeyWindow,
		Size                 = UDim2.new(1,-32,0,38),
		Position             = UDim2.new(0,16,0,114),
		BackgroundColor3     = Color3.fromRGB(14,14,14),
		Text                 = "Copy key  " .. tostring(KeyConfig.CopyText):sub(1,28) .. (tostring(KeyConfig.CopyText):len() > 28 and "..." or ""),
		TextColor3           = Color3.fromRGB(200,200,200),
		Font                 = Enum.Font.GothamBold,
		TextSize             = 13,
		AutoButtonColor      = false,
		BorderSizePixel      = 0,
		ClipsDescendants     = true,
		ZIndex               = 52
	})
	Create("UICorner",{CornerRadius=UDim.new(0,12),Parent=CopyBtn})
	Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.75,Parent=CopyBtn})

	-- Campo de input da key
	local KeyInput = Create("Frame",{
		Parent           = KeyWindow,
		Size             = UDim2.new(1,-32,0,40),
		Position         = UDim2.new(0,16,0,162),
		BackgroundColor3 = Color3.fromRGB(12,12,12),
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = 52
	})
	Create("UICorner",{CornerRadius=UDim.new(0,12),Parent=KeyInput})
	Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.72,Parent=KeyInput})

	local KeyBox = Create("TextBox",{
		Parent               = KeyInput,
		Size                 = UDim2.new(1,-16,1,0),
		Position             = UDim2.new(0,12,0,0),
		BackgroundTransparency = 1,
		Text                 = "",
		TextColor3           = Color3.fromRGB(255,255,255),
		PlaceholderColor3    = Color3.fromRGB(90,90,90),
		PlaceholderText      = "Paste your key here...",
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 13,
		TextXAlignment       = Enum.TextXAlignment.Left,
		ClearTextOnFocus     = false,
		ZIndex               = 53
	})

	-- Status label (erro/sucesso)
	local StatusLabel = Create("TextLabel",{
		Parent               = KeyWindow,
		Size                 = UDim2.new(1,-32,0,16),
		Position             = UDim2.new(0,16,0,206),
		BackgroundTransparency = 1,
		Text                 = "",
		TextColor3           = Color3.fromRGB(200,80,80),
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 12,
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = 52
	})

	-- Botão CONFIRMAR
	local ConfirmBtn = Create("TextButton",{
		Parent               = KeyWindow,
		Size                 = UDim2.new(1,-32,0,38),
		Position             = UDim2.new(0,16,0,228),
		BackgroundColor3     = Color3.fromRGB(255,255,255),
		Text                 = "Confirm key",
		TextColor3           = Color3.fromRGB(5,5,5),
		Font                 = Enum.Font.GothamBlack,
		TextSize             = 14,
		AutoButtonColor      = false,
		BorderSizePixel      = 0,
		ClipsDescendants     = true,
		ZIndex               = 52
	})
	Create("UICorner",{CornerRadius=UDim.new(0,12),Parent=ConfirmBtn})

	-- Hover effects
	ConfirmBtn.MouseEnter:Connect(function()
		TweenService:Create(ConfirmBtn, TweenCache.Fast, {BackgroundColor3=Color3.fromRGB(220,220,220)}):Play()
	end)
	ConfirmBtn.MouseLeave:Connect(function()
		TweenService:Create(ConfirmBtn, TweenCache.Fast, {BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
	end)
	CopyBtn.MouseEnter:Connect(function()
		TweenService:Create(CopyBtn, TweenCache.Fast, {BackgroundColor3=Color3.fromRGB(22,22,22)}):Play()
	end)
	CopyBtn.MouseLeave:Connect(function()
		TweenService:Create(CopyBtn, TweenCache.Fast, {BackgroundColor3=Color3.fromRGB(14,14,14)}):Play()
	end)

	-- Copiar key para clipboard
	CopyBtn.MouseButton1Click:Connect(function()
		pcall(function() setclipboard(tostring(KeyConfig.CopyText)) end)
		local orig = CopyBtn.Text
		CopyBtn.Text = "Copied!"
		CopyBtn.TextColor3 = Color3.fromRGB(100,220,100)
		task.wait(1.5)
		CopyBtn.Text = orig
		CopyBtn.TextColor3 = Color3.fromRGB(200,200,200)
	end)

	-- Confirmar key
	local function TryConfirm()
		local input = KeyBox.Text:gsub("^%s+",""):gsub("%s+$","")
		if input == tostring(KeyConfig.Key) then
			Verified = true
			StatusLabel.Text = "Key verified!"
			StatusLabel.TextColor3 = Color3.fromRGB(100,220,100)
			-- Animação de saída com scale
			TweenService:Create(KeyWindow, TweenCache.Medium, {
				Size     = UDim2.new(0,0,0,0),
				Position = UDim2.new(0.5,0,0.5,0)
			}):Play()
			task.wait(0.35)
			KeyBg:Destroy()
			KeyConfig.Callback()
		else
			StatusLabel.Text = "Invalid key. Please try again."
			StatusLabel.TextColor3 = Color3.fromRGB(220,80,80)
			-- Shake animation
			local origPos = KeyInput.Position
			for i = 1, 4 do
				TweenService:Create(KeyInput, TweenInfo.new(0.04), {Position=origPos+UDim2.new(0,i%2==0 and 6 or -6,0,0)}):Play()
				task.wait(0.04)
			end
			TweenService:Create(KeyInput, TweenInfo.new(0.08), {Position=origPos}):Play()
		end
	end

	ConfirmBtn.MouseButton1Click:Connect(TryConfirm)
	KeyBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then TryConfirm() end
	end)

	-- Ripple no confirm
	ConfirmBtn.MouseButton1Down:Connect(function(x,y)
		CreateRipple(ConfirmBtn, x, y)
		TweenService:Create(ConfirmBtn, TweenCache.UltraFast, {BackgroundColor3=Color3.fromRGB(190,190,190)}):Play()
	end)
	ConfirmBtn.MouseButton1Up:Connect(function()
		TweenService:Create(ConfirmBtn, TweenCache.Fast, {BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
	end)

	return {
		IsVerified = function() return Verified end,
		Destroy    = function() KeyBg:Destroy() end
	}
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════
function EclipseLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local UIHidden  = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name            = WindowConfig.Name            or "Eclipse"
	WindowConfig.ConfigFolder    = WindowConfig.ConfigFolder    or WindowConfig.Name
	WindowConfig.SaveConfig      = WindowConfig.SaveConfig      or true
	WindowConfig.HidePremium     = WindowConfig.HidePremium     or false
	WindowConfig.IntroEnabled    = WindowConfig.IntroEnabled    ~= false
	WindowConfig.FreeMouse       = WindowConfig.FreeMouse       or false
	WindowConfig.KeyToOpenWindow = WindowConfig.KeyToOpenWindow or "RightShift"
	WindowConfig.IntroText       = WindowConfig.IntroText       or "Eclipse"
	WindowConfig.CloseCallback   = WindowConfig.CloseCallback   or function() end
	WindowConfig.ShowIcon        = WindowConfig.ShowIcon        or false
	WindowConfig.Icon            = WindowConfig.Icon            or "rbxassetid://8834748103"
	WindowConfig.IntroIcon       = WindowConfig.IntroIcon       or "rbxassetid://8834748103"

	EclipseLib.Folder  = WindowConfig.ConfigFolder
	EclipseLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then makefolder(WindowConfig.ConfigFolder) end
	end
	if WindowConfig.FreeMouse then UnlockMouse(true) end

	local Tabs = {}

	-- Tab holder
	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame",Color3.fromRGB(255,255,255),3),{
		Size=UDim2.new(1,0,1,-94), Position=UDim2.new(0,0,0,42)
	}),{MakeElement("List"), MakeElement("Padding",8,0,0,8)}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0,0,0,TabHolder.UIListLayout.AbsoluteContentSize.Y+16)
	end)

	-- Search
	local SearchBox = Create("TextBox",{
		Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
		TextColor3=Color3.fromRGB(255,255,255), PlaceholderColor3=Color3.fromRGB(120,120,120),
		PlaceholderText="/ search", Font=Enum.Font.GothamBold,
		TextWrapped=false, Text='', TextXAlignment=Enum.TextXAlignment.Center,
		TextSize=12, ClearTextOnFocus=true
	})
	local TextboxActual = AddThemeObject(SearchBox,"Text")

	local SearchBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(255,255,255),1,7),{
		Size=UDim2.new(1,-16,0,28), Position=UDim2.new(0.5,0,0,7), AnchorPoint=Vector2.new(0.5,0)
	}),{
		Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
		TextboxActual
	}),"Main")

	AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
		local T = string.lower(SearchBox.Text)
		for i,v in pairs(Tabs) do
			if v:IsA('TextButton') then v.Visible = string.find(string.lower(i),T) and true or false end
		end
	end)

	-- Botões close/minimize
	local CloseBtn = SetChildren(SetProps(MakeElement("Button"),{
		Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0.5,0,0,0), BackgroundTransparency=1
	}),{
		AddThemeObject(SetProps(MakeElement("Image","rbxassetid://7072725342"),{
			Position=UDim2.new(0,9,0,6), Size=UDim2.new(0,18,0,18)
		}),"Text")
	})
	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"),{
		Size=UDim2.new(0.5,0,1,0), BackgroundTransparency=1
	}),{
		AddThemeObject(SetProps(MakeElement("Image","rbxassetid://7072719338"),{
			Position=UDim2.new(0,9,0,6), Size=UDim2.new(0,18,0,18), Name="Ico"
		}),"Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"),{Size=UDim2.new(1,0,0,50)})

	-- Painel lateral
	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,14),{
		Size=UDim2.new(0,152,1,-50), Position=UDim2.new(0,0,0,50)
	}),{
		AddThemeObject(SetProps(MakeElement("Frame"),{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,0)}),"Second"),
		Create("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
			BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.85,BorderSizePixel=0}),
		SearchBar,
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"),{Size=UDim2.new(1,0,0,52),Position=UDim2.new(0,0,1,-52)}),{
			Create("ImageLabel",{
				AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,36,0,36),
				Position=UDim2.new(0.5,0,0,18), Name="PlayerAvatar",
				BackgroundTransparency=1, BorderSizePixel=0,
				Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
			},{
				MakeElement("Corner",1),
				Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.8,Transparency=0.55})
			}),
			AddThemeObject(SetProps(MakeElement("Label",LocalPlayer.DisplayName,10),{
				Size=UDim2.new(1,-8,0,11), Position=UDim2.new(0,4,1,-13),
				TextXAlignment=Enum.TextXAlignment.Center, Name="PlayerName",
				Font=Enum.Font.GothamBold, TextScaled=true
			}),"Text")
		})
	}),"Second")

	-- Nome com letras individuais
	local WindowNameContainer = SetProps(MakeElement("Frame"),{
		Size=UDim2.new(0,400,0,30), Position=UDim2.new(0,25,0,10),
		BackgroundTransparency=1, ClipsDescendants=true
	})
	local windowLetters = {}
	local lx = 0
	for i=1,#WindowConfig.Name do
		local c = WindowConfig.Name:sub(i,i)
		local cw = c==" " and 7 or 11
		local lbl = AddThemeObject(SetProps(MakeElement("Label",c,18),{
			Parent=WindowNameContainer, Size=UDim2.new(0,cw,1,0), Position=UDim2.new(0,lx,0,0),
			Font=Enum.Font.GothamBlack, BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left
		}),"Text")
		table.insert(windowLetters, lbl)
		lx = lx + cw
	end

	-- FPS / Stats
	local fpsHistory, fps = {}, 60
	RunService.RenderStepped:Connect(function(dt)
		table.insert(fpsHistory, 1/dt)
		if #fpsHistory>30 then table.remove(fpsHistory,1) end
		local s=0; for _,v in ipairs(fpsHistory) do s=s+v end; fps=math.floor(s/#fpsHistory)
	end)
	local StatsLabel = AddThemeObject(SetProps(MakeElement("Label","",10),{
		Size=UDim2.new(0,230,0,20), Position=UDim2.new(1,-340,0,15),
		Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right
	}),"TextDark")
	spawn(function()
		while wait(0.5) do
			if not StatsLabel or not StatsLabel.Parent then break end
			local t=os.date("*t")
			local ping=math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
			StatsLabel.Text=string.format("%02d/%02d/%04d %02d:%02d | %d FPS | %dms",t.day,t.month,t.year,t.hour,t.min,fps,ping)
		end
	end)

	local WindowTopBarLine = Create("Frame",{
		Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),
		BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.82, BorderSizePixel=0
	})

	-- Janela principal (mais arredondada: 18)
	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,18),{
		Parent=Eclipse, Position=UDim2.new(0.5,-307,0.5,-172),
		Size=UDim2.new(0,615,0,344), ClipsDescendants=true, Active=true
	}),{
		Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.9,Transparency=0.62}),
		SetChildren(SetProps(MakeElement("TFrame"),{Size=UDim2.new(1,0,0,50),Name="TopBar"}),{
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,10),{
				Size=UDim2.new(0,72,0,30), Position=UDim2.new(1,-92,0,10)
			}),{
				Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
				Create("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(0.5,0,0,0),
					BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.75,BorderSizePixel=0}),
				CloseBtn, MinimizeBtn
			}),"Second"),
		}),
		DragPoint,
		WindowStuff,
	}),"Main")

	WindowNameContainer.Parent = MainWindow.TopBar
	StatsLabel.Parent           = MainWindow.TopBar

	if WindowConfig.ShowIcon then
		WindowNameContainer.Position = UDim2.new(0,48,0,-24)
		SetProps(MakeElement("Image",WindowConfig.Icon),{
			Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,24,0,16), Parent=MainWindow.TopBar
		})
	end

	MakeDraggable(DragPoint, MainWindow)

	-- Resize handle (canto inferior direito)
	local Resizing = false
	local ResizeHandle = Create("TextButton",{
		Size=UDim2.new(0,18,0,18), Position=UDim2.new(1,0,1,0),
		AnchorPoint=Vector2.new(1,1), BackgroundTransparency=1, Text="",
		Name="ResizeHandle", Parent=MainWindow, ZIndex=10
	})
	-- L-shape indicator
	for _, d in ipairs({{UDim2.new(1,-12,1,-5),UDim2.new(0,10,0,1)},{UDim2.new(1,-5,1,-12),UDim2.new(0,1,0,10)}}) do
		Create("Frame",{Parent=MainWindow,Size=d[2],Position=d[1],
			BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.5,BorderSizePixel=0})
	end

	local OriginalSize = UDim2.new(0,615,0,344)
	local StartSizeR, StartPosR

	AddConnection(ResizeHandle.InputBegan, function(Input)
		if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
			Resizing=true; StartSizeR=MainWindow.AbsoluteSize; StartPosR=Vector2.new(Input.Position.X,Input.Position.Y)
		end
	end)
	AddConnection(UserInputService.InputChanged, function(Input)
		if Resizing and (Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch) then
			local D=Vector2.new(Input.Position.X-StartPosR.X,Input.Position.Y-StartPosR.Y)
			local W=math.max(480,math.min(1200,StartSizeR.X+D.X))
			local H=math.max(280,math.min(800,StartSizeR.Y+D.Y))
			MainWindow.Size = UDim2.new(0,W,0,H); OriginalSize=MainWindow.Size
		end
	end)
	AddConnection(UserInputService.InputEnded, function(Input)
		if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
			Resizing=false
		end
	end)

	-- Mobile open button
	local MobileOpenButton = SetChildren(SetProps(MakeElement("Button"),{
		BackgroundTransparency=0, Parent=Eclipse, Text="Eclipse", TextScaled=true, TextSize=13,
		TextColor3=Color3.fromRGB(255,255,255), BackgroundColor3=Color3.fromRGB(5,5,5),
		Size=UDim2.new(0.06,0,0.035,0), AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0.5,0,0.5,0), Visible=false, Font=Enum.Font.GothamBold
	}),{
		MakeElement("Corner",0,10),
		Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.8,Transparency=0.5})
	})
	MakeDraggable(MobileOpenButton,MobileOpenButton)

	local function showMobile()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			MobileOpenButton.Visible = UIHidden
		end
	end

	AddConnection(MobileOpenButton.MouseButton1Click, function()
		MobileOpenButton.Visible=false; MainWindow.Visible=true; UIHidden=false
		freeMouse.Modal=true; buttonmodal.Modal=true
		UserInputService.MouseIconEnabled=true; freeMouse.Visible=true
	end)

	-- Hover animações no CloseBtn e MinimizeBtn
	AddConnection(CloseBtn.MouseEnter, function()
		TweenService:Create(CloseBtn:FindFirstChildOfClass("ImageLabel") or CloseBtn, TweenCache.Fast, {ImageTransparency=0.2}):Play()
	end)
	AddConnection(CloseBtn.MouseLeave, function()
		TweenService:Create(CloseBtn:FindFirstChildOfClass("ImageLabel") or CloseBtn, TweenCache.Fast, {ImageTransparency=0}):Play()
	end)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible=false; UIHidden=true
		mouselock=false; freeMouse.Visible=false; freeMouse.Modal=false; buttonmodal.Modal=false
		UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter; UserInputService.MouseIconEnabled=false
		if WindowConfig.FreeMouse then UnlockMouse(false) end
		EclipseLib:MakeNotification({Name="Interface Hidden",Content="Press "..WindowConfig.KeyToOpenWindow.." to reopen.",Time=5})
		showMobile(); WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input, gp)
		if gp then return end
		if Input.KeyCode == Enum.KeyCode[WindowConfig.KeyToOpenWindow] then
			if UIHidden then
				MainWindow.Visible=true; UIHidden=false; freeMouse.Visible=true
				freeMouse.Modal=true; buttonmodal.Modal=true
				UserInputService.MouseBehavior=Enum.MouseBehavior.Default; UserInputService.MouseIconEnabled=true
				if WindowConfig.FreeMouse then UnlockMouse(true) end
				showMobile()
			else
				MainWindow.Visible=false; UIHidden=true
				mouselock=false; freeMouse.Visible=false; freeMouse.Modal=false; buttonmodal.Modal=false
				UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter; UserInputService.MouseIconEnabled=false
				if WindowConfig.FreeMouse then UnlockMouse(false) end
				showMobile(); WindowConfig.CloseCallback()
			end
		end
	end)

	-- Minimize
	local nameWidth      = #WindowConfig.Name * 12
	local MinimizedSize  = UDim2.new(0,math.max(280,nameWidth+320),0,50)
	local savedVis       = {}
	local savedWindowSize= nil

	-- Animação contínua das letras
	task.spawn(function()
		task.wait(3)
		while true do
			for i=#windowLetters,1,-1 do
				TweenService:Create(windowLetters[i],TweenInfo.new(0.35,Enum.EasingStyle.Sine),{TextTransparency=1}):Play()
				task.wait(0.06)
			end
			task.wait(0.5)
			for i=1,#windowLetters do
				TweenService:Create(windowLetters[i],TweenInfo.new(0.35,Enum.EasingStyle.Sine),{TextTransparency=0}):Play()
				task.wait(0.06)
			end
			task.wait(5)
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Resizing then return end
		if Minimized then
			Minimized=false; MinimizeBtn.Ico.Image="rbxassetid://7072719338"
			freeMouse.Visible=true; freeMouse.Modal=true
			UserInputService.MouseBehavior=Enum.MouseBehavior.Default; UserInputService.MouseIconEnabled=true
			WindowStuff.Visible=true; WindowTopBarLine.Visible=true
			for el,vis in pairs(savedVis) do if el and el.Parent then el.Visible=vis end end
			if savedWindowSize then OriginalSize=savedWindowSize end
			StatsLabel.TextXAlignment=Enum.TextXAlignment.Right
			StatsLabel.Position=UDim2.new(1,-340,0,15); StatsLabel.Size=UDim2.new(0,230,0,20)
			MainWindow.ClipsDescendants=true
			local tw=TweenService:Create(MainWindow,TweenCache.Bounce,{Size=OriginalSize})
			tw:Play(); tw.Completed:Connect(function() MainWindow.ClipsDescendants=false end)
			savedVis={}
		else
			Minimized=true; MinimizeBtn.Ico.Image="rbxassetid://7072720870"
			savedWindowSize=MainWindow.Size
			for _,c in pairs(WindowStuff:GetDescendants()) do
				if c:IsA("GuiObject") then savedVis[c]=c.Visible end
			end
			TweenService:Create(StatsLabel,TweenCache.Fast,{
				Position=UDim2.new(0,nameWidth+28,0,15), Size=UDim2.new(0,180,0,20),
				TextXAlignment=Enum.TextXAlignment.Left
			}):Play()
			MainWindow.ClipsDescendants=true
			TweenService:Create(MainWindow,TweenCache.Bounce,{Size=MinimizedSize}):Play()
			task.wait(0.12)
			WindowStuff.Visible=false; WindowTopBarLine.Visible=false
		end
	end)

	-- Intro sequence
	local function LoadSequence()
		MainWindow.Visible=false
		local LoadBg=SetProps(MakeElement("Frame"),{
			Parent=Eclipse, Size=UDim2.new(1,0,1,0),
			BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0, ZIndex=999
		})
		local LoadIcon=SetProps(MakeElement("Image",WindowConfig.IntroIcon),{
			Parent=LoadBg, AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.43,0), Size=UDim2.new(0,0,0,0),
			ImageColor3=Color3.fromRGB(255,255,255), ImageTransparency=1, ZIndex=1000
		})
		local TC=SetProps(MakeElement("Frame"),{
			Parent=LoadBg, Size=UDim2.new(1,0,0,30),
			AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.57,0),
			BackgroundTransparency=1, ZIndex=1000
		})
		local text=WindowConfig.IntroText
		local letters,tw={},(function()
			local w=0
			for i=1,#text do w=w+(text:sub(i,i)==" " and 8 or 11) end
			return w
		end)()
		local cx=-tw/2
		for i=1,#text do
			local ch=text:sub(i,i); local cw=ch==" " and 8 or 11
			local lbl=SetProps(MakeElement("Label",ch,15),{
				Parent=TC, Size=UDim2.new(0,cw,1,0), Position=UDim2.new(0.5,cx,0,0),
				Font=Enum.Font.GothamBold, TextTransparency=1,
				TextColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=1, ZIndex=1001
			})
			table.insert(letters,lbl); cx=cx+cw
		end
		local LoadBar=SetChildren(SetProps(MakeElement("Frame"),{
			Parent=LoadBg, AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.64,0), Size=UDim2.new(0,160,0,2),
			BackgroundColor3=Color3.fromRGB(35,35,35), BackgroundTransparency=0, ZIndex=1000
		}),{
			SetProps(MakeElement("Frame"),{
				Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(255,255,255),
				Name="Fill", ZIndex=1001
			}),
			Create("UICorner",{CornerRadius=UDim.new(1,0)})
		})
		TweenService:Create(LoadIcon,TweenCache.Bounce,{Size=UDim2.new(0,44,0,44),ImageTransparency=0}):Play()
		wait(0.3)
		for i,letter in ipairs(letters) do
			task.spawn(function() wait(i*0.03); TweenService:Create(letter,TweenCache.Medium,{TextTransparency=0}):Play() end)
		end
		wait(0.2+#letters*0.03)
		TweenService:Create(LoadBar.Fill,TweenInfo.new(1.0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0)}):Play()
		wait(1.1)
		for i=#letters,1,-1 do
			local l=letters[i]
			task.spawn(function()
				wait((#letters-i)*0.022)
				TweenService:Create(l,TweenCache.Fast,{TextTransparency=1,Position=l.Position+UDim2.new(0,0,0,-8)}):Play()
			end)
		end
		TweenService:Create(LoadBg,TweenCache.Medium,{BackgroundTransparency=1}):Play()
		TweenService:Create(LoadIcon,TweenCache.Medium,{ImageTransparency=1}):Play()
		MainWindow.Visible=true; freeMouse.Modal=true; buttonmodal.Modal=true
		UserInputService.MouseIconEnabled=true; freeMouse.Visible=true
		wait(0.45); LoadBg:Destroy()
	end

	if WindowConfig.IntroEnabled then LoadSequence() end
	freeMouse.Visible=true

	-- ═══════════════════════════════════════════════════════════
	-- TAB BUILDER
	-- ═══════════════════════════════════════════════════════════
	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig            = TabConfig or {}
		TabConfig.Name       = TabConfig.Name       or "Tab"
		TabConfig.Icon       = TabConfig.Icon       or ""
		TabConfig.PremiumOnly= TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"),{
			Size=UDim2.new(1,0,0,32), Parent=TabHolder
		}),{
			AddThemeObject(SetProps(MakeElement("Image",TabConfig.Icon),{
				AnchorPoint=Vector2.new(0,0.5), Size=UDim2.new(0,17,0,17),
				Position=UDim2.new(0,10,0.5,0), ImageTransparency=1, Name="Ico"
			}),"Text"),
			AddThemeObject(SetProps(MakeElement("Label",TabConfig.Name,14),{
				Size=UDim2.new(1,-35,1,0), Position=UDim2.new(0,35,0,0),
				Font=Enum.Font.GothamSemibold, TextTransparency=1, Name="Title"
			}),"Text"),
			-- Indicador ativo (linha branca à esquerda)
			Create("Frame",{
				Size=UDim2.new(0,3,0.6,0), Position=UDim2.new(0,0,0.2,0),
				BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=1,
				BorderSizePixel=0, Name="ActiveBar"
			},{Create("UICorner",{CornerRadius=UDim.new(0,3)})})
		})
		if GetIcon(TabConfig.Icon) then TabFrame.Ico.Image = GetIcon(TabConfig.Icon) end
		Tabs[TabConfig.Name] = TabFrame
		TabFrame.Ico.ImageTransparency  = 0.5
		TabFrame.Title.TextTransparency = 0.5

		-- Hover
		AddConnection(TabFrame.MouseEnter, function()
			if TabFrame.Title.TextTransparency > 0 then
				TweenService:Create(TabFrame, TweenCache.Fast, {BackgroundColor3=Color3.fromRGB(16,16,16)}):Play()
			end
		end)
		AddConnection(TabFrame.MouseLeave, function()
			if TabFrame.Title.TextTransparency > 0 then
				TweenService:Create(TabFrame, TweenCache.Fast, {BackgroundColor3=Color3.fromRGB(5,5,5)}):Play()
			end
		end)

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame",Color3.fromRGB(255,255,255),4),{
			Size=UDim2.new(1,-152,1,-50), Position=UDim2.new(0,152,0,50),
			Parent=MainWindow, Visible=false, Name="ItemContainer",
			ClipsDescendants=true, BorderSizePixel=0
		}),{
			MakeElement("List",0,6), MakeElement("Padding",15,10,10,15)
		}),"Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize=UDim2.new(0,0,0,Container.UIListLayout.AbsoluteContentSize.Y+30)
		end)

		if FirstTab then
			FirstTab=false
			TabFrame.Ico.ImageTransparency=0; TabFrame.Title.TextTransparency=0
			TabFrame.Title.Font=Enum.Font.GothamBlack
			TabFrame.ActiveBar.BackgroundTransparency=0
			Container.Visible=true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			for _,Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font=Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico,  TweenCache.Fast,{ImageTransparency=0.5}):Play()
					TweenService:Create(Tab.Title,TweenCache.Fast,{TextTransparency=0.5}):Play()
					if Tab:FindFirstChild("ActiveBar") then
						TweenService:Create(Tab.ActiveBar,TweenCache.Fast,{BackgroundTransparency=1}):Play()
					end
					TweenService:Create(Tab,TweenCache.Fast,{BackgroundColor3=Color3.fromRGB(5,5,5)}):Play()
				end
			end
			for _,ic in next, MainWindow:GetChildren() do
				if ic.Name=="ItemContainer" then ic.Visible=false end
			end
			TweenService:Create(TabFrame.Ico,  TweenCache.Fast,{ImageTransparency=0}):Play()
			TweenService:Create(TabFrame.Title,TweenCache.Fast,{TextTransparency=0}):Play()
			TweenService:Create(TabFrame.ActiveBar,TweenCache.Bounce,{BackgroundTransparency=0}):Play()
			TabFrame.Title.Font=Enum.Font.GothamBlack
			Container.Visible=true
		end)

		-- ═══════════════════════════════════════════════════════
		-- ELEMENT BUILDERS
		-- ═══════════════════════════════════════════════════════
		local function GetElements(ItemParent)
			local EF = {}

			-- Helpers de hover
			local function HoverIn(f)
				TweenService:Create(f,TweenCache.Fast,{BackgroundColor3=Color3.fromRGB(18,18,18)}):Play()
			end
			local function HoverOut(f)
				TweenService:Create(f,TweenCache.Fast,{BackgroundColor3=EclipseLib.Themes[EclipseLib.SelectedTheme].Second}):Play()
			end

			function EF:AddLabel(Text)
				local LC=AddThemeObject(SetProps(MakeElement("Label","",15),{
					Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,12,0,0),
					Font=Enum.Font.GothamBold, Name="Content"
				}),"Text")
				local LF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,32), BackgroundTransparency=0.4, Parent=ItemParent
				}),{LC, Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.75})}),"Second")
				LC.Text=Text
				local fn={}; function fn:Set(v) LC.Text=v end; return fn
			end

			function EF:AddParagraph(Text, Content)
				Text=Text or "Text"; Content=Content or "Content"
				local PF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,32), BackgroundTransparency=0.4, Parent=ItemParent
				}),{
					AddThemeObject(SetProps(MakeElement("Label",Text,15),{
						Size=UDim2.new(1,-12,0,14), Position=UDim2.new(0,12,0,10),
						Font=Enum.Font.GothamBold, Name="Title"
					}),"Text"),
					AddThemeObject(SetProps(MakeElement("Label","",13),{
						Size=UDim2.new(1,-24,0,0), Position=UDim2.new(0,12,0,27),
						Font=Enum.Font.GothamSemibold, Name="Content", TextWrapped=true
					}),"TextDark"),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.75})
				}),"Second")
				AddConnection(PF.Content:GetPropertyChangedSignal("Text"),function()
					PF.Content.Size=UDim2.new(1,-24,0,PF.Content.TextBounds.Y)
					PF.Size=UDim2.new(1,0,0,PF.Content.TextBounds.Y+36)
				end)
				PF.Content.Text=Content
				local fn={}; function fn:Set(v) PF.Content.Text=v end; return fn
			end

			function EF:AddButton(BtnConfig)
				BtnConfig            = BtnConfig or {}
				BtnConfig.Name       = BtnConfig.Name     or "Button"
				BtnConfig.Callback   = BtnConfig.Callback or function() end
				BtnConfig.Icon       = BtnConfig.Icon     or "rbxassetid://3944703587"
				local Btn={}
				local Click=SetProps(MakeElement("Button"),{Size=UDim2.new(1,0,1,0)})
				local BL=AddThemeObject(SetProps(MakeElement("Label","",15),{
					Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,12,0,0),
					Font=Enum.Font.GothamBold, Name="Content"
				}),"Text")
				local BF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,36), Parent=ItemParent, ClipsDescendants=true
				}),{
					BL,
					AddThemeObject(SetProps(MakeElement("Image",BtnConfig.Icon),{
						Size=UDim2.new(0,18,0,18), Position=UDim2.new(1,-28,0,9)
					}),"TextDark"),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
					Click
				}),"Second")
				BL.Text=BtnConfig.Name
				AddConnection(Click.MouseEnter,   function() HoverIn(BF) end)
				AddConnection(Click.MouseLeave,   function() HoverOut(BF) end)
				AddConnection(Click.MouseButton1Down, function(x,y)
					CreateRipple(BF,x,y)
					TweenService:Create(BF,TweenCache.UltraFast,{BackgroundColor3=Color3.fromRGB(24,24,24)}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					HoverIn(BF); spawn(BtnConfig.Callback)
				end)
				function Btn:Set(t) BF.Content.Text=t end
				return Btn
			end

			function EF:AddToggle(TC2)
				TC2            = TC2 or {}
				TC2.Name       = TC2.Name     or "Toggle"
				TC2.Default    = TC2.Default  or false
				TC2.Callback   = TC2.Callback or function() end
				TC2.Flag       = TC2.Flag     or nil
				TC2.Save       = TC2.Save     or false
				local Toggle={Value=TC2.Default, Save=TC2.Save}
				local Click=SetProps(MakeElement("Button"),{Size=UDim2.new(1,0,1,0),ZIndex=5,Active=true})

				-- Toggle pill (estilo moderno)
				local Pill=SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(22,22,22),1,0),{
					Size=UDim2.new(0,44,0,24), Position=UDim2.new(1,-52,0.5,0),
					AnchorPoint=Vector2.new(0.5,0.5)
				}),{
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,
						Transparency=0.7, Name="Stroke"}),
					Create("Frame",{
						Size=UDim2.new(0,18,0,18),
						Position=UDim2.new(0,3,0.5,0),
						AnchorPoint=Vector2.new(0,0.5),
						BackgroundColor3=Color3.fromRGB(120,120,120),
						BorderSizePixel=0, Name="Knob"
					},{Create("UICorner",{CornerRadius=UDim.new(1,0)})})
				})

				local TF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,40), Parent=ItemParent, ClipsDescendants=true
				}),{
					AddThemeObject(SetProps(MakeElement("Label",TC2.Name,15),{
						Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,12,0,0),
						Font=Enum.Font.GothamBold, Name="Content"
					}),"Text"),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
					Pill, Click
				}),"Second")

				function Toggle:Set(v)
					Toggle.Value=v
					if v then
						TweenService:Create(Pill,TweenCache.Fast,{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
						TweenService:Create(Pill.Knob,TweenCache.Fast,{
							Position=UDim2.new(1,-21,0.5,0), BackgroundColor3=Color3.fromRGB(5,5,5)
						}):Play()
						TweenService:Create(Pill.UIStroke,TweenCache.Fast,{Transparency=0.9}):Play()
					else
						TweenService:Create(Pill,TweenCache.Fast,{BackgroundColor3=Color3.fromRGB(20,20,20)}):Play()
						TweenService:Create(Pill.Knob,TweenCache.Fast,{
							Position=UDim2.new(0,3,0.5,0), BackgroundColor3=Color3.fromRGB(100,100,100)
						}):Play()
						TweenService:Create(Pill.UIStroke,TweenCache.Fast,{Transparency=0.55}):Play()
					end
					TC2.Callback(Toggle.Value)
				end
				task.spawn(function() Toggle:Set(Toggle.Value) end)
				AddConnection(Click.MouseEnter,  function() HoverIn(TF) end)
				AddConnection(Click.MouseLeave,  function() HoverOut(TF) end)
				AddConnection(Click.Activated, function()
					HoverIn(TF); SaveCfg(game.GameId); Toggle:Set(not Toggle.Value)
				end)
				AddConnection(Click.MouseButton1Down,function(x,y) CreateRipple(TF,x,y) end)
				if TC2.Flag then EclipseLib.Flags[TC2.Flag]=Toggle end
				return Toggle
			end

			function EF:AddSlider(SC)
				SC              = SC or {}
				SC.Name         = SC.Name       or "Slider"
				SC.Min          = SC.Min        or 0
				SC.Max          = SC.Max        or 100
				SC.Increment    = SC.Increment  or 1
				SC.Default      = SC.Default    or 50
				SC.Callback     = SC.Callback   or function() end
				SC.ValueName    = SC.ValueName  or ""
				SC.Flag         = SC.Flag       or nil
				SC.Save         = SC.Save       or false
				local Slider={Value=SC.Default,Save=SC.Save}
				local Dragging, DragInput = false

				local SliderFill=SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(255,255,255),0,6),{
					Size=UDim2.new(0,0,1,0), BackgroundTransparency=0, ClipsDescendants=true
				}),{
					SetProps(MakeElement("Label","v",12),{
						Size=UDim2.new(1,-8,0,14), Position=UDim2.new(0,8,0,5),
						Font=Enum.Font.GothamBold, Name="Value",
						TextColor3=Color3.fromRGB(5,5,5)
					})
				})
				local SliderBar=SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(18,18,18),0,6),{
					Size=UDim2.new(1,-24,0,26), Position=UDim2.new(0,12,0,32),
					BackgroundTransparency=0, ClipsDescendants=false
				}),{
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.72}),
					SetProps(MakeElement("Label","v",12),{
						Size=UDim2.new(1,-8,0,14), Position=UDim2.new(0,8,0,6),
						Font=Enum.Font.GothamBold, Name="Value",
						TextColor3=Color3.fromRGB(140,140,140), TextTransparency=0.5
					}),
					SliderFill
				})
				local SF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,68), Parent=ItemParent
				}),{
					AddThemeObject(SetProps(MakeElement("Label",SC.Name,15),{
						Size=UDim2.new(1,-12,0,14), Position=UDim2.new(0,12,0,10),
						Font=Enum.Font.GothamBold, Name="Content"
					}),"Text"),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
					SliderBar
				}),"Second")

				AddConnection(SliderBar.InputBegan, function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
						Dragging=true
						AddConnection(Input.Changed,function()
							if Input.UserInputState==Enum.UserInputState.End then Dragging=false;FocusDrag=nil end
						end)
					end
				end)
				AddConnection(SliderBar.InputChanged,function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch then
						DragInput=Input; FocusDrag=DragInput
					end
				end)
				AddConnection(UserInputService.InputChanged,function(Input)
					if Input==DragInput and Input==FocusDrag and Dragging then
						local s=math.clamp((Input.Position.X-SliderBar.AbsolutePosition.X)/SliderBar.AbsoluteSize.X,0,1)
						Slider:Set(SC.Min+(SC.Max-SC.Min)*s); SaveCfg(game.GameId)
					end
				end)
				function Slider:Set(v)
					self.Value=math.clamp(Round(v,SC.Increment),SC.Min,SC.Max)
					TweenService:Create(SliderFill,TweenCache.Fast,{
						Size=UDim2.fromScale((self.Value-SC.Min)/(SC.Max-SC.Min),1)
					}):Play()
					SliderBar.Value.Text=tostring(self.Value).." "..SC.ValueName
					SliderFill.Value.Text=tostring(self.Value).." "..SC.ValueName
					SC.Callback(self.Value)
				end
				Slider:Set(Slider.Value)
				if SC.Flag then EclipseLib.Flags[SC.Flag]=Slider end
				return Slider
			end

			function EF:AddDropdown(DC)
				DC            = DC or {}
				DC.Name       = DC.Name     or "Dropdown"
				DC.Options    = DC.Options  or {}
				DC.Default    = DC.Default  or ""
				DC.Callback   = DC.Callback or function() end
				DC.Flag       = DC.Flag     or nil
				DC.Save       = DC.Save     or false
				local Dropdown={Value=DC.Default,Options=DC.Options,Buttons={},Toggled=false,Type="Dropdown",Save=DC.Save}
				local MaxElements=5
				if not table.find(Dropdown.Options,Dropdown.Value) then Dropdown.Value="..." end
				local DList=MakeElement("List")
				local DCont=AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame",Color3.fromRGB(12,12,12),3),{DList}),{
					Parent=ItemParent, Position=UDim2.new(0,0,0,40), Size=UDim2.new(1,0,1,-40), ClipsDescendants=true
				}),"Divider")
				local Clk=SetProps(MakeElement("Button"),{Size=UDim2.new(1,0,1,0)})
				local DF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,40), Parent=ItemParent, ClipsDescendants=true
				}),{
					DCont,
					SetProps(SetChildren(MakeElement("TFrame"),{
						AddThemeObject(SetProps(MakeElement("Label",DC.Name,15),{
							Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,12,0,0),
							Font=Enum.Font.GothamBold, Name="Content"
						}),"Text"),
						AddThemeObject(SetProps(MakeElement("Image","rbxassetid://7072706796"),{
							Size=UDim2.new(0,16,0,16), AnchorPoint=Vector2.new(0,0.5),
							Position=UDim2.new(1,-26,0.5,0), Name="Ico"
						}),"TextDark"),
						AddThemeObject(SetProps(MakeElement("Label","Selected",13),{
							Size=UDim2.new(1,-40,1,0), Font=Enum.Font.Gotham,
							Name="Selected", TextXAlignment=Enum.TextXAlignment.Right
						}),"TextDark"),
						Create("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
							Name="Line",Visible=false,BackgroundColor3=Color3.fromRGB(255,255,255),
							BackgroundTransparency=0.85,BorderSizePixel=0}),
						Clk
					}),{Size=UDim2.new(1,0,0,40),ClipsDescendants=true,Name="F"}),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
					MakeElement("Corner",0,12)
				}),"Second")
				AddConnection(DList:GetPropertyChangedSignal("AbsoluteContentSize"),function()
					DCont.CanvasSize=UDim2.new(0,0,0,DList.AbsoluteContentSize.Y)
				end)
				local function AddOptions(Options)
					for _,Option in pairs(Options) do
						local OB=SetProps(SetChildren(MakeElement("Button",Color3.fromRGB(10,10,10)),{
							MakeElement("Corner",0,8),
							AddThemeObject(SetProps(MakeElement("Label",Option,13,0.4),{
								Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-10,1,0), Name="Title"
							}),"Text")
						}),{Parent=DCont,Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,ClipsDescendants=true})
						AddConnection(OB.MouseButton1Click,function() Dropdown:Set(Option);SaveCfg(game.GameId) end)
						Dropdown.Buttons[Option]=OB
					end
				end
				function Dropdown:Refresh(Options,Del)
					if Del then for _,v in pairs(self.Buttons) do v:Destroy() end; table.clear(self.Options); table.clear(self.Buttons) end
					self.Options=Options; AddOptions(self.Options)
				end
				function Dropdown:Set(v)
					if not table.find(self.Options,v) then
						self.Value="..."; DF.F.Selected.Text=self.Value
						for _,b in pairs(self.Buttons) do TweenService:Create(b,TweenCache.Fast,{BackgroundTransparency=1}):Play() end; return
					end
					self.Value=v; DF.F.Selected.Text=self.Value
					for _,b in pairs(self.Buttons) do
						TweenService:Create(b,TweenCache.Fast,{BackgroundTransparency=1}):Play()
						TweenService:Create(b.Title,TweenCache.Fast,{TextTransparency=0.4}):Play()
					end
					TweenService:Create(self.Buttons[v],TweenCache.Fast,{BackgroundTransparency=0}):Play()
					TweenService:Create(self.Buttons[v].Title,TweenCache.Fast,{TextTransparency=0}):Play()
					return DC.Callback(self.Value)
				end
				AddConnection(Clk.MouseButton1Click,function()
					Dropdown.Toggled=not Dropdown.Toggled
					DF.F.Line.Visible=Dropdown.Toggled
					TweenService:Create(DF.F.Ico,TweenCache.Fast,{Rotation=Dropdown.Toggled and 180 or 0}):Play()
					local h=Dropdown.Toggled
						and (#Dropdown.Options>MaxElements and 40+MaxElements*30 or DList.AbsoluteContentSize.Y+40)
						or 40
					TweenService:Create(DF,TweenCache.Medium,{Size=UDim2.new(1,0,0,h)}):Play()
				end)
				Dropdown:Refresh(Dropdown.Options,false); Dropdown:Set(Dropdown.Value)
				if DC.Flag then EclipseLib.Flags[DC.Flag]=Dropdown end
				return Dropdown
			end

			-- ═══════════════════════════════════════════════════
			-- PLAYER DROPDOWN (com re-seleção automática + vermelho)
			-- ═══════════════════════════════════════════════════
			function EF:AddPlayerDropdown(Config)
				Config            = Config or {}
				Config.Name       = Config.Name     or "Players"
				Config.Callback   = Config.Callback or function() end
				Config.Flag       = Config.Flag     or nil
				Config.Save       = Config.Save     or false

				local Dropdown = {
					Value               = nil,
					Buttons             = {},
					SelectedPlayers     = {},        -- player -> true quando selecionado
					DisconnectedPlayers = {},        -- playerName -> true (saíram do server)
					StoredPlayerNames   = {},        -- nomes para re-selecionar quando voltam
					Toggled             = false,
					Type                = "PlayerDropdown",
					Save                = Config.Save,
				}
				local MaxElements = 5
				local NormalColor  = Color3.fromRGB(12, 12, 12)
				local SelectedColor= Color3.fromRGB(25, 25, 25)
				local OfflineColor = Color3.fromRGB(40, 8,  8)   -- vermelho escuro (offline)

				local DList = MakeElement("List")
				local DCont = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame",Color3.fromRGB(12,12,12),3),{DList}),{
					Parent=ItemParent, Position=UDim2.new(0,0,0,40),
					Size=UDim2.new(1,0,1,-40), ClipsDescendants=true
				}),"Divider")

				local Clk = SetProps(MakeElement("Button"),{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,AutoButtonColor=false,Name="CR"})

				local DF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,40), Parent=ItemParent, ClipsDescendants=true
				}),{
					DCont,
					SetProps(SetChildren(MakeElement("TFrame"),{
						AddThemeObject(SetProps(MakeElement("Label",Config.Name,15),{
							Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,12,0,0),
							Font=Enum.Font.GothamBold, Name="Content"
						}),"Text"),
						AddThemeObject(SetProps(MakeElement("Image","rbxassetid://7072706796"),{
							Size=UDim2.new(0,16,0,16), AnchorPoint=Vector2.new(0,0.5),
							Position=UDim2.new(1,-26,0.5,0), Name="Ico"
						}),"TextDark"),
						AddThemeObject(SetProps(MakeElement("Label","Select",13),{
							Size=UDim2.new(1,-40,1,0), Font=Enum.Font.Gotham,
							Name="Selected", TextXAlignment=Enum.TextXAlignment.Right
						}),"TextDark"),
						Create("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
							Name="Line",Visible=false, BackgroundColor3=Color3.fromRGB(255,255,255),
							BackgroundTransparency=0.85,BorderSizePixel=0}),
						Clk
					}),{Size=UDim2.new(1,0,0,40),ClipsDescendants=true,Name="F"}),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
					MakeElement("Corner",0,12)
				}),"Second")

				AddConnection(DList:GetPropertyChangedSignal("AbsoluteContentSize"),function()
					DCont.CanvasSize=UDim2.new(0,0,0,DList.AbsoluteContentSize.Y)
					if Dropdown.Toggled then
						local vis=#Dropdown.Buttons
						local h=vis>MaxElements and 40+MaxElements*44 or 40+vis*44
						TweenService:Create(DF,TweenCache.Fast,{Size=UDim2.new(1,0,0,h)}):Play()
					end
				end)

				-- Atualiza o texto do header e cores dos botões
				local function RefreshSelection()
					local names={}
					Dropdown.StoredPlayerNames={}
					for p in pairs(Dropdown.SelectedPlayers) do
						table.insert(names,p.Name)
						table.insert(Dropdown.StoredPlayerNames,p.Name)
					end
					DF.F.Selected.Text=#names>0 and table.concat(names,", ") or "Select"
					-- Atualizar cores
					for p,btn in pairs(Dropdown.Buttons) do
						if typeof(p)=="Instance" then
							local offline = Dropdown.DisconnectedPlayers[p.Name]
							local selected= Dropdown.SelectedPlayers[p]
							if offline then
								TweenService:Create(btn,TweenCache.Fast,{BackgroundColor3=OfflineColor}):Play()
							elseif selected then
								TweenService:Create(btn,TweenCache.Fast,{BackgroundColor3=SelectedColor}):Play()
							else
								TweenService:Create(btn,TweenCache.Fast,{BackgroundColor3=NormalColor}):Play()
							end
						end
					end
					Config.Callback(names)
				end

				-- Cria botão de jogador
				local function CreatePlayerBtn(p)
					local btn=SetProps(MakeElement("Button"),{
						Parent=DCont, Size=UDim2.new(1,0,0,44),
						BackgroundColor3=NormalColor, BackgroundTransparency=0,
						AutoButtonColor=false, ClipsDescendants=true
					})
					MakeElement("Corner",0,10).Parent=btn
					Create("UIStroke",{Color=Color3.fromRGB(60,60,60),Thickness=0.5,Transparency=0.3,Parent=btn})

					Create("ImageLabel",{
						Parent=btn, Size=UDim2.new(0,34,0,34),
						Position=UDim2.new(0,5,0.5,0), AnchorPoint=Vector2.new(0,0.5),
						BackgroundTransparency=1, Name="Avatar",
						Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=420&height=420&format=png"
					},{MakeElement("Corner",1)})

					-- Ícone de offline (X vermelho, hidden por padrão)
					local OfflineIcon=Create("ImageLabel",{
						Parent=btn, Size=UDim2.new(0,16,0,16),
						Position=UDim2.new(1,-24,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
						BackgroundTransparency=1, Name="OfflineIcon",
						Image="rbxassetid://7072725342",
						ImageColor3=Color3.fromRGB(220,80,80),
						ImageTransparency=1
					})

					AddThemeObject(SetProps(MakeElement("Label",p.DisplayName,14),{
						Parent=btn, Position=UDim2.new(0,46,0,5),
						Size=UDim2.new(1,-70,0,18), Font=Enum.Font.GothamBold,
						TextXAlignment=Enum.TextXAlignment.Left, Name="DName"
					}),"Text")
					AddThemeObject(SetProps(MakeElement("Label","@"..p.Name,12),{
						Parent=btn, Position=UDim2.new(0,46,0,22),
						Size=UDim2.new(1,-70,0,16), Font=Enum.Font.Gotham,
						TextXAlignment=Enum.TextXAlignment.Left, Name="UName",
						TextColor3=Color3.fromRGB(130,130,130)
					}),"TextDark")

					-- Hover
					btn.MouseEnter:Connect(function()
						if not Dropdown.DisconnectedPlayers[p.Name] and not Dropdown.SelectedPlayers[p] then
							TweenService:Create(btn,TweenCache.Fast,{BackgroundColor3=Color3.fromRGB(20,20,20)}):Play()
						end
					end)
					btn.MouseLeave:Connect(function()
						if not Dropdown.DisconnectedPlayers[p.Name] and not Dropdown.SelectedPlayers[p] then
							TweenService:Create(btn,TweenCache.Fast,{BackgroundColor3=NormalColor}):Play()
						end
					end)

					btn.MouseButton1Click:Connect(function()
						if Dropdown.DisconnectedPlayers[p.Name] then return end -- não deixa clicar em offline
						if Dropdown.SelectedPlayers[p] then
							Dropdown.SelectedPlayers[p]=nil
						else
							Dropdown.SelectedPlayers[p]=true
						end
						RefreshSelection()
						if Config.Save then SaveCfg(game.GameId) end
					end)

					Dropdown.Buttons[p]=btn
					return btn
				end

				-- Marcar jogador como offline (vermelho)
				local function MarkOffline(playerName)
					for p,btn in pairs(Dropdown.Buttons) do
						if typeof(p)=="Instance" and p.Name==playerName then
							Dropdown.DisconnectedPlayers[playerName]=true
							TweenService:Create(btn,TweenCache.Fast,{BackgroundColor3=OfflineColor}):Play()
							-- Mostrar ícone de offline
							if btn:FindFirstChild("OfflineIcon") then
								TweenService:Create(btn.OfflineIcon,TweenCache.Fast,{ImageTransparency=0}):Play()
							end
						end
					end
				end

				-- Restaurar jogador (voltou ao server)
				local function MarkOnline(p)
					local wasSelected = table.find(Dropdown.StoredPlayerNames, p.Name) ~= nil
					Dropdown.DisconnectedPlayers[p.Name]=nil
					if Dropdown.Buttons[p] then
						if btn:FindFirstChild("OfflineIcon") then
							TweenService:Create(btn.OfflineIcon,TweenCache.Fast,{ImageTransparency=1}):Play()
						end
					end
					-- RE-SELECIONAR se estava selecionado antes
					if wasSelected then
						Dropdown.SelectedPlayers[p]=true
						RefreshSelection()
					end
				end

				-- Construir lista inicial
				local function BuildList()
					-- Limpar botões que não são de jogadores desconectados
					for p,btn in pairs(Dropdown.Buttons) do
						if typeof(p)=="Instance" and not Dropdown.DisconnectedPlayers[p.Name] then
							btn:Destroy(); Dropdown.Buttons[p]=nil
						end
					end
					for _,p in ipairs(PlayerService:GetPlayers()) do
						if p~=LocalPlayer and not Dropdown.Buttons[p] then
							CreatePlayerBtn(p)
							-- Se estava na lista de stored, re-selecionar
							if table.find(Dropdown.StoredPlayerNames,p.Name) then
								Dropdown.SelectedPlayers[p]=true
								Dropdown.DisconnectedPlayers[p.Name]=nil
							end
						end
					end
					RefreshSelection()
				end

				-- Eventos
				PlayerService.PlayerAdded:Connect(function(p)
					if p==LocalPlayer then return end
					-- Verificar se é um "retorno" (estava na lista desconectados)
					if Dropdown.DisconnectedPlayers[p.Name] then
						-- Jogador voltou: remover marcação offline, re-selecionar
						Dropdown.DisconnectedPlayers[p.Name]=nil
						for pl,btn in pairs(Dropdown.Buttons) do
							if typeof(pl)=="Instance" and pl.Name==p.Name then
								-- Atualizar referência pelo novo player object
								local isStored = table.find(Dropdown.StoredPlayerNames,p.Name)~=nil
								btn:Destroy(); Dropdown.Buttons[pl]=nil
								if Dropdown.SelectedPlayers[pl] then Dropdown.SelectedPlayers[pl]=nil end
								break
							end
						end
						-- Criar novo botão para o jogador
						local nb=CreatePlayerBtn(p)
						if table.find(Dropdown.StoredPlayerNames,p.Name) then
							Dropdown.SelectedPlayers[p]=true
						end
						RefreshSelection()
					else
						-- Novo jogador
						if not Dropdown.Buttons[p] then CreatePlayerBtn(p) end
						RefreshSelection()
					end
				end)

				PlayerService.PlayerRemoving:Connect(function(p)
					if p==LocalPlayer then return end
					-- Marcar como offline em vez de remover
					if Dropdown.Buttons[p] then
						MarkOffline(p.Name)
						-- Salvar na lista de stored se estava selecionado
						if Dropdown.SelectedPlayers[p] then
							if not table.find(Dropdown.StoredPlayerNames,p.Name) then
								table.insert(Dropdown.StoredPlayerNames,p.Name)
							end
						end
						RefreshSelection()
					end
				end)

				AddConnection(Clk.MouseButton1Click,function()
					Dropdown.Toggled=not Dropdown.Toggled
					DF.F.Line.Visible=Dropdown.Toggled
					TweenService:Create(DF.F.Ico,TweenCache.Fast,{Rotation=Dropdown.Toggled and 180 or 0}):Play()
					local vis=0
					for _ in pairs(Dropdown.Buttons) do vis=vis+1 end
					local h=Dropdown.Toggled
						and (vis>MaxElements and 40+MaxElements*44 or 40+vis*44)
						or 40
					TweenService:Create(DF,TweenCache.Medium,{Size=UDim2.new(1,0,0,h)}):Play()
				end)

				BuildList()
				if Config.Flag then EclipseLib.Flags[Config.Flag]=Dropdown end
				return Dropdown
			end

			function EF:AddBind(BC)
				BC            = BC or {}
				BC.Name       = BC.Name     or "Bind"
				BC.Default    = BC.Default  or Enum.KeyCode.Unknown
				BC.Hold       = BC.Hold     or false
				BC.Callback   = BC.Callback or function() end
				BC.Flag       = BC.Flag     or nil
				BC.Save       = BC.Save     or false
				local Bind={Value=nil,Binding=false,Type="Bind",Save=BC.Save}
				local Holding=false
				local Click=SetProps(MakeElement("Button"),{Size=UDim2.new(1,0,1,0)})
				local BB=SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,10),{
					Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-14,0.5,0), AnchorPoint=Vector2.new(1,0.5)
				}),{
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.65}),
					AddThemeObject(SetProps(MakeElement("Label","",13),{
						Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamBold,
						TextXAlignment=Enum.TextXAlignment.Center, Name="Value"
					}),"Text")
				})
				local BF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,40), Parent=ItemParent
				}),{
					AddThemeObject(SetProps(MakeElement("Label",BC.Name,15),{
						Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,12,0,0),
						Font=Enum.Font.GothamBold, Name="Content"
					}),"Text"),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
					BB, Click
				}),"Second")
				AddConnection(BB.Value:GetPropertyChangedSignal("Text"),function()
					TweenService:Create(BB,TweenCache.Medium,{Size=UDim2.new(0,BB.Value.TextBounds.X+16,0,26)}):Play()
				end)
				AddConnection(Click.InputEnded,function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding=true; BB.Value.Text=""
					end
				end)
				AddConnection(UserInputService.InputBegan,function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name==Bind.Value or Input.UserInputType.Name==Bind.Value) and not Bind.Binding then
						if BC.Hold then Holding=true;BC.Callback(Holding) else BC.Callback() end
					elseif Bind.Binding then
						local Key
						pcall(function() if not CheckKey(BlacklistedKeys,Input.KeyCode) then Key=Input.KeyCode end end)
						pcall(function() if CheckKey(WhitelistedMouse,Input.UserInputType) and not Key then Key=Input.UserInputType end end)
						Bind:Set(Key or Bind.Value); SaveCfg(game.GameId)
					end
				end)
				AddConnection(UserInputService.InputEnded,function(Input)
					if (Input.KeyCode.Name==Bind.Value or Input.UserInputType.Name==Bind.Value) then
						if BC.Hold and Holding then Holding=false;BC.Callback(Holding) end
					end
				end)
				AddConnection(Click.MouseEnter,  function() HoverIn(BF) end)
				AddConnection(Click.MouseLeave,  function() HoverOut(BF) end)
				AddConnection(Click.MouseButton1Down,function(x,y) CreateRipple(BF,x,y) end)
				function Bind:Set(Key)
					self.Binding=false; self.Value=Key or self.Value
					self.Value=(self.Value and (self.Value.Name or self.Value)) or "None"
					BB.Value.Text=self.Value
				end
				Bind:Set(BC.Default)
				if BC.Flag then EclipseLib.Flags[BC.Flag]=Bind end
				return Bind
			end

			function EF:AddTextbox(TBC)
				TBC               = TBC or {}
				TBC.Name          = TBC.Name         or "Textbox"
				TBC.Default       = TBC.Default       or ""
				TBC.TextDisappear = TBC.TextDisappear or false
				TBC.Callback      = TBC.Callback      or function() end
				local Click=SetProps(MakeElement("Button"),{Size=UDim2.new(1,0,1,0)})
				local TbA=AddThemeObject(Create("TextBox",{
					Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
					TextColor3=Color3.fromRGB(255,255,255), PlaceholderColor3=Color3.fromRGB(100,100,100),
					PlaceholderText="Input", Font=Enum.Font.GothamSemibold,
					TextXAlignment=Enum.TextXAlignment.Center, TextSize=14, ClearTextOnFocus=false
				}),"Text")
				local TC3=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,10),{
					Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-14,0.5,0), AnchorPoint=Vector2.new(1,0.5)
				}),{
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.65}),
					TbA
				}),"Main")
				local TbF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,40), Parent=ItemParent
				}),{
					AddThemeObject(SetProps(MakeElement("Label",TBC.Name,15),{
						Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,12,0,0),
						Font=Enum.Font.GothamBold, Name="Content"
					}),"Text"),
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7}),
					TC3, Click
				}),"Second")
				AddConnection(TbA:GetPropertyChangedSignal("Text"),function()
					TweenService:Create(TC3,TweenCache.Smooth,{Size=UDim2.new(0,TbA.TextBounds.X+16,0,26)}):Play()
				end)
				AddConnection(TbA.FocusLost,function()
					TBC.Callback(TbA.Text)
					if TBC.TextDisappear then TbA.Text="" end
				end)
				TbA.Text=TBC.Default
				AddConnection(Click.MouseEnter,  function() HoverIn(TbF) end)
				AddConnection(Click.MouseLeave,  function() HoverOut(TbF) end)
				AddConnection(Click.MouseButton1Up,function() TweenService:Create(TbF,TweenCache.Fast,{BackgroundColor3=Color3.fromRGB(18,18,18)}):Play(); TbA:CaptureFocus() end)
				AddConnection(Click.MouseButton1Down,function(x,y) CreateRipple(TbF,x,y) end)
			end

			function EF:AddColorpicker(CPC)
				CPC            = CPC or {}
				CPC.Name       = CPC.Name     or "Colorpicker"
				CPC.Default    = CPC.Default  or Color3.fromRGB(255,255,255)
				CPC.Callback   = CPC.Callback or function() end
				CPC.Flag       = CPC.Flag     or nil
				CPC.Save       = CPC.Save     or false
				local H,S,V=Color3.toHSV(CPC.Default)
				local CH,CS,CV=H,S,V
				local CP={Value=CPC.Default,Toggled=false,Type="Colorpicker",Save=CPC.Save}
				local CSel=Create("ImageLabel",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(S,0,1-V,0),
					AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,
					Image="http://www.roblox.com/asset/?id=4805639000"})
				local HSel=Create("ImageLabel",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0.5,0,1-H,0),
					AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,
					Image="http://www.roblox.com/asset/?id=4805639000"})
				local CPad=Create("ImageLabel",{Size=UDim2.new(1,-24,1,0),Visible=false,Image="rbxassetid://4155801252"},
					{Create("UICorner",{CornerRadius=UDim.new(0,6)}),CSel})
				local HPad=Create("Frame",{Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-18,0,0),Visible=false},{
					Create("UIGradient",{Rotation=270,Color=ColorSequence.new{
						ColorSequenceKeypoint.new(0.00,Color3.fromRGB(255,0,4)),
						ColorSequenceKeypoint.new(0.20,Color3.fromRGB(234,255,0)),
						ColorSequenceKeypoint.new(0.40,Color3.fromRGB(21,255,0)),
						ColorSequenceKeypoint.new(0.60,Color3.fromRGB(0,255,255)),
						ColorSequenceKeypoint.new(0.80,Color3.fromRGB(0,17,255)),
						ColorSequenceKeypoint.new(0.90,Color3.fromRGB(255,0,251)),
						ColorSequenceKeypoint.new(1.00,Color3.fromRGB(255,0,4))
					}}),
					Create("UICorner",{CornerRadius=UDim.new(0,6)}),HSel
				})
				local CPCont=Create("Frame",{Position=UDim2.new(0,0,0,34),Size=UDim2.new(1,0,1,-34),
					BackgroundTransparency=1,ClipsDescendants=true},{
					HPad,CPad,
					Create("UIPadding",{PaddingLeft=UDim.new(0,28),PaddingRight=UDim.new(0,28),
						PaddingBottom=UDim.new(0,8),PaddingTop=UDim.new(0,12)})
				})
				local Clk=SetProps(MakeElement("Button"),{Size=UDim2.new(1,0,1,0)})
				local CPBox=SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,8),{
					Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-14,0.5,0), AnchorPoint=Vector2.new(1,0.5)
				}),{Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=1,Transparency=0.45})})
				local CPF=AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame",Color3.fromRGB(5,5,5),0,12),{
					Size=UDim2.new(1,0,0,40), Parent=ItemParent
				}),{
					SetProps(SetChildren(MakeElement("TFrame"),{
						AddThemeObject(SetProps(MakeElement("Label",CPC.Name,15),{
							Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,12,0,0),
							Font=Enum.Font.GothamBold, Name="Content"
						}),"Text"),
						CPBox, Clk,
						Create("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
							Name="Line",Visible=false, BackgroundColor3=Color3.fromRGB(255,255,255),
							BackgroundTransparency=0.85,BorderSizePixel=0})
					}),{Size=UDim2.new(1,0,0,40),ClipsDescendants=true,Name="F"}),
					CPCont,
					Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=0.5,Transparency=0.7})
				}),"Second")
				local lastCPU=0
				local function UpdateCP()
					if tick()-lastCPU<0.05 then return end; lastCPU=tick()
					local c=Color3.fromHSV(CH,CS,CV); CP.Value=c
					CPBox.BackgroundColor3=c; CPad.BackgroundColor3=Color3.fromHSV(CH,1,1)
					CPC.Callback(c); SaveCfg(game.GameId)
				end
				local isAnim=false
				AddConnection(Clk.MouseButton1Click,function()
					if isAnim then return end; isAnim=true
					CP.Toggled=not CP.Toggled
					if CP.Toggled then
						CPad.Visible=true; HPad.Visible=true; CPF.F.Line.Visible=true
						TweenService:Create(CPF,TweenCache.Medium,{Size=UDim2.new(1,0,0,158)}):Play()
						task.wait(0.3)
					else
						TweenService:Create(CPF,TweenCache.Fast,{Size=UDim2.new(1,0,0,40)}):Play()
						task.wait(0.2); CPad.Visible=false; HPad.Visible=false; CPF.F.Line.Visible=false
					end
					isAnim=false
				end)
				local DrgC,DrgI_C=false
				AddConnection(CPad.InputBegan,function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
						DrgC=true; AddConnection(Input.Changed,function() if Input.UserInputState==Enum.UserInputState.End then DrgC=false;FocusDrag=nil end end)
					end
				end)
				AddConnection(CPad.InputChanged,function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch then
						DrgI_C=Input; FocusDrag=DrgI_C
					end
				end)
				AddConnection(UserInputService.InputChanged,function(Input)
					if Input==DrgI_C and DrgC and Input==FocusDrag then
						CS=math.clamp((Input.Position.X-CPad.AbsolutePosition.X)/CPad.AbsoluteSize.X,0,1)
						CV=1-math.clamp((Input.Position.Y-CPad.AbsolutePosition.Y)/CPad.AbsoluteSize.Y,0,1)
						CSel.Position=UDim2.new(CS,0,1-CV,0); UpdateCP()
					end
				end)
				local DrgH,DrgI_H=false
				AddConnection(HPad.InputBegan,function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
						DrgH=true; AddConnection(Input.Changed,function() if Input.UserInputState==Enum.UserInputState.End then DrgH=false;FocusDrag=nil end end)
					end
				end)
				AddConnection(HPad.InputChanged,function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch then
						DrgI_H=Input; FocusDrag=DrgI_H
					end
				end)
				AddConnection(UserInputService.InputChanged,function(Input)
					if Input==DrgI_H and DrgH and DrgI_H==FocusDrag then
						local hy=math.clamp((Input.Position.Y-HPad.AbsolutePosition.Y)/HPad.AbsoluteSize.Y,0,1)
						HSel.Position=UDim2.new(0.5,0,hy,0); CH=1-hy; UpdateCP()
					end
				end)
				function CP:Set(v)
					self.Value=v; CPBox.BackgroundColor3=v
					local nh,ns,nv=Color3.toHSV(v); CH,CS,CV=nh,ns,nv
					CSel.Position=UDim2.new(ns,0,1-nv,0); HSel.Position=UDim2.new(0.5,0,1-nh,0)
					CPad.BackgroundColor3=Color3.fromHSV(nh,1,1); CPC.Callback(v)
				end
				CP:Set(CPC.Default)
				if CPC.Flag then EclipseLib.Flags[CPC.Flag]=CP end
				return CP
			end

			return EF
		end -- GetElements

		local ElementFunction={}
		function ElementFunction:AddSection(SC2)
			SC2.Name=SC2.Name or "Section"
			local SF=SetChildren(SetProps(MakeElement("TFrame"),{
				Size=UDim2.new(1,0,0,26), Parent=Container
			}),{
				AddThemeObject(SetProps(MakeElement("Label",SC2.Name,13),{
					Size=UDim2.new(1,-12,0,16), Position=UDim2.new(0,0,0,3),
					Font=Enum.Font.GothamSemibold
				}),"TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"),{
					AnchorPoint=Vector2.new(0,0), Size=UDim2.new(1,0,1,-24),
					Position=UDim2.new(0,0,0,23), Name="Holder"
				}),{MakeElement("List",0,6)})
			})
			AddConnection(SF.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"),function()
				SF.Size=UDim2.new(1,0,0,SF.Holder.UIListLayout.AbsoluteContentSize.Y+31)
				SF.Holder.Size=UDim2.new(1,0,0,SF.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)
			local SFn={}
			for i,v in next, GetElements(SF.Holder) do SFn[i]=v end
			return SFn
		end
		for i,v in next, GetElements(Container) do ElementFunction[i]=v end
		return ElementFunction
	end -- MakeTab

	return TabFunction
end -- MakeWindow

return EclipseLib

-- ============================================================
-- BABIS HUB — BIZARRE RUN (Library Build)
-- Loaded via loadstring — returns the Babis handle.
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local TextService = game:GetService("TextService")
local PhysicsService = game:GetService("PhysicsService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local genv = _G
do
    local ok, g = pcall(function() return getgenv() end)
    if ok and type(g) == "table" then genv = g end
end
if type(genv.BabisUnload) == "function" then pcall(genv.BabisUnload) end
if type(genv.ANON_TOPNOTIF_CLEANUP) == "function" then pcall(genv.ANON_TOPNOTIF_CLEANUP) end

local safeParent = playerGui
do
    local ok, h = pcall(function() return gethui() end)
    if ok and h then safeParent = h
    else
        local ok2, cg = pcall(function() return CoreGui end)
        if ok2 and cg then safeParent = cg end
    end
end

for _, holder in ipairs({ safeParent, playerGui, CoreGui }) do
    pcall(function()
        for _, n in ipairs({ "ModernUI", "BabisFOVCircle", "BabisPlatformToggle", "BabisAutoAttack", "BabisBlock", "EssenceUI", "BabisIntro", "BabisNotification", "BabisHub", "BabisWatermark", "AutoBlockUI", "CactusZone", "RemoveTreesRocks", "HorseSpeed", "BabisESP", "WaypointESP", "CodeScanUI", "StandMonitorUI", "StandScanUI", "AutoSummonStandUI", "StandMonitorScanUI", "BizarreScanUI", "ImgViewerUI", "ImgScanUI", "SpinScanUI", "SpinDiagUI", "AutoSpinUI", "ANON_TopNotif", "SpinBanner", "NoDashCDPanel", "AimCamPanel", "AutoBlockPanel", "BabisBlockRange", "BabisBlockRangeCircle", "SlideToBackUI", "SideDashStandalone", "EspSuitePanel", "EspDrawGui", "EspSkeletonDraw", "EspBoxDraw", "EspLinesDraw", "HubGUI", "ScarySafe", "AutoBandage", "GetKey", "SA_Panel", "SA_Fov", "AutoPickKey", "ScaryMonsterSafe", "EspLinesDraw" }) do
            local old = holder:FindFirstChild(n)
            if old then old:Destroy() end
        end
    end)
end
pcall(function()
    for _, n in ipairs({"BabisSafePlatforms","BabisPlatforms","SafeWaterBomb","WaypointESP_Folder","BabisBlockRangeCircle","BabisBlockRange","SideDashRange","SideDashRangeStandalone"}) do
        local f = Workspace:FindFirstChild(n)
        if f then f:Destroy() end
    end
end)

local THEME = {
    Window=Color3.fromRGB(10,10,10), WindowStroke=Color3.fromRGB(36,36,38), Content=Color3.fromRGB(12,12,12), Line=Color3.fromRGB(22,22,22), Header=Color3.fromRGB(15,15,15), HeaderBand=Color3.fromRGB(12,12,12), Card=Color3.fromRGB(18,18,18), CardStroke=Color3.fromRGB(24,24,24), TabActive=Color3.fromRGB(20,20,20), TabStroke=Color3.fromRGB(22,30,36), Text=Color3.fromRGB(255,255,255), TextSub=Color3.fromRGB(110,110,110), HeaderText=Color3.fromRGB(100,100,100), Value=Color3.fromRGB(230,230,230), Dash=Color3.fromRGB(200,200,200), BtnSq=Color3.fromRGB(26,26,26), TextDim=Color3.fromRGB(65,65,65), TextGhost=Color3.fromRGB(150,150,150), Box=Color3.fromRGB(14,14,14), BoxOn=Color3.fromRGB(34,34,34), BoxStroke=Color3.fromRGB(32,32,32), BoxStrokeOn=Color3.fromRGB(160,160,160), KnobOff=Color3.fromRGB(100,100,100), KnobOn=Color3.fromRGB(195,195,195), Track=Color3.fromRGB(22,22,22), Fill=Color3.fromRGB(195,195,195), Thumb=Color3.fromRGB(135,135,135), Popup=Color3.fromRGB(16,16,16), Hover=Color3.fromRGB(30,30,30)
}

local FONT, FONT_B = Enum.Font.GothamMedium, Enum.Font.GothamBold
local WIN_W, WIN_H = 408, 272
local TOP_H, SIDE_W, MIN_SIZE, UI_TRANSPARENCY = 32, 95, 48, 0
local alive, keyCapturing = true, false
local KeybindCallbacks = {}

local function create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    inst.Parent = parent
    return inst
end
local function stroke(inst, c, t) return create("UIStroke", { Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, inst) end
local function tween(inst, props, t) TweenService:Create(inst, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end
local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local function sanitize(n) n = tostring(n or ""):gsub("[^%w _%-]", ""); n = n:match("^%s*(.-)%s*$"); return n:sub(1, 24) end

local function makeDraggable(handle, target, onClick)
    local dragging, moved, ds, sp = false, false, nil, nil
    local function clampTarget()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local absPos = target.AbsolutePosition
        local w = target.Size.X.Offset
        local h = target.Size.Y.Offset
        local dx, dy = 0, 0
        if absPos.X < 0 then dx = -absPos.X end
        if absPos.Y < 0 then dy = -absPos.Y end
        if absPos.X + w > vp.X then dx = dx + (vp.X - (absPos.X + w)) end
        if absPos.Y + h > vp.Y then dy = dy + (vp.Y - (absPos.Y + h)) end
        if dx ~= 0 or dy ~= 0 then
            target.Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset + dx, target.Position.Y.Scale, target.Position.Y.Offset + dy)
        end
    end
    handle.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true; moved = false; ds = input.Position; sp = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragging and not moved and onClick then onClick() end
                    dragging = false
                    clampTarget()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and isMove(input) then
            local d = input.Position - ds
            if d.Magnitude > 4 then moved = true end
            if moved then
                target.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
                clampTarget()
            end
        end
    end)
end

local DEFAULTS = {
    theme_color=THEME.Header, auto_load_config=false, last_selected_config="", keybind="RightShift",
    aim_toggle=false, aim_target_bone="HumanoidRootPart", aim_predict_value=0.08,
    aimcam_toggle=false, aimcam_target_bone="HumanoidRootPart", aimcam_predict_value=0.08,
    aimcam_offset_h=-2.00, aimcam_offset_v=0.00,
    cactus_remove=false, remove_tree=false, remove_mini_rocks=false,
    horse_speed_toggle=false, horse_speed_value=170,
    esp_master=false, esp_highlight=false, esp_skeleton=false, esp_name=false, esp_box=false, esp_lines=false, esp_health=false,
    esp_players=false, esp_stand=false, esp_horse=false, esp_waypoints=false,
    low_graphics=false,
    sandman_slide=false, sandman_slide_speed=5,
    silent_aim=false, silent_bone="HumanoidRootPart", silent_fov=300, silent_predict=0.08,
    silent_ping_comp=false,
    auto_attack=false, aa_range=15, aa_delay=0.36,
    auto_block=false, ab_range=15, range_view=false,
    platform_safe=false,
    summon_stand=false, summon_interval=0.5, summon_timeout=8,
    auto_reload=false, reload_interval=1.0,
    auto_spin=false, spin_interval=1,
    best_settings=false, auto_mount=false, auto_mount_interval=1, dash_nocooldown=false, dash_size=0.3,
    auto_join_queue=false,
    side_dash=false, side_dash_speed=50, side_dash_range=19, side_dash_range_view=false, side_dash_direction="RIGHT",
    esp_arrow=false, esp_arrow_fragment=false, esp_arrow_bandage=false, esp_arrow_rokakaka=false, esp_arrow_exit=false,
    arrow_remove_tunnels=false,
    auto_key=false, key_esp=false,
    auto_bandage=false, bandage_hp=80,
    kb_silent_aim="None", kb_auto_attack="None", kb_auto_block="None", kb_aim_toggle="None", kb_aimcam_toggle="None", kb_side_dash="None", kb_side_dash_fire="None", kb_auto_join_queue="None"
}
genv.BabisOptions = genv.BabisOptions or {}
local Options = genv.BabisOptions
for k, v in pairs(DEFAULTS) do if Options[k] == nil then Options[k] = v end end

local ChangedEvent = Instance.new("BindableEvent")
genv.BabisOptionChanged = ChangedEvent.Event
local function setOption(k, v) Options[k] = v; pcall(function() ChangedEvent:Fire(k, v) end) end
local Registry = {}

local FOLDER, CONFIG_FOLDER, AUTOLOAD_FILE = "ModernUI", "ModernUI/configs", "ModernUI/autoload.txt"
local hasFS = typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function" and typeof(listfiles) == "function" and typeof(delfile) == "function" and typeof(makefolder) == "function" and typeof(isfolder) == "function"
local memory = { configs = {}, auto = nil }
if hasFS then pcall(function() if not isfolder(FOLDER) then makefolder(FOLDER) end; if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end end) end
local function cfgPath(n) return CONFIG_FOLDER .. "/" .. n .. ".json" end
local Storage = {}
function Storage.list()
    local out = {}
    if hasFS then
        local ok, files = pcall(listfiles, CONFIG_FOLDER)
        if ok and typeof(files) == "table" then
            for _, p in ipairs(files) do local n = tostring(p):match("([/\\]+)%.json$") or tostring(p):match("([^/\\]+)%.json$"); if n then table.insert(out, n) end end
        end
    else for n in pairs(memory.configs) do table.insert(out, n) end end
    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end
function Storage.exists(n) if hasFS then local ok, r = pcall(isfile, cfgPath(n)); return ok and r == true end; return memory.configs[n] ~= nil end
function Storage.write(n, d)
    local okEnc, json = pcall(HttpService.JSONEncode, HttpService, d)
    if not okEnc then return false end
    if hasFS then return (pcall(writefile, cfgPath(n), json)) end
    memory.configs[n] = json; return true
end
function Storage.read(n)
    local json
    if hasFS then local ok, r = pcall(readfile, cfgPath(n)); if not ok then return nil end; json = r else json = memory.configs[n] end
    if not json then return nil end
    local ok, d = pcall(HttpService.JSONDecode, HttpService, json)
    if ok and typeof(d) == "table" then return d end
end
function Storage.delete(n) if hasFS then return (pcall(delfile, cfgPath(n))) end; memory.configs[n] = nil; return true end
function Storage.getAuto()
    if hasFS then
        local ok, has = pcall(isfile, AUTOLOAD_FILE)
        if ok and has then local ok2, r = pcall(readfile, AUTOLOAD_FILE); if ok2 and r ~= "" then return r end end
        return nil
    end
    return memory.auto
end
function Storage.setAuto(n)
    if hasFS then
        if n then pcall(writefile, AUTOLOAD_FILE, n) else pcall(function() if isfile(AUTOLOAD_FILE) then delfile(AUTOLOAD_FILE) end end) end
    else memory.auto = n end
end

local PERSIST_KEYS = {
    "theme_color", "last_selected_config", "keybind", "aim_toggle", "aim_target_bone", "aim_predict_value", "aimcam_toggle", "aimcam_target_bone", "aimcam_predict_value",
    "aimcam_offset_h", "aimcam_offset_v",
    "cactus_remove", "remove_tree", "remove_mini_rocks",
    "horse_speed_toggle", "horse_speed_value",
    "esp_master", "esp_highlight", "esp_skeleton", "esp_name", "esp_box", "esp_lines", "esp_health",
    "esp_players", "esp_stand", "esp_horse", "esp_waypoints",
    "low_graphics",
    "sandman_slide", "sandman_slide_speed",
    "silent_aim", "silent_bone", "silent_fov", "silent_predict", "silent_ping_comp",
    "auto_attack", "aa_range", "aa_delay",
    "auto_block", "ab_range", "range_view",
    "platform_safe",
    "summon_stand", "summon_interval", "summon_timeout",
    "auto_reload", "reload_interval",
    "auto_spin", "spin_interval",
    "best_settings", "auto_mount", "auto_mount_interval", "dash_nocooldown", "dash_size",
    "auto_join_queue",
    "side_dash", "side_dash_speed", "side_dash_range", "side_dash_range_view", "side_dash_direction",
    "esp_arrow", "esp_arrow_fragment", "esp_arrow_bandage", "esp_arrow_rokakaka", "esp_arrow_exit",
    "arrow_remove_tunnels",
    "auto_key", "key_esp",
    "auto_bandage", "bandage_hp",
    "kb_silent_aim", "kb_auto_attack", "kb_auto_block", "kb_aim_toggle", "kb_aimcam_toggle", "kb_side_dash", "kb_side_dash_fire", "kb_auto_join_queue"
}
local STR_KEYS = {
    last_selected_config=true, keybind=true, aim_target_bone=true, aimcam_target_bone=true, silent_bone=true, side_dash_direction=true,
    kb_silent_aim=true, kb_auto_attack=true, kb_auto_block=true, kb_aim_toggle=true, kb_aimcam_toggle=true, kb_side_dash=true, kb_side_dash_fire=true, kb_auto_join_queue=true
}
local NUM_KEYS = { horse_speed_value=true, sandman_slide_speed=true, silent_fov=true, silent_predict=true, aim_predict_value=true, aimcam_predict_value=true, aa_range=true, aa_delay=true, ab_range=true, summon_interval=true, summon_timeout=true, reload_interval=true, spin_interval=true, aimcam_offset_h=true, aimcam_offset_v=true, dash_size=true, auto_mount_interval=true, side_dash_speed=true, side_dash_range=true, bandage_hp=true }

local function serializeOptions()
    local s = {}
    for _, k in ipairs(PERSIST_KEYS) do local v = Options[k]; if typeof(v) == "Color3" then s[k] = { R = v.R, G = v.G, B = v.B } else s[k] = v end end
    return s
end
local function parseColor(v)
    if type(v) == "table" and type(v.R) == "number" and type(v.G) == "number" and type(v.B) == "number" then return Color3.new(math.clamp(v.R, 0, 1), math.clamp(v.G, 0, 1), math.clamp(v.B, 0, 1)) end
end
local function deserializeOptions(d)
    local a = {}
    for _, k in ipairs(PERSIST_KEYS) do
        local v = d[k]
        if v ~= nil then
            local g
            if k == "theme_color" then g = parseColor(v) elseif type(v) == "boolean" then g = v elseif NUM_KEYS[k] then local n = tonumber(v); if n then g = n end elseif STR_KEYS[k] then if type(v) == "string" then g = v end end
            if g ~= nil then setOption(k, g); a[k] = true end
        end
    end
    return a
end

local gui = create("ScreenGui", { Name="ModernUI", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=100 }, safeParent)
genv.BabisHub = gui

local main = create("Frame", { Name="Main", AnchorPoint=Vector2.new(0,0), Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2), Size=UDim2.new(0,WIN_W,0,WIN_H), BackgroundColor3=THEME.Window, BackgroundTransparency=UI_TRANSPARENCY, BorderSizePixel=0 }, gui)
stroke(main, THEME.WindowStroke, 1)

local topBar = create("Frame", { Name="TopBar", Size=UDim2.new(1,0,0,TOP_H), BackgroundColor3=THEME.Header, BackgroundTransparency=UI_TRANSPARENCY, BorderSizePixel=0 }, main)
create("TextLabel", { Name="Title", BackgroundTransparency=1, Position=UDim2.new(0,11,0,0), Size=UDim2.new(1,-60,1,0), Font=FONT_B, RichText=true, Text='<font size="16">BABIS</font> | A BIZZARE RUN <font size="11" color="rgb(70,70,82)">(Mobile)</font>', TextColor3=THEME.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd }, topBar)

local minimizeBtn = create("TextButton", { Name="Minimize", AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-6,0.5,0), Size=UDim2.new(0,24,0,24), BackgroundTransparency=1, AutoButtonColor=false, Font=FONT, Text="-", TextColor3=THEME.Dash, TextSize=13 }, topBar)
minimizeBtn.MouseEnter:Connect(function() tween(minimizeBtn, { TextColor3 = THEME.Text }) end)
minimizeBtn.MouseLeave:Connect(function() tween(minimizeBtn, { TextColor3 = THEME.Dash }) end)
create("Frame", { Name="TopLine", Position=UDim2.new(0,0,1,0), Size=UDim2.new(1,0,0,1), BackgroundColor3=THEME.Line, BorderSizePixel=0 }, topBar)

local body = create("Frame", { Name="Body", Position=UDim2.new(0,0,0,TOP_H+1), Size=UDim2.new(1,0,1,-(TOP_H+1)), BackgroundTransparency=1, ClipsDescendants=true }, main)
local sidebar = create("Frame", { Name="Sidebar", Size=UDim2.new(0,SIDE_W,1,0), BackgroundTransparency=1 }, body)
create("UIPadding", { PaddingTop=UDim.new(0,6), PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4) }, sidebar)
create("UIListLayout", { Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder }, sidebar)
local content = create("Frame", { Name="Content", Position=UDim2.new(0,SIDE_W+1,0,0), Size=UDim2.new(1,-(SIDE_W+1),1,0), BackgroundColor3=THEME.Content, BackgroundTransparency=0, BorderSizePixel=0 }, body)
create("Frame", { Name="SideLine", Position=UDim2.new(0,SIDE_W,0,0), Size=UDim2.new(0,1,1,0), BackgroundColor3=THEME.Line, BorderSizePixel=0 }, body)

local toast = create("TextLabel", { Name="Toast", AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,SIDE_W/2,1,-8), Size=UDim2.new(0,240,0,22), BackgroundColor3=THEME.Popup, BackgroundTransparency=0, BorderSizePixel=0, Font=FONT, Text="", TextColor3=THEME.Text, TextSize=10, Visible=false, ZIndex=20 }, main)
stroke(toast, THEME.BoxStroke, 1)
local toastToken = 0
local function notify(t) if not alive then return end; toastToken += 1; local m = toastToken; toast.Text = tostring(t); toast.Visible = true; task.delay(2.5, function() if toastToken == m and toast then toast.Visible = false end end) end

local closer = create("TextButton", { Name="Closer", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Visible=false, ZIndex=9 }, main)
local activePopup = nil
local function closePopup() if activePopup then activePopup:Destroy(); activePopup = nil end; closer.Visible = false end
closer.MouseButton1Click:Connect(closePopup)

local layoutCounter = 0
local function nextOrder() layoutCounter += 1; return layoutCounter end
local pageSec, deps, rowMeta = {}, {}, {}

local function setDisabled(inner, d)
    local m = rowMeta[inner]; if not m then return end
    if m.stroke then tween(m.stroke, { Transparency = d and 0.6 or 0 }, 0.15) end
    m.sink.Visible = d
end
local function refreshDeps(flag)
    local list = deps[flag]; if not list then return end
    local on = Options[flag] == true
    for _, inner in ipairs(list) do setDisabled(inner, not on) end
end

local function newRow(page, h, requires, plain)
    local outer = create("Frame", { Size=UDim2.new(1,0,0,h), BackgroundColor3=THEME.Card, BackgroundTransparency=plain and 1 or 0, BorderSizePixel=0, LayoutOrder=nextOrder() }, page)
    local st = nil; if not plain then st = stroke(outer, THEME.CardStroke, 1) end
    local inner = create("Frame", { Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0 }, outer)
    local sink = create("TextButton", { Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", AutoButtonColor=false, Visible=false, ZIndex=5 }, outer)
    rowMeta[inner] = { outer = outer, stroke = st, sink = sink }
    local sec = pageSec[page]; if sec then sec.rows[#sec.rows + 1] = outer end
    if requires then deps[requires] = deps[requires] or {}; table.insert(deps[requires], inner); setDisabled(inner, Options[requires] ~= true) end
    return inner
end

local function newLabel(parent, t, h)
    return create("TextLabel", { BackgroundTransparency=1, Position=UDim2.new(0,8,0,0), Size=UDim2.new(0.6,0,0,h), Font=FONT, Text=t, TextColor3=THEME.Text, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left }, parent)
end

local function addSectionHeader(page, title)
    local outer = create("Frame", { Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, BorderSizePixel=0, LayoutOrder=nextOrder() }, page)
    local band = create("Frame", { Size=UDim2.new(1,0,0,20), BackgroundColor3=THEME.HeaderBand, BorderSizePixel=0 }, outer)
    create("Frame", { Position=UDim2.new(0,0,1,-1), Size=UDim2.new(1,0,0,1), BackgroundColor3=THEME.Line, BorderSizePixel=0 }, band)
    create("TextLabel", { BackgroundTransparency=1, Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,-20,1,0), Font=FONT_B, Text=string.upper(title), TextColor3=THEME.HeaderText, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left }, band)
    local btn = create("TextButton", { AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0.5,-1), Size=UDim2.new(0,13,0,13), BackgroundColor3=THEME.BtnSq, BorderSizePixel=0, AutoButtonColor=false, Font=FONT_B, Text="-", TextColor3=THEME.Text, TextSize=13 }, band)
    local sec = { rows = {}, collapsed = false }; pageSec[page] = sec
    btn.MouseButton1Click:Connect(function()
        sec.collapsed = not sec.collapsed
        btn.Text = sec.collapsed and "+" or "-"
        for _, r in ipairs(sec.rows) do r.Visible = not sec.collapsed end
    end)
end

local function addToggle(page, opts)
    local r = newRow(page, 27, opts.Requires)
    newLabel(r, opts.Text, 27)
    local kbBox
    if opts.Keybind then
        kbBox = create("TextButton", { AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-42,0.5,0), Size = UDim2.new(0,40,0,18), BackgroundColor3 = THEME.Box, BorderSizePixel = 0, AutoButtonColor = false, Font = FONT, Text = Options[opts.Keybind] or "None", TextColor3 = THEME.TextSub, TextSize = 9, ZIndex = 2 }, r)
        local kbs = stroke(kbBox, THEME.BoxStroke, 1)
        local listening = false
        kbBox.MouseButton1Click:Connect(function()
            if listening then
                listening = false
                kbBox.Text = Options[opts.Keybind] or "None"
                tween(kbs, { Color=THEME.BoxStroke }, 0.15)
            else
                listening = true
                kbBox.Text = "..."
                pcall(function() GuiService:ReleaseFocus() end)
                tween(kbs, { Color=THEME.BoxStrokeOn }, 0.15)
            end
        end)
        if opts.Keybind then Registry[opts.Keybind] = function(v) kbBox.Text = tostring(v); end end
        UserInputService.InputBegan:Connect(function(input, processed)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if listening then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        listening = false
                        kbBox.Text = Options[opts.Keybind] or "None"
                    else
                        setOption(opts.Keybind, input.KeyCode.Name)
                        kbBox.Text = input.KeyCode.Name
                        listening = false
                        pcall(function() GuiService:ReleaseFocus() end)
                    end
                    tween(kbs, { Color=THEME.BoxStroke }, 0.15)
                end
                return
            end
        end)
    end
    local box = create("Frame", { AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-8,0.5,0), Size=UDim2.new(0,26,0,12), BackgroundColor3=THEME.Box, BorderSizePixel=0 }, r)
    local bs = stroke(box, THEME.BoxStroke, 1)
    local knob = create("Frame", { AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,2,0.5,0), Size=UDim2.new(0,9,0,9), BackgroundColor3=THEME.KnobOff, BorderSizePixel=0 }, box)
    local btn = create("TextButton", { Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=1 }, r)
    local state = Options[opts.Flag] == true
    local function render(a)
        local d = a and 0.15 or 0
        tween(knob, { Position = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = state and THEME.KnobOn or THEME.KnobOff }, d)
        tween(box, { BackgroundColor3 = state and THEME.BoxOn or THEME.Box }, d)
        tween(bs, { Color = state and THEME.BoxStrokeOn or THEME.BoxStroke }, d)
        if opts.Flag then refreshDeps(opts.Flag) end
    end
    render(false)
    local function performToggle(newState, viaKeybind, fromButton)
        state = newState
        setOption(opts.Flag, state)
        render(true)
        if opts.Callback then opts.Callback(state, viaKeybind, fromButton) end
    end
    if opts.Flag then Registry[opts.Flag] = function(v, viaKeybind, fromButton) performToggle(v == true, viaKeybind, fromButton) end end
    btn.MouseButton1Click:Connect(function()
        if opts.Requires and Options[opts.Requires] ~= true then return end
        performToggle(not state, false)
    end)
    if opts.Keybind then
        KeybindCallbacks[opts.Keybind] = function()
            if opts.Requires and Options[opts.Requires] ~= true then return end
            performToggle(not state, true)
        end
    end
    return { Set = function(v) performToggle(v, false) end }
end

local function addSlider(page, spec)
    local key, minV, maxV = spec.Flag, spec.Min, spec.Max
    local dec = spec.Decimals or 0
    local suffix = spec.Suffix or ""
    local mult = 10 ^ dec
    local value = tonumber(Options[key]) or minV
    local r = newRow(page, 32, spec.Requires)
    local rowFrame = rowMeta[r].outer
    newLabel(r, spec.Text, 22)
    local vl = create("TextLabel", { BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-8,0,0), Size=UDim2.new(0,80,0,22), Font=FONT, Text=tostring(value)..suffix, TextColor3=THEME.Value, TextSize=9, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=0 }, rowFrame)
    local track = create("Frame", { Position=UDim2.new(0,8,0,24), Size=UDim2.new(1,-16,0,2), BackgroundColor3=THEME.Track, BorderSizePixel=0, ZIndex=0 }, rowFrame)
    local fill = create("Frame", { Size=UDim2.new(0,0,1,0), BackgroundColor3=THEME.Fill, BorderSizePixel=0 }, track)
    local holder = create("Frame", { Position=UDim2.new(0,8,0,24), Size=UDim2.new(1,-16,0,2), BackgroundTransparency=1, BorderSizePixel=0 }, r)
    local thumb = create("Frame", { AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0,0,0.5,0), Size=UDim2.new(0,4,0,7), BackgroundColor3=THEME.Thumb, BorderSizePixel=0, ZIndex=2 }, holder)
    local hit = create("TextButton", { Position=UDim2.new(0,4,0,16), Size=UDim2.new(1,-8,0,16), BackgroundTransparency=1, Text="" }, r)
    local function render()
        local a = (value - minV) / (maxV - minV)
        fill.Size = UDim2.new(a, 0, 1, 0); thumb.Position = UDim2.new(a, 0, 0.5, 0); vl.Text = tostring(value)..suffix
    end
    render()
    if key then
        Registry[key] = function(v)
            local n = tonumber(v); if not n then return end
            value = math.clamp(math.floor(n * mult + 0.5) / mult, minV, maxV)
            render(); if spec.Callback then pcall(spec.Callback, value) end
        end
    end
    local function isLocked() return spec.Requires and Options[spec.Requires] ~= true end
    local dragging = false
    local function setVal(v)
        if isLocked() then return end
        value = math.clamp(math.floor(v * mult + 0.5) / mult, minV, maxV)
        setOption(key, value); render(); if spec.Callback then spec.Callback(value) end
    end
    local function fromX(x)
        if isLocked() then return end
        local pos = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setVal(minV + (maxV - minV) * pos)
    end
    hit.InputBegan:Connect(function(input)
        if isPress(input) then
            if isLocked() then return end
            dragging = true; page.ScrollingEnabled = false; fromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input) if dragging and isMove(input) then fromX(input.Position.X) end end)
    UserInputService.InputEnded:Connect(function(input) if dragging and isPress(input) then dragging = false; page.ScrollingEnabled = true end end)
end

local function addDropdown(page, title, spec)
    local r = newRow(page, 27, spec.Requires)
    newLabel(r, title, 27)
    local btn = create("TextButton", { AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-8,0.5,0), Size=UDim2.new(0,160,0,20), BackgroundTransparency=1, AutoButtonColor=false, Text="" }, r)
    local cur = create("TextLabel", { BackgroundTransparency=1, Size=UDim2.new(1,-14,1,0), Font=FONT, Text=tostring(spec.get()), TextColor3=THEME.TextSub, TextSize=9, TextXAlignment=Enum.TextXAlignment.Right, TextTruncate=Enum.TextTruncate.AtEnd }, btn)
    create("TextLabel", { AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,10,1,0), BackgroundTransparency=1, Font=FONT, Text="v", TextColor3=THEME.TextDim, TextSize=9, TextXAlignment=Enum.TextXAlignment.Right }, btn)
    local obj = {}
    local function render() cur.Text = tostring(spec.get()) end
    obj.refresh = render
    if spec.flag then Registry[spec.flag] = function(v) spec.set(v); render() end end
    btn.MouseButton1Click:Connect(function()
        if activePopup then closePopup(); return end
        local opts = spec.getOptions(); local ih, vis = 20, math.min(#opts, 5); local ph = vis * (ih + 2) + 4
        local w = math.max(btn.AbsoluteSize.X, 140); local p = btn.AbsolutePosition - main.AbsolutePosition
        local x = p.X + btn.AbsoluteSize.X - w; local y = p.Y + btn.AbsoluteSize.Y + 3
        if y + ph > WIN_H - 4 then y = p.Y - ph - 3 end
        closer.Visible = true
        local popup = create("Frame", { Position=UDim2.fromOffset(x,y), Size=UDim2.new(0,w,0,ph), BackgroundColor3=THEME.Popup, BorderSizePixel=0, ZIndex=10 }, main)
        stroke(popup, THEME.BoxStroke, 1)
        local scroll = create("ScrollingFrame", { Position=UDim2.new(0,2,0,2), Size=UDim2.new(1,-4,1,-4), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=THEME.BoxStroke, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ZIndex=10 }, popup)
        create("UIListLayout", { Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder }, scroll)
        for i, opt in ipairs(opts) do
            local item = create("TextButton", { Size=UDim2.new(1,-2,0,ih), BackgroundColor3=THEME.Hover, BackgroundTransparency=1, BorderSizePixel=0, AutoButtonColor=false, Font=FONT, Text=opt, TextColor3=(opt==spec.get()) and THEME.Text or THEME.TextSub, TextSize=10, TextTruncate=Enum.TextTruncate.AtEnd, LayoutOrder=i, ZIndex=11 }, scroll)
            item.MouseEnter:Connect(function() tween(item, { BackgroundTransparency = 0 }, 0.1) end)
            item.MouseLeave:Connect(function() tween(item, { BackgroundTransparency = 1 }, 0.1) end)
            item.MouseButton1Click:Connect(function() closePopup(); spec.set(opt); render(); if spec.Callback then spec.Callback(opt) end end)
        end
        activePopup = popup
    end)
    return obj
end

local function addTextbox(page, opts)
    local r = newRow(page, 27, opts.Requires)
    newLabel(r, opts.Text, 27)
    local frame = create("Frame", { AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-8,0.5,0), Size=UDim2.new(0,120,0,18), BackgroundColor3=THEME.Box, BorderSizePixel=0 }, r)
    local fs = stroke(frame, THEME.BoxStroke, 1)
    local init = opts.Flag and tostring(Options[opts.Flag] or "") or ""
    local tb = create("TextBox", { BackgroundTransparency=1, Position=UDim2.new(0,8,0,0), Size=UDim2.new(1,-16,1,0), Font=FONT, PlaceholderText=opts.Placeholder or "", PlaceholderColor3=THEME.TextDim, Text=init, TextColor3=THEME.Text, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false, ClipsDescendants=true }, frame)
    tb.Focused:Connect(function() tween(fs, { Color = THEME.BoxStrokeOn }) end)
    tb.FocusLost:Connect(function() tween(fs, { Color = THEME.BoxStroke }); if opts.Flag then setOption(opts.Flag, tb.Text) end end)
    tb:GetPropertyChangedSignal("Text"):Connect(function() local c = tb.Text:gsub("[^%w _%-]", ""):sub(1, 24); if c ~= tb.Text then tb.Text = c end end)
    if opts.Flag then Registry[opts.Flag] = function(v) tb.Text = tostring(v or "") end end
    return { Get = function() return tb.Text end, Set = function(v) tb.Text = tostring(v) end }
end

local function addKeybind(page, key, title, callback, onPress, requires)
    local r = newRow(page, 27, requires)
    newLabel(r, title, 27)
    local frame = create("Frame", { AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-8,0.5,0), Size=UDim2.new(0,120,0,18), BackgroundColor3=THEME.Box, BorderSizePixel=0 }, r)
    local fs = stroke(frame, THEME.BoxStroke, 1)
    local tb = create("TextButton", { BackgroundTransparency=1, Position=UDim2.new(0,8,0,0), Size=UDim2.new(1,-16,1,0), Font=FONT, Text=tostring(Options[key] or "RightShift"), TextColor3=THEME.Text, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=2 }, frame)
    local listening = false; local listenerConn = nil
    local function render()
        if listening then tb.Text = "Press a key..."; tb.TextColor3 = THEME.BoxStrokeOn; tween(fs, { Color = THEME.BoxStrokeOn }, 0.15)
        else tb.Text = tostring(Options[key] or "RightShift"); tb.TextColor3 = THEME.Text; tween(fs, { Color = THEME.BoxStroke }, 0.15) end
    end
    render()
    local function stopListening() listening = false; keyCapturing = false; if listenerConn then pcall(function() listenerConn:Disconnect() end); listenerConn = nil end; render() end
    if key then Registry[key] = function(v) Options[key] = v; render() end end
    tb.MouseButton1Click:Connect(function()
        if requires and Options[requires] ~= true then return end
        if listening then stopListening(); return end
        listening = true; keyCapturing = true; render()
        if listenerConn then pcall(function() listenerConn:Disconnect() end) end
        listenerConn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if not listening then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Escape then stopListening(); return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            setOption(key, input.KeyCode.Name); stopListening()
            pcall(function() GuiService:ReleaseFocus() end)
            if callback then callback(input.KeyCode.Name) end
        end)
    end)
    frame.MouseEnter:Connect(function() if not listening then tween(fs, { Color = THEME.BoxStrokeOn }, 0.12) end end)
    frame.MouseLeave:Connect(function() if not listening then tween(fs, { Color = THEME.BoxStroke }, 0.15) end end)
    if onPress then
        KeybindCallbacks[key] = function()
            if requires and Options[requires] ~= true then return end
            onPress()
        end
    end
end

local function addButtons(page, buttons)
    local r = newRow(page, 24, nil, true)
    local n = #buttons; local gap = 4
    for i, info in ipairs(buttons) do
        local b = create("TextButton", { Position=UDim2.new((i-1)/n,(i-1)*gap/n,0,0), Size=UDim2.new(1/n,-gap*(n-1)/n,1,0), BackgroundColor3=THEME.Card, BackgroundTransparency=(info.Locked==true) and 0.35 or 0, BorderSizePixel=0, AutoButtonColor=false, Font=FONT, Text=info.Text, TextColor3=(info.Locked==true) and THEME.TextGhost or THEME.Text, TextSize=10, ClipsDescendants=true }, r)
        stroke(b, THEME.CardStroke, 1)
        b.MouseEnter:Connect(function() tween(b, { BackgroundColor3 = THEME.Hover }, 0.1) end)
        b.MouseLeave:Connect(function() tween(b, { BackgroundColor3 = THEME.Card }, 0.1) end)
        b.MouseButton1Click:Connect(function()
            if info.Locked == true then notify("Only available in the Premium version."); return end
            b.BackgroundColor3 = THEME.TabActive; tween(b, { BackgroundColor3 = THEME.Hover }, 0.15)
            if info.Callback then info.Callback() end
        end)
    end
end

local pages, tabButtons, tabStrokes = {}, {}, {}
local function selectTab(name)
    closePopup()
    for n, data in pairs(pages) do
        local sel = (n == name)
        data.page.Visible = sel
        tween(tabButtons[n], { BackgroundTransparency = sel and 0 or 1, TextColor3 = sel and THEME.Text or THEME.TextGhost })
        tween(tabStrokes[n], { Transparency = sel and 0 or 1 })
    end
end
local function createTab(name)
    local btn = create("TextButton", { Name=name, Size=UDim2.new(1,0,0,24), BackgroundColor3=THEME.TabActive, BackgroundTransparency=1, BorderSizePixel=0, AutoButtonColor=false, Font=FONT, Text=name, TextColor3=THEME.TextGhost, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=nextOrder() }, sidebar)
    create("UIPadding", { PaddingLeft = UDim.new(0, 7) }, btn)
    local ts = stroke(btn, THEME.TabStroke, 1); ts.Transparency = 1
    local page = create("ScrollingFrame", { Name=name.."Page", Position=UDim2.new(0,5,0,5), Size=UDim2.new(1,-9,1,-5), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=THEME.BoxStroke, ScrollBarImageTransparency=0.4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, Visible=false }, content)
    create("UIListLayout", { Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder }, page)
    create("UIPadding", { PaddingTop=UDim.new(0,2), PaddingLeft=UDim.new(0,2), PaddingRight=UDim.new(0,3), PaddingBottom=UDim.new(0,6) }, page)
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    btn.MouseEnter:Connect(function() if not page.Visible then tween(btn, { TextColor3 = THEME.Text }) end end)
    btn.MouseLeave:Connect(function() if not page.Visible then tween(btn, { TextColor3 = THEME.TextGhost }) end end)
    tabButtons[name] = btn; tabStrokes[name] = ts; pages[name] = { page = page }
    return page
end

local function getMyOrigin()
    local char = player.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    if head then return head.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position + Vector3.new(0, 1.5, 0) end
    return nil
end

local isAiming, isCamLocked = false, false
local aimConn = nil
local camLockTarget = nil
local camLockBind = "BabisAimCamLock"
local lastCamCFrame = nil
local camGraceUntil = 0
local lastToolName = nil

local SilentAim = (function()
    local fovGui = create("ScreenGui", { Name="BabisFOVCircle", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=90 }, safeParent)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local function getFov() return tonumber(Options.silent_fov) or 300 end
    local function getBone() return tostring(Options.silent_bone or "HumanoidRootPart") end
    local function getPredict()
        local base = tonumber(Options.silent_predict) or 0.08
        if Options.silent_ping_comp then
            local ok, p = pcall(function() return player:GetNetworkPing() end)
            if ok and type(p) == "number" and p > 0 then base = base + p end
        end
        return base
    end
    local circle = create("Frame", { AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.fromOffset(getFov()*2, getFov()*2), BackgroundTransparency=1, BorderSizePixel=0, Visible=false }, fovGui)
    create("UICorner", { CornerRadius=UDim.new(0.5,0) }, circle)
    create("UIStroke", { Color=WHITE, Thickness=1.5, Transparency=0.25, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, circle)
    create("Frame", { AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.fromOffset(3,3), BackgroundColor3=WHITE, BackgroundTransparency=0.2, BorderSizePixel=0 }, circle)
    local function updateCircle()
        local px = getFov()
        circle.Size = UDim2.fromOffset(px*2, px*2)
        circle.Visible = Options.silent_aim == true
    end
    updateCircle()

    local remotes = {}
    pcall(function()
        local s = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Knit") and ReplicatedStorage.Packages.Knit:FindFirstChild("Services")
        if not s then return end
        local frf = s.FirearmService and s.FirearmService:FindFirstChild("RF")
        if frf then remotes.Shoot = frf:FindFirstChild("Shoot"); remotes.ShootShotgun = frf:FindFirstChild("ShootShotgun") end
        local asvc = s.AimService and s.AimService:FindFirstChild("RE")
        if asvc then remotes.Aim = asvc:FindFirstChild("Aim") end
    end)

    local function forgeAim(tgt)
        if not remotes.Aim or not tgt then return end
        local myOrigin = getMyOrigin()
        if not myOrigin then return end
        local aimPos = tgt.part.Position
        local predict = getPredict()
        if predict > 0 then
            local root = tgt.char and tgt.char:FindFirstChild("HumanoidRootPart")
            if root then aimPos = aimPos + root.AssemblyLinearVelocity * predict end
        end
        local dir = aimPos - myOrigin
        if dir.Magnitude < 0.1 then return end
        dir = dir.Unit
        local pitch = math.deg(math.asin(math.clamp(dir.Y, -1, 1)))
        local yaw = math.deg(math.atan2(-dir.X, -dir.Z))
        local b = buffer.create(2)
        buffer.writeu8(b, 0, math.floor(pitch + 0.5) % 256)
        buffer.writeu8(b, 1, math.floor(yaw / 180 * 128 + 0.5) % 256)
        if isCamLocked then
            local myChar = player.Character
            if myChar then
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                if hum and myHrp then
                    local flatDir = Vector3.new(dir.X, 0, dir.Z)
                    if flatDir.Magnitude > 0.05 then
                        if not isAiming then
                            hum.AutoRotate = false
                            task.delay(0.1, function()
                                if hum and hum.Parent and not isAiming then hum.AutoRotate = true end
                            end)
                        end
                        myHrp.CFrame = CFrame.lookAt(myHrp.Position, myHrp.Position + flatDir.Unit)
                    end
                end
            end
        end
        pcall(function() remotes.Aim:FireServer(b) end)
    end

    local function findNearest()
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        if isCamLocked and camLockTarget and camLockTarget.Parent then
            local hum = camLockTarget:FindFirstChildOfClass("Humanoid")
            local hrp = camLockTarget:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local tp = camLockTarget:FindFirstChild(getBone()) or camLockTarget:FindFirstChild("Head") or hrp
                if tp then
                    return { char = camLockTarget, part = tp, player = true, hum = hum, dist = 0, name = camLockTarget.Name }
                end
            end
        end
        local vp = cam.ViewportSize; local center = Vector2.new(vp.X/2, vp.Y/2)
        local myPos = myHrp.Position; local bone = getBone(); local maxRange = 500; local fovRadius = getFov()
        local best, bestDist = nil, math.huge
        local function checkTarget(charModel, isPlayer)
            local hum = charModel:FindFirstChildOfClass("Humanoid")
            local hrp = charModel:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local d = (hrp.Position - myPos).Magnitude
                if d <= maxRange and d < bestDist then
                    local tp = charModel:FindFirstChild(bone) or charModel:FindFirstChild("Head") or hrp
                    if tp then
                        local sp, on = cam:WorldToViewportPoint(tp.Position)
                        if on then
                            local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if screenDist <= fovRadius then
                                best = { char = charModel, part = tp, player = isPlayer and true or false, hum = hum, dist = d, name = charModel.Name }
                                bestDist = d
                            end
                        end
                    end
                end
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then checkTarget(p.Character, true) end
        end
        local rigs = workspace:FindFirstChild("Rigs")
        if rigs then
            for _, m in ipairs(rigs:GetChildren()) do
                if m:IsA("Model") and m ~= myChar and m.Name ~= player.Name then checkTarget(m, false) end
            end
        end
        return best
    end

    local function mutate(packed, n, tgt)
        local cfIdx, v3Idx, partIdx = nil, nil, nil
        for i = 1, n do
            local a = packed[i]
            if typeof(a) == "CFrame" and not cfIdx then cfIdx = i end
            if typeof(a) == "Vector3" and a.Magnitude > 20 and not v3Idx then v3Idx = i end
            if typeof(a) == "Instance" and a:IsA("BasePart") and not partIdx then partIdx = i end
        end
        if not cfIdx or not v3Idx then return false end
        local aimPos = tgt.part.Position
        local predict = getPredict()
        if predict > 0 then
            local root = tgt.char and tgt.char:FindFirstChild("HumanoidRootPart")
            if root then aimPos = aimPos + root.AssemblyLinearVelocity * predict end
        end
        local myOrigin = getMyOrigin()
        if not myOrigin then return false end
        local dir = aimPos - myOrigin
        if dir.Magnitude < 0.1 then return false end
        packed[cfIdx] = CFrame.lookAt(myOrigin, aimPos)
        packed[v3Idx] = aimPos
        if partIdx then packed[partIdx] = tgt.part end
        return true
    end

    local installed, mtRef, oldRef = false, nil, nil
    local function hooked(self, old, ...)
        local method
        local ok = pcall(function() method = getnamecallmethod() end)
        if not ok or not method then return old(self, ...) end
        if not (method == "InvokeServer" and (self == remotes.Shoot or self == remotes.ShootShotgun)) then return old(self, ...) end
        if not Options.silent_aim then return old(self, ...) end
        local tgt = findNearest()
        if not tgt then return old(self, ...) end
        forgeAim(tgt); forgeAim(tgt); forgeAim(tgt)
        local n = select("#", ...); local packed = table.pack(...)
        if not mutate(packed, n, tgt) then return old(self, ...) end
        local invokeFn = nil
        pcall(function() invokeFn = self.InvokeServer end)
        local ret
        if invokeFn then
            local ok2, r = pcall(invokeFn, self, table.unpack(packed, 1, n))
            if ok2 then ret = r
            else
                local fbOk, fbRet = pcall(function() return old(self, table.unpack(packed, 1, n)) end)
                if fbOk then ret = fbRet end
            end
        else
            local ok2, r = pcall(function() return old(self, table.unpack(packed, 1, n)) end)
            if ok2 then ret = r end
        end
        return ret
    end

    local function install()
        if installed then return true end
        local ok, mt = pcall(getrawmetatable, game)
        if not ok or not mt then return false end
        local old = mt.__namecall
        if not old then return false end
        mtRef, oldRef = mt, old
        local sOk = pcall(function() setreadonly(mt, false); mt.__namecall = function(self, ...) return hooked(self, old, ...) end; setreadonly(mt, true) end)
        installed = sOk
        return sOk
    end

    local function uninstall()
        if mtRef and oldRef then pcall(function() setreadonly(mtRef, false); mtRef.__namecall = oldRef; setreadonly(mtRef, true) end) end
        mtRef, oldRef = nil, nil; installed = false
    end

    return { setEnabled = function(on) if on then install() else uninstall() end; updateCircle() end, updateCircle = updateCircle, destroy = function() uninstall(); pcall(function() fovGui:Destroy() end) end }
end)()

local AutoAttack = (function()
    local remotes = {}
    pcall(function() local s = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Knit") and ReplicatedStorage.Packages.Knit:FindFirstChild("Services"); if s then local attack = s.AttackService and s.AttackService:FindFirstChild("RE"); remotes.Attack = attack and attack:FindFirstChild("Attack") end end)
    local state = { running = false, combo = 1, lastTarget = "" }; local thread = nil
    local function findNearest()
        local c = player.Character; if not c then return nil end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
        local myPos = hrp.Position; local rng = tonumber(Options.aa_range) or 15
        local best, bestDist = nil, math.huge
        local function check(charModel, isPlayer, pName)
            local hum = charModel:FindFirstChildOfClass("Humanoid")
            local pHrp = charModel:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and pHrp then
                local d = (pHrp.Position - myPos).Magnitude
                if d <= rng and d < bestDist then
                    local tp = charModel:FindFirstChild("Head") or pHrp
                    best = { char = charModel, part = tp, player = {Name = pName}, dist = d, hum = hum }
                    bestDist = d
                end
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then check(p.Character, true, p.Name) end
        end
        local rigs = Workspace:FindFirstChild("Rigs")
        if rigs then
            for _, m in ipairs(rigs:GetChildren()) do
                if m:IsA("Model") and m ~= c and m.Name ~= player.Name then check(m, false, m.Name) end
            end
        end
        return best
    end
    local function fire()
        if not remotes.Attack then return false end
        local c = player.Character; if not c then return false end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
        local target = findNearest(); if not target then state.combo = 1; return false end
        if state.lastTarget ~= target.player.Name then state.lastTarget = target.player.Name; state.combo = 1 end
        local myPos = hrp.Position + Vector3.new(0, 1.5, 0); local cf = CFrame.lookAt(myPos, target.part.Position); local now = workspace:GetServerTimeNow()
        pcall(function() remotes.Attack:FireServer(state.combo, now, cf) end)
        state.combo = (state.combo % 6) + 1
        return true
    end
    local function loop()
        while state.running do
            local ok = fire()
            if ok then task.wait(tonumber(Options.aa_delay) or 0.36) else task.wait(0.1) end
        end
        thread = nil
    end
    return { setEnabled = function(on) state.running = on; if on then state.combo = 1; state.lastTarget = ""; if thread then return end; thread = task.spawn(loop) end end }
end)()

local RangeView = (function()
    local RANGE_DEFAULT = 15; local COLOR_IN  = Color3.fromRGB(40, 255, 80); local COLOR_OUT = Color3.fromRGB(255, 40, 40); local TRANSP_IN  = 0.55; local TRANSP_OUT = 0.7; local THICKNESS  = 0.2; local GROUND_OFF = 0.1
    local state = { part = nil, enabled = false, lastCheck = 0, groundY = nil }
    local function build()
        if state.part and state.part.Parent then state.part:Destroy() end
        local p = Instance.new("Part"); p.Name = "BabisBlockRange"; p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.CastShadow = false; p.Material = Enum.Material.SmoothPlastic; p.Color = COLOR_OUT; p.Transparency = 1; p.Size = Vector3.new(RANGE_DEFAULT * 2, THICKNESS, RANGE_DEFAULT * 2); p.Parent = Workspace; state.part = p
    end
    local function getGroundY()
        if tick() - state.lastCheck < 0.25 and state.groundY then return state.groundY end; state.lastCheck = tick()
        local c = player.Character; if not c then return nil end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
        local ray = RaycastParams.new(); ray.FilterType = Enum.RaycastFilterType.Exclude; ray.FilterDescendantsInstances = { c }; ray.IgnoreWater = true
        local ok, result = pcall(function() return Workspace:Raycast(hrp.Position, Vector3.new(0, -60, 0), ray) end)
        local y; if ok and result then y = result.Position.Y else local hum = c:FindFirstChildOfClass("Humanoid"); y = hrp.Position.Y - ((hum and hum.HipHeight) or 2) end
        state.groundY = y; return y
    end
    local function anyoneInRange(myPos, rng)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - myPos).Magnitude <= rng then return true end
            end
        end
        local rigs = Workspace:FindFirstChild("Rigs")
        if rigs then
            for _, m in ipairs(rigs:GetChildren()) do
                if m:IsA("Model") and m.Name ~= player.Name then
                    local mHrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    if mHrp and mHrp:IsA("BasePart") and (mHrp.Position - myPos).Magnitude <= rng then return true end
                end
            end
        end
        return false
    end
    build()

    local lastViewUpdate = 0
    task.spawn(function()
        while alive do
            local p = state.part
            if p and tick() - lastViewUpdate > 0.066 then
                lastViewUpdate = tick()
                if not state.enabled then if p.Transparency ~= 1 then p.Transparency = 1 end
                else
                    local c = player.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart"); local groundY = hrp and getGroundY()
                    if hrp and groundY then
                        local rng = tonumber(Options.ab_range) or RANGE_DEFAULT
                        p.CFrame = CFrame.new(hrp.Position.X, groundY + GROUND_OFF, hrp.Position.Z); p.Size = Vector3.new(rng * 2, THICKNESS, rng * 2)
                        local inR = anyoneInRange(hrp.Position, rng); p.Color = inR and COLOR_IN or COLOR_OUT; p.Transparency = inR and TRANSP_IN or TRANSP_OUT
                    else if p.Transparency ~= 1 then p.Transparency = 1 end end
                end
            end
            task.wait(0.05)
        end
    end)
    return { setEnabled = function(on) state.enabled = on == true; if not state.enabled and state.part then state.part.Transparency = 1 end end, destroy = function() if state.part then state.part:Destroy(); state.part = nil end end }
end)()

local AutoBlock = (function()
    local blockRemote = nil
    pcall(function() local s = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Knit") and ReplicatedStorage.Packages.Knit:FindFirstChild("Services"); if s then local attack = s.AttackService and s.AttackService:FindFirstChild("RE"); blockRemote = attack and attack:FindFirstChild("Block") end end)
    local state = { running = false, lastInRange = false }; local rsConn = nil
    local function anyInRange()
        local c = player.Character; if not c then return false end
        local myHrp = c:FindFirstChild("HumanoidRootPart"); if not myHrp then return false end
        local rng = tonumber(Options.ab_range) or 15
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if pHrp and (pHrp.Position - myHrp.Position).Magnitude <= rng then return true end
            end
        end
        local rigs = Workspace:FindFirstChild("Rigs")
        if rigs then
            for _, m in ipairs(rigs:GetChildren()) do
                if m:IsA("Model") and m.Name ~= player.Name then
                    local mHrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    if mHrp and mHrp:IsA("BasePart") and (mHrp.Position - myHrp.Position).Magnitude <= rng then return true end
                end
            end
        end
        return false
    end
    local function tryFire()
        if not blockRemote then return end
        local c = player.Character; if not c then return end
        local inRange = anyInRange()
        if inRange then
            local now = workspace:GetServerTimeNow(); local readyAt = c:GetAttribute("CombatBlockReadyAt") or 0; if now < readyAt then return end
            pcall(function() blockRemote:FireServer(true, now, nil) end); state.lastInRange = true
        elseif state.lastInRange then
            pcall(function() blockRemote:FireServer(false, workspace:GetServerTimeNow()) end); state.lastInRange = false
        end
    end
    task.spawn(function()
        while true do
            if state.running then
                local c = player.Character
                if c then
                    local hrp = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 and hum.MoveDirection.Magnitude > 0.1 then
                        local st = hum:GetState()
                        if st == Enum.HumanoidStateType.Running or st == Enum.HumanoidStateType.RunningNoPhysics or st == Enum.HumanoidStateType.Landed then
                            local dir = hum.MoveDirection.Unit; local step = dir * 8 * 0.05
                            local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = { c }
                            local hit = workspace:Raycast(hrp.Position, step * 2, params); if not hit then pcall(function() hrp.CFrame = hrp.CFrame + step end) end
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
    return { setEnabled = function(on) state.running = on; if on then if not rsConn then rsConn = RunService.Heartbeat:Connect(function() if state.running then tryFire() end end) end else if rsConn then rsConn:Disconnect(); rsConn = nil end; if state.lastInRange and blockRemote then pcall(function() blockRemote:FireServer(false, workspace:GetServerTimeNow()) end); state.lastInRange = false end end end }
end)()

local function hasActiveStand()
    local char = player.Character; if not char then return false, "no character" end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Model") then
            local nm = c.Name:lower(); local ss = nil; pcall(function() ss = c:GetAttribute("StandStyle") end)
            local hasSS = ss and tostring(ss) ~= "" and tostring(ss) ~= "None"
            if nm:find("stand") or hasSS then return true, "char/" .. c.Name end
        end
    end
    if char:FindFirstChild("StandPart") then return true, "char/StandPart" end
    if char:FindFirstChild("StandAura") then return true, "char/StandAura" end
    local rigs = Workspace:FindFirstChild("Rigs"); local rig = rigs and rigs:FindFirstChild(player.Name)
    if rig then
        for _, c in ipairs(rig:GetChildren()) do
            if c:IsA("Model") then
                local nm = c.Name:lower(); local ss = nil; pcall(function() ss = c:GetAttribute("StandStyle") end)
                local hasSS = ss and tostring(ss) ~= "" and tostring(ss) ~= "None"
                if nm:find("stand") or hasSS then return true, "rig/" .. c.Name end
            end
        end
    end
    local tagged = nil
    pcall(function()
        for _, inst in ipairs(CollectionService:GetTagged("Stand")) do
            if inst:IsDescendantOf(char) then tagged = "tag Stand"; return end
            if rig and inst:IsDescendantOf(rig) then tagged = "tag Stand"; return end
        end
        if not tagged then
            for _, inst in ipairs(CollectionService:GetTagged("StandActive")) do
                if inst:IsDescendantOf(char) then tagged = "tag StandActive"; return end
                if rig and inst:IsDescendantOf(rig) then tagged = "tag StandActive"; return end
            end
        end
    end)
    if tagged then return true, tagged end
    return false, "none"
end

local function getSpawnStandRemote()
    local r = nil
    pcall(function()
        local s = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Knit") and ReplicatedStorage.Packages.Knit:FindFirstChild("Services")
        if not s then return end
        local svc = s.StandService and s.StandService:FindFirstChild("RE")
        r = svc and svc:FindFirstChild("SpawnStand")
    end)
    return r
end

local AutoSummonStand = (function()
    local state = { running=false, summoned_once=false, lastFireAt=0, interval=tonumber(Options.summon_interval) or 0.5, postFireLock=2, fireTimeout=tonumber(Options.summon_timeout) or 8 }
    local function fire() local remote = getSpawnStandRemote(); if not remote then return false end; return pcall(function() remote:FireServer() end) end
    local function loop()
        while state.running do
            local active = hasActiveStand(); local now = tick()
            if active then if state.summoned_once then state.summoned_once = false end
            elseif not state.summoned_once then if now - state.lastFireAt >= state.postFireLock then if fire() then state.summoned_once = true; state.lastFireAt = now end end
            else if now - state.lastFireAt > state.fireTimeout then state.summoned_once = false end end
            task.wait(state.interval)
        end
    end
    return {
        setEnabled = function(on) if on == state.running then return end; state.running = on; if on then state.summoned_once = false; state.lastFireAt = 0; state.interval = tonumber(Options.summon_interval) or 0.5; state.fireTimeout = tonumber(Options.summon_timeout) or 8; task.spawn(loop) end end,
        setInterval = function(v) state.interval = math.clamp(tonumber(v) or 0.5, 0.1, 5) end,
        setTimeout = function(v) state.fireTimeout = math.clamp(tonumber(v) or 8, 3, 30) end,
    }
end)()

local PlatformSafe = (function()
    local COLOR = Color3.fromRGB(0, 255, 100)
    local MATERIAL = Enum.Material.SmoothPlastic
    local TRANSPARENCY_ON = 1
    local PLATFORMS = {
        { cframe=CFrame.new(3163.81,-169.02,-1558.33)*CFrame.fromEulerAnglesXYZ(math.rad(-156.7),math.rad(-89.6),math.rad(-156.8)), size=Vector3.new(394.41,4.84,1123.81) },
        { cframe=CFrame.new(3550.80,-194.24,-1593.87)*CFrame.fromEulerAnglesXYZ(math.rad(87.8),math.rad(44.6),math.rad(85.8)), size=Vector3.new(513.98,618.36,19.60) },
        { cframe=CFrame.new(3948.04,20.90,-1553.62)*CFrame.fromEulerAnglesXYZ(math.rad(177.9),math.rad(-3.3),math.rad(179.9)), size=Vector3.new(378.78,0.20,384.28) },
    }
    local state = { enabled = false, parts = {}, built = false }
    local function getFolder()
        local f = Workspace:FindFirstChild("SafeWaterBomb")
        if not f then f = Instance.new("Folder"); f.Name = "SafeWaterBomb"; f.Parent = Workspace end
        return f
    end
    local function buildAll()
        local f = getFolder()
        for _, c in ipairs(f:GetChildren()) do if c:IsA("BasePart") and c.Name:find("Platform_") then pcall(function() c:Destroy() end) end end
        state.parts = {}
        for i, p in ipairs(PLATFORMS) do
            local part = Instance.new("Part"); part.Name = "Platform_" .. i .. "_" .. tostring(math.floor(tick() % 100000))
            part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
            part.Size = p.size; part.CFrame = p.cframe; part.Color = COLOR; part.Material = MATERIAL; part.Transparency = 1
            part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
            part.Parent = f; state.parts[#state.parts+1] = part
        end
        state.built = true; return #state.parts
    end
    local function setEnabled(on)
        state.enabled = on == true
        if state.enabled then
            if not state.built then buildAll() end
            for _, p in ipairs(state.parts) do
                if p and p.Parent then pcall(function() p.CanCollide = true; p.CanTouch = false; p.Transparency = TRANSPARENCY_ON end) end
            end
        else
            for _, p in ipairs(state.parts) do
                if p and p.Parent then pcall(function() p.CanCollide = false; p.CanTouch = false; p.Transparency = 1 end) end
            end
        end
    end
    buildAll(); return { setEnabled = setEnabled }
end)()

local ANON_Notify = (function()
    local RunS = game:GetService("RunService"); local UIS = game:GetService("UserInputService")
    local CONFIG = { MaxWidth=320, MinWidth=260, Top=12, Gap=8, MaxVisible=5, DefaultTime=5, MaxLines=3, ReduceMotion=false, Sound=false }
    local THEME2 = { bgTop=Color3.fromRGB(28,28,28), bgBottom=Color3.fromRGB(8,8,8), ring=Color3.fromRGB(18,18,18), title=Color3.fromRGB(255,255,255), message=Color3.fromRGB(180,180,180), closeIcon=Color3.fromRGB(200,200,200) }
    local RADIUS = 12
    local PAD_T, PAD_B, PAD_R = 12, 14, 14
    local LOGO, LOGO_X = 46, 16
    local TEXT_X = LOGO_X + LOGO + 12
    local TITLE_H, TITLE_SIZE = 20, 15
    local MSG_SIZE, MSG_LINE = 11, 1.15
    local BORDER_T, BORDER_HOT = 0.55, 0.2
    local WHITE = Color3.new(1,1,1); local BLACK = Color3.new(0,0,0)
    local function new(class, props, parent) local inst = Instance.new(class); for k, v in pairs(props) do pcall(function() inst[k] = v end) end; if parent then inst.Parent = parent end; return inst end
    local function round(parent, r) return new("UICorner", { CornerRadius = r and UDim.new(0, r) or UDim.new(1,0) }, parent) end
    local function tw(obj, time, props, style, dir) local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props); t:Play(); return t end
    local function measure(text, size, font, width) local ok, v = pcall(function() return TextService:GetTextSize(text, size, font, Vector2.new(width, 10000)) end); if ok and v then return v end; return Vector2.new(width, size) end
    local function isSticky(d) return d <= 0 or d == math.huge end
    local function cardWidth() local cam = workspace.CurrentCamera; local vx = cam and cam.ViewportSize.X or 1280; return math.clamp(math.floor(vx * 0.42), CONFIG.MinWidth, CONFIG.MaxWidth) end
    local function safeCall(fn, ...) if type(fn) == "function" then task.spawn(pcall, fn, ...) end end
    local function norm(t) local r = {}; if type(t) == "table" then for k, v in pairs(t) do r[string.lower(tostring(k))] = v end end; return r end
    local function resolveParent() if gethui then local ok, h = pcall(gethui); if ok and h then return h end end; local ok, core = pcall(function() return game:GetService("CoreGui") end); if ok and core then return core end; return Players.LocalPlayer:WaitForChild("PlayerGui") end
    local gui2 = new("ScreenGui", { Name="ANON_TopNotif", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=2147483647, ZIndexBehavior=Enum.ZIndexBehavior.Sibling })
    do local ok = pcall(function() gui2.Parent = resolveParent() end); if not ok then gui2.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end end
    genv.ANON_TOPNOTIF = gui2
    local stack = new("Frame", { Name="Stack", AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,CONFIG.Top), Size=UDim2.new(0,CONFIG.MaxWidth,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, BorderSizePixel=0 }, gui2)
    new("UIListLayout", { Padding=UDim.new(0,0), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center }, stack)
    local active, globalConns = {}, {}
    local nextId = 0
    local drag, loop, dismiss
    local function computeLayout(n)
        local titleW = n.W - TEXT_X - 38
        local msgW = n.W - TEXT_X - PAD_R
        local msgH = 0
        if n.messageText ~= "" then
            local one = measure("Ag", MSG_SIZE, Enum.Font.Gotham, msgW)
            local full = measure(n.messageText, MSG_SIZE, Enum.Font.Gotham, msgW)
            local lineH = math.max(one.Y, 1)
            local lines = math.clamp(math.floor(full.Y / lineH + 0.5), 1, CONFIG.MaxLines)
            msgH = math.ceil(lines * lineH * MSG_LINE)
        end
        local textH = TITLE_H + ((msgH > 0) and (4 + msgH) or 0)
        local contentH = math.max(textH, LOGO)
        return { H = PAD_T + contentH + PAD_B, titleW = titleW, msgW = msgW, msgH = msgH, textH = textH, contentH = contentH }
    end
    local function px(x) return math.floor(x + 0.5) end
    local function applyLayout(n, animate)
        local L = computeLayout(n); n.H = L.H
        local rowSize = UDim2.fromOffset(n.W, L.H + CONFIG.Gap)
        local holderSize = UDim2.new(1, 0, 0, L.H)
        if animate then tw(n.row, 0.3, { Size = rowSize }); tw(n.holder, 0.3, { Size = holderSize }) else n.holder.Size = holderSize end
        local logoCY = PAD_T + px((L.contentH - LOGO) / 2) + LOGO / 2
        n.logo.Position = UDim2.fromOffset(LOGO_X + LOGO / 2, logoCY)
        n.iconBg.Position = UDim2.fromOffset(LOGO_X + LOGO / 2, logoCY)
        local textY = PAD_T + px((L.contentH - L.textH) / 2)
        n.title.Position = UDim2.fromOffset(TEXT_X, textY)
        n.title.Size = UDim2.fromOffset(L.titleW, TITLE_H)
        n.msg.Position = UDim2.fromOffset(TEXT_X, textY + TITLE_H + 4)
        n.msg.Size = UDim2.fromOffset(L.msgW, math.max(L.msgH, 1))
        n.msg.Visible = L.msgH > 0
    end
    local function applyType(n)
        local c = n.color or Color3.fromRGB(220,220,220)
        n.bar.BackgroundColor3 = c; n.fill.BackgroundColor3 = c; n.border.Color = c
        n.title.TextColor3 = n.titleColor or THEME2.title
        if n.msgColor then n.msg.TextColor3 = n.msgColor end
    end
    local function setHover(n, h)
        n.hovered = h
        if n.entered and not n.removing then tw(n.border, 0.2, { Transparency = h and BORDER_HOT or BORDER_T }) end
        for _, l in ipairs(n.closeLines) do tw(l, 0.2, { BackgroundTransparency = h and 0.05 or 0.45 }) end
    end
    local function onHitBegan(n, input)
        if n.removing then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        drag = { n = n, input = input, sx = input.Position.X, dx = 0, moved = false }
    end
    local function onInputChanged(input)
        if not drag then return end
        local t = input.UserInputType
        local isMv = (t == Enum.UserInputType.MouseMovement) or (t == Enum.UserInputType.Touch and input == drag.input)
        if not isMv then return end
        local n = drag.n
        if n.removing then drag = nil; return end
        local dx = input.Position.X - drag.sx
        if not drag.moved and math.abs(dx) > 6 then drag.moved = true end
        if drag.moved then
            drag.dx = dx
            n.body.Position = UDim2.fromOffset(dx, 0)
            n.body.Rotation = math.clamp(dx / n.W * 8, -8, 8)
            n.card.BackgroundTransparency = math.clamp(math.abs(dx) / (n.W * 0.9), 0, 0.65)
        end
    end
    local function onInputEnded(input)
        if not drag then return end
        local t = input.UserInputType
        local isEnd = (t == Enum.UserInputType.MouseButton1) or (t == Enum.UserInputType.Touch and input == drag.input)
        if not isEnd then return end
        local d = drag; drag = nil; local n = d.n
        if n.removing then return end
        if d.moved then
            if math.abs(d.dx) > n.W * 0.35 then dismiss(n, d.dx > 0 and 1 or -1, "swipe")
            else tw(n.body, 0.35, { Position = UDim2.fromOffset(0, 0), Rotation = 0 }, Enum.EasingStyle.Back); tw(n.card, 0.25, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad) end
        else safeCall(n.onClick, n.handle) end
    end
    local function build(n)
        n.row = new("Frame", { Name="Row", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.fromOffset(n.W,0), LayoutOrder=n.id }, stack)
        n.holder = new("Frame", { Name="Holder", BackgroundTransparency=1, BorderSizePixel=0, AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,0), Size=UDim2.new(1,0,0,60) }, n.row)
        n.scale = new("UIScale", { Scale = 1 }, n.holder)
        n.body = new("Frame", { Name="Body", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0) }, n.holder)
        n.shadows = {}
        for _, s in ipairs({ { 3, 0.86 }, { 8, 0.93 } }) do
            local f = new("Frame", { Name="Shadow", BackgroundTransparency=1, BorderSizePixel=0, ZIndex=0, Position=UDim2.fromOffset(0,3), Size=UDim2.new(1,0,1,0) }, n.body)
            round(f, RADIUS)
            local st = new("UIStroke", { Color=BLACK, Thickness=s[1], Transparency=1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, f)
            n.shadows[#n.shadows+1] = { stroke = st, target = s[2] }
        end
        local card = new("Frame", { Name="Card", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), BackgroundColor3=THEME2.bgTop, ZIndex=1 }, n.body)
        round(card, RADIUS); n.card = card
        local edge = new("Frame", { Name="Edge", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=2 }, n.body)
        round(edge, RADIUS); n.border = new("UIStroke", { Color=WHITE, Thickness=1.2, Transparency=1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, edge)
        local bg = new("Frame", { Name="Bg", BackgroundColor3=WHITE, BackgroundTransparency=0.02, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=1 }, card)
        round(bg, RADIUS); new("UIGradient", { Rotation=90, Color=ColorSequence.new(THEME2.bgTop, THEME2.bgBottom) }, bg)
        n.bar = new("Frame", { Name="Accent", BackgroundColor3=WHITE, BorderSizePixel=0, Position=UDim2.new(0,8,0,10), Size=UDim2.new(0,3,1,-20), ZIndex=3 }, card); round(n.bar)
        n.iconBg = new("Frame", { Name="IconBg", BackgroundColor3=WHITE, BackgroundTransparency=0.9, BorderSizePixel=0, AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.fromOffset(LOGO+4, LOGO+4), ZIndex=5 }, card); round(n.iconBg, 8)
        n.logo = new("ImageLabel", { Name="RewardImg", BackgroundTransparency=1, BorderSizePixel=0, AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.fromOffset(LOGO, LOGO), Image=n.icon or "", ImageColor3=WHITE, ImageTransparency=0, ScaleType=Enum.ScaleType.Fit, ZIndex=6 }, card)
        n.logoScale = new("UIScale", { Scale = 0 }, n.logo)
        n.title = new("TextLabel", { Name="Title", BackgroundTransparency=1, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=TITLE_SIZE, TextColor3=THEME2.title, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center, TextTruncate=Enum.TextTruncate.AtEnd, Text=n.titleText, ZIndex=7 }, card)
        n.msg = new("TextLabel", { Name="Message", BackgroundTransparency=1, BorderSizePixel=0, Font=Enum.Font.Gotham, TextSize=MSG_SIZE, LineHeight=MSG_LINE, TextColor3=THEME2.message, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=true, TextTruncate=Enum.TextTruncate.AtEnd, Text=n.messageText, ZIndex=7 }, card)
        n.track = new("Frame", { Name="Track", BackgroundColor3=WHITE, BackgroundTransparency=0.92, BorderSizePixel=0, AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,14,1,-6), Size=UDim2.new(1,-28,0,2), ZIndex=10, Visible=not n.sticky }, card); round(n.track)
        n.fill = new("Frame", { Name="Fill", BackgroundColor3=WHITE, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=11 }, n.track); round(n.fill)
        n.hit = new("TextButton", { Name="Hit", Text="", AutoButtonColor=false, BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=20 }, card)
        n.hit.InputBegan:Connect(function(input) onHitBegan(n, input) end)
        n.close = new("TextButton", { Name="Close", Text="", AutoButtonColor=false, BackgroundColor3=WHITE, BackgroundTransparency=1, BorderSizePixel=0, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-10,0,10), Size=UDim2.fromOffset(20,20), ZIndex=30 }, card); round(n.close)
        local function line(parent, x1, y1, x2, y2, thick, color)
            local dx, dy = x2-x1, y2-y1; local len = math.sqrt(dx*dx + dy*dy)
            local f = new("Frame", { AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromOffset((x1+x2)/2, (y1+y2)/2), Size=UDim2.fromOffset(len+thick, thick), Rotation=math.deg(math.atan2(dy, dx)), BackgroundColor3=color, BorderSizePixel=0 }, parent)
            round(f); return f
        end
        for _, p in ipairs({ { 6.5, 6.5, 13.5, 13.5 }, { 13.5, 6.5, 6.5, 13.5 } }) do
            local l = line(n.close, p[1], p[2], p[3], p[4], 1.5, THEME2.closeIcon)
            l.BackgroundTransparency = 0.45; n.closeLines[#n.closeLines+1] = l
        end
        n.close.MouseEnter:Connect(function() tw(n.close, 0.15, { BackgroundTransparency = 0.88 }) end)
        n.close.MouseLeave:Connect(function() tw(n.close, 0.15, { BackgroundTransparency = 1 }) end)
        n.close.Activated:Connect(function() dismiss(n, 0, "close") end)
    end
    local function enter(n, first)
        local calm = CONFIG.ReduceMotion
        local style = calm and Enum.EasingStyle.Quad or Enum.EasingStyle.Back
        local startY = calm and 0 or (first and -(n.H + 40) or -CONFIG.Gap)
        n.holder.Position = UDim2.new(0.5, 0, 0, startY); n.scale.Scale = calm and 1 or 0.93
        tw(n.row, 0.40, { Size = UDim2.fromOffset(n.W, n.H + CONFIG.Gap) })
        tw(n.holder, 0.55, { Position = UDim2.new(0.5, 0, 0, 0) }, style)
        tw(n.scale, 0.55, { Scale = 1 }, style)
        tw(n.card, 0.30, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad)
        tw(n.border, 0.40, { Transparency = BORDER_T }, Enum.EasingStyle.Quad)
        for _, s in ipairs(n.shadows) do tw(s.stroke, 0.50, { Transparency = s.target }, Enum.EasingStyle.Quad) end
        task.delay(0.12, function() if n.removing then return end tw(n.logoScale, calm and 0.2 or 0.55, { Scale = 1 }, style) end)
        task.delay(0.30, function() if n.removing then return end n.entered = true end)
    end
    dismiss = function(n, dir, reason)
        if n.removing then return end
        n.removing = true
        local i = table.find(active, n); if i then table.remove(active, i) end
        if drag and drag.n == n then drag = nil end
        safeCall(n.onClose, reason or "api")
        local calm = CONFIG.ReduceMotion; local dirX = dir or 0
        tw(n.card, 0.26, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(n.border, 0.22, { Transparency = 1 })
        for _, s in ipairs(n.shadows) do tw(s.stroke, 0.22, { Transparency = 1 }) end
        if not calm then
            if dirX ~= 0 then tw(n.body, 0.30, { Position = UDim2.fromOffset(dirX * (n.W + 30), 0), Rotation = dirX * 8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            else tw(n.holder, 0.30, { Position = UDim2.new(0.5, 0, 0, -6) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In); tw(n.scale, 0.30, { Scale = 0.95 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In) end
        end
        task.delay(0.16, function() tw(n.row, 0.34, { Size = UDim2.fromOffset(n.W, 0) }, Enum.EasingStyle.Quint) end)
        task.delay(0.6, function() n.row:Destroy() end)
    end
    local function makeHandle(n) local h = {}; h.Dismiss = function() dismiss(n, 0, "api") end; h.IsOpen = function() return not n.removing end; return h end
    local function step(dt)
        local mouse; if UIS.MouseEnabled then mouse = UIS:GetMouseLocation() end
        if drag and drag.input.UserInputState == Enum.UserInputState.End then drag = nil end
        for i = #active, 1, -1 do
            local n = active[i]
            if n and not n.removing then
                local over = false
                if mouse then local p, s = n.card.AbsolutePosition, n.card.AbsoluteSize; over = mouse.X >= p.X and mouse.X <= p.X + s.X and mouse.Y >= p.Y and mouse.Y <= p.Y + s.Y end
                if over ~= n.hovered then setHover(n, over) end
                if not n.sticky then
                    local held = n.hovered or (drag ~= nil and drag.n == n)
                    if not held then n.elapsed = n.elapsed + dt end
                    n.fill.Size = UDim2.new(math.clamp(1 - n.elapsed / n.duration, 0, 1), 0, 1, 0)
                    if n.elapsed >= n.duration then dismiss(n, 0, "timeout") end
                end
            end
        end
        if #active == 0 and loop then loop:Disconnect(); loop = nil end
    end
    local function ensureLoop() if not loop then loop = RunS.Heartbeat:Connect(step) end end
    local function notify(a)
        local o = norm(a)
        local title = (tostring(o.title or ""):gsub("[\r\n]+", " "))
        local message = tostring(o.message or "")
        local duration = tonumber(o.duration) or CONFIG.DefaultTime
        while #active >= CONFIG.MaxVisible and active[1] do dismiss(active[1], 0, "limit") end
        nextId = nextId + 1
        local n = { id = nextId, titleText = title, messageText = message, W = cardWidth(), duration = duration, sticky = isSticky(duration), elapsed = 0, icon = tostring(o.icon or ""), color = typeof(o.color) == "Color3" and o.color or nil, titleColor = typeof(o.titlecolor) == "Color3" and o.titlecolor or nil, msgColor = typeof(o.msgcolor) == "Color3" and o.msgcolor or nil, rainbow = o.rainbow == true, onClose = o.onclose, hovered = false, removing = false, entered = false, closeLines = {} }
        build(n); applyType(n); applyLayout(n, false); n.handle = makeHandle(n)
        if n.rainbow then task.spawn(function() local t = 0; while not n.removing and n.card and n.card.Parent do t = t + 0.08; local c = Color3.fromHSV((t % 1), 0.85, 1); n.bar.BackgroundColor3 = c; n.fill.BackgroundColor3 = c; n.border.Color = c; n.title.TextColor3 = c; task.wait(0.1) end end) end
        local first = (#active == 0)
        active[#active + 1] = n; enter(n, first); ensureLoop(); return n.handle
    end
    local function safeNotify(...) local ok, res = pcall(notify, ...); if not ok then warn("[ANON_Notif] " .. tostring(res)); return nil end; return res end
    globalConns[#globalConns + 1] = UIS.InputChanged:Connect(onInputChanged)
    globalConns[#globalConns + 1] = UIS.InputEnded:Connect(onInputEnded)
    genv.ANON_TOPNOTIF_CLEANUP = function() if loop then loop:Disconnect(); loop = nil end; for _, c in ipairs(globalConns) do pcall(function() c:Disconnect() end) end; pcall(function() gui2:Destroy() end) end
    genv.ANON_Notify = safeNotify
    return safeNotify
end)()

local NOTIF_LOGO = "rbxassetid://74204271047613"
local COLOR_OK = Color3.fromRGB(120, 220, 130)
local COLOR_FAIL = Color3.fromRGB(230, 100, 100)
local COLOR_INFO = Color3.fromRGB(200, 200, 200)
local MONEY_ICON = "rbxassetid://135556993670271"
local POOL = {
    Cash500 = { name="$500 CASH", icon=MONEY_ICON, titleColor=Color3.fromRGB(200,200,200), type="Money", amount=500, weight=41 },
    Cash1000 = { name="$1,000 CASH", icon=MONEY_ICON, titleColor=Color3.fromRGB(230,230,230), type="Money", amount=1000, weight=30 },
    ArrowFragment = { name="STAND ARROW FRAGMENT", icon="rbxassetid://125894668761864", color=Color3.fromRGB(180,140,50), titleColor=Color3.fromRGB(200,160,70), type="ArrowFragment", amount=1, weight=20 },
    StandArrow = { name="STAND ARROW", icon="rbxassetid://137161993733843", color=Color3.fromRGB(230,200,50), titleColor=Color3.fromRGB(240,220,80), type="Item", amount=1, weight=5 },
    RokakakaFruit = { name="ROKAKAKA FRUIT", icon="rbxassetid://103313376054039", color=Color3.fromRGB(220,50,50), titleColor=Color3.fromRGB(240,80,80), type="Item", amount=1, weight=3.5 },
    ShinyArrow = { name="SHINY STAND ARROW", icon="rbxassetid://115010899877143", rainbow=true, type="Item", amount=1, weight=0.5 },
    Dash = { name="DASH", icon="rbxassetid://1135556993670271", color=Color3.fromRGB(50,200,100), titleColor=Color3.fromRGB(80,230,130), type="Item", amount=1, weight=0 },
}
local function poolFromName(name) if not name then return nil end; local n = string.upper(name); for _, p in pairs(POOL) do if string.upper(p.name) == n then return p end end; for id, p in pairs(POOL) do if string.upper(id) == n then return p end end; return nil end

local AutoSpin = (function()
    local spinRF
    pcall(function() spinRF = ReplicatedStorage.Packages.Knit.Services.WheelSpinService.RF.Spin end)
    local WSUIC
    pcall(function() WSUIC = require(ReplicatedStorage.Client.Controllers.UIController.WheelSpinUIController) end)
    local state = { running=false, spinCount=1, thread=nil }
    local shownRequests = {}
    local function uuid() local t = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"; return string.gsub(t, "[xy]", function(c) local v = (c == "x") and math.random(0, 15) or math.random(8, 11); return string.format("%x", v) end) end
    local function getLastResult() if not WSUIC then return nil end; local ok, reel = pcall(function() return WSUIC.Reel end); if not ok or not reel then return nil end; local ok2, data = pcall(function() return reel.Data end); if not ok2 or not data then return nil end; local ok3, ws = pcall(function() return data.WheelSpins end); if not ok3 or not ws then return nil end; return ws.LastResult end
    local function isSpinning() if not WSUIC then return false end; local ok, v = pcall(function() return WSUIC.Reel.Spinning end); return ok and v == true end
    local function extractReward(t) if type(t) ~= "table" then return nil end; if t.Reward and type(t.Reward) == "table" then return t.Reward end; if t.LastResult and type(t.LastResult) == "table" and t.LastResult.Reward then return t.LastResult.Reward end; if t.Name and (t.Id or t.Type) then return t end; return nil end
    local function showRewardOnce(reqId, pool) if reqId and shownRequests[reqId] then return end; if reqId then shownRequests[reqId] = true end; ANON_Notify({ Title = pool.name, Message = string.format("Spins: %d", state.spinCount), Duration = 4, Icon = pool.icon, TitleColor = pool.titleColor, Color = pool.color, Rainbow = pool.rainbow == true }); state.spinCount = state.spinCount + 1 end
    local function fireSpin()
        if not spinRF then return false, nil end
        local id = uuid()
        local ok, result = pcall(function() return spinRF:InvokeServer(id) end)
        if not ok then return false, nil end
        local reward = extractReward(result)
        if reward then local pool = POOL[reward.Id or ""] or poolFromName(reward.Name); if pool then showRewardOnce(id, pool) end end
        return true, id
    end
    local function waitForReward(reqId, timeout) if not reqId or shownRequests[reqId] then return end; local t0 = tick(); while tick() - t0 < timeout do task.wait(0.3); if shownRequests[reqId] then return end; local lr = getLastResult(); if lr and lr.RequestId == reqId and lr.Reward then local pool = POOL[lr.Reward.Id or ""] or poolFromName(lr.Reward.Name); if pool then showRewardOnce(reqId, pool) end; return end end end
    local function loop()
        local lastFire = 0
        while state.running do
            local waited = 0; while isSpinning() and state.running and waited < 30 do task.wait(0.1); waited = waited + 0.1 end; if not state.running then break end
            local interval = tonumber(Options.spin_interval) or 1; local sinceLast = tick() - lastFire
            if sinceLast < interval then local remain = interval - sinceLast; while state.running and remain > 0 do task.wait(math.min(remain, 0.1)); remain = remain - 0.1 end end
            if not state.running then break end
            local ok, reqId = fireSpin()
            if ok then lastFire = tick(); if reqId then task.spawn(function() waitForReward(reqId, 15) end) end else task.wait(0.3) end
        end
    end
    return { setEnabled = function(on) if on == state.running then return end; state.running = on; if on then if state.thread and task.status and task.status(state.thread) ~= "dead" then return end; state.thread = task.spawn(loop) end end, getSpinCount = function() return state.spinCount end }
end)()

local AutoReload = (function()
    local remote = nil
    pcall(function() local s = ReplicatedStorage.Packages.Knit.Services; local svc = s.FirearmService and s.FirearmService:FindFirstChild("RF"); remote = svc and svc:FindFirstChild("Reload") end)
    local state = { running = false }
    local function loop() while state.running do if remote then pcall(function() remote:InvokeServer() end) end; task.wait(tonumber(Options.reload_interval) or 1.0) end end
    return { setEnabled = function(on) if on == state.running then return end; state.running = on; if on then task.spawn(loop) end end }
end)()

local RedeemCodes = (function()
    local CODES = { "RELEASE", "SORRYTRADERS", "D4C", "150KLIKES", "WIRED", "SHUTDOWNSORRY", "SHUTDOWNSORRY2", "250KLIKES", "300KLIKES", "SCARYMONSTERS", "STAGE3FIX", "10MINDELAY", "QOLUPD", "350KLIKES" }
    local function getRemote() local r; pcall(function() local s = ReplicatedStorage.Packages.Knit.Services; local svc = s.LobbyShopService and s.LobbyShopService:FindFirstChild("RF"); r = svc and svc:FindFirstChild("Redeem") end); return r end
    local state = { running = false }
    local function execute()
        if state.running then ANON_Notify({ Title = "Codes", Message = "Already running", Duration = 3, Icon = NOTIF_LOGO, MsgColor = COLOR_INFO, Color = COLOR_INFO }); return end
        local remote = getRemote(); if not remote then ANON_Notify({ Title = "Codes", Message = "Remote not found", Duration = 4, Icon = NOTIF_LOGO, MsgColor = COLOR_FAIL, Color = COLOR_FAIL }); return end
        state.running = true
        task.spawn(function()
            local newCount, alreadyCount = 0, 0; local isRF = remote:IsA("RemoteFunction")
            for _, code in ipairs(CODES) do
                local ok, result = pcall(function() if isRF then return remote:InvokeServer(code) else remote:FireServer(code); return true end end)
                local success = ok; local isAlready = false
                if ok and isRF then
                    if result == false then success = false
                    elseif type(result) == "string" then local lower = result:lower(); if lower:find("already") or lower:find("used") or lower:find("redeemed") then success = false; isAlready = true elseif lower:find("fail") or lower:find("error") or lower:find("invalid") then success = false end
                    elseif type(result) == "table" then if result.success == false or result.Success == false or result.ok == false then success = false end; if result.already == true or result.Already == true then success = false; isAlready = true end end
                end
                if success then newCount = newCount + 1; ANON_Notify({ Title = code, Message = "Redeemed!", Duration = 4, Icon = NOTIF_LOGO, MsgColor = COLOR_OK, Color = COLOR_OK })
                else alreadyCount = alreadyCount + 1; ANON_Notify({ Title = code, Message = "Code already redeemed", Duration = 4, Icon = NOTIF_LOGO, MsgColor = COLOR_FAIL, Color = COLOR_FAIL }) end
                task.wait(1.2)
            end
            ANON_Notify({ Title = "Codes Done", Message = newCount .. " new · " .. alreadyCount .. " redeemed", Duration = 5, Icon = NOTIF_LOGO, MsgColor = COLOR_INFO, Color = COLOR_INFO })
            state.running = false
        end)
    end
    return { execute = execute }
end)()

local function checkCliffRock()
    local map = Workspace:FindFirstChild("Map"); if not map then return false end
    local visual = map:FindFirstChild("Visual"); if not visual then return false end
    local nature = visual:FindFirstChild("Nature"); if not nature then return false end
    local grasslands = nature:FindFirstChild("Grasslands"); if not grasslands then return false end
    local rocks = grasslands:FindFirstChild("Rocks"); if not rocks then return false end
    local cliffs = rocks:FindFirstChild("Cliffs"); if not cliffs then return false end
    local child59 = cliffs:GetChildren()[59]; if not child59 then return false end
    return child59:FindFirstChild("Meshes/LargeCliffRock") ~= nil
end

local CactusRemove = (function()
    local WS = Workspace; local disabledState={}; local enabled=false
    local function isAvailable() return checkCliffRock() end
    local function collectCactiFolders()
        local folders={}; local map=WS:FindFirstChild("Map"); local visual=map and map:FindFirstChild("Visual"); if not visual then return folders end
        local nature=visual:FindFirstChild("Nature")
        if nature then for _,zone in ipairs(nature:GetChildren()) do local foliage=zone:FindFirstChild("Foliage"); if foliage then for _,n in ipairs({"Cactus","Cacti","CactusFoliage"}) do local c=foliage:FindFirstChild(n); if c then folders[#folders+1]=c end end end end end
        local sc=visual:FindFirstChild("ShootingCactuses"); sc=sc and sc:FindFirstChild("Cactuses"); if sc then folders[#folders+1]=sc end
        return folders
    end
    local function forEachPart(root,cb) for _,child in ipairs(root:GetChildren()) do if child:IsA("BasePart") then cb(child) end; for _,d in ipairs(child:GetDescendants()) do if d:IsA("BasePart") then cb(d) end end end end
    local function disablePart(p) if disabledState[p] then return end; disabledState[p]={t=p.Transparency,cc=p.CanCollide,ct=p.CanTouch}; pcall(function() p.Transparency=1; p.CanCollide=false; p.CanTouch=false end) end
    local function restorePart(p) local s=disabledState[p]; if not s then return end; pcall(function() p.Transparency=s.t; p.CanCollide=s.cc; p.CanTouch=s.ct end); disabledState[p]=nil end
    local function applyCactusRemove() for _,folder in ipairs(collectCactiFolders()) do forEachPart(folder,function(p) if not disabledState[p] then disablePart(p) end end) end end
    local function restoreAll() for p,_ in pairs(disabledState) do if p and p.Parent then restorePart(p) end end; disabledState={} end
    local function loop() while enabled do if isAvailable() then applyCactusRemove() end task.wait(0.5) end end
    return { isAvailable = isAvailable, setEnabled = function(on) if on==enabled then return end; enabled=on; if on then task.spawn(loop) else restoreAll() end end }
end)()

local TreesRemove = (function()
    local WS = Workspace; local disabled={}; local enabled=false
    local function collectTrees()
        local folders={}; local nature=WS:FindFirstChild("Map") and WS.Map:FindFirstChild("Visual") and WS.Map.Visual:FindFirstChild("Nature"); if not nature then return folders end
        for _,zone in ipairs(nature:GetChildren()) do local t=zone:FindFirstChild("Foliage") and zone.Foliage:FindFirstChild("Trees"); if t then folders[#folders+1]=t end end
        return folders
    end
    local function forEachPart(root,cb) for _,child in ipairs(root:GetChildren()) do if child:IsA("BasePart") then cb(child) end; for _,d in ipairs(child:GetDescendants()) do if d:IsA("BasePart") then cb(d) end end end end
    local function hidePart(p) if disabled[p] then return end; disabled[p]={t=p.Transparency,cc=p.CanCollide,ct=p.CanTouch}; pcall(function() p.Transparency=1; p.CanCollide=false; p.CanTouch=false end) end
    local function restoreAll() for p,s in pairs(disabled) do if p and p.Parent then pcall(function() p.Transparency=s.t; p.CanCollide=s.cc; p.CanTouch=s.ct end) end end; disabled={} end
    local function apply() for _,folder in ipairs(collectTrees()) do forEachPart(folder,function(p) if not disabled[p] then hidePart(p) end end) end end
    local function loop() while enabled do apply(); task.wait(0.5) end end
    return { setEnabled = function(on) if on==enabled then return end; enabled=on; if on then task.spawn(loop) else restoreAll() end end }
end)()

local MiniRocksRemove = (function()
    local WS = Workspace; local disabled={}; local enabled=false
    local function collectRocks()
        local folders={}; local nature=WS:FindFirstChild("Map") and WS.Map:FindFirstChild("Visual") and WS.Map.Visual:FindFirstChild("Nature"); if not nature then return folders end
        for _,zone in ipairs(nature:GetChildren()) do local r=zone:FindFirstChild("Rocks"); if r then for _,n in ipairs({"Boulders","Spires"}) do local f=r:FindFirstChild(n); if f then folders[#folders+1]=f end end end end
        return folders
    end
    local function forEachPart(root,cb) for _,child in ipairs(root:GetChildren()) do if child:IsA("BasePart") then cb(child) end; for _,d in ipairs(child:GetDescendants()) do if d:IsA("BasePart") then cb(d) end end end end
    local function hidePart(p) if disabled[p] then return end; disabled[p]={t=p.Transparency,cc=p.CanCollide,ct=p.CanTouch}; pcall(function() p.Transparency=1; p.CanCollide=false; p.CanTouch=false end) end
    local function restoreAll() for p,s in pairs(disabled) do if p and p.Parent then pcall(function() p.Transparency=s.t; p.CanCollide=s.cc; p.CanTouch=s.ct end) end end; disabled={} end
    local function apply() for _,folder in ipairs(collectRocks()) do forEachPart(folder,function(p) if not disabled[p] then hidePart(p) end end) end end
    local function loop() while enabled do apply(); task.wait(0.5) end end
    return { setEnabled = function(on) if on==enabled then return end; enabled=on; if on then task.spawn(loop) else restoreAll() end end }
end)()

local BestSettings = (function()
    local setSetting, setHitboxDebug
    pcall(function() local s = ReplicatedStorage.Packages.Knit.Services; setSetting = s.DataService and s.DataService:FindFirstChild("RF") and s.DataService.RF:FindFirstChild("SetSetting"); setHitboxDebug = s.AttackService and s.AttackService:FindFirstChild("RF") and s.AttackService.RF:FindFirstChild("SetHitboxDebug") end)
    local state = { running = false }
    local function fire()
        if not setSetting or not setHitboxDebug then return false end
        pcall(function() setSetting:InvokeServer("LowGraphicsMode", true) end); pcall(function() setHitboxDebug:InvokeServer(true) end)
        pcall(function() setSetting:InvokeServer("ReduceFlashes", true) end); pcall(function() setSetting:InvokeServer("MusicVolume", 0.1) end); pcall(function() setSetting:InvokeServer("ShowHitboxes", true) end)
        return true
    end
    task.spawn(function() while alive do task.wait(5); if state.running then fire() end end end)
    return { setEnabled = function(on) if on == state.running then return end; state.running = on; if on then fire() end end }
end)()

local AutoMount = (function()
    local mountRemote
    pcall(function() local s = ReplicatedStorage.Packages.Knit.Services; mountRemote = s.HorseService and s.HorseService:FindFirstChild("RF") and s.HorseService.RF:FindFirstChild("MountCalledHorse") end)
    local state = { running = false }
    local function fire() if not mountRemote then return false end; return pcall(function() mountRemote:InvokeServer() end) end
    task.spawn(function() while alive do local interval = math.clamp(tonumber(Options.auto_mount_interval) or 1, 1, 5); task.wait(interval); if state.running then fire() end end end)
    return { setEnabled = function(on) state.running = on == true; if on then fire() end end }
end)()

local AutoJoinQueue = (function()
    local remote
    pcall(function() local s = ReplicatedStorage.Packages.Knit.Services; local svc = s.QueueService and s.QueueService:FindFirstChild("RF"); remote = svc and svc:FindFirstChild("JoinQueue") end)
    local state = { running = false, lastFire = 0 }
    local function fire() if not remote then return false end; local ok = pcall(function() remote:InvokeServer() end); if ok then state.lastFire = tick() end; return ok end
    task.spawn(function() while alive do task.wait(3); if state.running then local now = tick(); if now - state.lastFire >= 10 then fire() end end end end)
    return { setEnabled = function(on) if on == state.running then return end; state.running = on; if on then if not remote then ANON_Notify({ Title = "Auto Join Queue", Message = "Remote not found", Duration = 4, Icon = NOTIF_LOGO, MsgColor = COLOR_FAIL, Color = COLOR_FAIL }) else fire(); ANON_Notify({ Title = "Auto Join Queue", Message = "Enabled", Duration = 3, Icon = NOTIF_LOGO, MsgColor = COLOR_OK, Color = COLOR_OK }) end end end }
end)()

local NoDashCooldown = (function()
    local DASH_ANIM = { BACK  = "rbxassetid://74124095477161", LEFT  = "rbxassetid://140323810466191", RIGHT = "rbxassetid://117964155609810" }
    local DASH_SOUND = { BACK  = "rbxassetid://123469111772953", LEFT  = "rbxassetid://123469111772953", RIGHT = "rbxassetid://72045809807649" }
    local DASH_SPEED = 75; local DASH_FOV_KICK = 6; local DASH_INTERVAL = 1.0; local STEER_ENABLED = true
    local state = { running = false, nextDashAt = 0, dashActive = false, hookedBtn = nil }
    local function getDirection()
        local char = player.Character; if not char then return nil, nil end
        local hum = char:FindFirstChildOfClass("Humanoid"); local cam = workspace.CurrentCamera; if not hum or not cam then return nil, nil end
        local md = hum.MoveDirection; if md.Magnitude < 0.1 then return nil, nil end
        local dF = md:Dot(cam.CFrame.LookVector); local dR = md:Dot(cam.CFrame.RightVector)
        if math.abs(dF) > math.abs(dR) then if dF > 0 then return nil, md end; return "BACK", md else return (dR > 0) and "RIGHT" or "LEFT", md end
    end
    local function doDash()
        if not state.running then return end; if state.dashActive then return end; if tick() < state.nextDashAt then return end
        local char = player.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid"); if not hrp or not hum or hum.Health <= 0 then return end
        local dir, moveVec = getDirection(); if not dir then return end
        local duration = math.clamp(tonumber(Options.dash_size) or 0.3, 0.1, 0.5)
        state.nextDashAt = tick() + DASH_INTERVAL; state.dashActive = true; task.delay(duration, function() state.dashActive = false end)
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then local anim = Instance.new("Animation"); anim.AnimationId = DASH_ANIM[dir]; local ok, track = pcall(function() return animator:LoadAnimation(anim) end); if ok and track then pcall(function() track:Play(0.1) end); task.delay(1, function() pcall(function() track:Stop() end) end) end end
        local rigs = workspace:FindFirstChild("Rigs"); local rig = rigs and rigs:FindFirstChild(player.Name); local torso = (rig and rig:FindFirstChild("Torso")) or hrp
        local sound = Instance.new("Sound"); sound.SoundId = DASH_SOUND[dir]; sound.Volume = 0.5; sound.Parent = torso; sound:Play(); task.delay(2, function() pcall(function() sound:Destroy() end) end)
        local origWalkSpeed = hum.WalkSpeed; pcall(function() hum.WalkSpeed = DASH_SPEED end)
        local startT = tick(); local currentDir = moveVec.Unit
        local att = Instance.new("Attachment", hrp); local lv = Instance.new("LinearVelocity", hrp)
        lv.Attachment0 = att; lv.MaxForce = math.huge; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.VectorVelocity = currentDir * DASH_SPEED
        task.spawn(function()
            while tick() - startT < duration do if hrp and hrp.Parent and hum and hum.Parent then if STEER_ENABLED then local md = hum.MoveDirection; if md.Magnitude > 0.1 then currentDir = md.Unit end end; pcall(function() lv.VectorVelocity = currentDir * DASH_SPEED end) end; RunService.Heartbeat:Wait() end
            pcall(function() lv:Destroy() end); pcall(function() att:Destroy() end); if hum and hum.Parent then pcall(function() hum.WalkSpeed = origWalkSpeed end) end
        end)
        local cam = workspace.CurrentCamera
        if cam then local origFov = cam.FieldOfView; TweenService:Create(cam, TweenInfo.new(0.05), { FieldOfView = origFov + DASH_FOV_KICK }):Play(); task.delay(duration, function() if cam and cam.Parent then TweenService:Create(cam, TweenInfo.new(0.2), { FieldOfView = origFov }):Play() end end) end
    end
    local function hookDashButton()
        local dashBtn; pcall(function() dashBtn = player.PlayerGui.MobileControls.Actions.Dash end); if not dashBtn then return end; if state.hookedBtn == dashBtn then return end; state.hookedBtn = dashBtn
        pcall(function() if getconnections then local sigs = { dashBtn.MouseButton1Click, dashBtn.Activated, dashBtn.TouchTap }; for _, sig in ipairs(sigs) do for _, c in ipairs(getconnections(sig)) do pcall(function() c:Disable() end) end end end end)
        pcall(function() dashBtn.MouseButton1Click:Connect(function() if state.running then doDash() end end); dashBtn.Activated:Connect(function() if state.running then doDash() end end) end)
    end
    UserInputService.InputBegan:Connect(function(input, processed) if processed then return end; if input.UserInputType ~= Enum.UserInputType.Keyboard then return end; if input.KeyCode == Enum.KeyCode.LeftControl then doDash() end end)
    hookDashButton(); player.CharacterAdded:Connect(function() task.wait(1); state.hookedBtn = nil; hookDashButton() end)
    return { setEnabled = function(on) state.running = on; if on then hookDashButton() end end }
end)()

local Shop = (function()
    local remote; pcall(function() local s = ReplicatedStorage.Packages.Knit.Services; local svc = s.TrainShopService; remote = svc and svc:FindFirstChild("RF") and svc.RF:FindFirstChild("BuyItem") end)
    local function doBuy(itemId, displayName)
        if not remote then ANON_Notify({ Title = displayName, Message = "Remote not found", Duration = 4, Icon = NOTIF_LOGO, MsgColor = COLOR_FAIL, Color = COLOR_FAIL }); return false end
        local ok, res = pcall(function() return remote:InvokeServer(itemId) end)
        if ok then ANON_Notify({ Title = displayName, Message = "Purchased!", Duration = 4, Icon = NOTIF_LOGO, MsgColor = COLOR_OK, Color = COLOR_OK }); return true, res end
        ANON_Notify({ Title = displayName, Message = "Failed", Duration = 4, Icon = NOTIF_LOGO, MsgColor = COLOR_FAIL, Color = COLOR_FAIL }); return false, tostring(res)
    end
    return { doBuy = doBuy, remote = remote }
end)()

local HorseSpeed = (function()
    local RS2 = ReplicatedStorage; local WS = Workspace
    local horse, horseHum, horseHRP; local HorseStatsMod, originalHS; local horseStatsChild, originalHSC; local attrSnapshots = {}; local autoOn = false; local loopRunning = false
    local function findHRP(m) local p=m:FindFirstChild("HumanoidRootPart"); if p and p:IsA("BasePart") then return p end; p=m.PrimaryPart; if p then return p end; for _,d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") and d.Name:match("Root") then return d end end; return nil end
    local function detectMount()
        horse,horseHum,horseHRP=nil,nil,nil; local c=player.Character; if not c then return false end
        local ph=c:FindFirstChildOfClass("Humanoid"); if not ph then return false end
        if ph.SeatPart then local m=ph.SeatPart.Parent; while m and m~=WS do if m:IsA("Model") then local h=m:FindFirstChildOfClass("Humanoid"); if h and h~=ph then local hrp=findHRP(m); if hrp then horse,horseHum,horseHRP=m,h,hrp; return true end end end; m=m.Parent end end
        return false
    end
    local function cacheGlobalStats() if HorseStatsMod then return end; local hs=RS2:FindFirstChild("Shared") and RS2.Shared:FindFirstChild("HorseStats"); if hs then local ok,mod=pcall(require,hs); if ok and type(mod)=="table" then HorseStatsMod=mod; originalHS={}; for k,v in pairs(mod) do if type(v)=="number" then originalHS[k]=v end end end end end
    local function cacheHorseStats() if horseStatsChild or not horse then return end; local s=horse:FindFirstChild("Stats"); if s and s:IsA("ModuleScript") then local ok,mod=pcall(require,s); if ok and type(mod)=="table" then horseStatsChild=mod; originalHSC={}; for k,v in pairs(mod) do if type(v)=="number" then originalHSC[k]=v end end end end end
    local function cacheAttrs() attrSnapshots={}; if not horse then return end; local ok,attrs=pcall(function() return horse:GetAttributes() end); if ok and type(attrs)=="table" then for k,v in pairs(attrs) do if type(v)=="number" then attrSnapshots[#attrSnapshots+1]={kind="attr",obj=horse,key=k,orig=v} end end end end
    local function applyMutations(speedVal)
        if HorseStatsMod then pcall(function() HorseStatsMod.TopSpeed=speedVal; HorseStatsMod.SprintModifier=2.25; HorseStatsMod.Acceleration=speedVal*2.0; if (HorseStatsMod.TurnSpeed or 0)<800 then HorseStatsMod.TurnSpeed=800 end end) end
        if horseStatsChild then pcall(function() if horseStatsChild.TopSpeed then horseStatsChild.TopSpeed=speedVal end; if horseStatsChild.SprintModifier then horseStatsChild.SprintModifier=2.25 end; if horseStatsChild.Acceleration then horseStatsChild.Acceleration=speedVal*2.0 end end) end
        if horseHum then pcall(function() horseHum.WalkSpeed=speedVal end) end
        for _,s in ipairs(attrSnapshots) do local name=tostring(s.key):lower(); if name:find("speed") or name:find("vel") or name:find("top") or name:find("sprint") then pcall(function() if s.kind=="attr" then s.obj:SetAttribute(s.key,speedVal) else s.obj.Value=speedVal end end) end end
    end
    local function restoreAll() if HorseStatsMod and originalHS then pcall(function() for k,v in pairs(originalHS) do HorseStatsMod[k]=v end end) end; if horseStatsChild and originalHSC then pcall(function() for k,v in pairs(originalHSC) do horseStatsChild[k]=v end end) end; for _,s in ipairs(attrSnapshots) do pcall(function() if s.kind=="attr" then s.obj:SetAttribute(s.key,s.orig) else s.obj.Value=s.orig end end) end end
    local function autoLoop() if loopRunning then return end; loopRunning=true; task.spawn(function() while autoOn do local spd = tonumber(Options.horse_speed_value) or 170; if detectMount() then applyMutations(spd); if not horseStatsChild then cacheHorseStats() end; if not HorseStatsMod then cacheGlobalStats() end; cacheAttrs() end; task.wait(0.3) end; loopRunning=false end) end
    return { setEnabled = function(on) if on then autoOn=true; cacheGlobalStats(); autoLoop() else autoOn=false; restoreAll() end end }
end)()

local SandmanSlide = (function()
    local sprintRemote
    pcall(function() sprintRemote = ReplicatedStorage.Packages.Knit.Services.SandmanService.RE.Sprint end)
    local state = { sprinting=false, conn=nil, hooked=false, prev=nil, mult=20 }
    local function equipped()
        local c=player.Character; if not c then return false end
        for _,k in ipairs({"Style","StandStyle","CurrentStand","Stand","StandName"}) do local v=c:GetAttribute(k); if v and tostring(v):lower():find("sandman") then return true end end
        for _,ch in ipairs(c:GetChildren()) do
            if ch.Name:lower():find("sandman") then return true end
            if ch:IsA("Model") then local s=ch:GetAttribute("StandStyle"); if s and tostring(s):lower():find("sandman") then return true end end
        end
        local rigs=Workspace:FindFirstChild("Rigs"); local rig=rigs and rigs:FindFirstChild(player.Name)
        if rig then for _,ch in ipairs(rig:GetChildren()) do
            if ch.Name:lower():find("sandman") then return true end
            if ch:IsA("Model") then local s=ch:GetAttribute("StandStyle"); if s and tostring(s):lower():find("sandman") then return true end end
        end end
        return false
    end
    local function stopDrag() if state.conn then state.conn:Disconnect(); state.conn=nil end end
    local function startDrag()
        if state.conn then return end
        state.conn = RunService.Heartbeat:Connect(function(dt)
            if not state.sprinting or not Options.sandman_slide then return end
            if not equipped() then return end
            local c=player.Character; if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart"); local h=c:FindFirstChildOfClass("Humanoid")
            if not hrp or not h or h.Health<=0 then return end
            local look=hrp.CFrame.LookVector; local flat=Vector3.new(look.X,0,look.Z)
            if flat.Magnitude<0.05 then return end
            flat=flat.Unit
            local speed=math.clamp(tonumber(Options.sandman_slide_speed) or 5, 1, 10)*state.mult
            local step=flat*speed*dt
            local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances={c}; params.IgnoreWater=true
            if not Workspace:Raycast(hrp.Position, step*1.2, params) then pcall(function() hrp.CFrame=hrp.CFrame+step end) end
        end)
    end
    local function install()
        if state.hooked or not sprintRemote then return end
        local ok, mt = pcall(getrawmetatable, game)
        if not ok or not mt or not mt.__namecall then return end
        state.prev = mt.__namecall
        pcall(function()
            setreadonly(mt,false)
            mt.__namecall = newcclosure(function(self, ...)
                local m; pcall(function() m=getnamecallmethod() end)
                if m=="FireServer" and self==sprintRemote then
                    local a1=select(1,...)
                    if a1==true then state.sprinting=true; if Options.sandman_slide then startDrag() end
                    elseif a1==false then state.sprinting=false; stopDrag() end
                end
                return state.prev(self, ...)
            end)
            setreadonly(mt,true)
        end)
        state.hooked=true
    end
    local function uninstall()
        if not state.hooked then return end
        local ok, mt = pcall(getrawmetatable, game)
        if ok and mt and state.prev then pcall(function() setreadonly(mt,false); mt.__namecall=state.prev; setreadonly(mt,true) end) end
        state.hooked=false; state.prev=nil
    end
    return { setEnabled=function(on) on=on==true; if on then install(); if state.sprinting then startDrag() end else state.sprinting=false; stopDrag(); uninstall() end end, destroy=function() stopDrag(); uninstall() end }
end)()

local EspHorse = (function()
    local state = { enabled = false }; local store = {}
    local function findHorses()
        local list = {}; local mounts = Workspace:FindFirstChild("Mounts")
        if mounts then for _, m in ipairs(mounts:GetChildren()) do if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then list[#list+1] = m end end end
        for _, m in ipairs(Workspace:GetChildren()) do if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then local nm = string.lower(m.Name); if nm:find("horse") or nm:find("mount") then local dup = false; for _, e in ipairs(list) do if e == m then dup = true; break end end; if not dup then list[#list+1] = m end end end end
        return list
    end
    local function attach(horse) if store[horse] then return end; local hl = Instance.new("Highlight"); hl.Name = "BabisHorseHL"; hl.FillColor = Color3.fromRGB(255, 200, 80); hl.OutlineColor = Color3.fromRGB(255, 160, 0); hl.FillTransparency = 0.55; hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee = horse; hl.Parent = horse; store[horse] = hl end
    local function detach(horse) local hl = store[horse]; if not hl then return end; pcall(function() hl:Destroy() end); store[horse] = nil end
    local function detachAll() local keys = {}; for h in pairs(store) do keys[#keys+1] = h end; for _, h in ipairs(keys) do detach(h) end end
    local function refreshAll() for h in pairs(store) do if not h or not h.Parent then detach(h) end end; if not state.enabled then return end; for _, h in ipairs(findHorses()) do attach(h) end end
    task.spawn(function() while true do task.wait(1); if state.enabled then refreshAll() end end end)
    return { setEnabled = function(on) state.enabled = on == true; if state.enabled then refreshAll() else detachAll() end end, destroy = function() detachAll() end }
end)()

local EspWaypoints = (function()
    local state = { enabled = false }; local markers = {}; local folder = nil; local tunnelHighlight = nil
    local WAYPOINTS = {
        { name="Shortcut 1", pos=Vector3.new(-378.16, 222.90, 2108.24), color=Color3.fromRGB(80, 180, 255) },
        { name="Tunnel", pos=Vector3.new(7.19, 49.30, -425.56), color=Color3.fromRGB(120, 255, 150), isTunnel=true },
        { name="Shortcut 2", pos=Vector3.new(502.41, 213.11, 2260.01), color=Color3.fromRGB(255, 190, 80) },
    }
    local function isAvailable() return checkCliffRock() end
    local function findTunnel() local map = Workspace:FindFirstChild("Map"); if not map then return nil end; local visual = map:FindFirstChild("Visual"); if not visual then return nil end; local tt = visual:FindFirstChild("TrainTracks"); if not tt then return nil end; local t = tt:FindFirstChild("Tunnels"); if not t then return nil end; return t:GetChildren()[17] end
    local function getObjectPosition(obj) if not obj then return nil end; if obj:IsA("BasePart") then return obj.Position end; if obj:IsA("Model") then local prim = obj.PrimaryPart; if prim then return prim.Position end end; local anyPart = obj:FindFirstChildWhichIsA("BasePart", true); if anyPart then return anyPart.Position end; return nil end
    local function getFolder() if folder and folder.Parent then return folder end; folder = create("Folder", { Name = "WaypointESP_Folder" }, Workspace); return folder end
    local function destroyMarker(name) local m = markers[name]; if not m then return end; pcall(function() if m.bb then m.bb:Destroy() end end); pcall(function() if m.anchor then m.anchor:Destroy() end end); markers[name] = nil end
    local function createMarker(wp)
        if markers[wp.name] then destroyMarker(wp.name) end
        local f = getFolder()
        local anchor = create("Part", { Name = "WP_" .. wp.name:gsub("%s",""), Size = Vector3.new(1,1,1), Transparency = 1, Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false, CFrame = CFrame.new(wp.pos) }, f)
        local bb = create("BillboardGui", { Name = wp.name:gsub("%s","") .. "_BB", Size = UDim2.fromOffset(140, 28), StudsOffset = Vector3.new(0, 2.2, 0), AlwaysOnTop = true, LightInfluence = 0, MaxDistance = 5000, Adornee = anchor, Enabled = false }, anchor)
        create("TextLabel", { Size = UDim2.new(1,0,0,16), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = "◈ " .. wp.name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = wp.color, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0,0,0), TextXAlignment = Enum.TextXAlignment.Center }, bb)
        local distLbl = create("TextLabel", { Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,16), BackgroundTransparency = 1, Text = "--", Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Color3.fromRGB(220,230,245), TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0,0,0), TextXAlignment = Enum.TextXAlignment.Center }, bb)
        markers[wp.name] = { anchor=anchor, bb=bb, distLbl=distLbl, color=wp.color }
    end
    local function enableTunnelHighlight()
        local wp2 = WAYPOINTS[2]; local tunnel = findTunnel(); if not tunnel then return end
        if tunnelHighlight and tunnelHighlight.Parent then tunnelHighlight.Adornee = tunnel; tunnelHighlight.Enabled = true; return end
        tunnelHighlight = create("Highlight", { Name = "Tunnel_Highlight", FillColor = wp2.color, FillTransparency = 0.75, OutlineColor = wp2.color, OutlineTransparency = 0.1, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = tunnel, Enabled = true }, tunnel)
    end
    local function disableTunnelHighlight() if tunnelHighlight then pcall(function() tunnelHighlight:Destroy() end); tunnelHighlight = nil end end

    local lastWpUpdate = 0
    task.spawn(function()
        while true do
            if state.enabled and tick() - lastWpUpdate > 0.2 then
                lastWpUpdate = tick()
                if not isAvailable() then for _, m in pairs(markers) do if m.bb then m.bb.Enabled = false end end; disableTunnelHighlight()
                else
                    for _, m in pairs(markers) do if m.bb then m.bb.Enabled = true end end; enableTunnelHighlight()
                    local c = player.Character; local h = c and c:FindFirstChild("HumanoidRootPart"); local ppos = h and h.Position or Vector3.zero
                    for _, wp in ipairs(WAYPOINTS) do local m = markers[wp.name]; if m and m.distLbl and m.distLbl.Parent then local d = (wp.pos - ppos).Magnitude; m.distLbl.Text = string.format("%d studs", math.floor(d + 0.5)) end end
                end
            end
            task.wait(0.1)
        end
    end)
    return {
        isAvailable = isAvailable,
        setEnabled = function(on) if on and not isAvailable() then return end; state.enabled = on == true; if state.enabled then getFolder(); for _, wp in ipairs(WAYPOINTS) do createMarker(wp); local m = markers[wp.name]; if m and m.bb then m.bb.Enabled = true end end; enableTunnelHighlight() else for name in pairs(markers) do destroyMarker(name) end; disableTunnelHighlight(); if folder and folder.Parent then pcall(function() folder:Destroy() end) end; folder = nil end end,
        destroy = function() for name in pairs(markers) do destroyMarker(name) end; disableTunnelHighlight(); if folder and folder.Parent then pcall(function() folder:Destroy() end) end end,
    }
end)()

local LowGraphics = (function()
    local enabled = false; local snapshots = {}; local oldQuality = nil
    local function snap(inst, prop, val) if not snapshots[inst] then snapshots[inst] = {} end; if snapshots[inst][prop] == nil then snapshots[inst][prop] = val end end
    local function processInst(v)
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then pcall(function() snap(v, "Material", v.Material); v.Material = Enum.Material.Plastic; snap(v, "Reflectance", v.Reflectance); v.Reflectance = 0 end)
        elseif v:IsA("Decal") then pcall(function() snap(v, "Transparency", v.Transparency); v.Transparency = 1 end)
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then pcall(function() snap(v, "Lifetime", v.Lifetime); v.Lifetime = NumberRange.new(0) end) end
    end
    local function apply()
        local w = game:GetService("Workspace"); local l = game:GetService("Lighting"); local t = w.Terrain
        if t then pcall(function() snap(t, "WaterWaveSize", t.WaterWaveSize); t.WaterWaveSize = 0; snap(t, "WaterWaveSpeed", t.WaterWaveSpeed); t.WaterWaveSpeed = 0 end) end
        pcall(function() snap(l, "GlobalShadows", l.GlobalShadows); l.GlobalShadows = false; snap(l, "FogEnd", l.FogEnd); l.FogEnd = 9e9; snap(l, "Brightness", l.Brightness); l.Brightness = 2 end)
        pcall(function() oldQuality = settings().Rendering.QualityLevel; settings().Rendering.QualityLevel = 1 end)
        for _, v in ipairs(w:GetDescendants()) do processInst(v) end
        for _, e in ipairs(l:GetChildren()) do if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then pcall(function() snap(e, "Enabled", e.Enabled); e.Enabled = false end) end end
    end
    local function restore() for inst, props in pairs(snapshots) do if inst then for prop, val in pairs(props) do pcall(function() inst[prop] = val end) end end end; snapshots = {}; if oldQuality then pcall(function() settings().Rendering.QualityLevel = oldQuality end); oldQuality = nil end end
    return { setEnabled = function(on) if on == enabled then return end; enabled = on; if on then apply() else restore() end end, destroy = function() if enabled then restore(); enabled = false end end }
end)()

local SideDash = (function()
    local isSliding = false; local ball, ballImg, ballTxt; local rangePart; local lastCheck, cachedY = 0, nil
    local BALL_POS = UDim2.new(0.4500, 274, 0.8500, 8); local BALL_SIZE = 70; local IMG_ID = "rbxassetid://86849040113647"
    local ANIM = { BACK  = "rbxassetid://74124095477161", LEFT  = "rbxassetid://140323810466191", RIGHT = "rbxassetid://117964155609810" }
    local SOUND = { LEFT  = { id = "rbxassetid://123469111772953", name = "side dash1" }, RIGHT = { id = "rbxassetid://72045809807649",  name = "side dash2" } }
    local SOUND_VOLUME = 0.5; local SOUND_DELAY = 0.05; local FOV_KICK = 6.5; local FOV_IN_TIME = 0.04; local FOV_HOLD = 0.06; local FOV_OUT_TIME = 0.35
    local BACK_OFFSET = 5; local ARC_HEIGHT_RATIO = 0.45; local ARC_HEIGHT_MAX = 14; local DURATION_MIN = 0.30; local DURATION_MAX = 1.60; local VERTICAL_FOLLOW = 8; local SPEED_MULT = 0.85
    local CG_ME = "SD_Me"; local CG_TARGET = "SD_Target"; local cgOK = false
    pcall(function() PhysicsService:RegisterCollisionGroup(CG_ME) end); pcall(function() PhysicsService:RegisterCollisionGroup(CG_TARGET) end)
    pcall(function() PhysicsService:CollisionGroupSetCollidable(CG_ME, CG_TARGET, false); cgOK = true end)

    ball = create("TextButton", { Name = "SideDashBall", AnchorPoint = Vector2.new(0.5, 0.5), Position = BALL_POS, Size = UDim2.fromOffset(BALL_SIZE, BALL_SIZE), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = "", Visible = false, ZIndex = 15 }, gui)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, ball)
    ballImg = create("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Image = IMG_ID, ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0, ScaleType = Enum.ScaleType.Fit, Active = false, ZIndex = 15 }, ball)
    ballTxt = create("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Font = FONT_B, Text = "Side Dash", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextStrokeTransparency = 0.3, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), ZIndex = 16 }, ball)

    rangePart = Instance.new("Part"); rangePart.Name = "SideDashRange"; rangePart.Anchored = true; rangePart.CanCollide = false; rangePart.CanTouch = false; rangePart.CanQuery = false; rangePart.CastShadow = false; rangePart.Material = Enum.Material.SmoothPlastic; rangePart.Color = Color3.fromRGB(220, 50, 50); rangePart.Transparency = 1; rangePart.Size = Vector3.new(50, 0.15, 50); rangePart.Parent = Workspace

    local function anyoneInRange(myPos, rng)
        for _, p in ipairs(Players:GetPlayers()) do if p ~= player and p.Character then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp and (hrp.Position - myPos).Magnitude <= rng then return true end end end
        local rigs = Workspace:FindFirstChild("Rigs")
        if rigs then for _, m in ipairs(rigs:GetChildren()) do if m:IsA("Model") and m.Name ~= player.Name then local mHrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart; if mHrp and mHrp:IsA("BasePart") and (mHrp.Position - myPos).Magnitude <= rng then return true end end end end
        return false
    end

    local lastSideUpdate = 0
    RunService.Heartbeat:Connect(function()
        if tick() - lastSideUpdate < 0.066 then return end
        lastSideUpdate = tick()
        if not rangePart then return end
        local wantRange = (Options.side_dash == true) and (Options.side_dash_range_view == true)
        if not wantRange then if rangePart.Transparency ~= 1 then rangePart.Transparency = 1 end; return end
        local c = player.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then if rangePart.Transparency ~= 1 then rangePart.Transparency = 1 end; return end
        if tick() - lastCheck > 0.25 then
            lastCheck = tick(); local ray = RaycastParams.new(); ray.FilterType = Enum.RaycastFilterType.Exclude; ray.FilterDescendantsInstances = { c }; ray.IgnoreWater = true
            local ok, result = pcall(function() return Workspace:Raycast(hrp.Position, Vector3.new(0, -60, 0), ray) end)
            if ok and result then cachedY = result.Position.Y else local hum = c:FindFirstChildOfClass("Humanoid"); cachedY = hrp.Position.Y - ((hum and hum.HipHeight) or 2) end
        end
        if not cachedY then return end
        local rng = tonumber(Options.side_dash_range) or 19
        rangePart.CFrame = CFrame.new(hrp.Position.X, cachedY + 0.1, hrp.Position.Z); rangePart.Size = Vector3.new(rng * 2, 0.15, rng * 2)
        local inR = anyoneInRange(hrp.Position, rng)
        if inR then rangePart.Color = Color3.fromRGB(50, 130, 255); rangePart.Transparency = 0.55 else rangePart.Color = Color3.fromRGB(220, 50, 50); rangePart.Transparency = 0.75 end
    end)

    local function findTarget(maxRange)
        local c = player.Character; if not c then return nil end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
        local myPos = hrp.Position; local best, bestDist = nil, maxRange
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then local pHum = p.Character:FindFirstChildOfClass("Humanoid"); local pHrp = p.Character:FindFirstChild("HumanoidRootPart"); if pHum and pHum.Health > 0 and pHrp then local d = (pHrp.Position - myPos).Magnitude; if d <= bestDist then bestDist = d; best = { char = p.Character, hrp = pHrp, hum = pHum, isPlayer = true } end end end
        end
        local rigs = Workspace:FindFirstChild("Rigs")
        if rigs then for _, m in ipairs(rigs:GetChildren()) do if m:IsA("Model") and m ~= c and m.Name ~= player.Name then local mHum = m:FindFirstChildOfClass("Humanoid"); local mHrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart; if mHum and mHum.Health > 0 and mHrp and mHrp:IsA("BasePart") then local d = (mHrp.Position - myPos).Magnitude; if d <= bestDist then bestDist = d; best = { char = m, hrp = mHrp, hum = mHum, isPlayer = false } end end end end end
        return best
    end
    local function resolveArcSide() local dir = tostring(Options.side_dash_direction or "RIGHT"); if dir == "LEFT" then return -1 end; if dir == "RIGHT" then return 1 end; return (math.random() < 0.5) and 1 or -1 end
    local function stopAllAnimations(animator, char) if not animator then return end; local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end); if ok and tracks then for _, track in ipairs(tracks) do pcall(function() track:Stop(0) end); pcall(function() track:Destroy() end) end end; if char then local animate = char:FindFirstChild("Animate"); if animate and animate:IsA("LocalScript") then pcall(function() animate.Disabled = true end) end end end
    local function restoreAnimations(animator, char) if not animator then return end; if char then local animate = char:FindFirstChild("Animate"); if animate and animate:IsA("LocalScript") then pcall(function() animate.Disabled = false end) end end end
    local function setCollisionGroup(char, group) if not char then return end; for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.CollisionGroup = group end) end end end
    local function disableTargetCollision(targetChar, store) if not targetChar then return end; for _, part in ipairs(targetChar:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then store[part] = true; pcall(function() part.CanCollide = false end) end end end
    local function restoreTargetCollision(store) for part in pairs(store) do if part and part.Parent then pcall(function() part.CanCollide = true end) end end end
    local function getSoundParent(myChar) local rigs = Workspace:FindFirstChild("Rigs"); local myRig = rigs and rigs:FindFirstChild(player.Name); if myRig then local t = myRig:FindFirstChild("Torso") or myRig:FindFirstChild("UpperTorso"); if t then return t end end; if myChar then return myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head") end; return nil end
    local function playDashSound(side, myChar) local cfg = SOUND[side]; if not cfg then return end; local parent = getSoundParent(myChar); if not parent then return end; local snd = Instance.new("Sound"); snd.Name = cfg.name; snd.SoundId = cfg.id; snd.Volume = SOUND_VOLUME; snd.Parent = parent; snd:Play(); task.delay(1.5, function() pcall(function() snd:Destroy() end) end) end
    local function applyFovKick() local cam = workspace.CurrentCamera; if not cam then return nil, nil, nil, nil end; local origFov = cam.FieldOfView; local targetFov = origFov + FOV_KICK; local tin = TweenService:Create(cam, TweenInfo.new(FOV_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = targetFov }); tin:Play(); local tout = nil; task.delay(FOV_IN_TIME + FOV_HOLD, function() if cam and cam.Parent then tout = TweenService:Create(cam, TweenInfo.new(FOV_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = origFov }); tout:Play() end end); return tin, tout, cam, origFov end

    local function performSlide()
        if Options.side_dash ~= true then return false end
        if isSliding then return false end
        local rng = tonumber(Options.side_dash_range) or 19
        local target = findTarget(rng)
        if not target then return false end
        local myChar = player.Character; if not myChar then return false end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart"); local hum = myChar:FindFirstChildOfClass("Humanoid"); if not myHrp or not hum then return false end
        local tHrp = target.hrp; if not tHrp or not tHrp.Parent then return false end
        local startCF = myHrp.CFrame; local startPos = myHrp.Position; local initialDist = (tHrp.Position - startPos).Magnitude
        local sliderSpeed = tonumber(Options.side_dash_speed) or 50; local effectiveSpeed = sliderSpeed * SPEED_MULT; local totalTime = math.clamp(initialDist / effectiveSpeed, DURATION_MIN, DURATION_MAX)
        local arcSide = resolveArcSide(); local travelSide = (arcSide > 0) and "RIGHT" or "LEFT"
        local arcDir = nil; local toTargetFlat = Vector3.new(tHrp.Position.X - startPos.X, 0, tHrp.Position.Z - startPos.Z)
        if toTargetFlat.Magnitude > 0.5 then local flatDir = toTargetFlat.Unit; arcDir = flatDir:Cross(Vector3.new(0, 1, 0)).Unit * arcSide end
        local arcHeight = math.min(initialDist * ARC_HEIGHT_RATIO, ARC_HEIGHT_MAX)
        isSliding = true; local origSpeed = hum.WalkSpeed; local origAutoRot = hum.AutoRotate; hum.WalkSpeed = 0; hum.AutoRotate = false
        pcall(function() myHrp.AssemblyLinearVelocity = Vector3.zero; myHrp.AssemblyAngularVelocity = Vector3.zero end)
        local animator = hum:FindFirstChildOfClass("Animator"); pcall(function() stopAllAnimations(animator, myChar) end)
        local disabledParts = {}
        if cgOK then pcall(function() setCollisionGroup(myChar, CG_ME) end); pcall(function() setCollisionGroup(target.char, CG_TARGET) end) else pcall(function() disableTargetCollision(target.char, disabledParts) end) end
        local currentTrack
        if animator then local anim = Instance.new("Animation"); anim.AnimationId = ANIM[travelSide]; local ok, track = pcall(function() return animator:LoadAnimation(anim) end); if ok and track then currentTrack = track; pcall(function() track:Play(0.05) end); pcall(function() track:AdjustSpeed(math.clamp(0.55 / totalTime, 0.55, 2)) end) end end
        task.delay(SOUND_DELAY, function() playDashSound(travelSide, myChar) end)
        local fovIn, fovOut, camRef, origFov = applyFovKick()
        local startT = tick(); local done = false; local conn
        local function cleanup()
            if done then return end; done = true; if conn then pcall(function() conn:Disconnect() end) end; if currentTrack then pcall(function() currentTrack:Stop(0.2) end) end
            if hum and hum.Parent then hum.WalkSpeed = origSpeed; hum.AutoRotate = origAutoRot end
            if myHrp and myHrp.Parent then pcall(function() myHrp.AssemblyLinearVelocity = Vector3.zero end) end
            if fovIn then pcall(function() fovIn:Cancel() end) end; if fovOut then pcall(function() fovOut:Cancel() end) end
            if camRef and camRef.Parent and origFov then pcall(function() camRef.FieldOfView = origFov end) end
            if cgOK then pcall(function() setCollisionGroup(myChar, "Default") end); if target.char then pcall(function() setCollisionGroup(target.char, "Default") end) end else restoreTargetCollision(disabledParts) end
            pcall(function() restoreAnimations(animator, myChar) end); isSliding = false
        end
        conn = RunService.Heartbeat:Connect(function()
            if done then return end; if not myHrp.Parent or not hum.Parent then cleanup(); return end; if not tHrp.Parent or not target.hum.Parent or target.hum.Health <= 0 then cleanup(); return end
            local tLook = tHrp.CFrame.LookVector; local flatLook = Vector3.new(tLook.X, 0, tLook.Z); if flatLook.Magnitude < 0.1 then flatLook = Vector3.new(0, 0, 1) end; flatLook = flatLook.Unit
            local behind = tHrp.Position - flatLook * BACK_OFFSET; local followY = startPos.Y + math.clamp(tHrp.Position.Y - startPos.Y, -VERTICAL_FOLLOW, VERTICAL_FOLLOW); local destPos = Vector3.new(behind.X, followY, behind.Z)
            local elapsed = tick() - startT; local progress = math.clamp(elapsed / totalTime, 0, 1); local eased = progress * progress * (3 - 2 * progress)
            local posOnLine = startPos:Lerp(destPos, eased); local arcOffset = Vector3.zero; if arcDir then arcOffset = arcDir * arcHeight * math.sin(progress * math.pi) end; local finalPos = posOnLine + arcOffset
            local toT = Vector3.new(tHrp.Position.X - finalPos.X, 0, tHrp.Position.Z - finalPos.Z); local newCF
            if toT.Magnitude > 0.1 then newCF = CFrame.lookAt(finalPos, finalPos + toT.Unit) else newCF = CFrame.new(finalPos) * (startCF - startCF.Position) end
            pcall(function() myHrp.CFrame = newCF; myHrp.AssemblyLinearVelocity = Vector3.zero; myHrp.AssemblyAngularVelocity = Vector3.zero end)
            if progress >= 1 then cleanup() end
        end)
        task.delay(totalTime + 1.5, cleanup)
        return true
    end

    ball.MouseButton1Click:Connect(function() if Options.side_dash == true then performSlide() end end)
    return {
        setEnabled = function(on, viaKeybind)
            if ball then
                if on == true then
                    if viaKeybind then ball.Visible = false else ball.Visible = true end
                else ball.Visible = false end
            end
            if not on then if Options.side_dash_range_view == true then if Registry["side_dash_range_view"] then Registry["side_dash_range_view"](false) end end; if rangePart then rangePart.Transparency = 1 end end
        end,
        fire = performSlide,
        destroy = function() if ball then ball:Destroy(); ball = nil end; if rangePart then rangePart:Destroy(); rangePart = nil end end,
    }
end)()

local PART_OPTIONS = { "HumanoidRootPart", "Head", "UpperTorso", "LowerTorso", "Torso" }

local function getNearestTarget()
    local char = player.Character; if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local myPos = hrp.Position
    local bestChar = nil; local bestDist = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local pHum = p.Character:FindFirstChildOfClass("Humanoid");
            local pHrp = p.Character:FindFirstChild("HumanoidRootPart");
            if pHum and pHum.Health > 0 and pHrp then
                local d = (pHrp.Position - myPos).Magnitude;
                if d < bestDist then bestDist = d; bestChar = p.Character end
            end
        end
    end
    local rigs = Workspace:FindFirstChild("Rigs")
    if rigs then
        for _, m in ipairs(rigs:GetChildren()) do
            if m:IsA("Model") and m ~= char and m.Name ~= player.Name then
                local mHum = m:FindFirstChildOfClass("Humanoid")
                local mHrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                if mHum and mHum.Health > 0 and mHrp and mHrp:IsA("BasePart") then
                    local d = (mHrp.Position - myPos).Magnitude
                    if d < bestDist then bestDist = d; bestChar = m end
                end
            end
        end
    end
    return bestChar
end

local function rotateRootTo(hrp, targetPos) if not hrp or not hrp.Parent then return end; local cur = hrp.CFrame; local dir = Vector3.new(targetPos.X - cur.Position.X, 0, targetPos.Z - cur.Position.Z); if dir.Magnitude < 0.05 then return end; hrp.CFrame = CFrame.lookAt(cur.Position, cur.Position + dir.Unit) end
local function predictedPos(char, partName, predict) if not char then return nil end; local part = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart"); if not part then return nil end; local pos = part.Position; if predict and predict > 0 then local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then pos = pos + hrp.AssemblyLinearVelocity * predict end end; return pos end

local function startAiming(viaKeybind)
    if not alive or isAiming then return end
    isAiming = true
    if not viaKeybind then crosshairBtn.Visible = true end
    if aimConn then aimConn:Disconnect() end
    aimConn = RunService.RenderStepped:Connect(function()
        if not alive or not isAiming then return end
        local char = player.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if hum.AutoRotate then hum.AutoRotate = false end
        local bestChar = getNearestTarget()
        if bestChar then
            local predict = tonumber(Options.aim_predict_value) or 0.08;
            local pos = predictedPos(bestChar, Options.aim_target_bone, predict);
            if pos then rotateRootTo(hrp, pos) end
        end
    end)
end
local function stopAiming() if not isAiming then return end; isAiming = false; if aimConn then aimConn:Disconnect(); aimConn = nil end; local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate = true end end

local function camTick()
    if not alive or not isCamLocked then return end
    if not camLockTarget or not camLockTarget.Parent then
        local nt = getNearestTarget();
        if nt then camLockTarget = nt else return end
    end
    local hum = camLockTarget:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        local nt = getNearestTarget();
        if nt then camLockTarget = nt else return end
    end
    local myChar = player.Character; if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
    local tool = myChar:FindFirstChildOfClass("Tool"); local tn = tool and tool.Name or nil
    if tn ~= lastToolName then lastToolName = tn; camGraceUntil = tick() + 0.8; lastCamCFrame = nil end
    if tick() < camGraceUntil then return end
    local predict = tonumber(Options.aimcam_predict_value) or 0.08; local rawTarget = predictedPos(camLockTarget, Options.aimcam_target_bone, predict); if not rawTarget then return end
    local myPos = myHrp.Position; local camCF = camera.CFrame; local targetPos = rawTarget + camCF.RightVector * (tonumber(Options.aimcam_offset_h) or 0) + camCF.UpVector * (tonumber(Options.aimcam_offset_v) or 0)
    local lookDir = (targetPos - myPos).Unit; local right = lookDir:Cross(Vector3.new(0,1,0)); local rightVec = right.Magnitude > 0.01 and right.Unit or Vector3.new(1,0,0)
    local camPos = myPos - lookDir * 11 + Vector3.new(0, 5, 0) + rightVec * 1.5; local desired = CFrame.lookAt(camPos, targetPos)
    if lastCamCFrame then camera.CFrame = lastCamCFrame:Lerp(desired, 0.85) else camera.CFrame = desired end; lastCamCFrame = camera.CFrame
end
local function startCamLock(viaKeybind)
    if not alive or isCamLocked then return end
    if not viaKeybind then camBtn.Visible = true end
    isCamLocked = true; camLockTarget = getNearestTarget(); lastCamCFrame = nil; lastToolName = nil; camGraceUntil = tick() + 0.5
    pcall(function() RunService:UnbindFromRenderStep(camLockBind) end); RunService:BindToRenderStep(camLockBind, Enum.RenderPriority.Camera.Value + 1, camTick)
end
local function stopCamLock() if not isCamLocked then return end; isCamLocked = false; camLockTarget = nil; lastCamCFrame = nil; pcall(function() RunService:UnbindFromRenderStep(camLockBind) end) end

local crosshairBtn, crosshairRingStroke, crosshairDot, crosshairTicks
local function updateCrosshairVisual()
    if not crosshairRingStroke then return end
    local targetT = isAiming and 0.10 or 0.55
    tween(crosshairRingStroke, { Transparency = targetT, Thickness = isAiming and 7 or 5 }, 0.2)
    if crosshairDot then tween(crosshairDot, { BackgroundTransparency = targetT }, 0.2) end
    if crosshairTicks then for _, tk in ipairs(crosshairTicks) do tween(tk, { BackgroundTransparency = targetT }, 0.2) end end
end

do
    crosshairBtn = create("TextButton", { Name="FloatingCrosshair", AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-80,0.5,0), Size=UDim2.fromOffset(100,100), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.55, Text="", AutoButtonColor=false, ClipsDescendants=false, Visible=false, ZIndex=50 }, gui)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, crosshairBtn); create("UIScale", { Scale = 0.7 }, crosshairBtn)
    local ring = create("Frame", { Size=UDim2.fromOffset(60,60), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1 }, crosshairBtn); create("UICorner", { CornerRadius = UDim.new(1, 0) }, ring)
    crosshairRingStroke = create("UIStroke", { Color=Color3.fromRGB(220,220,220), Thickness=5, Transparency=0.55, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, ring)
    crosshairDot = create("Frame", { Size=UDim2.fromOffset(28,28), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.fromRGB(220,220,220), BackgroundTransparency=0.55, BorderSizePixel=0 }, crosshairBtn); create("UICorner", { CornerRadius = UDim.new(1, 0) }, crosshairDot)
    local off, long, thick = 30, 14, 6; crosshairTicks = {}
    local function mkTick(pos, size) local t = create("Frame", { Size=size, Position=pos, AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.fromRGB(220,220,220), BackgroundTransparency=0.55, BorderSizePixel=0 }, crosshairBtn); create("UICorner", { CornerRadius = UDim.new(1, 0) }, t); table.insert(crosshairTicks, t) end
    mkTick(UDim2.new(0.5,0,0.5,-off), UDim2.fromOffset(thick,long)); mkTick(UDim2.new(0.5,0,0.5,off), UDim2.fromOffset(thick,long)); mkTick(UDim2.new(0.5,-off,0.5,0), UDim2.fromOffset(long,thick)); mkTick(UDim2.new(0.5,off,0.5,0), UDim2.fromOffset(long,thick))
    crosshairBtn.MouseEnter:Connect(function() tween(crosshairBtn, { BackgroundTransparency = 0.3 }, 0.1) end)
    crosshairBtn.MouseLeave:Connect(function() tween(crosshairBtn, { BackgroundTransparency = 0.55 }, 0.1) end)
    crosshairBtn.MouseButton1Click:Connect(function()
        if not alive then return end
        if isAiming then stopAiming(); notify("Aim Target: Detached") else if isCamLocked then stopCamLock() end; startAiming(true); notify("Aim Target: Locked") end
        updateCrosshairVisual()
        updateCamVisual()
    end)
end

local camBtn, camRingStroke, camDot
local function updateCamVisual()
    if not camRingStroke then return end
    local targetT = isCamLocked and 0.10 or 0.55
    tween(camRingStroke, { Transparency = targetT, Thickness = isCamLocked and 6 or 4 }, 0.2)
    if camDot then tween(camDot, { BackgroundTransparency = targetT }, 0.2) end
end

do
    camBtn = create("TextButton", { Name="FloatingCam", AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-200,0.5,90), Size=UDim2.fromOffset(80,80), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.55, Text="", AutoButtonColor=false, ClipsDescendants=false, Visible=false, ZIndex=50 }, gui)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, camBtn); create("UIScale", { Scale = 0.7 }, camBtn)
    local camRing = create("Frame", { Size=UDim2.fromOffset(50,50), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1 }, camBtn); create("UICorner", { CornerRadius = UDim.new(1, 0) }, camRing)
    camRingStroke = create("UIStroke", { Color=Color3.fromRGB(220,220,220), Thickness=4, Transparency=0.55, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, camRing)
    camDot = create("Frame", { Size=UDim2.fromOffset(20,20), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.fromRGB(220,220,220), BackgroundTransparency=0.55, BorderSizePixel=0 }, camBtn); create("UICorner", { CornerRadius = UDim.new(1, 0) }, camDot)
    camBtn.MouseEnter:Connect(function() tween(camBtn, { BackgroundTransparency = 0.3 }, 0.1) end)
    camBtn.MouseLeave:Connect(function() tween(camBtn, { BackgroundTransparency = 0.55 }, 0.1) end)
    camBtn.MouseButton1Click:Connect(function()
        if not alive then return end
        if isCamLocked then stopCamLock(); notify("Aim Cam: Detached") else if isAiming then stopAiming() end; startCamLock(true); notify("Aim Cam: Locked") end
        updateCamVisual()
        updateCrosshairVisual()
    end)
end

local FEATURES = { highlight=false, skeleton=false, name=false, box=false, lines=false, health=false }
local BODY_PARTS = { Head=true, Torso=true, UpperTorso=true, LowerTorso=true, ["Left Arm"]=true, ["Right Arm"]=true, ["Left Leg"]=true, ["Right Leg"]=true, LeftUpperArm=true, LeftLowerArm=true, LeftHand=true, RightUpperArm=true, RightLowerArm=true, RightHand=true, LeftUpperLeg=true, LeftLowerLeg=true, LeftFoot=true, RightUpperLeg=true, RightLowerLeg=true, RightFoot=true }
local LINES_R15 = { {"Neck","Waist"},{"Waist","Pelvis"},{"Neck","LeftShoulder"},{"Neck","RightShoulder"},{"LeftShoulder","RightShoulder"},{"Pelvis","LeftHip"},{"Pelvis","RightHip"},{"LeftHip","RightHip"},{"LeftShoulder","LeftElbow"},{"LeftElbow","LeftWrist"},{"RightShoulder","RightElbow"},{"RightElbow","RightWrist"},{"LeftHip","LeftKnee"},{"LeftKnee","LeftAnkle"},{"RightHip","RightKnee"},{"RightKnee","RightAnkle"} }
local LINES_R6 = { {"Neck","Pelvis"},{"Neck","LeftShoulder"},{"Neck","RightShoulder"},{"LeftShoulder","RightShoulder"},{"Pelvis","LeftHip"},{"Pelvis","RightHip"},{"LeftHip","RightHip"},{"LeftShoulder","LeftWrist"},{"RightShoulder","RightWrist"},{"LeftHip","LeftAnkle"},{"RightHip","RightAnkle"} }

local boxDrawGui = create("ScreenGui", { Name="EspBoxDraw", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=90 }, safeParent)
local linesDrawGui = create("ScreenGui", { Name="EspLinesDraw", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=89 }, safeParent)
local skeletonDrawGui = create("ScreenGui", { Name="EspSkeletonDraw", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=88 }, safeParent)

local EspSuite = (function()
    local store = {}
    local function getStandName(model)
        local rigs = Workspace:FindFirstChild("Rigs")
        local rig = rigs and rigs:FindFirstChild(model.Name)
        local stand = rig and rig:FindFirstChild("STAND")
        if stand then
            local ok, s = pcall(function() return stand:GetAttribute("StandStyle") end)
            if ok and s and tostring(s) ~= "" and tostring(s) ~= "None" then return tostring(s) end
        end
        local ok, s = pcall(function() return model:GetAttribute("StandStyle") end)
        if ok and s and tostring(s) ~= "" and tostring(s) ~= "None" then return tostring(s) end
        local ok2, s2 = pcall(function() return model:GetAttribute("Style") end)
        if ok2 and s2 and tostring(s2) ~= "" and tostring(s2) ~= "None" then return tostring(s2) end
        return nil
    end
    local function buildDisplayName(displayName, model)
        local out = tostring(displayName):gsub("[<>&]", "")
        if Options.esp_stand then
            local stand = getStandName(model)
            if stand then out = out .. " [" .. stand .. "]" end
        end
        return out
    end
    local function getJoints(model)
        local j = {}
        if model:FindFirstChild("UpperTorso") then
            local ut, lt, head = model.UpperTorso, model.LowerTorso, model.Head; local lua, lla, lh = model.LeftUpperArm, model.LeftLowerArm, model.LeftHand; local rua, rla, rh = model.RightUpperArm, model.RightLowerArm, model.RightHand; local lul, lll, lf = model.LeftUpperLeg, model.LeftLowerLeg, model.LeftFoot; local rul, rll, rf = model.RightUpperLeg, model.RightLowerLeg, model.RightFoot
            if not (ut and lt and head and lua and rua and lul and rul) then return nil end
            j.Neck = (head.CFrame * CFrame.new(0, -head.Size.Y/2, 0)).Position; j.Waist = (ut.CFrame * CFrame.new(0, -ut.Size.Y/2, 0)).Position; j.Pelvis = (lt.CFrame * CFrame.new(0, -lt.Size.Y/2, 0)).Position
            j.LeftShoulder = (lua.CFrame * CFrame.new(0, lua.Size.Y/2, 0)).Position; j.LeftElbow = (lla.CFrame * CFrame.new(0, lla.Size.Y/2, 0)).Position; j.LeftWrist = (lh.CFrame * CFrame.new(0, lh.Size.Y/2, 0)).Position
            j.RightShoulder = (rua.CFrame * CFrame.new(0, rua.Size.Y/2, 0)).Position; j.RightElbow = (rla.CFrame * CFrame.new(0, rla.Size.Y/2, 0)).Position; j.RightWrist = (rh.CFrame * CFrame.new(0, rh.Size.Y/2, 0)).Position
            j.LeftHip = (lul.CFrame * CFrame.new(0, lul.Size.Y/2, 0)).Position; j.LeftKnee = (lll.CFrame * CFrame.new(0, lll.Size.Y/2, 0)).Position; j.LeftAnkle = (lf.CFrame * CFrame.new(0, lf.Size.Y/2, 0)).Position
            j.RightHip = (rul.CFrame * CFrame.new(0, rul.Size.Y/2, 0)).Position; j.RightKnee = (rll.CFrame * CFrame.new(0, rll.Size.Y/2, 0)).Position; j.RightAnkle = (rf.CFrame * CFrame.new(0, rf.Size.Y/2, 0)).Position
            return j, LINES_R15
        elseif model:FindFirstChild("Torso") then
            local torso, head = model.Torso, model.Head; local la, ra, ll, rl = model["Left Arm"], model["Right Arm"], model["Left Leg"], model["Right Leg"]
            if not (torso and head and la and ra and ll and rl) then return nil end
            j.Neck = (head.CFrame * CFrame.new(0, -head.Size.Y/2, 0)).Position; j.Pelvis = (torso.CFrame * CFrame.new(0, -torso.Size.Y/2, 0)).Position
            j.LeftShoulder = (la.CFrame * CFrame.new(0, la.Size.Y/2, 0)).Position; j.LeftWrist = (la.CFrame * CFrame.new(0, -la.Size.Y/2, 0)).Position
            j.RightShoulder = (ra.CFrame * CFrame.new(0, ra.Size.Y/2, 0)).Position; j.RightWrist = (ra.CFrame * CFrame.new(0, -ra.Size.Y/2, 0)).Position
            j.LeftHip = (ll.CFrame * CFrame.new(0, ll.Size.Y/2, 0)).Position; j.LeftAnkle = (ll.CFrame * CFrame.new(0, -ll.Size.Y/2, 0)).Position
            j.RightHip = (rl.CFrame * CFrame.new(0, rl.Size.Y/2, 0)).Position; j.RightAnkle = (rl.CFrame * CFrame.new(0, -rl.Size.Y/2, 0)).Position
            return j, LINES_R6
        end
        return nil
    end
    local function initModel(model, displayName)
        if store[model] then return end
        local hum, hrp, head = model:FindFirstChildOfClass("Humanoid"), model:FindFirstChild("HumanoidRootPart"), model:FindFirstChild("Head")
        if not hum or not hrp or not head then return end
        local data = { lines = {}, dots = {}, boxFrame = nil, skeletonLines = {}, displayName = displayName }
        local hl = Instance.new("Highlight"); hl.Name="EspHighlight"; hl.FillColor=Color3.fromRGB(255,255,255); hl.FillTransparency=0.75; hl.OutlineColor=Color3.fromRGB(255,255,255); hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=model; hl.Enabled=FEATURES.highlight; hl.Parent=model; data.highlight=hl
        local nameBB = Instance.new("BillboardGui"); nameBB.Name="EspNameBB"; nameBB.Size=UDim2.fromOffset(300,26); nameBB.StudsOffset=Vector3.new(0,3.2,0); nameBB.AlwaysOnTop=true; nameBB.LightInfluence=0; nameBB.MaxDistance=2000; nameBB.Adornee=head; nameBB.Enabled=FEATURES.name; nameBB.Parent=head
        local nameLbl = Instance.new("TextLabel"); nameLbl.BackgroundTransparency=1; nameLbl.Size=UDim2.fromScale(1,1); nameLbl.Font=Enum.Font.Code; nameLbl.TextSize=14; nameLbl.TextStrokeTransparency=0; nameLbl.TextStrokeColor3=Color3.fromRGB(0,0,0); nameLbl.TextColor3=Color3.fromRGB(255,255,255); nameLbl.Text=buildDisplayName(displayName, model); nameLbl.Parent=nameBB; data.nameBB=nameBB; data.nameLbl=nameLbl
        local boxFrame = create("Frame", { Name="EspBox", BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ZIndex=1 }, boxDrawGui); data.boxFrame=boxFrame; data.boxStroke=create("UIStroke", { Color=Color3.fromRGB(255,255,255), Thickness=1.5, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, boxFrame)
        local healthFrame = create("Frame", { Name="EspHealthFrame", BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.35, BorderSizePixel=0, Visible=false, ZIndex=1 }, boxDrawGui); create("UIStroke", { Color=Color3.fromRGB(0,0,0), Thickness=1, Transparency=0.25, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, healthFrame); data.healthFrame=healthFrame; data.healthFill=create("Frame", { Name="Fill", AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,0,1,0), Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.fromRGB(60,220,90), BorderSizePixel=0 }, healthFrame)
        local lineFrame = create("Frame", { Name="EspLine", AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, Visible=false, ZIndex=1 }, linesDrawGui); data.lineFrame=lineFrame
        store[model] = data
    end
    local function removeModel(model)
        local data = store[model]; if not data then return end
        if data.highlight then data.highlight:Destroy() end; if data.nameBB then data.nameBB:Destroy() end
        if data.boxFrame then data.boxFrame:Destroy() end; if data.healthFrame then data.healthFrame:Destroy() end
        if data.lineFrame then data.lineFrame:Destroy() end
        for _, f in ipairs(data.skeletonLines) do f:Destroy() end; for _, d in ipairs(data.dots) do d:Destroy() end
        store[model] = nil
    end
    local function scan()
        local present = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= player and p.Character then present[p.Character] = true; initModel(p.Character, p.Name) end end
        local rigs = Workspace:FindFirstChild("Rigs")
        local function considerModel(m) if not m:IsA("Model") or m == player.Character or m.Name == player.Name then return end; if not m:FindFirstChildOfClass("Humanoid") then return end; present[m] = true; initModel(m, tostring(m.Name):match("^(.-)_[%x]+%-") or m.Name) end
        if rigs then for _, m in ipairs(rigs:GetChildren()) do considerModel(m) end end
        for _, m in ipairs(Workspace:GetChildren()) do if m:IsA("Model") then considerModel(m) end end
        for m in pairs(store) do if not present[m] or not m.Parent then removeModel(m) end end
    end
    task.spawn(function() while true do task.wait(0.75); pcall(scan) end end)

    local lastEspUpdate = 0
    RunService.Heartbeat:Connect(function()
        if tick() - lastEspUpdate < 0.05 then return end
        lastEspUpdate = tick()

        for model, data in pairs(store) do
            if data.healthFill and data.healthFill.Parent then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum then
                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    data.healthFill.Size = UDim2.fromScale(1, pct)
                    if pct > 0.75 then data.healthFill.BackgroundColor3 = Color3.fromRGB(60, 220, 90)
                    elseif pct > 0.5 then data.healthFill.BackgroundColor3 = Color3.fromRGB(255, 220, 50)
                    elseif pct > 0.25 then data.healthFill.BackgroundColor3 = Color3.fromRGB(255, 130, 50)
                    else data.healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end
                end
            end
        end
    end)

    local lastRender = 0
    RunService.RenderStepped:Connect(function()
        if tick() - lastRender < 0.05 then return end
        lastRender = tick()
        local cam = workspace.CurrentCamera; if not cam then return end
        local vp = cam.ViewportSize
        for model, data in pairs(store) do
            local hrp = model:FindFirstChild("HumanoidRootPart"); if not hrp or not model.Parent then continue end
            if not Options.esp_master then
                if data.highlight then data.highlight.Enabled = false end
                if data.nameBB then data.nameBB.Enabled = false end
                if data.boxFrame then data.boxFrame.Visible = false end
                if data.healthFrame then data.healthFrame.Visible = false end
                if data.lineFrame then data.lineFrame.Visible = false end
                for _, f in ipairs(data.skeletonLines) do f.Visible = false end
                for _, d in ipairs(data.dots) do d.Visible = false end
                continue
            end
            if data.highlight then data.highlight.Enabled = FEATURES.highlight end; if data.nameBB then data.nameBB.Enabled = FEATURES.name end
            if FEATURES.box or FEATURES.health then
                local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge; local any = false
                for _, part in ipairs(model:GetChildren()) do if part:IsA("BasePart") and BODY_PARTS[part.Name] then local cf = part.CFrame; local half = part.Size * 0.5; for _, sx in ipairs({-1,1}) do for _, sy in ipairs({-1,1}) do for _, sz in ipairs({-1,1}) do local wp = (cf * CFrame.new(sx*half.X, sy*half.Y, sz*half.Z)).Position; local sp, on = cam:WorldToViewportPoint(wp); if on and sp.Z > 0.5 then any = true; if sp.X < minX then minX = sp.X end; if sp.Y < minY then minY = sp.Y end; if sp.X > maxX then maxX = sp.X end; if sp.Y > maxY then maxY = sp.Y end end end end end end end
                if any and maxX > minX and maxY > minY then
                    local w, h = (maxX - minX) * 1.0, (maxY - minY) * 1.3; local cx, cy = (minX + maxX) * 0.5, (minY + maxY) * 0.5; local leftEdge, topEdge = cx - w * 0.5, cy - h * 0.5
                    if FEATURES.box then data.boxFrame.Position = UDim2.fromOffset(leftEdge, topEdge); data.boxFrame.Size = UDim2.fromOffset(w, h); data.boxFrame.Visible = true else data.boxFrame.Visible = false end
                    if FEATURES.health then data.healthFrame.Position = UDim2.fromOffset(leftEdge - 8, topEdge); data.healthFrame.Size = UDim2.fromOffset(4, h); data.healthFrame.Visible = true else data.healthFrame.Visible = false end
                else data.boxFrame.Visible = false; data.healthFrame.Visible = false end
            else data.boxFrame.Visible = false; data.healthFrame.Visible = false end
            if FEATURES.lines then
                local targetPart = model:FindFirstChild("Head") or hrp
                if targetPart then local sp, on = cam:WorldToViewportPoint(targetPart.Position); if on and sp.Z > 0.5 then local tx, ty = sp.X, sp.Y; local ox, oy = vp.X * 0.5, 0; local dx, dy = tx - ox, ty - oy; local len = math.sqrt(dx*dx + dy*dy); if len > 2 and len < 3000 then data.lineFrame.Size = UDim2.fromOffset(len, 1.5); data.lineFrame.Position = UDim2.fromOffset(ox + dx*0.5, oy + dy*0.5); data.lineFrame.Rotation = math.deg(math.atan2(dy, dx)); data.lineFrame.Visible = true else data.lineFrame.Visible = false end else data.lineFrame.Visible = false end else data.lineFrame.Visible = false end
            else data.lineFrame.Visible = false end
            if FEATURES.skeleton then
                local joints, lineConnections = getJoints(model)
                if joints and lineConnections then
                    while #data.skeletonLines < #lineConnections do local frame = create("Frame", { AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ZIndex=1 }, skeletonDrawGui); create("UIStroke", { Color=Color3.fromRGB(255,255,255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, frame); table.insert(data.skeletonLines, frame) end
                    local jointNames = {}; for k in pairs(joints) do table.insert(jointNames, k) end
                    while #data.dots < #jointNames do local dot = create("Frame", { AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, Visible=false, ZIndex=2 }, skeletonDrawGui); create("UICorner", { CornerRadius=UDim.new(1,0) }, dot); table.insert(data.dots, dot) end
                    local screenPos = {}; local minY, maxY = math.huge, -math.huge
                    for name, pos in pairs(joints) do local sp, on = cam:WorldToViewportPoint(pos); if on and sp.Z > 0.5 and math.abs(sp.X) < 5000 and math.abs(sp.Y) < 5000 then local v2 = Vector2.new(sp.X, sp.Y); screenPos[name] = v2; if v2.Y < minY then minY = v2.Y end; if v2.Y > maxY then maxY = v2.Y end end end
                    local screenHeight = (maxY > minY) and (maxY - minY) or 0; local scaleFactor = math.clamp(screenHeight / 150, 0.15, 3.0)
                    local dynamicThickness = math.clamp(1.5 * scaleFactor, 0.5, 4.5); local dynamicDotSize = math.clamp(4.0 * scaleFactor, 1.5, 12.0)
                    local dotIdx = 1
                    for name, sp in pairs(screenPos) do local dot = data.dots[dotIdx]; dot.Position = UDim2.fromOffset(sp.X, sp.Y); dot.Size = UDim2.fromOffset(dynamicDotSize, dynamicDotSize); dot.Visible = true; dotIdx += 1 end
                    for i = dotIdx, #data.dots do data.dots[i].Visible = false end
                    for i, conn in ipairs(lineConnections) do local frame = data.skeletonLines[i]; local p1 = screenPos[conn[1]]; local p2 = screenPos[conn[2]]; if p1 and p2 then local dx, dy = p2.X - p1.X, p2.Y - p1.Y; local len = math.sqrt(dx*dx + dy*dy); if len > 0.5 and len < 3000 then frame.Size = UDim2.fromOffset(len, 0); frame.Position = UDim2.fromOffset(p1.X + dx*0.5, p1.Y + dy*0.5); frame.Rotation = math.deg(math.atan2(dy, dx)); frame.UIStroke.Thickness = dynamicThickness; frame.Visible = true else frame.Visible = false end else frame.Visible = false end end
                    for i = #lineConnections + 1, #data.skeletonLines do data.skeletonLines[i].Visible = false end
                end
            else for _, f in ipairs(data.skeletonLines) do f.Visible = false end; for _, d in ipairs(data.dots) do d.Visible = false end end
        end
    end)
    return {
        setFeature = function(name, on)
            FEATURES[name] = on
            if name == "highlight" then for _, d in pairs(store) do if d.highlight then d.highlight.Enabled = on end end end
            if name == "name" then for _, d in pairs(store) do if d.nameBB then d.nameBB.Enabled = on end end end
        end,
        refreshNames = function()
            for model, data in pairs(store) do
                if data.nameLbl and data.nameLbl.Parent then data.nameLbl.Text = buildDisplayName(data.displayName, model) end
            end
        end,
        destroy = function() for m in pairs(store) do removeModel(m) end end
    }
end)()

local ArrowESP = (function()
    local COLORS = { Arrow=Color3.fromRGB(255,70,70), Fragment=Color3.fromRGB(255,200,60), Bandage=Color3.fromRGB(80,200,255), Rokakaka=Color3.fromRGB(255,105,180), Exit=Color3.fromRGB(60,255,90) }
    local S = { esp={}, exitActive=nil, hidden={} }
    local function gp() local m=Workspace:FindFirstChild("Map"); return m and m:FindFirstChild("Gameplay") end
    local function sewers() local map=Workspace:FindFirstChild("Map"); local vis=map and map:FindFirstChild("Visual"); local vil=vis and vis:FindFirstChild("Village"); local sw=vil and vil:FindFirstChild("Sewer"); return sw and sw:FindFirstChild("Sewers") end
    local function hasTouch(p) for _,c in ipairs(p:GetChildren()) do if c:IsA("TouchTransmitter") then return true end end end
    local function mk(part,kind,lblTxt)
        local c=COLORS[kind]
        local hl=Instance.new("Highlight"); hl.Adornee=part; hl.FillColor=c; hl.FillTransparency=0.45
        hl.OutlineColor=c; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=gui
        local bb=Instance.new("BillboardGui"); bb.Adornee=part; bb.Size=UDim2.fromOffset(180,26)
        bb.StudsOffsetWorldSpace=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.LightInfluence=0; bb.MaxDistance=0; bb.Parent=gui
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.fromScale(1,1); lbl.BackgroundTransparency=1
        lbl.Font=Enum.Font.GothamBold; lbl.Text=lblTxt or part.Name; lbl.TextColor3=c
        lbl.TextStrokeTransparency=0; lbl.TextStrokeColor3=Color3.new(0,0,0); lbl.TextSize=14; lbl.Parent=bb
        S.esp[part]={kind=kind, hl=hl, bb=bb, label=lbl}
    end
    local function kill(part) local e=S.esp[part]; if not e then return end
        if e.hl then e.hl:Destroy() end; if e.bb then e.bb:Destroy() end; S.esp[part]=nil end
    local function pickExit()
        local g=gp(); local ex=g and g:FindFirstChild("Exits"); if not ex then return nil end
        local list,wt={},{}
        for _,c in ipairs(ex:GetChildren()) do if c:IsA("BasePart") and c.Name=="Exit" then list[#list+1]=c; if hasTouch(c) then wt[#wt+1]=c end end end
        if #wt==1 then return wt[1] end
        if #wt>1 then local sw=g:FindFirstChild("SewerEntrance"); if sw then table.sort(wt,function(a,b) return (a.Position-sw.Position).Magnitude<(b.Position-sw.Position).Magnitude end) end; return wt[1] end
        local sw=g:FindFirstChild("SewerEntrance"); local cd={}
        for _,p in ipairs(list) do if p.CanTouch then cd[#cd+1]=p end end
        if #cd==0 then cd=list end
        if sw and #cd>1 then table.sort(cd,function(a,b) return (a.Position-sw.Position).Magnitude<(b.Position-sw.Position).Magnitude end) end
        return cd[1]
    end
    local function hideTun()
        local sws=sewers(); if not sws then return end
        for _,ch in ipairs(sws:GetChildren()) do
            if ch.Name=="SewerWalls" or ch.Name=="Tunnels" then
                local parts = ch:IsA("BasePart") and {ch} or {}
                if not ch:IsA("BasePart") then for _,d in ipairs(ch:GetDescendants()) do if d:IsA("BasePart") then parts[#parts+1]=d end end end
                for _,p in ipairs(parts) do if not S.hidden[p] then S.hidden[p]={t=p.Transparency, cc=p.CanCollide, ct=p.CanTouch} end; p.Transparency=1; p.CanCollide=false; p.CanTouch=false end
            end
        end
    end
    local function restoreTun() for p,o in pairs(S.hidden) do if p and p.Parent then pcall(function() p.Transparency=o.t; p.CanCollide=o.cc; p.CanTouch=o.ct end) end end; S.hidden={} end
    local function scan()
        local g=gp()
        if g then for _,ch in ipairs(g:GetChildren()) do
            if ch:IsA("BasePart") then
                local kind = ch.Name=="Arrow" and "Arrow" or ch.Name=="ArrowFragment" and "Fragment" or ch.Name=="Bandage" and "Bandage"
                if kind then
                    local flag = "esp_arrow" .. (kind=="Arrow" and "" or "_"..string.lower(kind))
                    if Options[flag] and not S.esp[ch] then mk(ch,kind)
                    elseif not Options[flag] and S.esp[ch] then kill(ch) end
                end
            end
        end end
        local roka=Workspace:FindFirstChild("RokakakaFruit")
        if roka and roka:IsA("BasePart") then
            if Options.esp_arrow_rokakaka and not S.esp[roka] then mk(roka,"Rokakaka","ROKAKAKA")
            elseif not Options.esp_arrow_rokakaka and S.esp[roka] then kill(roka) end
        end
        if Options.esp_arrow_exit then
            local a=pickExit()
            if a~=S.exitActive then
                if S.exitActive and S.esp[S.exitActive] then kill(S.exitActive) end
                S.exitActive=a; if a then mk(a,"Exit","EXIT") end
            end
        elseif S.exitActive then if S.esp[S.exitActive] then kill(S.exitActive) end; S.exitActive=nil end
        for p in pairs(S.esp) do if not p.Parent then kill(p) end end
        if Options.arrow_remove_tunnels then hideTun() elseif next(S.hidden) then restoreTun() end
    end
    task.spawn(function() while alive do task.wait(0.4); pcall(scan) end end)

    local lastArrowRender = 0
    RunService.RenderStepped:Connect(function()
        if tick() - lastArrowRender < 0.1 then return end
        lastArrowRender = tick()
        local cam=workspace.CurrentCamera; if not cam then return end
        local cp=cam.CFrame.Position
        for p,e in pairs(S.esp) do if e.label and p.Parent then
            if e.kind=="Exit" then e.label.Text=string.format("EXIT  %dm",math.floor((p.Position-cp).Magnitude))
            elseif e.kind=="Rokakaka" then e.label.Text=string.format("ROKAKAKA  %dm",math.floor((p.Position-cp).Magnitude)) end
        end end
    end)
    return {
        clearKind=function(k) for p,e in pairs(S.esp) do if e.kind==k then kill(p) end end; if k=="Exit" then S.exitActive=nil end end,
        restoreTunnels=restoreTun,
        destroy=function() for p in pairs(S.esp) do kill(p) end; restoreTun() end,
    }
end)()

local AutoPickKey = (function()
    local CFG = {
        KeyName = "Stage3VillageKey",
        StepSize = 4, StepWait = 0.015, ArriveDist = 1.5,
        FlyTimeout = 20, MaxSearchDist = 200,
        CoverProbeWait = 2.0, KeyOpenWait = 2.0,
        HoldDuration = 1.4, ConfirmTime = 0.4,
        KeySpawnWait = 10, VoidDrop = 400, MaxCycles = 999,
        PostHoldWait = 0.5,
    }
    local state = { running = false, phase = "idle", lockedCFrame = nil, steppedCon = nil, thread = nil }
    local function setPhase(p)
        state.phase = p
        local c = player.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if p == "idle" then
            state.lockedCFrame = nil
            if hrp then pcall(function() hrp.Anchored = false end) end
            if hum then
                pcall(function() hum.PlatformStand = false end)
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true) end)
            end
        elseif p == "flying" then
            if hrp then pcall(function() hrp.Anchored = true end) end
            if hum then pcall(function() hum.PlatformStand = true end) end
        elseif p == "locked" then
            if hrp then pcall(function() hrp.Anchored = true end) end
            if hum then
                pcall(function() hum.PlatformStand = false end)
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true) end)
            end
        end
    end
    local function startStepped()
        if state.steppedCon then return end
        state.steppedCon = RunService.Stepped:Connect(function()
            if not state.running then return end
            if state.phase == "idle" then return end
            local c = player.Character; if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not hrp.Anchored then hrp.Anchored = true end
            if state.phase == "flying" then
                if hum and not hum.PlatformStand then pcall(function() hum.PlatformStand = true end) end
            elseif state.phase == "locked" then
                if state.lockedCFrame and (hrp.CFrame.Position - state.lockedCFrame.Position).Magnitude > 0.05 then hrp.CFrame = state.lockedCFrame end
                if hum and hum.PlatformStand then pcall(function() hum.PlatformStand = false end) end
            end
        end)
    end
    local function stopStepped()
        if state.steppedCon then pcall(function() state.steppedCon:Disconnect() end); state.steppedCon = nil end
    end
    local function anchorOf(obj)
        if not obj then return nil end
        if obj:IsA("BasePart") then return obj end
        if obj:IsA("Model") then
            local ok, p = pcall(function() return obj.PrimaryPart end)
            if ok and p then return p end
            return obj:FindFirstChildWhichIsA("BasePart", false)
        end
        return nil
    end
    local function getKey()
        local k = Workspace:FindFirstChild(CFG.KeyName); if k then return k end
        local map = Workspace:FindFirstChild("Map"); if not map then return nil end
        local gp = map:FindFirstChild("Gameplay")
        if gp then k = gp:FindFirstChild(CFG.KeyName, true); if k then return k end end
        return map:FindFirstChild(CFG.KeyName, true)
    end
    local function getCharParts()
        local c = player.Character
        if not c or not c.Parent then return nil end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hrp and hrp.Parent and hum and hum.Parent and hum.Health > 0 then return hrp, hum, c end
        return nil
    end
    local function movementContextReady(target)
        if not alive or not state.running or not Workspace.Parent then return false end
        local hrp, hum, char = getCharParts()
        if not hrp or not hum or not char then return false end
        if target then
            local ok, valid = pcall(function() return target.Parent ~= nil and target:IsDescendantOf(Workspace) end)
            if not ok or not valid then return false end
        end
        return true
    end
    local function keyGoneFor(sec)
        local t0 = tick()
        while tick() - t0 < sec do if getKey() ~= nil then return false end; task.wait(0.05) end
        return true
    end
    local function promptsIn(obj)
        local list = {}
        if not obj then return list end
        for _, d in ipairs(obj:GetDescendants()) do if d:IsA("ProximityPrompt") then table.insert(list, d) end end
        return list
    end
    local function getFirePP() local f=rawget(_G,"fireproximityprompt"); if type(f)=="function" then return f end; local g=genv; if type(g)=="table" and type(g.fireproximityprompt)=="function" then return g.fireproximityprompt end end
    local function getFireCD() local f=rawget(_G,"fireclickdetector"); if type(f)=="function" then return f end; local g=genv; if type(g)=="table" and type(g.fireclickdetector)=="function" then return g.fireclickdetector end end
    local function manualPrompt(prompt)
        if not prompt or not prompt.Parent then return false end
        pcall(function()
            if not prompt.Enabled then prompt.Enabled = true end
            prompt.RequiresLineOfSight = false
            if (prompt.MaxActivationDistance or 0) < 32 then prompt.MaxActivationDistance = 32 end
        end)
        if not pcall(function() prompt:InputHoldBegin() end) then return false end
        task.wait(0.4)
        pcall(function() prompt:InputHoldEnd() end)
        task.wait(0.1)
        return true
    end
    local function tryInteractObject(part)
        local interacted = false
        for _, prompt in ipairs(promptsIn(part)) do
            if (prompt.HoldDuration or 0) <= 0.2 then
                local fpp = getFirePP(); if fpp then pcall(fpp, prompt); interacted = true end
                manualPrompt(prompt); interacted = true
            end
        end
        local fcd = getFireCD()
        if fcd then for _, d in ipairs(part:GetDescendants()) do if d:IsA("ClickDetector") then pcall(fcd, d); interacted = true end end end
        if not interacted and part.Parent then
            for _, prompt in ipairs(promptsIn(part.Parent)) do
                if (prompt.HoldDuration or 0) <= 0.2 then
                    local fpp = getFirePP(); if fpp then pcall(fpp, prompt); interacted = true end
                    manualPrompt(prompt); interacted = true
                end
            end
        end
        return interacted
    end
    local function holdCycle(prompt, cycleIdx)
        if not prompt or not prompt.Parent or not movementContextReady(prompt) then return false end
        pcall(function()
            if not prompt.Enabled then prompt.Enabled = true end
            prompt.RequiresLineOfSight = false
            if (prompt.MaxActivationDistance or 0) < 32 then prompt.MaxActivationDistance = 32 end
        end)
        if not pcall(function() prompt:InputHoldBegin() end) then return false end
        local t0 = tick()
        while tick() - t0 < CFG.HoldDuration do
            if not movementContextReady(prompt) then break end
            if state.lockedCFrame then
                local hrp = getCharParts()
                if hrp and (hrp.Position - state.lockedCFrame.Position).Magnitude > 1.5 then
                    pcall(function() if movementContextReady(prompt) then hrp.CFrame = state.lockedCFrame end end)
                end
            end
            if not prompt.Parent then break end
            task.wait(0.03)
        end
        pcall(function() prompt:InputHoldEnd() end)
        task.wait(0.05)
        if not alive or not state.running then return false end
        if keyGoneFor(CFG.ConfirmTime) then return true end
        return false
    end
    local function moveToStraight(destPos, targetInstance)
        if typeof(destPos) ~= "Vector3" or not movementContextReady(targetInstance) then return false end
        local hrp, hum = getCharParts()
        if not hrp or not hum then return false end
        setPhase("flying")
        local abortY = destPos.Y - CFG.VoidDrop
        local t0 = tick()
        while tick() - t0 < CFG.FlyTimeout do
            if not movementContextReady(targetInstance) then setPhase("idle"); return false end
            hrp, hum = getCharParts()
            if not hrp or not hum or not hrp.Parent then setPhase("idle"); return false end
            local cur = hrp.Position
            if cur.Y < abortY then setPhase("idle"); return false end
            local dist = (destPos - cur).Magnitude
            if dist < CFG.ArriveDist then state.lockedCFrame = CFrame.new(cur); setPhase("locked"); return true end
            local step = math.min(CFG.StepSize, dist)
            local moved = pcall(function()
                if not movementContextReady(targetInstance) or not hrp.Parent then error("movement target was removed") end
                hrp.CFrame = CFrame.new(cur + (destPos - cur).Unit * step)
            end)
            if not moved then setPhase("idle"); return false end
            task.wait(CFG.StepWait)
        end
        setPhase("idle")
        return false
    end
    local function faceAndCreep(targetPart)
        if not targetPart or not movementContextReady(targetPart) then return end
        local hrp = getCharParts()
        if not hrp or not targetPart.Parent then return end
        local kp, cp = targetPart.Position, hrp.Position
        local dir = kp - cp
        if dir.Magnitude > 0.05 then
            local cf = CFrame.lookAt(cp, Vector3.new(kp.X, cp.Y, kp.Z))
            hrp.CFrame = cf; state.lockedCFrame = cf
        end
        if dir.Magnitude > 1.2 then
            local newPos = kp - dir.Unit * 1.2
            local cf = CFrame.new(newPos, Vector3.new(kp.X, newPos.Y, kp.Z))
            hrp.CFrame = cf; state.lockedCFrame = cf
        end
    end
    local BAD_KW = {"door", "porta", "gate", "portao", "fence", "cerca"}
    local GOOD_KW = {"nightstand", "wardrobe", "bedsheet", "bed", "drawer", "cabinet", "cama", "armario", "gaveta", "colchao", "criado"}
    local function isBadName(part)
        local hay = tostring(part and part.Name or ""):lower()
        for _, kw in ipairs(BAD_KW) do if hay:find(kw, 1, true) then return true end end
        return false
    end
    local function findFurnitureObjects(key)
        local a = anchorOf(key)
        if not a or not a.Parent then return {} end
        local map = Workspace:FindFirstChild("Map")
        local workspaceInterior = Workspace:FindFirstChild("Interior")
        local stack = {}
        if map and map.Parent then table.insert(stack, {node = map, inInterior = map.Name == "Interior"}) end
        if workspaceInterior and workspaceInterior.Parent and workspaceInterior ~= map then table.insert(stack, {node = workspaceInterior, inInterior = true}) end
        if #stack == 0 then return {} end
        local results = {}; local visited = {}
        while #stack > 0 do
            if not alive or not state.running or not a.Parent then return {} end
            local entry = table.remove(stack)
            local node = entry and entry.node
            if node and node.Parent and not visited[node] then
                visited[node] = true
                local okChildren, children = pcall(function() return node:GetChildren() end)
                if okChildren then
                    for _, d in ipairs(children) do
                        if d and d.Parent then
                            local inInterior = entry.inInterior or d.Name == "Interior"
                            if inInterior and (d:IsA("Model") or d:IsA("BasePart")) then
                                local isFurniture = false
                                local n = tostring(d.Name):lower()
                                for _, kw in ipairs(GOOD_KW) do if n:find(kw, 1, true) then isFurniture = true; break end end
                                if isFurniture and not isBadName(d) then
                                    local part = anchorOf(d)
                                    if part and part.Parent then
                                        local okDist, dist = pcall(function() return (part.Position - a.Position).Magnitude end)
                                        if okDist and dist <= CFG.MaxSearchDist then table.insert(results, {part = part, model = d, dist = dist}) end
                                    end
                                end
                            end
                            if d:IsA("Model") or d:IsA("Folder") or d:IsA("Configuration") then table.insert(stack, {node = d, inInterior = inInterior}) end
                        end
                    end
                end
            end
        end
        table.sort(results, function(x, y) return x.dist < y.dist end)
        return results
    end
    local function openFurniture(key)
        if not key then return false end
        local list = findFurnitureObjects(key)
        if #list == 0 then return false end
        local target = list[1]
        if not moveToStraight(target.part.Position, target.part) then return false end
        if not target.part.Parent then return false end
        faceAndCreep(target.part)
        task.wait(0.15)
        if not state.running then return false end
        local preKeyPos = anchorOf(key)
        if preKeyPos then preKeyPos = preKeyPos.Position else return false end
        tryInteractObject(target.model)
        local t0 = tick()
        while tick() - t0 < CFG.CoverProbeWait do
            if not state.running then return false end
            if getKey() == nil then return true end
            local kNow = getKey()
            local aNow = kNow and anchorOf(kNow)
            if aNow and (aNow.Position - preKeyPos).Magnitude > 1 then return true end
            task.wait(0.05)
        end
        return false
    end
    local function tryHoldKey(key)
        if not key or not key.Parent then return keyGoneFor(CFG.ConfirmTime) end
        local keyPrompts = promptsIn(key)
        local longP = {}
        for _, p in ipairs(keyPrompts) do if (p.HoldDuration or 0) > 0.1 then table.insert(longP, p) end end
        if #longP == 0 then return false end
        local ka = anchorOf(key)
        if ka then
            if not moveToStraight(ka.Position, ka) then return false end
            if not ka.Parent then return false end
            faceAndCreep(ka)
            task.wait(0.1)
        end
        for _, p in ipairs(longP) do
            if holdCycle(p, 0) then return true end
            if not state.running then return false end
        end
        return keyGoneFor(CFG.ConfirmTime)
    end
    local function tryInteract(key)
        if not key or not key.Parent then
            if keyGoneFor(CFG.ConfirmTime) then return true end
            return false
        end
        if not state.running then return false end
        if tryHoldKey(key) then return true end
        if not state.running then return false end
        openFurniture(key)
        task.wait(0.5)
        if not state.running then return false end
        key = getKey()
        if not key then return keyGoneFor(CFG.ConfirmTime) end
        if tryHoldKey(key) then return true end
        return keyGoneFor(CFG.ConfirmTime)
    end
    local function mainLoop()
        setPhase("idle")
        startStepped()
        while state.running and alive do
            local key = nil
            local t0 = tick()
            while tick() - t0 < CFG.KeySpawnWait do
                if not state.running then break end
                local k = getKey()
                if k and anchorOf(k) then key = k; break end
                task.wait(0.3)
            end
            if not state.running then break end
            if not key then task.wait(0.8)
            else
                local a = anchorOf(key)
                if not a then task.wait(0.3)
                else
                    if tryInteract(key) then setPhase("idle"); task.wait(0.8)
                    else setPhase("idle"); task.wait(0.5) end
                end
            end
        end
        setPhase("idle"); stopStepped(); state.thread = nil
    end
    return {
        setEnabled = function(on)
            if on == state.running then return end
            state.running = on
            if on then
                if state.thread then pcall(function() task.cancel(state.thread) end); state.thread = nil end
                state.phase = "idle"; state.lockedCFrame = nil
                state.thread = task.spawn(mainLoop)
            else
                setPhase("idle"); stopStepped()
            end
        end,
        destroy = function() state.running = false; setPhase("idle"); stopStepped() end,
    }
end)()

local ESPKey = (function()
    local currentTarget = nil
    local function cleanup()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "BabisKeyHighlight" or obj.Name == "BabisKeyName" then
                pcall(function() obj:Destroy() end)
            end
        end
        currentTarget = nil
    end
    local function buildIfNeeded()
        local target = Workspace:FindFirstChild("Stage3VillageKey", true)
        if not target then
            if currentTarget then cleanup() end
            return
        end
        if currentTarget == target then
            local stillHas = false
            for _, obj in ipairs(target:GetDescendants()) do
                if obj.Name == "BabisKeyHighlight" then stillHas = true; break end
            end
            if stillHas then return end
        end
        cleanup()
        local adornee = (target:IsA("Model") and target) or (target:IsA("BasePart") and target)
        if not adornee then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "BabisKeyHighlight"
        highlight.Adornee = adornee
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.8
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = adornee
        local part = (target:IsA("BasePart") and target) or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
        if not part then return end
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "BabisKeyName"
        billboard.Adornee = part
        billboard.Size = UDim2.fromOffset(100, 24)
        billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.Parent = part
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "Key"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.TextSize = 16
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
        currentTarget = target
    end
    task.spawn(function()
        while alive do
            task.wait(0.4)
            if Options.key_esp then
                buildIfNeeded()
            elseif currentTarget then
                cleanup()
            end
        end
    end)
    return { destroy = cleanup }
end)()

local AutoBandage = (function()
    local useRemote
    pcall(function() useRemote=ReplicatedStorage.Packages.Knit.Services.ItemService.RE.UseItem end)
    local state={running=false}
    local function loop()
        while state.running and alive do
            local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
            if h and useRemote then
                local th=tonumber(Options.bandage_hp) or 80
                if h.Health>0 and h.Health<=th then pcall(function() useRemote:FireServer("Bandage") end) end
            end
            task.wait(1.0)
        end
    end
    return { setEnabled=function(on) if on==state.running then return end; state.running=on; if on then task.spawn(loop) end end }
end)()

local AntiKick = (function()
    local Cfg={BlockKick=true, BlockKickMember=true, BlockForceBlock=true, BlockGameKick=true,
        KM={"kickmember","kick_member","removeplayer","removemember","remove_player"},
        FB={"forceblock","force_block","blockforce","forcekick"},
        GK={"gamekick","kickplayer","banplayer","ban_player"},
        RB={ "reporttopspeed","reportspeed","report_speed","speedreport" }, SpeedBase=60}
    local St={installed=false, prev=nil, ref=nil, ext={}}
    local function cls(n)
        local l=string.lower(n)
        for i=1,#Cfg.RB do if l==Cfg.RB[i] then return "speed" end end
        for i=1,#Cfg.KM do if string.find(l,Cfg.KM[i],1,true) then return "km" end end
        for i=1,#Cfg.FB do if string.find(l,Cfg.FB[i],1,true) then return "fb" end end
        for i=1,#Cfg.GK do if string.find(l,Cfg.GK[i],1,true) then return "gk" end end
    end
    local function targetsMe(a) return a==player or a==player.UserId or a==player.Name or tostring(a)==tostring(player.UserId) end
    local function core(self, prev, ...)
        if self==player or self==Players then if Cfg.BlockKick and getnamecallmethod()=="Kick" then return nil end; return prev(self, ...) end
        if typeof(self)=="Instance" and (self.ClassName=="RemoteEvent" or self.ClassName=="RemoteFunction") then
            local kind=cls(self.Name)
            if kind then
                local m=getnamecallmethod()
                if m=="InvokeServer" or m=="FireServer" then
                    if kind=="speed" then return prev(self, math.min(tonumber((...)) or Cfg.SpeedBase, Cfg.SpeedBase))
                    elseif kind=="km" and Cfg.BlockKickMember then if targetsMe((...)) then return nil end
                    elseif kind=="fb" and Cfg.BlockForceBlock then return nil
                    elseif kind=="gk" and Cfg.BlockGameKick then local t=(...); if targetsMe(t) or t==nil then return nil end end
                end
            end
        end
        return prev(self, ...)
    end
    local function install()
        if St.installed then return end
        local ok, mt = pcall(getrawmetatable, game); if not ok or not mt or not mt.__namecall then return end
        St.prev=mt.__namecall; St.ref=newcclosure(function(self, ...) return core(self, St.prev, ...) end)
        pcall(function() setreadonly(mt,false); mt.__namecall=St.ref; setreadonly(mt,true) end)
        St.installed=true
    end
    local function uninstall()
        if not St.installed then return end
        local ok, mt = pcall(getrawmetatable, game)
        if ok and mt and St.prev then pcall(function() setreadonly(mt,false); mt.__namecall=St.prev; setreadonly(mt,true) end) end
        St.installed=false; St.prev=nil; St.ref=nil
    end
    task.spawn(function() while alive do task.wait(2.0); if not St.installed then pcall(install) end end end)
    return { install=install, uninstall=uninstall }
end)()

pcall(function() AntiKick.install() end)

local Destroyer = (function()
    local running=true; local TRIGGER=60
    local function getTrainExterior()
        local map=Workspace:FindFirstChild("Map"); local vis=map and map:FindFirstChild("Visual"); local ti=vis and vis:FindFirstChild("TrainInterior"); if not ti then return nil end
        for _,d in ipairs(ti:GetDescendants()) do if d:IsA("BasePart") and d.Name=="Exterior" then return d end end
    end
    local function inTrainInterior()
        local map=Workspace:FindFirstChild("Map"); local vis=map and map:FindFirstChild("Visual"); local ti=vis and vis:FindFirstChild("TrainInterior"); if not ti then return false end
        local h=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not h then return false end
        local sections={"EndSection","SectionPassenger","BarSection"}
        for _,secName in ipairs(sections) do
            local sec=ti:FindFirstChild(secName)
            if sec then
                local base=sec:FindFirstChild("Base") or sec:FindFirstChild("TrainBase")
                if base then
                    local interior=base:FindFirstChild("Interior") or base:FindFirstChild("Exterior")
                    if interior and interior:IsA("BasePart") then
                        if (interior.Position-h.Position).Magnitude < 50 then return true end
                    end
                end
            end
        end
        return false
    end
    local function kill()
        if not running then return end
        running=false
        pcall(function() if genv.BabisUnload then genv.BabisUnload() end end)
    end
    task.spawn(function() while running and alive do task.wait(0.3)
        local ex=getTrainExterior()
        if ex then
            local h=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if h and (ex.Position-h.Position).Magnitude < TRIGGER then kill(); return end
        end
        if inTrainInterior() then kill(); return end
    end end)
    return { stop=function() running=false end }
end)()

local pMain = createTab("Main")
addSectionHeader(pMain, "Silent Aim")
addToggle(pMain, { Text="Silent Aim", Flag="silent_aim", Keybind="kb_silent_aim", Callback=function(on, viaKeybind) SilentAim.setEnabled(on); notify("Silent Aim: " .. (on and "ON" or "OFF")) end })
addDropdown(pMain, "Bone", { flag="silent_bone", getOptions=function() return {"HumanoidRootPart","Head","UpperTorso","Torso"} end, get=function() return Options.silent_bone end, set=function(v) setOption("silent_bone", v) end })
addSlider(pMain, { Flag="silent_fov", Text="FOV", Min=30, Max=800, Requires="silent_aim", Callback=function(v) SilentAim.updateCircle() end })
addSlider(pMain, { Flag="silent_predict", Text="Predict (s)", Min=0, Max=0.3, Decimals=3, Requires="silent_aim", Callback=function(v) end })
addToggle(pMain, { Text="Ping Comp", Flag="silent_ping_comp", Requires="silent_aim", Callback=function(on) notify("Ping Comp: " .. (on and "ON" or "OFF")) end })

addSectionHeader(pMain, "Auto Attack")
addToggle(pMain, { Text="Auto Attack", Flag="auto_attack", Keybind="kb_auto_attack", Callback=function(on, viaKeybind) AutoAttack.setEnabled(on); notify("Auto Attack: " .. (on and "ON" or "OFF")) end })
addSlider(pMain, { Flag="aa_range", Text="Range (studs)", Min=3, Max=35, Requires="auto_attack", Callback=function(v) end })
addSlider(pMain, { Flag="aa_delay", Text="Delay (s)", Min=0.1, Max=0.8, Decimals=2, Requires="auto_attack", Callback=function(v) end })

addSectionHeader(pMain, "Auto Block (Beta)")
addToggle(pMain, { Text="Auto Block", Flag="auto_block", Keybind="kb_auto_block", Callback=function(on, viaKeybind)
    AutoBlock.setEnabled(on)
    if not on and Options.range_view then setOption("range_view", false); if Registry["range_view"] then Registry["range_view"](false) end end
    notify("Auto Block: " .. (on and "ON" or "OFF"))
end })
addSlider(pMain, { Flag="ab_range", Text="Range", Min=3, Max=35, Requires="auto_block", Callback=function(v) end })
addToggle(pMain, { Text="Range View", Flag="range_view", Callback=function(on) RangeView.setEnabled(on); notify("Range View: " .. (on and "ON" or "OFF")) end })

addSectionHeader(pMain, "STAND")
addToggle(pMain, { Text="Auto Summon Stand", Flag="summon_stand", Callback=function(on) AutoSummonStand.setEnabled(on); notify("Summon Stand: " .. (on and "ON" or "OFF")) end })
addSlider(pMain, { Flag="summon_interval", Text="Summon Interval (s)", Min=0.2, Max=5, Decimals=2, Requires="summon_stand", Callback=function(v) AutoSummonStand.setInterval(v) end })
addSlider(pMain, { Flag="summon_timeout", Text="Summon Timeout (s)", Min=3, Max=30, Decimals=0, Requires="summon_stand", Callback=function(v) AutoSummonStand.setTimeout(v) end })

addSectionHeader(pMain, "Aim Target")
addToggle(pMain, { Text="Aim Target", Flag="aim_toggle", Keybind="kb_aim_toggle", Callback=function(on, viaKeybind, fromButton)
    if on then
        if Options.aimcam_toggle then setOption("aimcam_toggle", false); if Registry["aimcam_toggle"] then Registry["aimcam_toggle"](false) end end
        if not viaKeybind and not fromButton then crosshairBtn.Visible = true end
        startAiming(viaKeybind); updateCrosshairVisual(); notify("Aim Target: ON")
    else
        stopAiming(); updateCrosshairVisual(); notify("Aim Target: OFF")
        if not viaKeybind and not fromButton then crosshairBtn.Visible = false end
    end
end })
addDropdown(pMain, "Target Bone", { flag="aim_target_bone", getOptions=function() return PART_OPTIONS end, get=function() return Options.aim_target_bone end, set=function(v) setOption("aim_target_bone", v) end })
addSlider(pMain, { Flag="aim_predict_value", Text="Predict (s)", Min=0, Max=0.3, Decimals=3, Requires="aim_toggle", Callback=function(v) end })

addSectionHeader(pMain, "Aim Cam")
addToggle(pMain, { Text="Aim Cam", Flag="aimcam_toggle", Keybind="kb_aimcam_toggle", Callback=function(on, viaKeybind, fromButton)
    if on then
        if Options.aim_toggle then setOption("aim_toggle", false); if Registry["aim_toggle"] then Registry["aim_toggle"](false) end end
        if not viaKeybind and not fromButton then camBtn.Visible = true end
        startCamLock(viaKeybind); updateCamVisual(); notify("Aim Cam: ON")
    else
        stopCamLock(); updateCamVisual(); notify("Aim Cam: OFF")
        if not viaKeybind and not fromButton then camBtn.Visible = false end
    end
end })
addDropdown(pMain, "Cam Bone", { flag="aimcam_target_bone", getOptions=function() return PART_OPTIONS end, get=function() return Options.aimcam_target_bone end, set=function(v) setOption("aimcam_target_bone", v) end })
addSlider(pMain, { Flag="aimcam_predict_value", Text="Predict (s)", Min=0, Max=0.3, Decimals=3, Requires="aimcam_toggle", Callback=function(v) end })

local pShop = createTab("Shop")
addSectionHeader(pShop, "Train Shop")
addButtons(pShop, {{ Text = "Buy Lasso", Callback = function() Shop.doBuy("Lasso", "Lasso") end }})
addButtons(pShop, {{ Text = "Buy Dynamite", Callback = function() Shop.doBuy("Dynamite", "Dynamite") end }})
addButtons(pShop, {{ Text = "Buy Shotgun", Callback = function() Shop.doBuy("Shotgun", "Shotgun") end }})
addButtons(pShop, {{ Text = "Buy Shotgun Ammo", Callback = function() Shop.doBuy("ShotgunAmmo", "Shotgun Ammo") end }})
addButtons(pShop, {{ Text = "Buy Ammo Revolver", Callback = function() Shop.doBuy("Ammo", "Ammo Revolver") end }})

local pStage1 = createTab("Stage 1")
addSectionHeader(pStage1, "Environment")
addToggle(pStage1, { Text="Remove Cactus", Flag="cactus_remove", Callback=function(on)
    if on and not CactusRemove.isAvailable() then
        notify("Remove Cactus: You are not in stage 1")
        Registry["cactus_remove"](false)
        return
    end
    CactusRemove.setEnabled(on)
    notify("Cactus: " .. (on and "ON" or "OFF"))
end })
addToggle(pStage1, { Text="Remove Tree", Flag="remove_tree", Callback=function(on) TreesRemove.setEnabled(on); notify("Tree: " .. (on and "ON" or "OFF")) end })
addToggle(pStage1, { Text="Remove Mini Rocks", Flag="remove_mini_rocks", Callback=function(on) MiniRocksRemove.setEnabled(on); notify("Mini Rocks: " .. (on and "ON" or "OFF")) end })

local pStage3 = createTab("Stage 3")
addSectionHeader(pStage3, "Arrow ESP")
addToggle(pStage3, { Text="ESP Arrow", Flag="esp_arrow", Callback=function(on) if not on then ArrowESP.clearKind("Arrow") end end })
addToggle(pStage3, { Text="ESP Fragment", Flag="esp_arrow_fragment", Callback=function(on) if not on then ArrowESP.clearKind("Fragment") end end })
addToggle(pStage3, { Text="ESP Bandage", Flag="esp_arrow_bandage", Callback=function(on) if not on then ArrowESP.clearKind("Bandage") end end })
addToggle(pStage3, { Text="ESP Rokakaka", Flag="esp_arrow_rokakaka", Callback=function(on) if not on then ArrowESP.clearKind("Rokakaka") end end })
addToggle(pStage3, { Text="ESP Exit", Flag="esp_arrow_exit", Callback=function(on) if not on then ArrowESP.clearKind("Exit") end end })
addToggle(pStage3, { Text="Remove Tunnels", Flag="arrow_remove_tunnels", Callback=function(on) if not on then ArrowESP.restoreTunnels() end end })
addSectionHeader(pStage3, "Auto Pick Key")
addToggle(pStage3, { Text="Auto Pick Key", Flag="auto_key", Callback=function(on) AutoPickKey.setEnabled(on); notify("Auto Pick Key: " .. (on and "ON" or "OFF")) end })
addToggle(pStage3, { Text="ESP Key", Flag="key_esp", Callback=function(on) notify("ESP Key: " .. (on and "ON" or "OFF")) end })
addSectionHeader(pStage3, "Auto Use Bandage")
addToggle(pStage3, { Text="Auto Use Bandage", Flag="auto_bandage", Callback=function(on) AutoBandage.setEnabled(on); notify("Auto Use Bandage: " .. (on and "ON" or "OFF")) end })
addSlider(pStage3, { Flag="bandage_hp", Text="HP Threshold", Min=10, Max=100, Requires="auto_bandage", Callback=function(v) end })

local pVisual = createTab("Visual")
addSectionHeader(pVisual, "ESP Settings")
addToggle(pVisual, { Text="ESP Player", Flag="esp_master", Callback=function(on) end })
addToggle(pVisual, { Text="ESP Stand Users", Flag="esp_stand", Requires="esp_master", Callback=function(on) EspSuite.refreshNames(); notify("ESP Stand: " .. (on and "ON" or "OFF")) end })
addToggle(pVisual, { Text="ESP Highlight", Flag="esp_highlight", Requires="esp_master", Callback=function(on) EspSuite.setFeature("highlight", on) end })
addToggle(pVisual, { Text="ESP Skeleton", Flag="esp_skeleton", Requires="esp_master", Callback=function(on) EspSuite.setFeature("skeleton", on) end })
addToggle(pVisual, { Text="ESP Name", Flag="esp_name", Requires="esp_master", Callback=function(on) EspSuite.setFeature("name", on) end })
addToggle(pVisual, { Text="ESP Box", Flag="esp_box", Requires="esp_master", Callback=function(on) EspSuite.setFeature("box", on) end })
addToggle(pVisual, { Text="ESP Lines", Flag="esp_lines", Requires="esp_master", Callback=function(on) EspSuite.setFeature("lines", on) end })
addToggle(pVisual, { Text="ESP Health", Flag="esp_health", Requires="esp_master", Callback=function(on) EspSuite.setFeature("health", on) end })
addSectionHeader(pVisual, "Extras")
addToggle(pVisual, { Text="ESP Horse", Flag="esp_horse", Callback=function(on) EspHorse.setEnabled(on); notify("ESP Horse: " .. (on and "ON" or "OFF")) end })
addToggle(pVisual, { Text="ESP Shortcuts", Flag="esp_waypoints", Callback=function(on)
    if on and not EspWaypoints.isAvailable() then
        notify("ESP Shortcuts: You need to be in stage 1 to see shortcuts")
        Registry["esp_waypoints"](false)
        return
    end
    EspWaypoints.setEnabled(on)
    notify("ESP Shortcuts: " .. (on and "ON" or "OFF"))
end })
addToggle(pVisual, { Text="Low Graphics", Flag="low_graphics", Callback=function(on) LowGraphics.setEnabled(on); notify("Low Graphics: " .. (on and "ON" or "OFF")) end })

local pPlayers = createTab("Players")
addSectionHeader(pPlayers, "Side Dash")
addToggle(pPlayers, { Text="Side Dash", Flag="side_dash", Keybind="kb_side_dash", Callback=function(on, viaKeybind) SideDash.setEnabled(on, viaKeybind); notify("Side Dash: " .. (on and "ON" or "OFF")) end })
addKeybind(pPlayers, "kb_side_dash_fire", "Keybind Side Dash", nil, function() SideDash.fire() end, "side_dash")
addSlider(pPlayers, { Flag="side_dash_speed", Text="Dash Speed", Min=30, Max=140, Requires="side_dash", Callback=function(v) end })
addSlider(pPlayers, { Flag="side_dash_range", Text="Dash Range", Min=5, Max=50, Requires="side_dash", Callback=function(v) end })
addToggle(pPlayers, { Text="Range View", Flag="side_dash_range_view", Requires="side_dash", Callback=function(on) if on and Options.side_dash ~= true then if Registry["side_dash_range_view"] then Registry["side_dash_range_view"](false) end return end; notify("Range View: " .. (on and "ON" or "OFF")) end })
addDropdown(pPlayers, "Direction", { flag="side_dash_direction", getOptions=function() return {"LEFT","RIGHT","RANDOM"} end, get=function() return Options.side_dash_direction or "RIGHT" end, set=function(v) setOption("side_dash_direction", v) end, Requires="side_dash" })

addSectionHeader(pPlayers, "Mobility")
addToggle(pPlayers, { Text="No CD Dash", Flag="dash_nocooldown", Callback=function(on) NoDashCooldown.setEnabled(on); notify("Dash: " .. (on and "ON" or "OFF")) end })
addSlider(pPlayers, { Flag="dash_size", Text="Dash Distance", Min=0.1, Max=0.5, Decimals=2, Requires="dash_nocooldown", Callback=function(v) end })
addSectionHeader(pPlayers, "Horse")
addToggle(pPlayers, { Text="Horse Speed", Flag="horse_speed_toggle", Callback=function(on) HorseSpeed.setEnabled(on); notify("Horse Speed: " .. (on and "ON" or "OFF")) end })
addSlider(pPlayers, { Flag="horse_speed_value", Text="Speed Value", Min=170, Max=500, Requires="horse_speed_toggle", Callback=function(v) end })
addSectionHeader(pPlayers, "Sandman")
addToggle(pPlayers, { Text="Sandman Speed", Flag="sandman_slide", Callback=function(on) SandmanSlide.setEnabled(on); notify("Sandman: " .. (on and "ON" or "OFF")) end })
addSlider(pPlayers, { Flag="sandman_slide_speed", Text="Speed (1-10)", Min=1, Max=10, Requires="sandman_slide", Callback=function(v) end })

local pMisc = createTab("Misc")
addSectionHeader(pMisc, "Optimization")
addToggle(pMisc, { Text="Best Settings", Flag="best_settings", Callback=function(on) BestSettings.setEnabled(on); notify("Best Settings: " .. (on and "ON" or "OFF")) end })
addSectionHeader(pMisc, "Safe Water Bomb")
addToggle(pMisc, { Text="Safe Water Bomb", Flag="platform_safe", Callback=function(on) PlatformSafe.setEnabled(on); notify("Safe Water Bomb: " .. (on and "ON" or "OFF")) end })
addSectionHeader(pMisc, "Automation")
addToggle(pMisc, { Text="Auto Reload", Flag="auto_reload", Callback=function(on) AutoReload.setEnabled(on); notify("Auto Reload: " .. (on and "ON" or "OFF")) end })
addSlider(pMisc, { Flag="reload_interval", Text="Reload Interval (s)", Min=0.5, Max=10, Decimals=2, Requires="auto_reload", Callback=function(v) end })
addToggle(pMisc, { Text="Auto Spin", Flag="auto_spin", Callback=function(on) AutoSpin.setEnabled(on); notify("Auto Spin: " .. (on and "ON" or "OFF")) end })
addSlider(pMisc, { Flag="spin_interval", Text="Spin Delay (s)", Min=0.5, Max=10, Decimals=1, Requires="auto_spin", Callback=function(v) end })
addToggle(pMisc, { Text="Auto Mount", Flag="auto_mount", Callback=function(on) AutoMount.setEnabled(on); notify("Auto Mount: " .. (on and "ON" or "OFF")) end })
addSlider(pMisc, { Flag="auto_mount_interval", Text="Mount Delay (s)", Min=1, Max=5, Decimals=1, Requires="auto_mount", Callback=function(v) end })
addToggle(pMisc, { Text="Auto Join Queue", Flag="auto_join_queue", Keybind="kb_auto_join_queue", Callback=function(on, viaKeybind) AutoJoinQueue.setEnabled(on) end })
addSectionHeader(pMisc, "Codes")
addButtons(pMisc, {{ Text = "REDEEM ALL CODES", Callback = function() RedeemCodes.execute() end }})

local pSettings = createTab("Settings")
addSectionHeader(pSettings, "Keybind")
addKeybind(pSettings, "keybind", "Toggle UI Key", function(k) notify("Keybind: " .. k) end)
addSectionHeader(pSettings, "Config Files")
local nameBox = addTextbox(pSettings, { Text="Config Name", Placeholder="Enter preset name..." })
local selectedDD, autoToggle
local current_config = tostring(Options.last_selected_config or "")
local function refreshConfigs() local l = { "None" }; for _, n in ipairs(Storage.list()) do table.insert(l, n) end; if selectedDD and selectedDD.refresh then selectedDD.refresh() end; return #l - 1 end
selectedDD = addDropdown(pSettings, "Selected Config", { flag="last_selected_config", getOptions=function() local t = { "None" }; for _, v in ipairs(Storage.list()) do table.insert(t, v) end; return t end, get=function() return current_config end, set=function(v) current_config = v; setOption("last_selected_config", v); if Options.auto_load_config then Storage.setAuto(v) end end })
local function applyToUI(a) local delay = 0; for k, _ in pairs(a) do if k ~= "auto_load_config" and k ~= "last_selected_config" and Registry[k] then local opts = Options[k]; task.delay(delay, function() if alive and Registry[k] then pcall(Registry[k], opts) end end); delay += 0.05 end end end
addButtons(pSettings, {
    { Text="Create Config", Callback=function() local name = sanitize(nameBox.Get()); if name == "" then notify("Enter a name"); return end; if Storage.exists(name) then notify("'" .. name .. "' already exists"); return end; if Storage.write(name, serializeOptions()) then nameBox.Set(""); refreshConfigs(); current_config = name; setOption("last_selected_config", name); selectedDD.refresh(); notify("Created '" .. name .. "'") else notify("Failed") end end },
    { Text="Save Config", Callback=function() if current_config == "None" or current_config == "" then notify("Select a config"); return end; if Storage.write(current_config, serializeOptions()) then notify("Saved '" .. current_config .. "'") else notify("Failed") end end },
})
addButtons(pSettings, {
    { Text="Load Config", Callback=function() if current_config == "None" or current_config == "" then notify("Select a config"); return end; local d = Storage.read(current_config); if not d then notify("Cannot read"); return end; local a = deserializeOptions(d); applyToUI(a); notify("Loaded '" .. current_config .. "'") end },
    { Text="Delete Config", Callback=function() if current_config == "None" or current_config == "" then notify("Select a config"); return end; if Storage.delete(current_config) then if Storage.getAuto() == current_config then Storage.setAuto(nil); if Registry["auto_load_config"] then Registry["auto_load_config"](false) end end; current_config = "None"; setOption("last_selected_config", "None"); refreshConfigs(); selectedDD.refresh(); notify("Deleted") else notify("Failed") end end },
})
addButtons(pSettings, {{ Text="Refresh Configs", Callback=function() local n = refreshConfigs(); notify("Found " .. n .. " config(s)") end }})
autoToggle = addToggle(pSettings, { Text="Auto Load Config", Flag="auto_load_config", Callback=function(on) if on then if current_config == "None" or current_config == "" then notify("Select a config"); Registry["auto_load_config"](false); return end; Storage.setAuto(current_config); notify("Auto load: " .. current_config) else Storage.setAuto(nil); notify("Auto load off") end end })

makeDraggable(topBar, main)
local bBtn = create("TextButton", { Name="RestoreButton", Size=UDim2.new(0,MIN_SIZE,0,MIN_SIZE), BackgroundColor3=THEME.Window, BorderSizePixel=0, AutoButtonColor=false, Font=FONT_B, Text="B", TextColor3=THEME.Text, TextSize=20, Visible=false, Position=UDim2.new(0,10,0.5,-MIN_SIZE/2), ZIndex=30 }, gui)
stroke(bBtn, THEME.BoxStroke, 1)
local minimized = false
local function minimize() if not alive or minimized then return end; minimized = true; closePopup(); topBar.Visible = false; body.Visible = false; main.Visible = false; bBtn.Visible = true end
local function restore() if not alive or not minimized then return end; minimized = false; bBtn.Visible = false; main.Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2); main.Visible = true; topBar.Visible = true; body.Visible = true end
minimizeBtn.MouseButton1Click:Connect(minimize)
makeDraggable(bBtn, bBtn, restore)

UserInputService.InputBegan:Connect(function(input, processed)
    if not alive or processed or keyCapturing then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode.Name == tostring(Options.keybind or "RightShift") then
        gui.Enabled = not gui.Enabled
        pcall(function() SilentAim.updateCircle() end)
        return
    end
    for kbFlag, callback in pairs(KeybindCallbacks) do
        if Options[kbFlag] and Options[kbFlag] ~= "None" and Options[kbFlag] == input.KeyCode.Name then callback(); break end
    end
end)

selectTab("Main")
refreshConfigs()
do
    local a = Storage.getAuto()
    if a and Storage.exists(a) then
        local d = Storage.read(a)
        if d then
            current_config = a; selectedDD.refresh(); local applied = deserializeOptions(d)
            for k, _ in pairs(applied) do if Registry[k] then pcall(Registry[k], Options[k]) end end
            if autoToggle then Options["auto_load_config"] = true; autoToggle.Set(true); Storage.setAuto(a) end
            notify("Auto loaded '" .. a .. "'")
        end
    end
end

if Options.silent_aim then task.wait(0.1); if Registry["silent_aim"] then Registry["silent_aim"](true) end end
if Options.auto_attack then task.wait(0.1); if Registry["auto_attack"] then Registry["auto_attack"](true) end end
if Options.auto_block then task.wait(0.1); if Registry["auto_block"] then Registry["auto_block"](true) end end
if Options.range_view then task.wait(0.1); if Registry["range_view"] then Registry["range_view"](true) end end
if Options.summon_stand then task.wait(0.1); if Registry["summon_stand"] then Registry["summon_stand"](true) end end
if Options.auto_reload then task.wait(0.1); if Registry["auto_reload"] then Registry["auto_reload"](true) end end
if Options.auto_spin then task.wait(0.1); if Registry["auto_spin"] then Registry["auto_spin"](true) end end
if Options.platform_safe then task.wait(0.1); if Registry["platform_safe"] then Registry["platform_safe"](true) end end
if Options.aim_toggle then task.wait(0.1); if Registry["aim_toggle"] then Registry["aim_toggle"](true) end end
if Options.aimcam_toggle then task.wait(0.1); if Registry["aimcam_toggle"] then Registry["aimcam_toggle"](true) end end
if Options.cactus_remove then task.wait(0.1); if Registry["cactus_remove"] then Registry["cactus_remove"](true) end end
if Options.remove_tree then task.wait(0.1); if Registry["remove_tree"] then Registry["remove_tree"](true) end end
if Options.remove_mini_rocks then task.wait(0.1); if Registry["remove_mini_rocks"] then Registry["remove_mini_rocks"](true) end end
if Options.horse_speed_toggle then task.wait(0.1); if Registry["horse_speed_toggle"] then Registry["horse_speed_toggle"](true) end end
if Options.esp_master then task.wait(0.1); if Registry["esp_master"] then Registry["esp_master"](true) end end
if Options.esp_stand then task.wait(0.1); if Registry["esp_stand"] then Registry["esp_stand"](true) end end
if Options.esp_highlight then task.wait(0.1); if Registry["esp_highlight"] then Registry["esp_highlight"](true) end end
if Options.esp_name then task.wait(0.1); if Registry["esp_name"] then Registry["esp_name"](true) end end
if Options.esp_box then task.wait(0.1); if Registry["esp_box"] then Registry["esp_box"](true) end end
if Options.esp_horse then task.wait(0.1); if Registry["esp_horse"] then Registry["esp_horse"](true) end end
if Options.esp_waypoints then task.wait(0.1); if Registry["esp_waypoints"] then Registry["esp_waypoints"](true) end end
if Options.low_graphics then task.wait(0.1); if Registry["low_graphics"] then Registry["low_graphics"](true) end end
if Options.sandman_slide then task.wait(0.1); if Registry["sandman_slide"] then Registry["sandman_slide"](true) end end
if Options.best_settings then task.wait(0.1); if Registry["best_settings"] then Registry["best_settings"](true) end end
if Options.auto_mount then task.wait(0.1); if Registry["auto_mount"] then Registry["auto_mount"](true) end end
if Options.dash_nocooldown then task.wait(0.1); if Registry["dash_nocooldown"] then Registry["dash_nocooldown"](true) end end
if Options.auto_join_queue then task.wait(0.1); if Registry["auto_join_queue"] then Registry["auto_join_queue"](true) end end
if Options.side_dash then task.wait(0.1); if Registry["side_dash"] then Registry["side_dash"](true,true) end; if Options.side_dash_range_view then task.wait(0.1); if Registry["side_dash_range_view"] then Registry["side_dash_range_view"](true) end end end
if Options.esp_arrow then task.wait(0.1); if Registry["esp_arrow"] then Registry["esp_arrow"](true) end end
if Options.esp_arrow_fragment then task.wait(0.1); if Registry["esp_arrow_fragment"] then Registry["esp_arrow_fragment"](true) end end
if Options.esp_arrow_bandage then task.wait(0.1); if Registry["esp_arrow_bandage"] then Registry["esp_arrow_bandage"](true) end end
if Options.esp_arrow_rokakaka then task.wait(0.1); if Registry["esp_arrow_rokakaka"] then Registry["esp_arrow_rokakaka"](true) end end
if Options.esp_arrow_exit then task.wait(0.1); if Registry["esp_arrow_exit"] then Registry["esp_arrow_exit"](true) end end
if Options.auto_key then task.wait(0.1); if Registry["auto_key"] then Registry["auto_key"](true) end end
if Options.key_esp then task.wait(0.1); if Registry["key_esp"] then Registry["key_esp"](true) end end
if Options.auto_bandage then task.wait(0.1); if Registry["auto_bandage"] then Registry["auto_bandage"](true) end end

genv.BabisUnload = function()
    if not alive then return end
    alive = false
    pcall(function() SilentAim.destroy() end)
    pcall(function() AutoAttack.setEnabled(false) end)
    pcall(function() AutoBlock.setEnabled(false) end)
    pcall(function() RangeView.setEnabled(false) end)
    pcall(function() RangeView.destroy() end)
    pcall(function() AutoSummonStand.setEnabled(false) end)
    pcall(function() AutoReload.setEnabled(false) end)
    pcall(function() AutoSpin.setEnabled(false) end)
    pcall(function() PlatformSafe.setEnabled(false) end)
    pcall(function() BestSettings.setEnabled(false) end)
    pcall(function() AutoMount.setEnabled(false) end)
    pcall(function() AutoJoinQueue.setEnabled(false) end)
    pcall(function() NoDashCooldown.setEnabled(false) end)
    pcall(function() stopAiming() end)
    pcall(function() stopCamLock() end)
    pcall(function() CactusRemove.setEnabled(false) end)
    pcall(function() TreesRemove.setEnabled(false) end)
    pcall(function() MiniRocksRemove.setEnabled(false) end)
    pcall(function() HorseSpeed.setEnabled(false) end)
    pcall(function() SandmanSlide.destroy() end)
    pcall(function() EspSuite.destroy() end)
    pcall(function() EspHorse.destroy() end)
    pcall(function() EspWaypoints.destroy() end)
    pcall(function() LowGraphics.destroy() end)
    pcall(function() SideDash.setEnabled(false) end)
    pcall(function() SideDash.destroy() end)
    pcall(function() ArrowESP.destroy() end)
    pcall(function() AutoPickKey.destroy() end)
    pcall(function() ESPKey.destroy() end)
    pcall(function() AutoBandage.setEnabled(false) end)
    pcall(function() AntiKick.uninstall() end)
    pcall(function() Destroyer.stop() end)
    pcall(function() if genv.ANON_TOPNOTIF_CLEANUP then genv.ANON_TOPNOTIF_CLEANUP() end end)
    pcall(function() gui:Destroy() end)
    genv.BabisUnload = nil
end

local teleportConn = nil
local teleportConnectOK, teleportConnectResult = pcall(function()
    return player.OnTeleport:Connect(function(teleportState)
        if teleportState == Enum.TeleportState.Started then
            local unload = genv.BabisUnload
            if type(unload) == "function" then
                local ok, err = pcall(unload)
                if not ok then warn("[Babis] Teleport cleanup error: " .. tostring(err)) end
            else
                pcall(function() gui:Destroy() end)
            end
        end
    end)
end)

if teleportConnectOK then
    teleportConn = teleportConnectResult
else
    warn("[Babis] Could not connect Player.OnTeleport: " .. tostring(teleportConnectResult))
end

genv.Babis = {
    Options   = Options,
    Notify    = function(t) return genv.ANON_Notify and genv.ANON_Notify(t) end,
    GUI       = genv.BabisHub,
    Unload    = function() return genv.BabisUnload and genv.BabisUnload() end,
    GetOption = function(k) return Options[k] end,
    SetOption = function(k, v) setOption(k, v) end,
    Toggle    = function(k, v) if Registry[k] then Registry[k](v == true) end end,
    Registry  = Registry,
    Version   = "1.0.1",
}

return genv.Babis

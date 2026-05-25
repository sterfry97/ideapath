-- IdeaPath UI Library v2.0
-- Usage: local IdeaPath = loadstring(game:HttpGet("https://raw.githubusercontent.com/sterfry97/ideapath/main/main.lua"))()

local IdeaPath = {}
IdeaPath.__index = IdeaPath

---------------------------------------------------------------------------
-- Services
---------------------------------------------------------------------------
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UIS             = game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")
local LP              = Players.LocalPlayer

---------------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------------
local T = {
    Bg          = Color3.fromRGB(12, 12, 18),
    Panel       = Color3.fromRGB(18, 18, 26),
    Card        = Color3.fromRGB(23, 23, 33),
    CardHover   = Color3.fromRGB(28, 28, 40),
    Border      = Color3.fromRGB(38, 38, 58),
    Accent      = Color3.fromRGB(108, 152, 255),
    AccentGlow  = Color3.fromRGB(80, 120, 255),
    AccentDim   = Color3.fromRGB(55, 85, 190),
    Text        = Color3.fromRGB(225, 225, 238),
    TextSub     = Color3.fromRGB(120, 120, 150),
    TextDim     = Color3.fromRGB(65, 65, 90),
    Success     = Color3.fromRGB(72, 199, 116),
    Warning     = Color3.fromRGB(255, 180, 50),
    Danger      = Color3.fromRGB(255, 72, 72),
    White       = Color3.fromRGB(255, 255, 255),
}

---------------------------------------------------------------------------
-- Utility helpers
---------------------------------------------------------------------------
local function tw(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Corner(r, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function Stroke(color, thick, parent)
    local s = Instance.new("UIStroke")
    s.Color = color or T.Border
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Pad(l, r, t, b, parent)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

local function List(pad, sort, fill, align, parent)
    local l = Instance.new("UIListLayout")
    l.Padding               = UDim.new(0, pad or 0)
    l.SortOrder             = sort or Enum.SortOrder.LayoutOrder
    l.FillDirection         = fill or Enum.FillDirection.Vertical
    if align then l.HorizontalAlignment = align end
    l.Parent = parent
    return l
end

local function Draggable(frame, handle)
    handle = handle or frame
    local drag, start, origin
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; start = i.Position; origin = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)
end

-- destroy old gui
for _, name in ipairs({"IdeaPathGUI"}) do
    pcall(function() CoreGui[name]:Destroy() end)
    pcall(function() LP.PlayerGui[name]:Destroy() end)
end

---------------------------------------------------------------------------
-- LOADING SCREEN
---------------------------------------------------------------------------
local function ShowLoader(screenGui, title, subtitle, onDone)
    local W, H = 340, 200

    local Overlay = New("Frame", {
        Name             = "Loader",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Bg,
        BorderSizePixel  = 0,
        Position         = UDim2.fromScale(0.5, 0.5),
        Size             = UDim2.new(0, W, 0, H),
        ZIndex           = 100,
        Parent           = screenGui,
    })
    Corner(14, Overlay)
    Stroke(T.Border, 1, Overlay)

    -- glow bar at top
    New("Frame", {
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 2),
        ZIndex           = 101,
        Parent           = Overlay,
    }, { Instance.new("UICorner") })

    -- logo icon (diamond shape via rotation)
    local IconWrap = New("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position         = UDim2.new(0.5, 0, 0, 28),
        Size             = UDim2.new(0, 36, 0, 36),
        ZIndex           = 101,
        Parent           = Overlay,
    })
    local IconBg = New("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Position         = UDim2.fromScale(0.5, 0.5),
        Rotation         = 45,
        Size             = UDim2.new(0, 22, 0, 22),
        ZIndex           = 101,
        Parent           = IconWrap,
    })
    Corner(4, IconBg)

    -- title
    New("TextLabel", {
        AnchorPoint            = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position               = UDim2.new(0.5, 0, 0, 74),
        Size                   = UDim2.new(1, -20, 0, 22),
        Font                   = Enum.Font.GothamBold,
        Text                   = title,
        TextColor3             = T.Text,
        TextSize               = 16,
        ZIndex                 = 101,
        Parent                 = Overlay,
    })

    -- subtitle
    New("TextLabel", {
        AnchorPoint            = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position               = UDim2.new(0.5, 0, 0, 98),
        Size                   = UDim2.new(1, -20, 0, 16),
        Font                   = Enum.Font.Gotham,
        Text                   = subtitle,
        TextColor3             = T.TextSub,
        TextSize               = 12,
        ZIndex                 = 101,
        Parent                 = Overlay,
    })

    -- progress track
    local Track = New("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5, 0, 0, 132),
        Size             = UDim2.new(1, -48, 0, 4),
        ZIndex           = 101,
        Parent           = Overlay,
    })
    Corner(4, Track)

    local Fill = New("Frame", {
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 0, 1, 0),
        ZIndex           = 102,
        Parent           = Track,
    })
    Corner(4, Fill)

    -- status label
    local StatusLabel = New("TextLabel", {
        AnchorPoint            = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position               = UDim2.new(0.5, 0, 0, 146),
        Size                   = UDim2.new(1, -20, 0, 14),
        Font                   = Enum.Font.Gotham,
        Text                   = "Initializing...",
        TextColor3             = T.TextDim,
        TextSize               = 11,
        ZIndex                 = 101,
        Parent                 = Overlay,
    })

    -- animate icon pulse
    local function PulseIcon()
        tw(IconBg, {BackgroundColor3 = Color3.fromRGB(140, 180, 255)}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.delay(0.5, function()
            tw(IconBg, {BackgroundColor3 = T.Accent}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        end)
    end

    -- progress sequence
    local steps = {
        {pct = 0.25, text = "Loading modules..."},
        {pct = 0.55, text = "Building interface..."},
        {pct = 0.80, text = "Applying theme..."},
        {pct = 1.00, text = "Ready!"},
    }

    task.spawn(function()
        -- entrance
        Overlay.BackgroundTransparency = 1
        tw(Overlay, {BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Quint)
        task.wait(0.2)

        for _, step in ipairs(steps) do
            PulseIcon()
            StatusLabel.Text = step.text
            tw(Fill, {Size = UDim2.new(step.pct, 0, 1, 0)}, 0.45, Enum.EasingStyle.Quint)
            task.wait(0.52)
        end

        task.wait(0.25)

        -- exit
        tw(Overlay, {BackgroundTransparency = 1, Size = UDim2.new(0, W, 0, 0)}, 0.4, Enum.EasingStyle.Quint)
        task.wait(0.42)
        Overlay:Destroy()
        onDone()
    end)
end

---------------------------------------------------------------------------
-- CreateWindow
---------------------------------------------------------------------------
function IdeaPath:CreateWindow(config)
    if type(config) == "string" then config = {Title = config} end
    config = config or {}

    local Title    = config.Title    or "IdeaPath"
    local Subtitle = config.Subtitle or "UI Library"
    local W        = 580
    local H        = 420
    local SideW    = 148

    -- ScreenGui
    local SG = New("ScreenGui", {
        Name           = "IdeaPathGUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    pcall(function() SG.Parent = CoreGui end)
    if not SG.Parent then SG.Parent = LP.PlayerGui end

    -- Window object returned to user
    local Win = {_tabs = {}, _active = nil, _sg = SG}

    -- Show loader first, then build main GUI
    ShowLoader(SG, Title, Subtitle, function()
        -----------------------------------------------------------------
        -- Main frame
        -----------------------------------------------------------------
        local Main = New("Frame", {
            Name             = "Main",
            AnchorPoint      = Vector2.new(0.5, 0.5),
            BackgroundColor3 = T.Bg,
            BorderSizePixel  = 0,
            Position         = UDim2.fromScale(0.5, 0.5),
            Size             = UDim2.new(0, 0, 0, 0),
            Parent           = SG,
        })
        Corner(12, Main)
        Stroke(T.Border, 1, Main)

        -- entrance animation
        tw(Main, {Size = UDim2.new(0, W, 0, H)}, 0.45, Enum.EasingStyle.Quint)

        -----------------------------------------------------------------
        -- Top bar (drag handle)
        -----------------------------------------------------------------
        local TopBar = New("Frame", {
            BackgroundColor3 = T.Panel,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, 0, 0, 46),
            Parent           = Main,
        })
        Corner(12, TopBar)
        -- fill bottom corners of topbar
        New("Frame", {
            BackgroundColor3 = T.Panel,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 0, 0.5, 0),
            Size             = UDim2.new(1, 0, 0.5, 0),
            Parent           = TopBar,
        })
        -- thin accent line under topbar
        New("Frame", {
            BackgroundColor3 = T.Border,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 0, 1, -1),
            Size             = UDim2.new(1, 0, 0, 1),
            Parent           = TopBar,
        })

        Draggable(Main, TopBar)

        -- diamond logo
        local LogoDiamond = New("Frame", {
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundColor3 = T.Accent,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 16, 0.5, 0),
            Rotation         = 45,
            Size             = UDim2.new(0, 14, 0, 14),
            Parent           = TopBar,
        })
        Corner(3, LogoDiamond)

        New("TextLabel", {
            AnchorPoint            = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 38, 0.5, -1),
            Size                   = UDim2.new(0, 200, 0, 18),
            Font                   = Enum.Font.GothamBold,
            Text                   = Title,
            TextColor3             = T.Text,
            TextSize               = 14,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = TopBar,
        })
        New("TextLabel", {
            AnchorPoint            = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 38, 0.5, 12),
            Size                   = UDim2.new(0, 200, 0, 14),
            Font                   = Enum.Font.Gotham,
            Text                   = Subtitle,
            TextColor3             = T.TextSub,
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = TopBar,
        })

        -- window controls (right side)
        local function WinBtn(offsetX, col)
            local b = New("TextButton", {
                AnchorPoint      = Vector2.new(1, 0.5),
                BackgroundColor3 = col,
                BorderSizePixel  = 0,
                Position         = UDim2.new(1, offsetX, 0.5, 0),
                Size             = UDim2.new(0, 12, 0, 12),
                Text             = "",
                Parent           = TopBar,
            })
            Corner(6, b)
            return b
        end
        local CloseBtn = WinBtn(-14, Color3.fromRGB(255, 90, 90))
        local MinBtn   = WinBtn(-32, Color3.fromRGB(255, 190, 50))

        CloseBtn.MouseButton1Click:Connect(function()
            tw(Main, {Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint)
            task.wait(0.32)
            SG:Destroy()
        end)

        local minimized = false
        MinBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            tw(Main, {Size = UDim2.new(0, W, 0, minimized and 46 or H)}, 0.3, Enum.EasingStyle.Quint)
        end)

        -----------------------------------------------------------------
        -- Left sidebar
        -----------------------------------------------------------------
        local Sidebar = New("Frame", {
            BackgroundColor3 = T.Panel,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 0, 0, 46),
            Size             = UDim2.new(0, SideW, 1, -46),
            Parent           = Main,
        })
        -- right edge hard corner fill (no rounding on right side)
        New("Frame", {
            BackgroundColor3 = T.Panel,
            BorderSizePixel  = 0,
            Position         = UDim2.new(1, -12, 0, 0),
            Size             = UDim2.new(0, 12, 1, 0),
            Parent           = Sidebar,
        })
        -- bottom-left corner
        Corner(12, Sidebar)
        -- separator line
        New("Frame", {
            BackgroundColor3 = T.Border,
            BorderSizePixel  = 0,
            Position         = UDim2.new(1, -1, 0, 0),
            Size             = UDim2.new(0, 1, 1, 0),
            Parent           = Sidebar,
        })

        local TabScroll = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0, 0, 0, 10),
            Size                   = UDim2.new(1, 0, 1, -10),
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 0,
            Parent                 = Sidebar,
        })
        List(3, nil, nil, nil, TabScroll)
        Pad(8, 8, 0, 8, TabScroll)

        -----------------------------------------------------------------
        -- Content area
        -----------------------------------------------------------------
        local Content = New("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0, SideW + 1, 0, 46),
            Size                   = UDim2.new(1, -(SideW + 1), 1, -46),
            ClipsDescendants       = true,
            Parent                 = Main,
        })

        -----------------------------------------------------------------
        -- Tab helper
        -----------------------------------------------------------------
        local function SetActive(tab, state)
            if state then
                tw(tab._btn, {BackgroundColor3 = T.CardHover, BackgroundTransparency = 0}, 0.15)
                tw(tab._lbl, {TextColor3 = T.Text}, 0.15)
                tw(tab._bar, {BackgroundTransparency = 0}, 0.15)
                tab._lbl.Font = Enum.Font.GothamBold
                tab._page.Visible = true
            else
                tw(tab._btn, {BackgroundTransparency = 1}, 0.15)
                tw(tab._lbl, {TextColor3 = T.TextSub}, 0.15)
                tw(tab._bar, {BackgroundTransparency = 1}, 0.15)
                tab._lbl.Font = Enum.Font.Gotham
                tab._page.Visible = false
            end
        end

        -----------------------------------------------------------------
        -- CreateTab
        -----------------------------------------------------------------
        function Win:CreateTab(name, icon)
            local Tab = {_name = name}

            -- sidebar button
            local Btn = New("TextButton", {
                BackgroundColor3       = T.CardHover,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 32),
                Text                   = "",
                Parent                 = TabScroll,
            })
            Corner(7, Btn)

            -- active bar
            local Bar = New("Frame", {
                BackgroundColor3       = T.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0, 0, 0.5, -10),
                Size                   = UDim2.new(0, 3, 0, 20),
                Parent                 = Btn,
            })
            Corner(3, Bar)

            -- icon label
            New("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 10, 0.5, -7),
                Size                   = UDim2.new(0, 14, 0, 14),
                Font                   = Enum.Font.Gotham,
                Text                   = icon or "•",
                TextColor3             = T.TextSub,
                TextSize               = 12,
                Parent                 = Btn,
            })

            -- name label
            local Lbl = New("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 28, 0.5, -7),
                Size                   = UDim2.new(1, -32, 0, 14),
                Font                   = Enum.Font.Gotham,
                Text                   = name,
                TextColor3             = T.TextSub,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = Btn,
            })

            -- content page
            local Page = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.fromScale(1, 1),
                CanvasSize             = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize    = Enum.AutomaticSize.Y,
                ScrollBarThickness     = 3,
                ScrollBarImageColor3   = T.Border,
                Visible                = false,
                Parent                 = Content,
            })
            List(6, nil, nil, nil, Page)
            Pad(12, 12, 10, 12, Page)

            Tab._btn  = Btn
            Tab._lbl  = Lbl
            Tab._bar  = Bar
            Tab._page = Page

            -- click
            Btn.MouseButton1Click:Connect(function()
                if Win._active then SetActive(Win._active, false) end
                Win._active = Tab
                SetActive(Tab, true)
            end)
            Btn.MouseEnter:Connect(function()
                if Win._active ~= Tab then
                    tw(Btn, {BackgroundTransparency = 0.7, BackgroundColor3 = T.CardHover}, 0.1)
                end
            end)
            Btn.MouseLeave:Connect(function()
                if Win._active ~= Tab then
                    tw(Btn, {BackgroundTransparency = 1}, 0.1)
                end
            end)

            -- first tab auto-selects
            if #Win._tabs == 0 then
                Win._active = Tab
                SetActive(Tab, true)
            end
            table.insert(Win._tabs, Tab)

            -- element order counter
            local order = 0
            local function O() order = order + 1; return order end

            -- card factory
            local function Card(h)
                local c = New("Frame", {
                    BackgroundColor3 = T.Card,
                    BorderSizePixel  = 0,
                    LayoutOrder      = O(),
                    Size             = UDim2.new(1, 0, 0, h or 42),
                    Parent           = Page,
                })
                Corner(8, c)
                Stroke(T.Border, 1, c)
                return c
            end

            ------------------------------------------------------------
            -- CreateSection
            ------------------------------------------------------------
            function Tab:CreateSection(name)
                local f = New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder            = O(),
                    Size                   = UDim2.new(1, 0, 0, 22),
                    Parent                 = Page,
                })
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size                   = UDim2.new(1, 0, 1, 0),
                    Font                   = Enum.Font.GothamBold,
                    Text                   = name:upper(),
                    TextColor3             = T.TextDim,
                    TextSize               = 10,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = f,
                })
                New("Frame", {
                    AnchorPoint      = Vector2.new(0, 0.5),
                    BackgroundColor3 = T.Border,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 1, -1),
                    Size             = UDim2.new(1, 0, 0, 1),
                    Parent           = f,
                })
            end

            ------------------------------------------------------------
            -- CreateButton
            ------------------------------------------------------------
            function Tab:CreateButton(config, callback)
                if type(config) == "string" then config = {Name = config} end
                callback = callback or function() end
                local hasDesc = config.Description ~= nil
                local c = Card(hasDesc and 56 or 42)

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, hasDesc and 9 or 0),
                    Size                   = UDim2.new(0.65, 0, 0, hasDesc and 18 or 42),
                    Font                   = Enum.Font.GothamBold,
                    Text                   = config.Name or "Button",
                    TextColor3             = T.Text,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = c,
                })
                if hasDesc then
                    New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position               = UDim2.new(0, 14, 0, 29),
                        Size                   = UDim2.new(0.7, 0, 0, 14),
                        Font                   = Enum.Font.Gotham,
                        Text                   = config.Description,
                        TextColor3             = T.TextSub,
                        TextSize               = 11,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        Parent                 = c,
                    })
                end

                local Pill = New("TextButton", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(1, -12, 0.5, 0),
                    Size             = UDim2.new(0, 64, 0, 26),
                    Font             = Enum.Font.GothamBold,
                    Text             = config.ButtonText or "Run",
                    TextColor3       = T.White,
                    TextSize         = 12,
                    Parent           = c,
                })
                Corner(7, Pill)

                Pill.MouseButton1Click:Connect(function()
                    tw(Pill, {BackgroundColor3 = T.AccentDim}, 0.08)
                    task.delay(0.18, function() tw(Pill, {BackgroundColor3 = T.Accent}, 0.15) end)
                    task.spawn(callback)
                end)
                Pill.MouseEnter:Connect(function() tw(Pill, {BackgroundColor3 = Color3.fromRGB(130, 170, 255)}, 0.1) end)
                Pill.MouseLeave:Connect(function() tw(Pill, {BackgroundColor3 = T.Accent}, 0.1) end)
            end

            ------------------------------------------------------------
            -- CreateToggle
            ------------------------------------------------------------
            function Tab:CreateToggle(config, callback)
                if type(config) == "string" then config = {Name = config} end
                callback = callback or function() end
                local state = config.Default or false
                local hasDesc = config.Description ~= nil
                local c = Card(hasDesc and 56 or 42)

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, hasDesc and 9 or 0),
                    Size                   = UDim2.new(0.7, 0, 0, hasDesc and 18 or 42),
                    Font                   = Enum.Font.GothamBold,
                    Text                   = config.Name or "Toggle",
                    TextColor3             = T.Text,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = c,
                })
                if hasDesc then
                    New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position               = UDim2.new(0, 14, 0, 29),
                        Size                   = UDim2.new(0.7, 0, 0, 14),
                        Font                   = Enum.Font.Gotham,
                        Text                   = config.Description,
                        TextColor3             = T.TextSub,
                        TextSize               = 11,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        Parent                 = c,
                    })
                end

                local Track = New("Frame", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    BackgroundColor3 = state and T.Accent or T.Border,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(1, -14, 0.5, 0),
                    Size             = UDim2.new(0, 38, 0, 20),
                    Parent           = c,
                })
                Corner(10, Track)

                local Knob = New("Frame", {
                    AnchorPoint      = Vector2.new(0, 0.5),
                    BackgroundColor3 = T.White,
                    BorderSizePixel  = 0,
                    Position         = state and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    Size             = UDim2.new(0, 16, 0, 16),
                    Parent           = Track,
                })
                Corner(8, Knob)

                local Hitbox = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size                   = UDim2.fromScale(1, 1),
                    Text                   = "",
                    Parent                 = c,
                })
                Hitbox.MouseButton1Click:Connect(function()
                    state = not state
                    if state then
                        tw(Track, {BackgroundColor3 = T.Accent}, 0.18)
                        tw(Knob, {Position = UDim2.new(0, 20, 0.5, 0)}, 0.18, Enum.EasingStyle.Quint)
                    else
                        tw(Track, {BackgroundColor3 = T.Border}, 0.18)
                        tw(Knob, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.18, Enum.EasingStyle.Quint)
                    end
                    task.spawn(callback, state)
                end)

                local obj = {}
                function obj:Set(v)
                    state = v
                    Track.BackgroundColor3 = v and T.Accent or T.Border
                    Knob.Position = v and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                    callback(state)
                end
                function obj:Get() return state end
                return obj
            end

            ------------------------------------------------------------
            -- CreateSlider
            ------------------------------------------------------------
            function Tab:CreateSlider(config, callback)
                if type(config) == "string" then config = {Name = config} end
                callback = callback or function() end
                local mn   = config.Min     or 0
                local mx   = config.Max     or 100
                local val  = config.Default or mn
                local step = config.Step    or 1
                local hasDesc = config.Description ~= nil
                local c = Card(hasDesc and 64 or 52)

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, 9),
                    Size                   = UDim2.new(0.65, 0, 0, 15),
                    Font                   = Enum.Font.GothamBold,
                    Text                   = config.Name or "Slider",
                    TextColor3             = T.Text,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = c,
                })
                local ValLbl = New("TextLabel", {
                    AnchorPoint            = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(1, -14, 0, 9),
                    Size                   = UDim2.new(0, 55, 0, 15),
                    Font                   = Enum.Font.GothamBold,
                    Text                   = tostring(val),
                    TextColor3             = T.Accent,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    Parent                 = c,
                })
                if hasDesc then
                    New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position               = UDim2.new(0, 14, 0, 26),
                        Size                   = UDim2.new(0.8, 0, 0, 12),
                        Font                   = Enum.Font.Gotham,
                        Text                   = config.Description,
                        TextColor3             = T.TextSub,
                        TextSize               = 11,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        Parent                 = c,
                    })
                end

                local ty = hasDesc and 42 or 33
                local TrBg = New("Frame", {
                    BackgroundColor3 = T.Border,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 14, 0, ty),
                    Size             = UDim2.new(1, -28, 0, 5),
                    Parent           = c,
                })
                Corner(4, TrBg)

                local pct = (val - mn) / (mx - mn)
                local FillF = New("Frame", {
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel  = 0,
                    Size             = UDim2.new(pct, 0, 1, 0),
                    Parent           = TrBg,
                })
                Corner(4, FillF)

                local KnobF = New("Frame", {
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = T.White,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(pct, 0, 0.5, 0),
                    Size             = UDim2.new(0, 13, 0, 13),
                    ZIndex           = 3,
                    Parent           = TrBg,
                })
                Corner(7, KnobF)
                Stroke(T.Accent, 2, KnobF)

                local sliding = false
                TrBg.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
                end)
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                UIS.InputChanged:Connect(function(i)
                    if not sliding or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    local rel = math.clamp((i.Position.X - TrBg.AbsolutePosition.X) / TrBg.AbsoluteSize.X, 0, 1)
                    val = math.clamp(math.round((mn + rel * (mx - mn)) / step) * step, mn, mx)
                    local np = (val - mn) / (mx - mn)
                    FillF.Size     = UDim2.new(np, 0, 1, 0)
                    KnobF.Position = UDim2.new(np, 0, 0.5, 0)
                    ValLbl.Text    = tostring(val)
                    task.spawn(callback, val)
                end)

                local obj = {}
                function obj:Set(v)
                    val = math.clamp(v, mn, mx)
                    local np = (val - mn) / (mx - mn)
                    FillF.Size     = UDim2.new(np, 0, 1, 0)
                    KnobF.Position = UDim2.new(np, 0, 0.5, 0)
                    ValLbl.Text    = tostring(val)
                    callback(val)
                end
                function obj:Get() return val end
                return obj
            end

            ------------------------------------------------------------
            -- CreateInput
            ------------------------------------------------------------
            function Tab:CreateInput(config, callback)
                if type(config) == "string" then config = {Name = config} end
                callback = callback or function() end
                local hasDesc = config.Description ~= nil
                local c = Card(hasDesc and 68 or 56)

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, 8),
                    Size                   = UDim2.new(1, -28, 0, 15),
                    Font                   = Enum.Font.GothamBold,
                    Text                   = config.Name or "Input",
                    TextColor3             = T.Text,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = c,
                })
                if hasDesc then
                    New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position               = UDim2.new(0, 14, 0, 24),
                        Size                   = UDim2.new(1, -28, 0, 12),
                        Font                   = Enum.Font.Gotham,
                        Text                   = config.Description,
                        TextColor3             = T.TextSub,
                        TextSize               = 11,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        Parent                 = c,
                    })
                end

                local iy = hasDesc and 38 or 26
                local Box = New("TextBox", {
                    BackgroundColor3  = T.Bg,
                    BorderSizePixel   = 0,
                    ClearTextOnFocus  = config.ClearOnFocus ~= false,
                    Font              = Enum.Font.Gotham,
                    PlaceholderColor3 = T.TextDim,
                    PlaceholderText   = config.Placeholder or "Type here...",
                    Position          = UDim2.new(0, 14, 0, iy),
                    Size              = UDim2.new(1, -28, 0, 22),
                    Text              = config.Default or "",
                    TextColor3        = T.Text,
                    TextSize          = 12,
                    Parent            = c,
                })
                Corner(6, Box)
                Stroke(T.Border, 1, Box)
                Pad(8, 0, 0, 0, Box)

                Box.Focused:Connect(function() tw(Box, {}, 0.1) end) -- border highlight via stroke color change would need direct ref
                Box.FocusLost:Connect(function(enter)
                    if enter then task.spawn(callback, Box.Text) end
                end)
                if config.FireOnChange then
                    Box:GetPropertyChangedSignal("Text"):Connect(function() task.spawn(callback, Box.Text) end)
                end

                local obj = {}
                function obj:Set(v) Box.Text = v end
                function obj:Get() return Box.Text end
                return obj
            end

            ------------------------------------------------------------
            -- CreateDropdown
            ------------------------------------------------------------
            function Tab:CreateDropdown(config, callback)
                if type(config) == "string" then config = {Name = config, Options = {}} end
                callback = callback or function() end
                local opts     = config.Options or {}
                local selected = config.Default or opts[1] or "Select..."
                local open     = false
                local c = Card(42)

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0.5, -8),
                    Size                   = UDim2.new(0.48, 0, 0, 16),
                    Font                   = Enum.Font.GothamBold,
                    Text                   = config.Name or "Dropdown",
                    TextColor3             = T.Text,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = c,
                })

                local DropBtn = New("TextButton", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    BackgroundColor3 = T.Bg,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(1, -12, 0.5, 0),
                    Size             = UDim2.new(0, 136, 0, 24),
                    Font             = Enum.Font.Gotham,
                    Text             = selected .. "  ▾",
                    TextColor3       = T.Text,
                    TextSize         = 12,
                    Parent           = c,
                })
                Corner(6, DropBtn)
                Stroke(T.Border, 1, DropBtn)

                local menuH = math.min(#opts, 6) * 28
                local Menu = New("Frame", {
                    AnchorPoint      = Vector2.new(1, 0),
                    BackgroundColor3 = T.Panel,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    Position         = UDim2.new(1, -12, 1, 4),
                    Size             = UDim2.new(0, 136, 0, 0),
                    ZIndex           = 20,
                    Parent           = c,
                })
                Corner(7, Menu)
                Stroke(T.Border, 1, Menu)
                List(0, nil, nil, nil, Menu)

                for i, opt in ipairs(opts) do
                    local ob = New("TextButton", {
                        BackgroundColor3       = T.Panel,
                        BackgroundTransparency = 0,
                        BorderSizePixel        = 0,
                        LayoutOrder            = i,
                        Size                   = UDim2.new(1, 0, 0, 28),
                        Font                   = Enum.Font.Gotham,
                        Text                   = opt,
                        TextColor3             = T.TextSub,
                        TextSize               = 12,
                        ZIndex                 = 21,
                        Parent                 = Menu,
                    })
                    ob.MouseEnter:Connect(function() tw(ob, {BackgroundColor3 = T.CardHover, TextColor3 = T.Text}, 0.1) end)
                    ob.MouseLeave:Connect(function() tw(ob, {BackgroundColor3 = T.Panel, TextColor3 = T.TextSub}, 0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        selected = opt
                        DropBtn.Text = selected .. "  ▾"
                        open = false
                        tw(Menu, {Size = UDim2.new(0, 136, 0, 0)}, 0.15, Enum.EasingStyle.Quint)
                        tw(c, {Size = UDim2.new(1, 0, 0, 42)}, 0.15, Enum.EasingStyle.Quint)
                        task.spawn(callback, selected)
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        tw(Menu, {Size = UDim2.new(0, 136, 0, menuH)}, 0.2, Enum.EasingStyle.Quint)
                        tw(c, {Size = UDim2.new(1, 0, 0, 42 + menuH + 6)}, 0.2, Enum.EasingStyle.Quint)
                    else
                        tw(Menu, {Size = UDim2.new(0, 136, 0, 0)}, 0.15, Enum.EasingStyle.Quint)
                        tw(c, {Size = UDim2.new(1, 0, 0, 42)}, 0.15, Enum.EasingStyle.Quint)
                    end
                end)

                local obj = {}
                function obj:Set(v) selected = v; DropBtn.Text = v .. "  ▾"; callback(v) end
                function obj:Get() return selected end
                return obj
            end

            ------------------------------------------------------------
            -- CreateLabel
            ------------------------------------------------------------
            function Tab:CreateLabel(text)
                local c = Card(34)
                local lbl = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0.5, -7),
                    Size                   = UDim2.new(1, -28, 0, 14),
                    Font                   = Enum.Font.Gotham,
                    Text                   = text or "",
                    TextColor3             = T.TextSub,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = c,
                })
                local obj = {}
                function obj:Set(v) lbl.Text = v end
                function obj:Get() return lbl.Text end
                return obj
            end

            ------------------------------------------------------------
            -- CreateSeparator
            ------------------------------------------------------------
            function Tab:CreateSeparator()
                New("Frame", {
                    BackgroundColor3 = T.Border,
                    BorderSizePixel  = 0,
                    LayoutOrder      = O(),
                    Size             = UDim2.new(1, 0, 0, 1),
                    Parent           = Page,
                })
            end

            return Tab
        end

        -----------------------------------------------------------------
        -- Notify
        -----------------------------------------------------------------
        function Win:Notify(config)
            if type(config) == "string" then config = {Title = config} end
            local title    = config.Title    or "Notification"
            local body     = config.Content  or ""
            local duration = config.Duration or 4
            local tColors  = {info = T.Accent, success = T.Success, warning = T.Warning, danger = T.Danger}
            local accent   = tColors[config.Type or "info"] or T.Accent

            local NH = SG:FindFirstChild("_NH")
            if not NH then
                NH = New("Frame", {
                    Name                   = "_NH",
                    AnchorPoint            = Vector2.new(1, 1),
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(1, -14, 1, -14),
                    Size                   = UDim2.new(0, 280, 1, 0),
                    Parent                 = SG,
                })
                List(8, nil, nil, nil, NH)
                local l = NH:FindFirstChildOfClass("UIListLayout")
                if l then l.VerticalAlignment = Enum.VerticalAlignment.Bottom end
            end

            local hasBody = body ~= ""
            local nh = hasBody and 62 or 42
            local N = New("Frame", {
                BackgroundColor3       = T.Panel,
                BackgroundTransparency = 0.06,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, nh),
                Parent                 = NH,
            })
            Corner(9, N)
            Stroke(T.Border, 1, N)

            New("Frame", {
                BackgroundColor3 = accent,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 3, 1, 0),
                Parent           = N,
            }, {Corner(3, Instance.new("Frame"))}) -- corner applied below
            local bar = N:FindFirstChildOfClass("Frame")
            if bar then Corner(3, bar) end

            New("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 12, 0, hasBody and 9 or 0),
                Size                   = UDim2.new(1, -16, 0, hasBody and 16 or nh),
                Font                   = Enum.Font.GothamBold,
                Text                   = title,
                TextColor3             = T.Text,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = N,
            })
            if hasBody then
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 12, 0, 27),
                    Size                   = UDim2.new(1, -16, 0, 26),
                    Font                   = Enum.Font.Gotham,
                    Text                   = body,
                    TextColor3             = T.TextSub,
                    TextSize               = 11,
                    TextWrapped            = true,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = N,
                })
            end

            -- slide in
            N.Position = UDim2.new(1, 20, 1, 0) -- start off-screen right
            tw(N, {Position = UDim2.new(0, 0, 1, 0)}, 0.3, Enum.EasingStyle.Quint)

            task.delay(duration, function()
                tw(N, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.22)
                task.wait(0.25)
                pcall(function() N:Destroy() end)
            end)
        end

        function Win:Destroy()
            tw(Main, {Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint)
            task.wait(0.35)
            pcall(function() SG:Destroy() end)
        end

    end) -- end ShowLoader callback

    return Win
end

return IdeaPath

-- IdeaPath UI Library v1.0
-- A Rayfield-inspired Roblox UI Library
-- Usage: local IdeaPath = loadstring(game:HttpGet("RAW_URL"))()

local IdeaPath = {}
IdeaPath.__index = IdeaPath

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme
local Theme = {
    Background     = Color3.fromRGB(15, 15, 20),
    Surface        = Color3.fromRGB(22, 22, 30),
    SurfaceAlt     = Color3.fromRGB(28, 28, 38),
    Border         = Color3.fromRGB(45, 45, 65),
    Accent         = Color3.fromRGB(100, 140, 255),
    AccentDark     = Color3.fromRGB(60, 90, 200),
    Text           = Color3.fromRGB(230, 230, 240),
    TextMuted      = Color3.fromRGB(130, 130, 155),
    TextDim        = Color3.fromRGB(80, 80, 100),
    Success        = Color3.fromRGB(80, 200, 120),
    Warning        = Color3.fromRGB(255, 185, 60),
    Danger         = Color3.fromRGB(255, 80, 80),
    White          = Color3.fromRGB(255, 255, 255),
}

-- Utility
local function Tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local ti = TweenInfo.new(duration or 0.2, style, direction)
    TweenService:Create(obj, ti, props):Play()
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Remove old GUI if exists
pcall(function()
    if CoreGui:FindFirstChild("IdeaPathGUI") then
        CoreGui:FindFirstChild("IdeaPathGUI"):Destroy()
    end
end)
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("IdeaPathGUI") then
        LocalPlayer.PlayerGui:FindFirstChild("IdeaPathGUI"):Destroy()
    end
end)

----------------------------------------------------------------------
-- CreateWindow
----------------------------------------------------------------------
function IdeaPath:CreateWindow(config)
    if type(config) == "string" then
        config = { Title = config }
    end
    config = config or {}
    local Title    = config.Title    or "IdeaPath"
    local Subtitle = config.Subtitle or "UI Library"
    local Width    = config.Width    or 560
    local Height   = config.Height   or 400

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name             = "IdeaPathGUI",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset   = true,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer.PlayerGui
    end

    -- Drop shadow
    local Shadow = Create("ImageLabel", {
        Name              = "Shadow",
        AnchorPoint       = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position          = UDim2.fromScale(0.5, 0.5),
        Size              = UDim2.new(0, Width + 40, 0, Height + 40),
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        Parent            = ScreenGui,
    })

    -- Main frame
    local Main = Create("Frame", {
        Name            = "Main",
        AnchorPoint     = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position        = UDim2.fromScale(0.5, 0.5),
        Size            = UDim2.new(0, Width, 0, Height),
        Parent          = ScreenGui,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
        }),
    })
    MakeDraggable(Main)
    -- sync shadow position
    Main:GetPropertyChangedSignal("Position"):Connect(function()
        Shadow.Position = UDim2.new(
            Main.Position.X.Scale,
            Main.Position.X.Offset,
            Main.Position.Y.Scale,
            Main.Position.Y.Offset
        )
    end)

    -- Topbar
    local TopBar = Create("Frame", {
        Name            = "TopBar",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size            = UDim2.new(1, 0, 0, 50),
        Parent          = Main,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        -- Accent line
        Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 0, 1, -2),
            Size             = UDim2.new(1, 0, 0, 2),
        }),
    })

    -- Logo dot
    Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 16, 0.5, -6),
        Size             = UDim2.new(0, 12, 0, 12),
        Parent           = TopBar,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 36, 0, 8),
        Size                   = UDim2.new(0.5, 0, 0, 18),
        Font                   = Enum.Font.GothamBold,
        Text                   = Title,
        TextColor3             = Theme.Text,
        TextSize               = 14,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = TopBar,
    })

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 36, 0, 28),
        Size                   = UDim2.new(0.5, 0, 0, 14),
        Font                   = Enum.Font.Gotham,
        Text                   = Subtitle,
        TextColor3             = Theme.TextMuted,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = TopBar,
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        BackgroundColor3       = Color3.fromRGB(255, 75, 75),
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, -36, 0.5, -8),
        Size                   = UDim2.new(0, 16, 0, 16),
        Font                   = Enum.Font.GothamBold,
        Text                   = "",
        TextColor3             = Theme.White,
        TextSize               = 10,
        Parent                 = TopBar,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, { Size = UDim2.new(0, Width, 0, 0) }, 0.3, Enum.EasingStyle.Quint)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Minimize button
    local MinBtn = Create("TextButton", {
        BackgroundColor3       = Color3.fromRGB(255, 185, 60),
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, -58, 0.5, -8),
        Size                   = UDim2.new(0, 16, 0, 16),
        Font                   = Enum.Font.GothamBold,
        Text                   = "",
        Parent                 = TopBar,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, { Size = UDim2.new(0, Width, 0, 50) }, 0.3, Enum.EasingStyle.Quint)
        else
            Tween(Main, { Size = UDim2.new(0, Width, 0, Height) }, 0.3, Enum.EasingStyle.Quint)
        end
    end)

    -- Tab sidebar
    local Sidebar = Create("Frame", {
        Name            = "Sidebar",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position        = UDim2.new(0, 0, 0, 50),
        Size            = UDim2.new(0, 150, 1, -50),
        Parent          = Main,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
    })
    -- Fix top-right/bottom-right rounding being visible through content area
    Create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1, -10, 0, 0),
        Size             = UDim2.new(0, 10, 1, 0),
        Parent           = Sidebar,
    })

    local TabList = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 0, 0, 10),
        Size                   = UDim2.new(1, 0, 1, -10),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness     = 0,
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        Parent                 = Sidebar,
    }, {
        Create("UIListLayout", {
            Padding         = UDim.new(0, 4),
            SortOrder       = Enum.SortOrder.LayoutOrder,
        }),
        Create("UIPadding", {
            PaddingLeft  = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
    })

    -- Content area
    local ContentArea = Create("Frame", {
        Name            = "ContentArea",
        BackgroundTransparency = 1,
        Position        = UDim2.new(0, 158, 0, 58),
        Size            = UDim2.new(1, -166, 1, -66),
        Parent          = Main,
        ClipsDescendants = true,
    })

    -- Window object
    local Window = {}
    Window._tabs = {}
    Window._activeTab = nil
    Window._gui = ScreenGui

    -- Entry animation
    Main.Size = UDim2.new(0, Width, 0, 0)
    Tween(Main, { Size = UDim2.new(0, Width, 0, Height) }, 0.4, Enum.EasingStyle.Quint)

    ----------------------------------------------------------------------
    -- CreateTab
    ----------------------------------------------------------------------
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab._name = name
        Tab._elements = {}

        -- Tab button
        local TabBtn = Create("TextButton", {
            BackgroundColor3       = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 0, 34),
            Font                   = Enum.Font.Gotham,
            Text                   = "",
            Parent                 = TabList,
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 7) }),
        })

        local TabIcon = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 10, 0.5, -8),
            Size                   = UDim2.new(0, 16, 0, 16),
            Font                   = Enum.Font.GothamBold,
            Text                   = icon or "•",
            TextColor3             = Theme.TextMuted,
            TextSize               = 13,
            Parent                 = TabBtn,
        })

        local TabLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 30, 0.5, -8),
            Size                   = UDim2.new(1, -38, 0, 16),
            Font                   = Enum.Font.Gotham,
            Text                   = name,
            TextColor3             = Theme.TextMuted,
            TextSize               = 13,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = TabBtn,
        })

        -- Active indicator
        local ActiveBar = Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 0, 0.5, -10),
            Size             = UDim2.new(0, 3, 0, 20),
            BackgroundTransparency = 1,
            Parent           = TabBtn,
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
        })

        -- Tab content page
        local TabPage = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.fromScale(1, 1),
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = Theme.Border,
            Visible                = false,
            Parent                 = ContentArea,
        }, {
            Create("UIListLayout", {
                Padding   = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
            }),
        })

        local function SetActive(active)
            if active then
                Tween(TabBtn, { BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceAlt }, 0.15)
                Tween(TabLabel, { TextColor3 = Theme.Text }, 0.15)
                Tween(TabIcon,  { TextColor3 = Theme.Accent }, 0.15)
                Tween(ActiveBar, { BackgroundTransparency = 0 }, 0.15)
                TabLabel.Font = Enum.Font.GothamBold
                TabPage.Visible = true
            else
                Tween(TabBtn, { BackgroundTransparency = 1 }, 0.15)
                Tween(TabLabel, { TextColor3 = Theme.TextMuted }, 0.15)
                Tween(TabIcon,  { TextColor3 = Theme.TextDim }, 0.15)
                Tween(ActiveBar, { BackgroundTransparency = 1 }, 0.15)
                TabLabel.Font = Enum.Font.Gotham
                TabPage.Visible = false
            end
        end

        TabBtn.MouseButton1Click:Connect(function()
            if Window._activeTab then
                Window._activeTab._setActive(false)
            end
            Window._activeTab = Tab
            Tab._setActive(true)
        end)

        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(TabBtn, { BackgroundTransparency = 0.7 }, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(TabBtn, { BackgroundTransparency = 1 }, 0.1)
            end
        end)

        Tab._setActive = SetActive
        Tab._page = TabPage

        -- Auto-select first tab
        if #Window._tabs == 0 then
            Window._activeTab = Tab
            SetActive(true)
        end

        table.insert(Window._tabs, Tab)

        ----------------------------------------------------------------
        -- Helper: add section label
        ----------------------------------------------------------------
        local elementOrder = 0
        local function NextOrder()
            elementOrder = elementOrder + 1
            return elementOrder
        end

        local function MakeCard(heightVal)
            local card = Create("Frame", {
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, heightVal or 40),
                LayoutOrder      = NextOrder(),
                Parent           = TabPage,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
            })
            return card
        end

        ----------------------------------------------------------------
        -- CreateSection
        ----------------------------------------------------------------
        function Tab:CreateSection(name)
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size                   = UDim2.new(1, 0, 0, 24),
                Font                   = Enum.Font.GothamBold,
                Text                   = name:upper(),
                TextColor3             = Theme.TextDim,
                TextSize               = 10,
                TextXAlignment         = Enum.TextXAlignment.Left,
                LayoutOrder            = NextOrder(),
                Parent                 = TabPage,
            }, {
                Create("UIPadding", { PaddingLeft = UDim.new(0, 4) }),
            })
        end

        ----------------------------------------------------------------
        -- CreateButton
        ----------------------------------------------------------------
        function Tab:CreateButton(config, callback)
            if type(config) == "string" then
                config = { Name = config, Description = nil }
            end
            callback = callback or function() end

            local card = MakeCard(config.Description and 54 or 40)
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0, config.Description and 8 or 0),
                Size                   = UDim2.new(0.7, 0, 0, config.Description and 18 or 40),
                Font                   = Enum.Font.GothamBold,
                Text                   = config.Name or "Button",
                TextColor3             = Theme.Text,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = card,
            })

            if config.Description then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, 28),
                    Size                   = UDim2.new(0.75, 0, 0, 16),
                    Font                   = Enum.Font.Gotham,
                    Text                   = config.Description,
                    TextColor3             = Theme.TextMuted,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = card,
                })
            end

            -- Button pill
            local Pill = Create("TextButton", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0, 70, 0, 26),
                Font             = Enum.Font.GothamBold,
                Text             = config.ButtonText or "Run",
                TextColor3       = Theme.White,
                TextSize         = 12,
                Parent           = card,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            })

            Pill.MouseButton1Click:Connect(function()
                Tween(Pill, { BackgroundColor3 = Theme.AccentDark }, 0.1)
                task.delay(0.15, function()
                    Tween(Pill, { BackgroundColor3 = Theme.Accent }, 0.15)
                end)
                task.spawn(callback)
            end)
            Pill.MouseEnter:Connect(function()
                Tween(Pill, { BackgroundColor3 = Color3.fromRGB(120, 160, 255) }, 0.1)
            end)
            Pill.MouseLeave:Connect(function()
                Tween(Pill, { BackgroundColor3 = Theme.Accent }, 0.1)
            end)
        end

        ----------------------------------------------------------------
        -- CreateToggle
        ----------------------------------------------------------------
        function Tab:CreateToggle(config, callback)
            if type(config) == "string" then
                config = { Name = config }
            end
            callback = callback or function() end
            local state = config.Default or false

            local card = MakeCard(config.Description and 54 or 40)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0, config.Description and 8 or 0),
                Size                   = UDim2.new(0.7, 0, 0, config.Description and 18 or 40),
                Font                   = Enum.Font.GothamBold,
                Text                   = config.Name or "Toggle",
                TextColor3             = Theme.Text,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = card,
            })

            if config.Description then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, 28),
                    Size                   = UDim2.new(0.75, 0, 0, 16),
                    Font                   = Enum.Font.Gotham,
                    Text                   = config.Description,
                    TextColor3             = Theme.TextMuted,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = card,
                })
            end

            -- Toggle track
            local Track = Create("Frame", {
                BackgroundColor3 = state and Theme.Accent or Theme.Border,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -14, 0.5, 0),
                Size             = UDim2.new(0, 40, 0, 22),
                Parent           = card,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            })

            local Knob = Create("Frame", {
                BackgroundColor3 = Theme.White,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = state and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size             = UDim2.new(0, 18, 0, 18),
                Parent           = Track,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            })

            local ClickDetector = Create("TextButton", {
                BackgroundTransparency = 1,
                Size                   = UDim2.fromScale(1, 1),
                Text                   = "",
                Parent                 = card,
            })

            ClickDetector.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    Tween(Track, { BackgroundColor3 = Theme.Accent }, 0.2)
                    Tween(Knob, { Position = UDim2.new(0, 20, 0.5, 0) }, 0.2, Enum.EasingStyle.Quint)
                else
                    Tween(Track, { BackgroundColor3 = Theme.Border }, 0.2)
                    Tween(Knob, { Position = UDim2.new(0, 2, 0.5, 0) }, 0.2, Enum.EasingStyle.Quint)
                end
                task.spawn(callback, state)
            end)

            local ToggleObj = {}
            function ToggleObj:Set(val)
                state = val
                if state then
                    Track.BackgroundColor3 = Theme.Accent
                    Knob.Position = UDim2.new(0, 20, 0.5, 0)
                else
                    Track.BackgroundColor3 = Theme.Border
                    Knob.Position = UDim2.new(0, 2, 0.5, 0)
                end
                callback(state)
            end
            function ToggleObj:Get() return state end
            return ToggleObj
        end

        ----------------------------------------------------------------
        -- CreateSlider
        ----------------------------------------------------------------
        function Tab:CreateSlider(config, callback)
            if type(config) == "string" then
                config = { Name = config }
            end
            callback = callback or function() end
            local min  = config.Min     or 0
            local max  = config.Max     or 100
            local val  = config.Default or min
            local step = config.Step    or 1

            local card = MakeCard(config.Description and 64 or 54)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0, 8),
                Size                   = UDim2.new(0.7, 0, 0, 16),
                Font                   = Enum.Font.GothamBold,
                Text                   = config.Name or "Slider",
                TextColor3             = Theme.Text,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = card,
            })

            local ValLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint            = Vector2.new(1, 0),
                Position               = UDim2.new(1, -14, 0, 8),
                Size                   = UDim2.new(0, 60, 0, 16),
                Font                   = Enum.Font.GothamBold,
                Text                   = tostring(val),
                TextColor3             = Theme.Accent,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Right,
                Parent                 = card,
            })

            if config.Description then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, 26),
                    Size                   = UDim2.new(0.8, 0, 0, 14),
                    Font                   = Enum.Font.Gotham,
                    Text                   = config.Description,
                    TextColor3             = Theme.TextMuted,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = card,
                })
            end

            local trackY = config.Description and 44 or 34

            -- Track BG
            local TrackBG = Create("Frame", {
                BackgroundColor3 = Theme.SurfaceAlt,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 14, 0, trackY),
                Size             = UDim2.new(1, -28, 0, 6),
                Parent           = card,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            })

            local pct = (val - min) / (max - min)

            -- Fill
            local Fill = Create("Frame", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel  = 0,
                Size             = UDim2.new(pct, 0, 1, 0),
                Parent           = TrackBG,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            })

            -- Knob
            local Knob = Create("Frame", {
                BackgroundColor3 = Theme.White,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new(pct, 0, 0.5, 0),
                Size             = UDim2.new(0, 14, 0, 14),
                ZIndex           = 2,
                Parent           = TrackBG,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Create("UIStroke", { Color = Theme.Accent, Thickness = 2 }),
            })

            -- Drag
            local sliding = false
            TrackBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local trackAbs = TrackBG.AbsoluteSize.X
                    local trackPos = TrackBG.AbsolutePosition.X
                    local rel = math.clamp((input.Position.X - trackPos) / trackAbs, 0, 1)
                    local rawVal = min + rel * (max - min)
                    val = math.round(rawVal / step) * step
                    val = math.clamp(val, min, max)
                    local newPct = (val - min) / (max - min)
                    Fill.Size = UDim2.new(newPct, 0, 1, 0)
                    Knob.Position = UDim2.new(newPct, 0, 0.5, 0)
                    ValLabel.Text = tostring(val)
                    task.spawn(callback, val)
                end
            end)

            local SliderObj = {}
            function SliderObj:Set(v)
                val = math.clamp(v, min, max)
                local np = (val - min) / (max - min)
                Fill.Size = UDim2.new(np, 0, 1, 0)
                Knob.Position = UDim2.new(np, 0, 0.5, 0)
                ValLabel.Text = tostring(val)
                callback(val)
            end
            function SliderObj:Get() return val end
            return SliderObj
        end

        ----------------------------------------------------------------
        -- CreateInput
        ----------------------------------------------------------------
        function Tab:CreateInput(config, callback)
            if type(config) == "string" then
                config = { Name = config }
            end
            callback = callback or function() end

            local card = MakeCard(config.Description and 70 or 60)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0, 8),
                Size                   = UDim2.new(1, -28, 0, 16),
                Font                   = Enum.Font.GothamBold,
                Text                   = config.Name or "Input",
                TextColor3             = Theme.Text,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = card,
            })

            if config.Description then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position               = UDim2.new(0, 14, 0, 26),
                    Size                   = UDim2.new(1, -28, 0, 14),
                    Font                   = Enum.Font.Gotham,
                    Text                   = config.Description,
                    TextColor3             = Theme.TextMuted,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = card,
                })
            end

            local inputY = config.Description and 42 or 30

            local InputBox = Create("TextBox", {
                BackgroundColor3       = Theme.SurfaceAlt,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0, 14, 0, inputY),
                Size                   = UDim2.new(1, -28, 0, 22),
                Font                   = Enum.Font.Gotham,
                Text                   = config.Default or "",
                PlaceholderText        = config.Placeholder or "Enter value...",
                PlaceholderColor3      = Theme.TextDim,
                TextColor3             = Theme.Text,
                TextSize               = 12,
                ClearTextOnFocus       = config.ClearOnFocus ~= false,
                Parent                 = card,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
                Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }),
            })

            InputBox.FocusLost:Connect(function(enter)
                if enter or config.FireOnChange then
                    task.spawn(callback, InputBox.Text)
                end
            end)

            if config.FireOnChange then
                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    task.spawn(callback, InputBox.Text)
                end)
            end

            local InputObj = {}
            function InputObj:Set(v) InputBox.Text = v end
            function InputObj:Get() return InputBox.Text end
            return InputObj
        end

        ----------------------------------------------------------------
        -- CreateDropdown
        ----------------------------------------------------------------
        function Tab:CreateDropdown(config, callback)
            if type(config) == "string" then
                config = { Name = config, Options = {} }
            end
            callback = callback or function() end
            local options = config.Options or {}
            local selected = config.Default or (options[1] or "Select...")
            local open = false

            local card = MakeCard(40)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0.5, -8),
                Size                   = UDim2.new(0.5, 0, 0, 16),
                Font                   = Enum.Font.GothamBold,
                Text                   = config.Name or "Dropdown",
                TextColor3             = Theme.Text,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = card,
            })

            local DropBtn = Create("TextButton", {
                BackgroundColor3 = Theme.SurfaceAlt,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0, 130, 0, 26),
                Font             = Enum.Font.Gotham,
                Text             = selected .. "  ▾",
                TextColor3       = Theme.Text,
                TextSize         = 12,
                Parent           = card,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
            })

            -- Dropdown menu
            local Menu = Create("Frame", {
                BackgroundColor3 = Theme.SurfaceAlt,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(1, 0),
                Position         = UDim2.new(1, -12, 1, 4),
                Size             = UDim2.new(0, 130, 0, 0),
                ClipsDescendants = true,
                ZIndex           = 10,
                Parent           = card,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
            })

            local MenuList = Create("UIListLayout", {
                Padding   = UDim.new(0, 1),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = Menu,
            })

            for i, opt in ipairs(options) do
                local optBtn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size                   = UDim2.new(1, 0, 0, 28),
                    Font                   = Enum.Font.Gotham,
                    Text                   = opt,
                    TextColor3             = Theme.TextMuted,
                    TextSize               = 12,
                    ZIndex                 = 11,
                    LayoutOrder            = i,
                    Parent                 = Menu,
                })
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    DropBtn.Text = selected .. "  ▾"
                    open = false
                    Tween(Menu, { Size = UDim2.new(0, 130, 0, 0) }, 0.15)
                    task.spawn(callback, selected)
                end)
                optBtn.MouseEnter:Connect(function()
                    Tween(optBtn, { TextColor3 = Theme.Text }, 0.1)
                end)
                optBtn.MouseLeave:Connect(function()
                    Tween(optBtn, { TextColor3 = Theme.TextMuted }, 0.1)
                end)
            end

            local menuH = #options * 29
            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    Tween(Menu, { Size = UDim2.new(0, 130, 0, menuH) }, 0.2, Enum.EasingStyle.Quint)
                    Tween(card, { Size = UDim2.new(1, 0, 0, 40 + menuH + 8) }, 0.2, Enum.EasingStyle.Quint)
                else
                    Tween(Menu, { Size = UDim2.new(0, 130, 0, 0) }, 0.15)
                    Tween(card, { Size = UDim2.new(1, 0, 0, 40) }, 0.15)
                end
            end)

            local DDObj = {}
            function DDObj:Set(v)
                selected = v
                DropBtn.Text = selected .. "  ▾"
                callback(selected)
            end
            function DDObj:Get() return selected end
            return DDObj
        end

        ----------------------------------------------------------------
        -- CreateLabel
        ----------------------------------------------------------------
        function Tab:CreateLabel(text)
            local card = MakeCard(36)
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0.5, -8),
                Size                   = UDim2.new(1, -28, 0, 16),
                Font                   = Enum.Font.Gotham,
                Text                   = text or "Label",
                TextColor3             = Theme.TextMuted,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = card,
            })

            local LabelObj = {}
            function LabelObj:Set(v)
                card:FindFirstChildOfClass("TextLabel").Text = v
            end
            return LabelObj
        end

        ----------------------------------------------------------------
        -- CreateSeparator
        ----------------------------------------------------------------
        function Tab:CreateSeparator()
            Create("Frame", {
                BackgroundColor3 = Theme.Border,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 1),
                LayoutOrder      = NextOrder(),
                Parent           = TabPage,
            })
        end

        ----------------------------------------------------------------
        -- CreateColorPicker
        ----------------------------------------------------------------
        function Tab:CreateColorPicker(config, callback)
            if type(config) == "string" then config = { Name = config } end
            callback = callback or function() end
            local color = config.Default or Color3.fromRGB(100, 140, 255)

            local card = MakeCard(40)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0.5, -8),
                Size                   = UDim2.new(0.6, 0, 0, 16),
                Font                   = Enum.Font.GothamBold,
                Text                   = config.Name or "Color",
                TextColor3             = Theme.Text,
                TextSize               = 13,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = card,
            })

            local Swatch = Create("TextButton", {
                BackgroundColor3 = color,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -14, 0.5, 0),
                Size             = UDim2.new(0, 50, 0, 26),
                Text             = "",
                Parent           = card,
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
            })

            -- Simple RGB input row
            local inputs = {"R","G","B"}
            local inputFrames = {}
            local expanded = false
            local InputRow = Create("Frame", {
                BackgroundTransparency = 1,
                Position  = UDim2.new(0, 14, 1, 4),
                Size      = UDim2.new(1, -28, 0, 28),
                Visible   = false,
                ZIndex    = 5,
                Parent    = card,
            }, {
                Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding       = UDim.new(0, 4),
                }),
            })

            local r, g, b = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
            local vals = {r, g, b}

            for i, lbl in ipairs(inputs) do
                local box = Create("TextBox", {
                    BackgroundColor3  = Theme.SurfaceAlt,
                    BorderSizePixel   = 0,
                    Size              = UDim2.new(0, 50, 1, 0),
                    Font              = Enum.Font.GothamBold,
                    Text              = tostring(vals[i]),
                    TextColor3        = Theme.Text,
                    TextSize          = 11,
                    ZIndex            = 6,
                    Parent            = InputRow,
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
                })
                inputFrames[i] = box
                box.FocusLost:Connect(function()
                    vals[i] = math.clamp(tonumber(box.Text) or vals[i], 0, 255)
                    box.Text = tostring(vals[i])
                    color = Color3.fromRGB(vals[1], vals[2], vals[3])
                    Swatch.BackgroundColor3 = color
                    task.spawn(callback, color)
                end)
            end

            Swatch.MouseButton1Click:Connect(function()
                expanded = not expanded
                InputRow.Visible = expanded
                Tween(card, { Size = UDim2.new(1, 0, 0, expanded and 76 or 40) }, 0.15)
            end)

            local CPObj = {}
            function CPObj:Set(c)
                color = c
                Swatch.BackgroundColor3 = c
                vals = {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)}
                for i, box in ipairs(inputFrames) do box.Text = tostring(vals[i]) end
                callback(c)
            end
            function CPObj:Get() return color end
            return CPObj
        end

        return Tab
    end

    ----------------------------------------------------------------------
    -- Notification
    ----------------------------------------------------------------------
    function Window:Notify(config)
        if type(config) == "string" then
            config = { Title = config }
        end
        local title    = config.Title    or "Notification"
        local content  = config.Content  or ""
        local duration = config.Duration or 4
        local ntype    = config.Type     or "info" -- info, success, warning, danger

        local typeColors = {
            info    = Theme.Accent,
            success = Theme.Success,
            warning = Theme.Warning,
            danger  = Theme.Danger,
        }
        local accent = typeColors[ntype] or Theme.Accent

        -- Notification container (bottom-right)
        local NotifHolder = ScreenGui:FindFirstChild("NotifHolder")
        if not NotifHolder then
            NotifHolder = Create("Frame", {
                Name                   = "NotifHolder",
                BackgroundTransparency = 1,
                AnchorPoint            = Vector2.new(1, 1),
                Position               = UDim2.new(1, -16, 1, -16),
                Size                   = UDim2.new(0, 300, 1, -32),
                Parent                 = ScreenGui,
            }, {
                Create("UIListLayout", {
                    Padding         = UDim.new(0, 8),
                    SortOrder       = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                    FillDirection   = Enum.FillDirection.Vertical,
                }),
            })
        end

        local Notif = Create("Frame", {
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent           = NotifHolder,
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
        })

        -- Accent bar
        Create("Frame", {
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 4, 1, 0),
            Parent           = Notif,
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 14, 0, 10),
            Size                   = UDim2.new(1, -18, 0, 16),
            Font                   = Enum.Font.GothamBold,
            Text                   = title,
            TextColor3             = Theme.Text,
            TextSize               = 13,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = Notif,
        })

        if content ~= "" then
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0, 14, 0, 28),
                Size                   = UDim2.new(1, -18, 0, 28),
                Font                   = Enum.Font.Gotham,
                Text                   = content,
                TextColor3             = Theme.TextMuted,
                TextSize               = 11,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                Parent                 = Notif,
            })
        end

        local targetH = content ~= "" and 64 or 42
        Tween(Notif, { Size = UDim2.new(1, 0, 0, targetH), BackgroundTransparency = 0 }, 0.25, Enum.EasingStyle.Quint)

        task.delay(duration, function()
            Tween(Notif, { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) }, 0.25)
            task.wait(0.3)
            pcall(function() Notif:Destroy() end)
        end)
    end

    function Window:Destroy()
        pcall(function() ScreenGui:Destroy() end)
    end

    return Window
end

----------------------------------------------------------------------
-- SetTheme (global override)
----------------------------------------------------------------------
function IdeaPath:SetTheme(customTheme)
    for k, v in pairs(customTheme) do
        Theme[k] = v
    end
end

return IdeaPath

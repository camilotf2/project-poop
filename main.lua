local Services = setmetatable({}, {__index = function(_, k) return cloneref(game:GetService(k)) end})

local Workspace = Services.Workspace
local Camera = Workspace.CurrentCamera

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local RunService = Services.RunService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage

local Bullet = require(ReplicatedStorage.Modules.FPS.Bullet)
local AmmoTypes = ReplicatedStorage.AmmoTypes

local Fov = Drawing.new("Circle") Fov.Thickness, Fov.NumSides, Fov.Filled, Fov.Color = 1.5, 360, false, Color3.fromRGB(255, 255, 255)

local Utils = {}
do
    Utils.GetClosestPlayerToMouse = function()
        local MousePosition = UserInputService:GetMouseLocation()
        local Closest, ClosestDistance = nil,math.huge

            for _,Player in Players:GetPlayers() do
                if Player == LocalPlayer or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    continue
                end 

            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if not OnScreen then continue end

            local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePosition).Magnitude
            
            if Distance > Fov.Radius then continue end

            if Distance < ClosestDistance then
                Closest = Player.Character
                ClosestDistance = Distance
            end
        end

    return Closest
    end

    Utils.GetAmmoInfo = function(Ammo)
        if AmmoTypes:FindFirstChild(Ammo)then
            return AmmoTypes:FindFirstChild(Ammo)
        end
        return nil
    end

    Utils.PredictVelocity = function(Target, Speed)
        local Distance = (Target.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        local Time = Distance / Speed + (Distance / (Speed - 0.013 * Speed ^ 2 * (Distance / Speed) ^ 2))
        return Target.CFrame.Position + Target.Velocity * Time
    end

    Utils.GetCharacter = function(Player)
    if Player and Player:IsA("Player") and Player.Character then
        return Player.Character
    end
    return nil
    end 

    Utils.GetRoot = function(Player)
    local Character = Utils.GetCharacter(Player)
    if Character then
        return Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
    end

    Utils.ThreadFunction = function(Func, Name, ...)
        local args = {...}
        local wrappedFunc = Name and function()
            local Passed, Statement = pcall(Func, unpack(args))
            if not Passed then
                warn("Error in thread '" .. Name .. "': " .. tostring(Statement))
            end
        end or Func
    
        local Thread = coroutine.create(wrappedFunc)
        local Success, ErrorMsg = coroutine.resume(Thread)
        if not Success then
            error("Failed to start thread '" .. Name .. "': " .. tostring(ErrorMsg))
        end
    end
end


--#region linoria   
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()

local Window = Library:CreateWindow({Title = 'Sussy haxx', Center = true, AutoShow = true, TabPadding = 8, MenuFadeTime = 0.2})

do -- Combat Tab
    local Tab = Window:AddTab('Combat')

    local SilentAimBox = Tab:AddLeftGroupbox('Silent Aim')
    local GunMods = Tab:AddRightGroupbox('Gun mods')

    SilentAimBox:AddToggle('SilentAim', {
        Text = 'Enabled',
        Default = false,
        Tooltip = '',
    }):AddKeyPicker('SilentAimBind', { Default = 'C', NoUI = false, Text = 'Silent Aim', SyncToggleState = true})

    SilentAimBox:AddToggle('SilentAimFov', {
        Text = 'Show FOV',
        Default = false,
        Tooltip = '',
    })

    SilentAimBox:AddSlider('SilentAimFovSize', {
        Text = 'FOV Size',
        Default = 300,
        Min = 0,
        Max = 720,
        Rounding = 0,
        Compact = false,
    })

    SilentAimBox:AddDropdown('TargetPartsSilentAim', {
        Values = { 
            'FaceHitBox', 'Head', 'HeadTopHitBox',
            'UpperTorso', 'LowerTorso', 'HumanoidRootPart'
        },
        Default = 1,
        Multi = true,
        Text = 'Target parts',
        Tooltip = '',
    })
end

do -- Visuals Tab
    local Tab = Window:AddTab('Visuals')

    local EspBox = Tab:AddLeftGroupbox('ESP')
    local World = Tab:AddRightGroupbox('World')

    EspBox:AddToggle('ESPEnabled', {
        Text = 'Enabled',
        Default = false,
        Tooltip = '',
    })
    EspBox:AddToggle('BoxEnabled', {
        Text = 'Box',
        Default = false,
        Tooltip = '',
    })
    EspBox:AddToggle('BoxFill', {
        Text = 'Fill',
        Default = false,
        Tooltip = '',
    })
    EspBox:AddToggle('NameEnabled', {
        Text = 'Name',
        Default = false,
        Tooltip = '',
    })
    EspBox:AddToggle('HPEnabled', {
        Text = 'Health Bar',
        Default = false,
        Tooltip = '',
    })
    EspBox:AddToggle('DistanceEnabled', {
        Text = 'Distance',
        Default = false,
        Tooltip = '',
    })
    EspBox:AddToggle('Highlight', {
        Text = 'Chams',
        Default = false,
        Tooltip = '',
    })
end

do -- Misc Tab
    local Tab = Window:AddTab('Misc')

    local Miscbox = Tab:AddLeftGroupbox('Misc')

    Miscbox:AddToggle('Invisible', {
        Text = 'Invisible',
        Default = false,
        Tooltip = 'Hide underground making you invisible to AI and players',
    }):AddKeyPicker('InvisibleBind', { Default = 'K', NoUI = false, Text = 'Invisible', SyncToggleState = true})

    Miscbox:AddSlider('InvisibleOffSet', {
        Text = 'Position Offset',
        Default = 3,
        Min = 0,
        Max = 3,
        Rounding = 1,
        Compact = false,
        Tooltip = 'Determines how far underground you go',
    })
end

do -- Settings Tab
    local Tab = Window:AddTab('UI Settings')

    local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()
    local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua'))()

    local MenuGroup = Tab:AddLeftGroupbox('Menu')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

    Library.KeybindFrame.Visible = true
    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    ThemeManager:SetFolder('SussyHaxx')
    SaveManager:SetFolder('SussyHaxx/Project delta')
    SaveManager:BuildConfigSection(Tab)
    ThemeManager:ApplyToTab(Tab)
    SaveManager:LoadAutoloadConfig()
end
--#endregion
--#region esp
local Visuals = {
    Drawings = {}
}

do
    function Visuals:Make(Properties)
        if Properties and Properties.Player then
            local Self = setmetatable({
                Player = Properties.Player,
                Drawings = {
                    Name = Drawing.new("Text"),
                    BoxOutline = Drawing.new("Square"),
                    Box = Drawing.new("Square"),
                    BoxFill = Drawing.new("Square"),
                    HpBarOutline = Drawing.new("Square"),
                    Hpbar = Drawing.new("Square"),
                    HealthText = Drawing.new("Text"),
                    Distance = Drawing.new("Text"),
                    Highlight = Instance.new("Highlight", gethui())
                }
            }, {
                __index = Visuals
            })
            
            local Box, BoxFill, BoxOutline = Self.Drawings.Box, Self.Drawings.BoxFill, Self.Drawings.BoxOutline
            BoxFill.Visible = false
            BoxFill.Transparency = 0.4
            BoxFill.Color = Color3.fromRGB(255, 255, 255)
            BoxFill.ZIndex = 3

            Box.Thickness = 0.8
            Box.Filled = false
            Box.Color = Color3.fromRGB(255, 255, 255)
            Box.Visible = false
            Box.ZIndex = 5

            BoxOutline.Thickness = 2.8
            BoxOutline.Filled = false
            BoxOutline.Color = Color3.fromRGB(0, 0, 0)
            BoxOutline.Visible = false
            BoxOutline.ZIndex = 1

            local Name = Self.Drawings.Name
            Name.Text = Self.Player.Name
            Name.Center = true
            Name.Size = 16
            Name.Font = 2
            Name.Visible = false
            Name.Outline = true
            Name.Color = Color3.fromRGB(255, 255, 255)

            local HpBarOutline = Self.Drawings.HpBarOutline
            HpBarOutline.Thickness = 1.5
            HpBarOutline.Filled = true
            HpBarOutline.Visible = false
            HpBarOutline.Color = Color3.fromRGB(0, 0, 0)

            local Hpbar = Self.Drawings.Hpbar
            Hpbar.Thickness = 1.5
            Hpbar.Filled = true
            Hpbar.Visible = false

            local Hptext = Self.Drawings.HealthText
            Hptext.Text = "0"
            Hptext.Center = true
            Hptext.Size = 13
            Hptext.Font = 2
            Hptext.Visible = false
            Hptext.Outline = true

            local Distance = Self.Drawings.Distance
            Distance.Text = "0 s"
            Distance.Center = true
            Distance.Size = 16
            Distance.Font = 2
            Distance.Visible = false
            Distance.Outline = true

            local Highlight = Self.Drawings.Highlight
            Highlight.Enabled = false
            Highlight.Adornee = Utils.GetCharacter(Self.Player)
            Highlight.FillColor = Color3.fromRGB(255, 255, 255)
            Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
            Highlight.FillTransparency = 0.5
            Highlight.OutlineTransparency = 0

            Visuals.Drawings[Properties.Player] = Self

            return Self
        end
    end

    function Visuals:Remove()
        if self then
            setmetatable(self, {})
            Visuals.Drawings[self.Player] = nil

            for _, Value in pairs(self.Drawings) do
                if typeof(Value) == "Instance" then
                    Value:Destroy()
                else
                    Value:Remove()
                end
            end
        end
    end

    function Visuals:Update()
    if Toggles.ESPEnabled.Value then

        if self and self.Player then
            local Drawings = self.Drawings
            local Plr = self.Player
            local RootPart = Utils.GetRoot(Plr)
            if Plr and Plr.Character and RootPart and Plr.Character:FindFirstChild('Humanoid') and Plr.Character.Humanoid.Health ~= 0 then
                local Position, Visible = workspace.CurrentCamera:WorldToViewportPoint(RootPart.Position)

                if Visible then
                    local ViewportSize = workspace.CurrentCamera.ViewportSize
                        local ScreenWidth, ScreenHeight = ViewportSize.X, ViewportSize.Y
                        local Factor = 1 / (Position.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
                        local Width, Height = math.floor(ScreenHeight  / 25 * Factor), math.floor(ScreenWidth  /  27 * Factor)

                    if Toggles.BoxEnabled.Value then
                        Drawings.Box.Size = Vector2.new(Width, Height)
                        Drawings.Box.Position = Vector2.new(Position.X - Width / 2, Position.Y - Height / 2.2)
                        Drawings.Box.Visible = Toggles.BoxEnabled.Value

                        Drawings.BoxFill.Size =  Drawings.Box.Size
                        Drawings.BoxFill.Position = Drawings.Box.Position
                        Drawings.BoxFill.Visible = Toggles.BoxEnabled.Value
                        Drawings.BoxFill.Filled = Toggles.BoxFill.Value
                        Drawings.BoxFill.Color = Color3.new(1, 1, 1)

                        Drawings.BoxOutline.Size = Drawings.Box.Size
                        Drawings.BoxOutline.Position = Drawings.Box.Position
                        Drawings.BoxOutline.Visible = Toggles.BoxEnabled.Value
                    else
                        Drawings.Box.Size = Vector2.new(Width, Height)
                        Drawings.Box.Position = Vector2.new(Position.X - Width / 2, Position.Y - Height / 2.2)

                        Drawings.Box.Visible = false
                        Drawings.BoxFill.Visible = false
                        Drawings.BoxOutline.Visible = false
                    end

                    if Toggles.NameEnabled.Value then
                        Drawings.Name.Visible = Toggles.NameEnabled.Value
                        Drawings.Name.Text = Plr.Name
                        Drawings.Name.Position = Drawings.Box.Position + Vector2.new(Drawings.Box.Size.X / 2, -20)
                        Drawings.Name.Color = Color3.new(255, 255, 255)
                    else
                        Drawings.Name.Visible = false
                    end

                    if Toggles.HPEnabled.Value then
                        local Health, MaxHealth = Plr.Character:WaitForChild("Humanoid").Health or 0, Plr.Character:WaitForChild("Humanoid").MaxHealth or 100
                        local HealthPercentage = Health / MaxHealth
                        local Color = Color3.new(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), HealthPercentage)

                        Drawings.Hpbar.Visible = Toggles.HPEnabled.Value
                        Drawings.Hpbar.Size = Vector2.new(2.5, (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))) + 1)
                        Drawings.Hpbar.Position = Vector2.new(Drawings.Box.Position.X - 10, (Drawings.Box.Position.Y + Drawings.Box.Size.Y) - (math.floor(Drawings.Box.Size.Y * (Health / MaxHealth))))
                        Drawings.Hpbar.Color = Color or Color3.new(0,255,0)

                        Drawings.HpBarOutline.Visible = Drawings.Hpbar.Visible
                        Drawings.HpBarOutline.Size = Vector2.new(4.5, Drawings.Box.Size.Y + 3)
                        Drawings.HpBarOutline.Position = Vector2.new(Drawings.Box.Position.X - 11, Drawings.Box.Position.Y - 1)
                    else
                        Drawings.Hpbar.Visible = false
                        Drawings.HpBarOutline.Visible = false
                    end

                    if Toggles.DistanceEnabled.Value then
                        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude
                        Drawings.Distance.Position = Vector2.new(Drawings.Box.Position.X + Drawings.Box.Size.X / 2, Drawings.Box.Position.Y + Drawings.Box.Size.Y + 5)
                        Drawings.Distance.Visible = Toggles.DistanceEnabled.Value
                        Drawings.Distance.Text = string.format(math.floor(distance)) .. " s"
                        Drawings.Distance.Color = Color3.new(255,255,255)
                    else
                        Drawings.Distance.Visible = false
                    end

                    if Toggles.Highlight.Value then
                        Drawings.Highlight.Enabled = Toggles.Highlight.Value
						Drawings.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    else
                        Drawings.Highlight.Enabled = false
                    end

                else
                    for _, Drawing in pairs(Drawings) do
                        if typeof(Drawing) ~= "Instance" then
                            Drawing.Visible = false
                        else
                            Drawing.Enabled = false
                        end
                    end
                end
            else
                for _, Drawing in pairs(Drawings) do
                    if typeof(Drawing) ~= "Instance" then
                        Drawing.Visible = false
                    else
                        Drawing.Enabled = false
                    end
                end
            end
        end
    else
        for _, Drawing in pairs(self.Drawings) do
            if typeof(Drawing) ~= "Instance" then
                Drawing.Visible = false
            else
                Drawing.Enabled = false
            end
        end
    end
end
end

RunService.RenderStepped:Connect(function()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            if not Visuals.Drawings[Player] then
                Utils.ThreadFunction(function()
                    Visuals:Make({ Player = Player })
                end, "Visuals:Make")
            end
        end
    end
    for _, Drawing in pairs(Visuals.Drawings) do
        Utils.ThreadFunction(function()
            Drawing:Update()
        end, "Drawing:Update")
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    if Visuals.Drawings[Player] then
        Visuals.Drawings[Player]:Remove()
    end
end)


--#endregion

RunService.RenderStepped:Connect(function()
    local MousePos = UserInputService:GetMouseLocation()
    Fov.Position = Vector2.new(MousePos.x, MousePos.y)
    Fov.Visible = Toggles.SilentAimFov.Value
    Fov.Radius = Options.SilentAimFovSize.Value
end)

local Track = Instance.new("Animation")
Track.AnimationId = "rbxassetid://10714003221"
local Animation
RunService.Heartbeat:Connect(function()
    if not Toggles.Invisible.Value then
        if Animation then
            Animation:Stop()
            Animation = nil
        end
        return
    end

    if not Animation and Character:FindFirstChild('Humanoid') then
        Animation = Character:FindFirstChild('Humanoid'):LoadAnimation(Track)
    end
    Animation:Play(0, 1, 0)
    Animation.TimePosition = 1.48


    if Character and Character:FindFirstChild('HumanoidRootPart') then
        local OldHrp = Character.HumanoidRootPart.CFrame
        local oldVel = Character.HumanoidRootPart.AssemblyLinearVelocity
        Character.HumanoidRootPart.CFrame = OldHrp - Vector3.new(0, Options.InvisibleOffSet.Value, 0)
        RunService.RenderStepped:Wait()
        Character.HumanoidRootPart.CFrame = OldHrp
        Character.HumanoidRootPart.AssemblyLinearVelocity = oldVel
    end
end)

local OldCreateBullet
OldCreateBullet = hookfunction(Bullet.CreateBullet, function(_, weapon, weaponModel, playerData, firePosition, ...)
    local Ammo = Utils.GetAmmoInfo(select(2, ...))
    local Closest = Utils.GetClosestPlayerToMouse()

    local Parts = {}
    for Part, Enabled in Options.TargetPartsSilentAim.Value do
        if Enabled then
            table.insert(Parts, Part)
        end
    end
    local TargetPart = Parts[math.random(#Parts)]

    if not Toggles.SilentAim.Value or not Closest or #Parts == 0 then
        return OldCreateBullet(_, weapon, weaponModel, playerData, firePosition, ...)
    end

    local Prediction = Utils.PredictVelocity(Closest[TargetPart], Ammo:GetAttribute('MuzzleVelocity'))

    firePosition.CFrame = CFrame.new(
        firePosition.Position + (Toggles.Invisible.Value and Vector3.new(0, Options.InvisibleOffSet.Value, 0) or Vector3.new(0, 0, 0)),
        Prediction
    )

    return OldCreateBullet(_, weapon, weaponModel, playerData, firePosition, ...)
end)


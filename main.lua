--https://discord.gg/aGYKCdXnPm

local Services = setmetatable({}, {__index = function(_, k) return cloneref(game:GetService(k)) end})

local Workspace = Services.Workspace
local Camera = Workspace.CurrentCamera

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local RunService = Services.RunService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local Lighting = Services.Lighting

local Bullet = require(ReplicatedStorage.Modules.FPS.Bullet)
local AmmoTypes = ReplicatedStorage.AmmoTypes
local Detections = {10,13,8,9}


local Fov = Drawing.new("Circle") Fov.Thickness, Fov.NumSides, Fov.Filled, Fov.Color = 1.5, 360, false, Color3.fromRGB(255, 255, 255)
local Indicator = Drawing.new('Text') Indicator.Center = true Indicator.Size = 15 Indicator.Font = 2 Indicator.Color = Color3.fromRGB(255, 255, 255) Indicator.Outline = true
local Snap = Drawing.new('Line') Snap.Thickness = 2.5 Snap.Color = Color3.fromRGB(255, 255, 255) Snap.Visible = false

local Utils = {}
do
    Utils.GetClosestPlayerToMouse = function()
        local MousePosition = UserInputService:GetMouseLocation()
        local Closest, ClosestDistance = nil, math.huge
    
        for _, Player in Players:GetPlayers() do
            if Player == LocalPlayer or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                continue
            end
    
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    
            if not OnScreen then continue end
    
            local Direction = (Root.Position - Camera.CFrame.Position).Unit * 5000
            local RaycastParams = RaycastParams.new()
            RaycastParams.FilterDescendantsInstances = {Character}
            RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
		    local Ray = workspace:Raycast(Camera.CFrame.Position, Direction, RaycastParams)

            if Ray and Ray.Instance:IsDescendantOf(Player.Character) then
                local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePosition).Magnitude
    
                if Distance > Fov.Radius then continue end
    
                if Distance < ClosestDistance then
                    Closest = Player.Character
                    ClosestDistance = Distance
                end
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

    SilentAimBox:AddToggle('Indicator', {
        Text = 'Indicator',
        Default = false,
        Tooltip = '',
    })

    SilentAimBox:AddToggle('SilentAimFov', {
        Text = 'Show FOV',
        Default = false,
        Tooltip = '',
    })

    SilentAimBox:AddToggle('FreezeTarget', {
        Text = 'Freeze target',
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

    GunMods:AddToggle('NoRecoil', {
        Text = 'No recoil',
        Default = false,
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

    EspBox:AddLabel(' ')

    EspBox:AddToggle('SnapLines', {
        Text = 'Snap lines',
        Default = false,
        Tooltip = '',
    })

    EspBox:AddToggle('HighlightTarget', {
        Text = 'Highlight target',
        Default = false,
        Tooltip = '',
    })

    World:AddToggle('NoFog', {
        Text = 'No fog',
        Default = false,
        Tooltip = '',
    })
    World:AddToggle('FullBright', {
        Text = 'Full bright',
        Default = false,
        Tooltip = '',
    })

end

do -- Misc Tab
    local Tab = Window:AddTab('Misc')

    local Miscbox = Tab:AddLeftGroupbox('Misc')
    local Character = Tab:AddRightGroupbox('Character')

    Miscbox:AddToggle('Invisible', {
        Text = 'Invisible',
        Default = false,
        Tooltip = 'Hide underground making you invisible to AI and players',
    }):AddKeyPicker('InvisibleBind', { Default = 'K', NoUI = false, Text = 'Invisible', SyncToggleState = true})

    Miscbox:AddSlider('InvisibleOffSet', {
        Text = 'Position Offset',
        Default = 2,
        Min = 0,
        Max = 2.8,
        Rounding = 1,
        Compact = false,
        Tooltip = 'Determines how far underground you go',
    })

    Miscbox:AddLabel('Above 2 gets buggy')
    Miscbox:AddLabel('Do not crouch while invisible') 


    Character:AddToggle('Wsenabled', {
        Text = 'Enabled',
        Default = false,
        Tooltip = '',
    })
    Character:AddSlider('WalkSpeed', {
        Text = 'Walkspeed',
        Default = 18,
        Min = 0,
        Max = 25,
        Rounding = 0,
        Compact = false,
        Tooltip = '',
    })

    Character:AddToggle('Jpenabled', {
        Text = 'Enabled',
        Default = false,
        Tooltip = '',
    })
    Character:AddSlider('Jumppowe1r', {
        Text = 'Jump power',
        Default = 5,
        Min = 0,
        Max = 10,
        Rounding = 0,
        Compact = false,
        Tooltip = '',
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
        if not (Properties and Properties.Player) then return end

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
        }, { __index = Visuals })

        local draw = Self.Drawings
        draw.BoxFill.Visible = false
        draw.BoxFill.Transparency = 0.4
        draw.BoxFill.Color = Color3.fromRGB(255, 255, 255)
        draw.BoxFill.ZIndex = 3

        draw.Box.Thickness = 0.8
        draw.Box.Filled = false
        draw.Box.Color = Color3.fromRGB(255, 255, 255)
        draw.Box.Visible = false
        draw.Box.ZIndex = 5

        draw.BoxOutline.Thickness = 2.8
        draw.BoxOutline.Filled = false
        draw.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        draw.BoxOutline.Visible = false
        draw.BoxOutline.ZIndex = 1

        draw.Name.Text = Self.Player.Name
        draw.Name.Center = true
        draw.Name.Size = 16
        draw.Name.Font = 2
        draw.Name.Visible = false
        draw.Name.Outline = true
        draw.Name.Color = Color3.fromRGB(255, 255, 255)

        draw.HpBarOutline.Thickness = 1.5
        draw.HpBarOutline.Filled = true
        draw.HpBarOutline.Visible = false
        draw.HpBarOutline.Color = Color3.fromRGB(0, 0, 0)

        draw.Hpbar.Thickness = 1.5
        draw.Hpbar.Filled = true
        draw.Hpbar.Visible = false

        draw.HealthText.Text = "0"
        draw.HealthText.Center = true
        draw.HealthText.Size = 13
        draw.HealthText.Font = 2
        draw.HealthText.Visible = false
        draw.HealthText.Outline = true

        draw.Distance.Text = "0 s"
        draw.Distance.Center = true
        draw.Distance.Size = 16
        draw.Distance.Font = 2
        draw.Distance.Visible = false
        draw.Distance.Outline = true

        draw.Highlight.Enabled = false
        draw.Highlight.Adornee = Utils.GetCharacter(Self.Player)
        draw.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
        draw.Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        draw.Highlight.FillTransparency = 0.5
        draw.Highlight.OutlineTransparency = 0

        Visuals.Drawings[Properties.Player] = Self
        return Self
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

    if Toggles.Wsenabled.Value then
		if Character:FindFirstChild("Humanoid") then
        	Character.Humanoid.WalkSpeed = Options.WalkSpeed.Value
		end
	end
    if Toggles.Jpenabled.Value then
		if Character:FindFirstChild("Humanoid") then
       		Character.Humanoid.JumpHeight = Options.Jumppowe1r.Value
		end
    end

    local ClosestPlayer = Utils.GetClosestPlayerToMouse()
    local headPosition = ClosestPlayer and ClosestPlayer and ClosestPlayer:FindFirstChild("Head")

    Indicator.Position = UserInputService:GetMouseLocation() + Vector2.new(0,20)
    Indicator.Visible = Toggles.Indicator.Value
    Indicator.Text = ClosestPlayer and ClosestPlayer.Name or ''

    Snap.From = UserInputService:GetMouseLocation()

    if headPosition then
        local headScreenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(headPosition.Position)
        if onScreen then
            Snap.To = Vector2.new(headScreenPosition.X, headScreenPosition.Y)
            Snap.Visible = Toggles.SnapLines.Value
        else
            Snap.Visible = false
        end
    else
        Snap.Visible = false
    end

    if Toggles.FullBright.Value then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end 

    if Toggles.NoFog.Value then Lighting.Atmosphere.Density = 0 Lighting.FogEnd = 100000 end 

end)


local Track = Instance.new("Animation")
Track.AnimationId = "rbxassetid://10147821284"
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
    pcall(function()
        Animation:Play(0, 1, 0)
        Animation.TimePosition = 1.9
    end)


    if Character and Character:FindFirstChild('HumanoidRootPart') then
        local OldHrp = Character.HumanoidRootPart.CFrame
        local oldVel = Character.HumanoidRootPart.AssemblyLinearVelocity
        Character.HumanoidRootPart.CFrame -= Vector3.new(0, Options.InvisibleOffSet.Value, 0)
        Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, 0, math.pi)
        RunService.RenderStepped:Wait()
        Character.HumanoidRootPart.CFrame = OldHrp
        Character.HumanoidRootPart.AssemblyLinearVelocity = oldVel
        Camera.CFrame += Vector3.new(0, Options.InvisibleOffSet.Value + 3, 0)
    end
end)

--Hookers

local Bypass;
Bypass = hookmetamethod(game,"__namecall", function(self, ...)
        if getnamecallmethod() == "FireServer" and self.Name == 'ProjectileInflict' then
            local Args = {...}
            if table.find(Detections, Args[3]) then
                print('Prevented detection')
                return coroutine.yield()
            end
        end
    return Bypass(self, ...)
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

	if Toggles.FreezeTarget.Value then
		task.spawn(function()
			local Time = tick() + 1
			while tick() < Time do
				Closest.PrimaryPart.Anchored = true
				task.wait()
			end

			Closest.PrimaryPart.Anchored = false
		end)
	end


    local Prediction
    if not Toggles.FreezeTarget.Value then
        Prediction = Utils.PredictVelocity(Closest[TargetPart], Ammo:GetAttribute('MuzzleVelocity'))
    end

    firePosition.CFrame = CFrame.new(
        firePosition.Position + (Toggles.Invisible.Value and Vector3.new(0, Options.InvisibleOffSet.Value - 2.1, 0) or Vector3.new(0, 0, 0)),
        Prediction or Closest[TargetPart].Position
    )

    return OldCreateBullet(_, weapon, weaponModel, playerData, firePosition, ...)
end)

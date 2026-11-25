local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Variaveis de Controle Geral
local InfiniteJumpEnabled = false
local noclipEnabled = false
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
end)

-- Loop do Noclip (Unificado)
RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ==========================================
-- ABA 2 - CLIENTE
-- ==========================================
local Tab2 = Window:MakeTab({ "| Cliente", "user" })

Tab2:AddSlider({
    Name = "VELOCIDADE",
    Increase = 1,
    MinValue = 16,
    MaxValue = 1000,
    Default = 16,
    Callback = function(Value)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = Value end
    end
})
 
Tab2:AddSlider({
    Name = "PULO",
    Increase = 1,
    MinValue = 50,
    MaxValue = 500,
    Default = 50,
    Callback = function(Value)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = Value end
    end
})
 
Tab2:AddSlider({
    Name = "GRAVIDADE",
    Increase = 1,
    MinValue = 0,
    MaxValue = 10000,
    Default = 196.2,
    Callback = function(Value)
        Workspace.Gravity = Value
    end
})

-- Loop Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Tab2:AddButton({
    Name = "REDEFINIR VELOCIDADE/GRAVIDADE/ PULO",
    Callback = function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        Workspace.Gravity = 196.2
        InfiniteJumpEnabled = false
    end
})

Tab2:AddSection({ Name = "Outros" })

local SpinConnection
local SpinSpeed = 0.5

Tab2:AddTextBox({
    Name = "Velocidade do Spin",
    PlaceholderText = "Digite a velocidade",
    ClearText = false,
    Callback = function(Value)
        local Number = tonumber(Value)
        if Number then SpinSpeed = Number end
    end
})

Tab2:AddToggle({
    Name = "Spin",
    Description = "Gira o Personagem Infinitamente",
    Default = false,
    Callback = function(Value)
        if SpinConnection then SpinConnection:Disconnect() end
        if Value then
            SpinConnection = RunService.RenderStepped:Connect(function(dt)
                local Root = character and character:FindFirstChild("HumanoidRootPart")
                if Root then
                    Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(360 * SpinSpeed * dt), 0)
                end
            end)
        else
            SpinConnection = nil
        end
    end
})

Tab2:AddToggle({
    Name = "PULO INFINITO",
    Default = false,
    Callback = function(Value)
       InfiniteJumpEnabled = Value
    end
})

----------------------------------------------------
-- FLOAT V1 + V2 (SAGAZx HUB) - autocontido
----------------------------------------------------
do
    local Players     = game:GetService("Players")
    local RunService  = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local function makeFloat(isV2)
        local state = {
            Enabled = false,
            Part = nil,
            Render = nil,
            Jump = nil,
            TargetY = 0,
            IsV2 = isV2
        }

        local function disconnectAll()
            if state.Render then state.Render:Disconnect(); state.Render = nil end
            if state.Jump   then state.Jump:Disconnect();   state.Jump   = nil end
        end

        local function disable()
            state.Enabled = false
            disconnectAll()
            if state.Part then state.Part:Destroy(); state.Part = nil end
        end

        local function enable()
            if state.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end

            local root = char:FindFirstChild("HumanoidRootPart")
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end

            state.Enabled = true
            state.TargetY = root.Position.Y - (hum.HipHeight + 1.5)

            state.Part = Instance.new("Part")
            state.Part.Name          = "SAGAZ_Float_" .. (isV2 and "V2" or "V1")
            state.Part.Size          = Vector3.new(7, 1, 7)
            state.Part.Transparency  = 1
            state.Part.Anchored      = true
            state.Part.CanCollide    = true
            state.Part.Parent        = workspace

            -- Pulo
            state.Jump = hum.Jumping:Connect(function()
                if not state.Part then return end
                state.Part.CanCollide = false

                task.spawn(function()
                    local r = root
                    while r and r.Parent and r.AssemblyLinearVelocity.Y > 0 do
                        task.wait()
                    end
                    if state.Part then
                        if not isV2 and r and r.Parent then
                            local h = char:FindFirstChildOfClass("Humanoid")
                            if h then
                                state.TargetY = r.Position.Y - (h.HipHeight + 1.5)
                            end
                        end
                        state.Part.CanCollide = true
                    end
                end)
            end)

            -- Render
            state.Render = RunService.RenderStepped:Connect(function()
                local c = LocalPlayer.Character
                if not state.Part or not c then return end
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if not r or not h then return end

                state.Part.Position = Vector3.new(r.Position.X, state.TargetY, r.Position.Z)

                local st = h:GetState()
                local grounded =
                    st == Enum.HumanoidStateType.Running
                    or st == Enum.HumanoidStateType.RunningNoPhysics
                    or st == Enum.HumanoidStateType.Landed
                    or st == Enum.HumanoidStateType.Seated

                if grounded and state.Part.CanCollide then
                    r.AssemblyLinearVelocity =
                        Vector3.new(r.AssemblyLinearVelocity.X, 0, r.AssemblyLinearVelocity.Z)
                end
            end)
        end

        return {
            SetState = function(v) if v then enable() else disable() end end,
            Disable  = disable
        }
    end

    local FloatV1 = makeFloat(false)
    local FloatV2 = makeFloat(true)

    LocalPlayer.CharacterAdded:Connect(function()
        FloatV1.Disable()
        FloatV2.Disable()
    end)

    Tab2:AddToggle({
        Name = "Float",
        Default = false,
        Callback = function(v) FloatV1.SetState(v) end
    })

    Tab2:AddToggle({
        Name = "Float v2",
        Default = false,
        Callback = function(v) FloatV2.SetState(v) end
    })
end

Tab2:AddToggle({
    Name = "NOCLIP",
    Description = "ATRAVESSA PAREDES",
    Default = false,
    Callback = function(v)
        noclipEnabled = v
    end
})

Tab2:AddToggle({
    Name = "FullBright",
    Description = "Deixa o Mapa iluminado",
    Default = false,
    Callback = function(Value)
        if Value then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            Lighting.Brightness = 1
        end
    end
})

local Swimming = false
local OldGravity = Workspace.Gravity
local SwimBeat
local GravReset

Tab2:AddToggle({
    Name = "Swim",
    Description = "Nadar Sem Água",
    Default = false,
    Callback = function(Value)
        if not character then return end
        local Humanoid = character:FindFirstChildWhichIsA("Humanoid")
        local Root = character:FindFirstChild("HumanoidRootPart")
        if not Humanoid or not Root then return end

        if Value then
            OldGravity = Workspace.Gravity
            Workspace.Gravity = 0

            GravReset = Humanoid.Died:Connect(function()
                Workspace.Gravity = OldGravity
                Swimming = false
            end)

            for _, State in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                if State ~= Enum.HumanoidStateType.None then
                    Humanoid:SetStateEnabled(State, false)
                end
            end

            Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

            SwimBeat = RunService.Heartbeat:Connect(function()
                if Humanoid.MoveDirection.Magnitude > 0 then
                    Root.Velocity = Humanoid.MoveDirection * 20
                elseif UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    Root.Velocity = Vector3.new(0, 20, 0)
                else
                    Root.Velocity = Vector3.zero
                end
                Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            end)
            Swimming = true
        else
            Workspace.Gravity = OldGravity
            Swimming = false

            if GravReset then GravReset:Disconnect() GravReset = nil end
            if SwimBeat then SwimBeat:Disconnect() SwimBeat = nil end

            for _, State in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                if State ~= Enum.HumanoidStateType.None then
                    Humanoid:SetStateEnabled(State, true)
                end
            end
        end
    end
})

local LayConnection
Tab2:AddToggle({
    Name = "Deitar",
    Description = "Deita no Chão",
    Default = false,
    Callback = function(Value)
        if not character then return end
        local Humanoid = character:FindFirstChildWhichIsA("Humanoid")
        local Root = character:FindFirstChild("HumanoidRootPart")
        if not Humanoid or not Root then return end

        if Value then
            LayConnection = RunService.Heartbeat:Connect(function()
                Humanoid.PlatformStand = true
                Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(math.rad(90), Root.Orientation.Y * math.pi / 180, 0)
            end)
        else
            if LayConnection then LayConnection:Disconnect() LayConnection = nil end
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
})

Tab2:AddButton({
    Name = "Jerk",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
    end
})

Tab2:AddButton({
    Name = "Sit",
    Description = "Faz o Personagem Sentar",
    Callback = function()
        if character then
            local Humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then Humanoid.Sit = true end
        end
    end
})

Tab2:AddButton({
    Name = "Tp Tool",
    Description = "Teleporta Você Para Onde Você Clicar",
    Callback = function()
        if LocalPlayer.Backpack:FindFirstChild("Tp Tool") then return end
        local Mouse = LocalPlayer:GetMouse()
        local Tool = Instance.new("Tool")
        Tool.Name = "Tp Tool"
        Tool.RequiresHandle = false
        Tool.TextureId = "rbxassetid://1234567890"

        Tool.Activated:Connect(function()
            local Root = character and character:FindFirstChild("HumanoidRootPart")
            if Root then
                Root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 2.5, 0))
            end
        end)
        Tool.Parent = LocalPlayer.Backpack
    end
})

-- ==========================================
-- SEÇÃO ESPIÃO (COLOCADA NA COREGUI)
-- ==========================================
Tab2:AddSection({ Name = "Espião" })

local viewing = false
local playerList = {}
local currentIndex = 1
local screenGui
local lastPlayerName = nil

local function UpdatePlayerList()
    playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(playerList, plr) end
    end
    table.sort(playerList, function(a,b) return a.Name < b.Name end)
end

local function GetCurrentPlayer() return playerList[currentIndex] end

local function Spectate(plr)
    if not plr then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:FindFirstChild("Humanoid")
    if hum then cam.CameraSubject = hum end
end

local function ResetCamera()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then cam.CameraSubject = char.Humanoid end
end

local function CreateUI()
    if screenGui then screenGui:Destroy() end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EspiaoCoreGui"
    screenGui.Parent = CoreGui

    local back = Instance.new("TextButton", screenGui)
    back.Size = UDim2.new(0, 60, 0, 60)
    back.Position = UDim2.new(0, 412, 0, 425)
    back.Text = "<"
    back.TextSize = 50
    back.BackgroundColor3 = Color3.fromRGB(108,108,108)
    Instance.new("UICorner", back)

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(1, -688, 0, 425)
    frame.BackgroundColor3 = Color3.fromRGB(108,108,108)
    Instance.new("UICorner", frame)

    local img = Instance.new("ImageLabel", frame)
    img.Size = UDim2.new(0,40,0,40)
    img.Position = UDim2.new(0,10,0,10)
    img.BackgroundTransparency = 1

    local titulo = Instance.new("TextLabel", frame)
    titulo.Size = UDim2.new(1,-60,0,20)
    titulo.Position = UDim2.new(0,60,0,8)
    titulo.Text = "Espionando:"
    titulo.TextColor3 = Color3.new(1,1,1)
    titulo.BackgroundTransparency = 1
    titulo.Font = Enum.Font.GothamBold
    titulo.TextSize = 15
    titulo.TextXAlignment = Enum.TextXAlignment.Left

    local username = Instance.new("TextLabel", frame)
    username.Size = UDim2.new(1,-60,0,18)
    username.Position = UDim2.new(0,60,0,30)
    username.BackgroundTransparency = 1
    username.TextColor3 = Color3.new(1,1,1)
    username.Font = Enum.Font.Gotham
    username.TextSize = 12
    username.TextXAlignment = Enum.TextXAlignment.Left

    local nextBtn = Instance.new("TextButton", screenGui)
    nextBtn.Size = UDim2.new(0, 60, 0, 60)
    nextBtn.Position = UDim2.new(0, 685, 0, 425)
    nextBtn.Text = ">"
    nextBtn.TextSize = 50
    nextBtn.BackgroundColor3 = Color3.fromRGB(108,108,108)
    Instance.new("UICorner", nextBtn)

    local function UpdateUI()
        local plr = GetCurrentPlayer()
        if not plr then return end
        lastPlayerName = plr.Name
        username.Text = "@" .. plr.Name
        img.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=150&height=150&format=png"
        Spectate(plr)
    end

    back.MouseButton1Click:Connect(function()
        if #playerList == 0 then return end
        currentIndex = currentIndex - 1
        if currentIndex < 1 then currentIndex = #playerList end
        UpdateUI()
    end)

    nextBtn.MouseButton1Click:Connect(function()
        if #playerList == 0 then return end
        currentIndex = currentIndex + 1
        if currentIndex > #playerList then currentIndex = 1 end
        UpdateUI()
    end)

    UpdateUI()
end



Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- ==========================================
-- GERENCIADOR DE ESP & CORES UNIFICADO
-- ==========================================
local selectedColor = "RGB"
local espEnabled = false
local billboardGuis = {}
local connections = {}

-- Variáveis para os Cones
local ActiveEsps = {}
local EspConesEnabled = false
local TargetFolder = Workspace:WaitForChild("WorkspaceCom", 10):WaitForChild("001_TrafficCones", 10)

local function getESPColor()
    if selectedColor == "RGB" then
        local h = (tick() % 5) / 5
        return Color3.fromHSV(h, 1, 1)
    elseif selectedColor == "Preto" then return Color3.fromRGB(0,0,0)
    elseif selectedColor == "Branco" then return Color3.fromRGB(255,255,255)
    elseif selectedColor == "Vermelho" then return Color3.fromRGB(255,0,0)
    elseif selectedColor == "Verde" then return Color3.fromRGB(0,255,0)
    elseif selectedColor == "Azul" then return Color3.fromRGB(0,170,255)
    elseif selectedColor == "Amarelo" then return Color3.fromRGB(255,255,0)
    elseif selectedColor == "Rosa" then return Color3.fromRGB(255,105,180)
    elseif selectedColor == "Roxo" then return Color3.fromRGB(128,0,128)
    end
    return Color3.new(1,1,1)
end

Tab2:AddDropdown({
    Name = "COR DO ESP",
    Default = "RGB",
    Options = {"RGB", "Branco", "Preto", "Vermelho", "Verde", "Azul", "Amarelo", "Rosa", "Roxo"},
    Search = true,
    Callback = function(value)
        selectedColor = value
        local color = getESPColor()
        for _, gui in pairs(billboardGuis) do
            if gui and gui:FindFirstChild("TextLabel") then gui.TextLabel.TextColor3 = color end
        end
        for _, data in pairs(ActiveEsps) do
            if data.Label then data.Label.TextColor3 = color end
            if data.Highlight then data.Highlight.OutlineColor = color end
        end
    end
})

Tab2:AddToggle({
    Name = "Espiona Todos Os Players",
    Default = false,
    Callback = function(Value)
        viewing = Value
        if viewing then
            UpdatePlayerList()
            if #playerList == 0 then return end
            currentIndex = 1
            if lastPlayerName then
                for i, plr in ipairs(playerList) do
                    if plr.Name == lastPlayerName then currentIndex = i break end
                end
            end
            CreateUI()
            Spectate(GetCurrentPlayer())
        else
            if screenGui then screenGui:Destroy() screenGui = nil end
            ResetCamera()
        end
    end
})

-- Funções ESP Players
local function updateESP(player)
    if player == LocalPlayer or not espEnabled then return end
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    local gui = billboardGuis[player]
    if gui and gui:FindFirstChild("TextLabel") then
        gui.TextLabel.TextColor3 = getESPColor()
        return
    elseif gui then
        gui:Destroy()
    end

    local billboard = Instance.new("BillboardGui", head)
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Text = player.Name .. " | " .. player.AccountAge .. " dias"
    textLabel.TextColor3 = getESPColor()

    billboardGuis[player] = billboard
end

local function removeESP(player)
    if billboardGuis[player] then
        billboardGuis[player]:Destroy()
        billboardGuis[player] = nil
    end
end

Tab2:AddToggle({
    Name = "ESP PLAYERS",
    Description = "MOSTRA NOME E DIAS DOS PLAYERS",
    Default = false,
    Callback = function(value)
        espEnabled = value
        if espEnabled then
            for _, player in pairs(Players:GetPlayers()) do updateESP(player) end
            table.insert(connections, Players.PlayerAdded:Connect(function(p)
                updateESP(p)
                table.insert(connections, p.CharacterAdded:Connect(function() updateESP(p) end))
            end))
            table.insert(connections, Players.PlayerRemoving:Connect(removeESP))
        else
            for _, player in pairs(Players:GetPlayers()) do removeESP(player) end
            for _, conn in pairs(connections) do conn:Disconnect() end
            connections = {}
            billboardGuis = {}
        end
    end
})

-- ==========================================
-- ESP TRAFFIC CONES (LIMPO E LONGO ALCANCE)
-- ==========================================
local function CreateConeEsp(model)
    if not model:IsA("Model") or ActiveEsps[model] then return end
    local adornPart = model:FindFirstChildWhichIsA("BasePart")
    if not adornPart then return end

    local espData = {}
    local currentColor = getESPColor()

    -- Remove o prefixo "Prop_" ou "Prop" deixando apenas o nome real do player
    local cleanName = string.gsub(model.Name, "^Prop_?", "")

    -- Visto de muito longe e através de paredes (AlwaysOnTop)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZsgdHighlight"
    highlight.FillColor = currentColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = currentColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = model
    highlight.Parent = model
    espData.Highlight = highlight

    local billboard = Instance.new("BillboardGui", model)
    billboard.Name = "ZsgdBillboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = adornPart
    espData.Billboard = billboard

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = cleanName
    label.TextColor3 = currentColor
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    espData.Label = label

    ActiveEsps[model] = espData
end

local function RemoveConeEsp(model)
    local data = ActiveEsps[model]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        ActiveEsps[model] = nil
    end
end

local function CleanAllConeEsps()
    for model, _ in pairs(ActiveEsps) do RemoveConeEsp(model) end
end

-- Loop Geral de Atualização de Cores (RGB) e Verificação de Cones
RunService.Heartbeat:Connect(function()
    local color = getESPColor()
    
    -- Atualiza Cores de Players
    if espEnabled and selectedColor == "RGB" then
        for _, player in pairs(Players:GetPlayers()) do
            local gui = billboardGuis[player]
            if gui and gui:FindFirstChild("TextLabel") then gui.TextLabel.TextColor3 = color end
        end
    end

    -- Gerenciamento do ESP de Cones
    if not EspConesEnabled or not TargetFolder then 
        CleanAllConeEsps()
        return 
    end

    for _, child in ipairs(TargetFolder:GetChildren()) do
        if string.sub(child.Name, 1, 4) == "Prop" then
            CreateConeEsp(child)
        end
    end

    for model, data in pairs(ActiveEsps) do
        if not model or not model.Parent then
            ActiveEsps[model] = nil
        else
            if selectedColor == "RGB" then
                if data.Label then data.Label.TextColor3 = color end
                if data.Highlight then data.Highlight.OutlineColor = color end
            end
        end
    end
end)

Tab2:AddToggle({
    Name = "Esp Props",
    Description = "Mostra os Props e Donos",
    Default = false,
    Callback = function(Value)
        EspConesEnabled = Value
        if not Value then CleanAllConeEsps() end
    end
})
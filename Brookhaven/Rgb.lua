do
    ----------------------------------------------------------------------------------------------------------------
    ----------------------------------------- Aba RGB -----------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------
    local RbgTab = Window:MakeTab({ Title = "| RGB", Icon = "rbxassetid://10734910187" })

    -- =========================================================
    -- SERVIÇOS E CONFIGURAÇÕES INICIAIS
    -- =========================================================
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- Tabela de Cores Padrão (RGB/HSV)
    local colorMap = {
        ["Vermelho"] = Color3.fromRGB(255, 0, 0),
        ["Verde"]    = Color3.fromRGB(0, 255, 0),
        ["Azul"]     = Color3.fromRGB(0, 0, 255),
        ["Amarelo"]  = Color3.fromRGB(255, 255, 0),
        ["Roxo"]     = Color3.fromRGB(128, 0, 128),
        ["Ciano"]    = Color3.fromRGB(0, 255, 255),
        ["Laranja"]  = Color3.fromRGB(255, 165, 0),
        ["Rosa"]     = Color3.fromRGB(255, 192, 203),
        ["Branco"]   = Color3.fromRGB(255, 255, 255)
    }

    local colorList = {"RGB", "Vermelho", "Verde", "Azul", "Amarelo", "Roxo", "Ciano", "Laranja", "Rosa", "Branco"}

    local bodyColors = {
        "Pastel brown", "Pastel yellow", "Pastel blue", "Pastel green", "Pastel pink",
        "Really red", "Bright orange", "Bright blue", "Bright violet", "Bright green",
        "Bright yellow", "White", "Black", "Dark stone grey", "Medium stone grey",
        "Light stone grey", "Bright red", "Bright yellowish green", "Bright bluish green",
        "Bright purple", "Bright pink", "Reddish brown", "Earth green", "Sand red",
        "Sand blue", "Sand green", "Dark green", "Navy blue", "Toothpaste", "Cyan",
        "Hot pink", "Crimson", "Royal purple", "Neon orange", "Neon green", "Neon pink",
        "Neon blue", "Gold", "Bright gold", "New Yeller", "Dark orange", "Deep blue",
        "Maroon", "Bright maroon"
    }

    -- Controllers e Remotes
    local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
    local ChangeBodyColor = Remotes and Remotes:WaitForChild("ChangeBodyColor", 5)

    -- Estados Globais da Aba
    local effectSpeed = 5
    local selectedColor = "RGB"
    local selectedTarget = "Nome e Bio"
    local isEffectActive = false

    local pulseSpeed = 5
    local selectedPalette = "RGB"

    -- Estados dos Toggles
    local toolActive = false
    local houseActive = false
    local houseTextActive = false
    local vehicleActive = false
    local carActive = false
    local bodyActive = false
    local hairActive = false
    local accessoriesActive = false

    -- =========================================================
    -- FUNÇÕES DE SUPORTE
    -- =========================================================
    local function fireServer(eventName, args)
        local event = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild(eventName)
        if event then
            pcall(function()
                event:FireServer(unpack(args))
            end)
        end
    end

    local function applyColor(color)
        if selectedTarget == "Nome" or selectedTarget == "Nome e Bio" then
            fireServer("1RPNam1eColo1r", { "PickingRPNameColor", color })
        end
        if selectedTarget == "Bio" or selectedTarget == "Nome e Bio" then
            fireServer("1RPNam1eColo1r", { "PickingRPBioColor", color })
        end
    end

    local function calculateDynamicColor(tickCounter)
        local brightness = 0.25 + (math.sin(tickCounter) + 1) * 0.375

        if selectedPalette == "RGB" then
            local hue = (tickCounter * 0.1) % 1
            return Color3.fromHSV(hue, 1, brightness)
        else
            local baseColor = colorMap[selectedPalette] or Color3.fromRGB(255, 255, 255)
            local h, s, _ = baseColor:ToHSV()
            return Color3.fromHSV(h, s, brightness)
        end
    end

    local function getCarColorRemote()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end

        local mainGui = playerGui:FindFirstChild("MainGUIHandler")
        if not mainGui then return nil end

        local vehicleControl = mainGui:FindFirstChild("VehicleControl")
        if not vehicleControl then return nil end

        local colorPicker = vehicleControl:FindFirstChild("UIColorPicker")
        if not colorPicker then return nil end

        return colorPicker:FindFirstChild("SetColor")
    end

    local function MudarCorDoCabelo(novaCor)
        local character = LocalPlayer.Character
        if not character then return end

        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") and child.AccessoryType == Enum.AccessoryType.Hair then
                local assetId = child:GetAttribute("AssetId") or child:GetAttribute("AcessoryId")
                if assetId then
                    pcall(function()
                        WearingController.SetAccessoryColor(assetId, novaCor)
                    end)
                end
            end
        end
    end

    local function MudarCorDeTodosOsAcessorios(novaCor)
        local character = LocalPlayer.Character
        if not character then return end

        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then
                local assetId = child:GetAttribute("AssetId") or child:GetAttribute("AcessoryId")
                if assetId then
                    pcall(function()
                        WearingController.SetAccessoryColor(assetId, novaCor)
                    end)
                end
            end
        end
    end

    local function getSetColorRemote()
        local toolGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ToolGui")
        if not toolGui then return nil end

        local toolSettings = toolGui:FindFirstChild("ToolSettings")
        if not toolSettings then return nil end

        local settings = toolSettings:FindFirstChild("Settings")
        if not settings then return nil end

        local propsColor = settings:FindFirstChild("PropsColor")
        if not propsColor then return nil end

        return propsColor:FindFirstChild("SetColor")
    end

    local function updateHouseColor(targetColor)
        pcall(function()
            local userGui = LocalPlayer:FindFirstChild("PlayerGui")
            if userGui then
                local settingsModule = userGui:FindFirstChild("Player8Handler") and userGui.Player8Handler:FindFirstChild("Game8Settings")
                if settingsModule then
                    local settingsData = require(settingsModule)
                    local colorKey = settingsData.PickingHouseColor
                    local houseRemote = settingsData.PlayersHouse
                    if houseRemote and colorKey then
                        houseRemote:FireServer(colorKey, targetColor)
                    end
                end
            end
            
            local hasPackages, packageRemotes = pcall(function() 
                return require(ReplicatedStorage.Packages.Remotes) 
            end)
            if hasPackages and packageRemotes and packageRemotes.fireServer then
                packageRemotes.fireServer("Property:SetColor", targetColor)
            end
        end)
    end

    local function fireVehicleServer(eventName, args)
        local event = ReplicatedStorage:FindFirstChild("RE")
        if event and event:FindFirstChild(eventName) then
            pcall(function()
                event[eventName]:FireServer(unpack(args))
            end)
        end
    end

    -- =========================================================
    -- CONFIGURAÇÕES DO EFEITO LENTO (NOME E BIO)
    -- =========================================================
    RbgTab:AddSection({"Configurações do Efeito Lento"})

    RbgTab:AddSlider({
        Name = "Velocidade do Efeito",
        Min = 5,
        Max = 30,
        Increase = 1,
        Default = 5,
        Callback = function(value)
            effectSpeed = value
        end
    })

    RbgTab:AddDropdown({
        Name = "Cor",
        Options = colorList,
        Default = "RGB",
        Callback = function(option)
            selectedColor = option
        end
    })

    RbgTab:AddDropdown({
        Name = "Local",
        Options = {"Nome", "Bio", "Nome e Bio"},
        Default = "Nome e Bio",
        Callback = function(option)
            selectedTarget = option
        end
    })

    RbgTab:AddToggle({
        Name = "Nome/Bio RGB",
        Description = "",
        Default = false,
        Callback = function(state)
            isEffectActive = state
            if state then
                task.spawn(function()
                    local timeOffset = 0
                    local goingDark = true

                    while isEffectActive and LocalPlayer.Character do
                        local waitTime = math.clamp(0.25 - (effectSpeed * 0.02), 0.03, 0.25)
                        local step = 0.02 * (effectSpeed / 2)

                        if selectedColor == "RGB" then
                            local hue = (timeOffset % 1)
                            local brightness = goingDark and (1 - (timeOffset % 1)) or (timeOffset % 1)
                            brightness = math.clamp(brightness, 0.1, 1)

                            applyColor(Color3.fromHSV(hue, 1, brightness))
                            timeOffset = timeOffset + step

                            if timeOffset >= 1 then
                                timeOffset = 0
                                goingDark = not goingDark
                            end
                        else
                            local baseColor = colorMap[selectedColor] or Color3.fromRGB(255, 255, 255)
                            local h, s, _ = baseColor:ToHSV()

                            local brightness = goingDark and (1 - (timeOffset % 1)) or (timeOffset % 1)
                            brightness = math.clamp(brightness, 0.15, 1)

                            applyColor(Color3.fromHSV(h, s, brightness))
                            timeOffset = timeOffset + step

                            if timeOffset >= 1 then
                                timeOffset = 0
                                goingDark = not goingDark
                            end
                        end

                        task.wait(waitTime)
                    end
                end)
            end
        end
    })

    -- =========================================================
    -- CONFIGURAÇÕES GERAIS (PULSE SPEED & PALETA)
    -- =========================================================
    RbgTab:AddSection({"OUTROS"})

    RbgTab:AddSlider({
        Name = "Velocidade do Efeito",
        Min = 5,
        Max = 30,
        Increase = 1,
        Default = 5,
        Callback = function(val)
            pulseSpeed = val
        end
    })

    RbgTab:AddDropdown({
        Name = "Seleção de Cor",
        Options = colorList,
        Default = "RGB",
        Callback = function(choice)
            selectedPalette = choice
        end
    })

    -- =========================================================
    -- TOGGLES DE EFEITOS RGB
    -- =========================================================
    RbgTab:AddSection({"RGB Em Tools"})

    RbgTab:AddToggle({
        Name = "Tools RGB",
        Description = "Aplicar RGB Em Todos os Tools",
        Default = false,
        Callback = function(enabled)
            toolActive = enabled
            if enabled then
                task.spawn(function()
                    local tickCounter = 0
                    while toolActive do
                        local delayTime = math.clamp(0.12 - (pulseSpeed * 0.003), 0.015, 0.12)
                        local step = 0.04 * (pulseSpeed / 5)

                        tickCounter = tickCounter + step
                        local currentColor = calculateDynamicColor(tickCounter)
                        
                        local setColor = getSetColorRemote()
                        if setColor then
                            pcall(function()
                                setColor:FireServer(currentColor)
                            end)
                        end

                        task.wait(delayTime)
                    end
                end)
            end
        end
    })

    RbgTab:AddSection({"RGB Em Casas"})

    RbgTab:AddToggle({
        Name = "Casa RGB",
        Description = "",
        Default = false,
        Callback = function(enabled)
            houseActive = enabled
            if enabled then
                task.spawn(function()
                    local tickCounter = 0
                    while houseActive do
                        local delayTime = math.clamp(0.12 - (pulseSpeed * 0.003), 0.015, 0.12)
                        local step = 0.04 * (pulseSpeed / 5)
                        
                        tickCounter = tickCounter + step
                        updateHouseColor(calculateDynamicColor(tickCounter))
                        
                        task.wait(delayTime)
                    end
                end)
            end
        end
    })

    RbgTab:AddToggle({
        Name = "Texto Da Casa RGB",
        Description = "",
        Default = false,
        Callback = function(enabled)
            houseTextActive = enabled
            if enabled then
                task.spawn(function()
                    local tickCounter = 0
                    while houseTextActive do
                        local delayTime = math.clamp(0.12 - (pulseSpeed * 0.003), 0.015, 0.12)
                        local step = 0.04 * (pulseSpeed / 5)
                        
                        tickCounter = tickCounter + step
                        fireVehicleServer("1RPHous1eEven1tColo1r", {
                            "PickingBusinessNameColor",
                            calculateDynamicColor(tickCounter)
                        })
                        
                        task.wait(delayTime)
                    end
                end)
            end
        end
    })

    RbgTab:AddSection({"RGB Em Veículos"})

    RbgTab:AddToggle({
        Name = "Veículo Sem Motor RGB",
        Description = "",
        Default = false,
        Callback = function(enabled)
            vehicleActive = enabled
            if enabled then
                task.spawn(function()
                    local tickCounter = 0
                    while vehicleActive do
                        local delayTime = math.clamp(0.12 - (pulseSpeed * 0.003), 0.015, 0.12)
                        local step = 0.04 * (pulseSpeed / 5)
                        
                        tickCounter = tickCounter + step
                        fireVehicleServer("1Player1sCa1r", {
                            "NoMotorColor",
                            calculateDynamicColor(tickCounter)
                        })
                        
                        task.wait(delayTime)
                    end
                end)
            end
        end
    })

    RbgTab:AddToggle({
        Name = "Carro RGB",
        Description = "Tem Que Estar Sentado No Carro",
        Default = false,
        Callback = function(enabled)
            carActive = enabled
            if enabled then
                task.spawn(function()
                    local tickCounter = 0
                    while carActive do
                        local delayTime = math.clamp(0.12 - (pulseSpeed * 0.003), 0.015, 0.12)
                        local step = 0.04 * (pulseSpeed / 5)

                        tickCounter = tickCounter + step
                        local currentColor = calculateDynamicColor(tickCounter)
                        
                        local carRemote = getCarColorRemote()
                        if carRemote then
                            pcall(function()
                                carRemote:FireServer(currentColor)
                            end)
                        end

                        task.wait(delayTime)
                    end
                end)
            end
        end
    })
    
RbgTab:AddSection({"RGB Em Pets e Kids"})

local kidsActive = false
RbgTab:AddToggle({
    Name = "RGB Kids",
    Default = false,
    Callback = function(enabled)
        kidsActive = enabled
        if enabled then
            task.spawn(function()
                local player = game:GetService("Players").LocalPlayer
                
                -- Localiza a pasta/frame com os itens de cor
                local playerGui = player:FindFirstChild("PlayerGui")
                local noReset = playerGui and playerGui:FindFirstChild("NoResetGUIHandler")
                local petsMenu = noReset and noReset:FindFirstChild("PetsKidsMenu")
                local catalog = petsMenu and petsMenu:FindFirstChild("Catalog")
                local container = catalog and catalog:FindFirstChild("Container")
                local scrollingFrame = container and container:FindFirstChild("ScrollingFrameKid2")
                local frame = scrollingFrame and scrollingFrame:FindFirstChild("Frame")

                -- Tenta obter o Remote do Game8Settings
                local remote = nil
                pcall(function()
                    local StarterGui = game:GetService("StarterGui")
                    local gameSettings = StarterGui:FindFirstChild("Player8Handler") and StarterGui.Player8Handler:FindFirstChild("Game8Settings")
                    if gameSettings then
                        local settingsData = require(gameSettings)
                        remote = settingsData.RPNameColorRemote
                    end
                end)

                if frame and remote then
                    -- Coleta os objetos de cor válidos (filtrando "Institutional white")
                    local listaObjetosCor = {}
                    for _, item in ipairs(frame:GetChildren()) do
                        if item.Name == "FollowColor" then
                            local objetoCor = item:FindFirstChild("Color")
                            if objetoCor and objetoCor.Value ~= "Institutional white" and objetoCor.Name ~= "Institutional white" then
                                table.insert(listaObjetosCor, objetoCor)
                            end
                        end
                    end

                    -- Loop de execução
                    while kidsActive and #listaObjetosCor > 0 do
                        for _, objetoCor in ipairs(listaObjetosCor) do
                            if not kidsActive then break end
                            
                            pcall(function()
                                remote:FireServer("PickingRPFollowColor", objetoCor)
                            end)

                            -- Delay dinâmico baseado na velocidade do slider
                            local dynamicWait = math.clamp(0.5 / (pulseSpeed / 5), 0.05, 0.5)
                            task.wait(dynamicWait)
                        end
                    end
                end
            end)
        end
    end
})

local petsActive = false
RbgTab:AddToggle({
    Name = "RGB Pets",
    Default = false,
    Callback = function(enabled)
        petsActive = enabled
        if enabled then
            task.spawn(function()
                local player = game:GetService("Players").LocalPlayer
                
                -- Localiza a pasta/frame com os itens de cor dos pets
                local playerGui = player:FindFirstChild("PlayerGui")
                local noReset = playerGui and playerGui:FindFirstChild("NoResetGUIHandler")
                local petsMenu = noReset and noReset:FindFirstChild("PetsKidsMenu")
                local catalog = petsMenu and petsMenu:FindFirstChild("Catalog")
                local container = catalog and catalog:FindFirstChild("Container")
                local scrollingFrame = container and container:FindFirstChild("ScrollingFramePet2")
                local frame = scrollingFrame and scrollingFrame:FindFirstChild("Frame")

                -- Tenta carregar o módulo de Remotes
                local hasPackages, Remotes = pcall(function()
                    return require(ReplicatedStorage.Packages.Remotes)
                end)

                if frame and hasPackages and Remotes and Remotes.fireServer then
                    -- Coleta as cores válidas (filtrando "Institutional white")
                    local listaCores = {}
                    for _, item in ipairs(frame:GetChildren()) do
                        if item.Name == "FollowColor" then
                            local colorObj = item:FindFirstChild("Color")
                            if colorObj and colorObj:IsA("StringValue") and colorObj.Value ~= "Institutional white" then
                                table.insert(listaCores, colorObj.Value)
                            end
                        end
                    end

                    -- Loop de execução
                    while petsActive and #listaCores > 0 do
                        for _, nomeCor in ipairs(listaCores) do
                            if not petsActive then break end
                            
                            pcall(function()
                                Remotes.fireServer("Pet_SetNameColor", nomeCor)
                            end)

                            -- Delay dinâmico baseado na velocidade do slider
                            local dynamicWait = math.clamp(0.5 / (pulseSpeed / 5), 0.05, 0.5)
                            task.wait(dynamicWait)
                        end
                    end
                end
            end)
        end
    end
})

 RbgTab:AddSection({"RGB Em Você"})

    RbgTab:AddToggle({
        Name = "Corpo RGB",
        Description = "",
        Default = false,
        Callback = function(enabled)
            bodyActive = enabled
            if enabled and ChangeBodyColor then
                task.spawn(function()
                    while bodyActive do
                        for _, colorName in ipairs(bodyColors) do
                            if not bodyActive then break end
                            pcall(function()
                                ChangeBodyColor:FireServer(colorName)
                            end)
                            local dynamicWait = math.clamp(0.3 / (pulseSpeed / 5), 0.05, 0.5)
                            task.wait(dynamicWait)
                        end
                    end
                end)
            end
        end
    })

    RbgTab:AddToggle({
        Name = "Cabelo RGB",
        Description = "",
        Default = false,
        Callback = function(enabled)
            hairActive = enabled
            if enabled then
                task.spawn(function()
                    local tickCounter = 0
                    while hairActive do
                        local delayTime = math.clamp(0.12 - (pulseSpeed * 0.003), 0.015, 0.12)
                        local step = 0.04 * (pulseSpeed / 5)
                        
                        tickCounter = tickCounter + step
                        MudarCorDoCabelo(calculateDynamicColor(tickCounter))
                        
                        task.wait(delayTime)
                    end
                end)
            end
        end
    })

    RbgTab:AddToggle({
        Name = "Acessórios RGB",
        Description = "",
        Default = false,
        Callback = function(enabled)
            accessoriesActive = enabled
            if enabled then
                task.spawn(function()
                    local tickCounter = 0
                    while accessoriesActive do
                        local delayTime = math.clamp(0.12 - (pulseSpeed * 0.003), 0.015, 0.12)
                        local step = 0.04 * (pulseSpeed / 5)
                        
                        tickCounter = tickCounter + step
                        MudarCorDeTodosOsAcessorios(calculateDynamicColor(tickCounter))
                        
                        task.wait(delayTime)
                    end
                end)
            end
        end
    })
end

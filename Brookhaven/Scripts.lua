local TabScript = Window:MakeTab({"| Scripts ", "code"})

TabScript:AddSection({ Name = "Scripts Brookhaven" })


TabScript:AddButton({
    Name = "Interface de Botões Antigas do Brookhaven(Irreversível)",
    Description = "Meio Bugado",
    Callback = function()
        -- ====================================================================
        -- PROTEÇÃO CONTRA DUPLA EXECUÇÃO
        -- ====================================================================
        if _G.ScriptJaExecutado then
            warn("O script já foi executado! Ignorando nova execução.")
            return
        end
        _G.ScriptJaExecutado = true

        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local MainGUIHandler = PlayerGui:WaitForChild("MainGUIHandler")
        local MainButtons = MainGUIHandler:WaitForChild("MainButtons")
        local NoResetGUIHandler = PlayerGui:WaitForChild("NoResetGUIHandler")

        -- 0. DESATIVA O FRAME "New"
        local newFrame = MainButtons:FindFirstChild("New")
        if newFrame then
            newFrame.Visible = false
        end

        -- ====================================================================
        -- 1. EXCLUI OS BOTÕES "005Close" DOS CAMINHOS ESPECIFICADOS
        -- ====================================================================
        local caminhosClose = {
            {"NoResetGUIHandler", "CharacterThemeMenu", "Catalog", "Header", "CategoryTabs", "005Close"},
            {"NoResetGUIHandler", "CharacterNameMenu", "Catalog", "Header", "CategoryTabs", "005Close"},
            {"NoResetGUIHandler", "CharacterJobMenu", "Catalog", "Header", "CategoryTabs", "005Close"},
            {"NoResetGUIHandler", "PetsKidsMenu", "Catalog", "Header", "CategoryTabs", "005Close"}
        }

        for _, caminho in ipairs(caminhosClose) do
            local obj = PlayerGui
            for _, nome in ipairs(caminho) do
                if obj then
                    obj = obj:FindFirstChild(nome)
                end
            end
            if obj then
                obj:Destroy()
            end
        end

        -- ====================================================================
        -- 2. RECONFIGURA O CATEGORYTABS E UILISTLAYOUT DO PETSKIDSMENU
        -- ====================================================================
        local petsKidsTabs = NoResetGUIHandler:FindFirstChild("PetsKidsMenu")
            and NoResetGUIHandler.PetsKidsMenu:FindFirstChild("Catalog")
            and NoResetGUIHandler.PetsKidsMenu.Catalog:FindFirstChild("Header")
            and NoResetGUIHandler.PetsKidsMenu.Catalog.Header:FindFirstChild("CategoryTabs")

        if petsKidsTabs then
            petsKidsTabs.Size = UDim2.new(0, 300, 0, 29)
            petsKidsTabs.Position = UDim2.new(0, 10, 0, 18)

            local uiListLayout = petsKidsTabs:FindFirstChildOfClass("UIListLayout")
            if uiListLayout then
                uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            end
        end

        -- ====================================================================
        -- 3. GERENCIAMENTO E DESATIVAÇÃO DOS FRAMES
        -- ====================================================================
        local menusParaGerenciar = {
            NoResetGUIHandler:FindFirstChild("PetsKidsMenu"),
            NoResetGUIHandler:FindFirstChild("CharacterThemeMenu"),
            NoResetGUIHandler:FindFirstChild("CharacterNameMenu"),
            NoResetGUIHandler:FindFirstChild("CharacterJobMenu")
        }

        local function fecharTodosOsMenus()
            for _, menu in ipairs(menusParaGerenciar) do
                if menu then
                    menu.Visible = false
                end
            end
        end

        -- Variável para guardar o último menu ativado (Inicia com CharacterNameMenu como padrão)
        local ultimoMenuAtivo = NoResetGUIHandler:FindFirstChild("CharacterNameMenu")

        -- Monitora trocas de menu para salvar a última escolha
        for _, menu in ipairs(menusParaGerenciar) do
            if menu then
                menu:GetPropertyChangedSignal("Visible"):Connect(function()
                    if menu.Visible then
                        ultimoMenuAtivo = menu
                    end
                end)
            end
        end

        -- ====================================================================
        -- 4. ESTRUTURA DOS FRAMES (FramePaiCustom e FrameFilhoCustom)
        -- ====================================================================
        if MainButtons:FindFirstChild("FramePaiCustom") then
            MainButtons.FramePaiCustom:Destroy()
        end

        local FramePai = Instance.new("Frame")
        FramePai.Name = "FramePaiCustom"
        FramePai.Size = UDim2.new(1, 0, 1, 0)
        FramePai.Active = false
        FramePai.BackgroundTransparency = 1
        FramePai.Parent = MainButtons

        local FrameFilho = Instance.new("Frame")
        FrameFilho.Name = "FrameFilhoCustom"
        FrameFilho.Size = UDim2.new(0, 70, 0, 400)
        FrameFilho.AnchorPoint = Vector2.new(1, 0)
        FrameFilho.Position = UDim2.new(1, 0, 0, 0)
        FrameFilho.BackgroundTransparency = 1
        FrameFilho.Parent = FramePai

        -- ====================================================================
        -- 5. CLONAGEM DO SLIDE
        -- ====================================================================
        local SlideClonado = nil
        local targetSlide = newFrame 
            and newFrame:FindFirstChild("Frame") 
            and newFrame.Frame:FindFirstChild("Frame") 
            and newFrame.Frame.Frame:FindFirstChild("Slide")

        if targetSlide then
            SlideClonado = targetSlide:Clone()
            SlideClonado.Size = UDim2.new(0, 300, 0, 60)
            SlideClonado.Position = UDim2.new(0, 713, 0, 25)
            SlideClonado.Visible = false
            SlideClonado.Parent = FramePai

            local slideGridLayout = SlideClonado:FindFirstChildOfClass("UIGridLayout")
            if slideGridLayout then
                slideGridLayout.CellSize = UDim2.new(0, 70, 0, 50)
                slideGridLayout.FillDirection = Enum.FillDirection.Vertical
                slideGridLayout.FillDirectionMaxCells = 1
            end

            -- Botão vermelho no Slide
            local slideButton = Instance.new("ImageButton")
            slideButton.Name = "Z_LastSlideButton"
            slideButton.LayoutOrder = 999999
            slideButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            slideButton.BackgroundTransparency = 0.3
            slideButton.Parent = SlideClonado

            local slideBtnCorner = Instance.new("UICorner")
            slideBtnCorner.CornerRadius = UDim.new(0, 8)
            slideBtnCorner.Parent = slideButton

            local slideBtnIcon = Instance.new("ImageLabel")
            slideBtnIcon.Name = "Icon"
            slideBtnIcon.Size = UDim2.new(1, 0, 1, 0)
            slideBtnIcon.Position = UDim2.new(0, 0, 0, 0)
            slideBtnIcon.BackgroundTransparency = 1
            slideBtnIcon.Image = "rbxassetid://6893025659"
            slideBtnIcon.Parent = slideButton

            slideButton.MouseButton1Click:Connect(function()
                SlideClonado.Visible = false
                fecharTodosOsMenus()
            end)
        end

        -- ====================================================================
        -- 6. CLONAGEM DO BUTTONS E BOTÃO PRINCIPAL (CUSTOM)
        -- ====================================================================
        local targetButtons = newFrame 
            and newFrame:FindFirstChild("Frame") 
            and newFrame.Frame:FindFirstChild("Frame") 
            and newFrame.Frame.Frame:FindFirstChild("Buttons")

        if targetButtons then
            local ButtonsClonado = targetButtons:Clone()
            ButtonsClonado.Size = UDim2.new(1, 0, 1, 0)
            ButtonsClonado.Position = UDim2.new(0, 0, 0, 0)
            ButtonsClonado.Parent = FrameFilho

            local gridLayout = ButtonsClonado:FindFirstChildOfClass("UIGridLayout")
            if gridLayout then
                gridLayout.CellSize = UDim2.new(1, 0, 0, 65)
                gridLayout.FillDirection = Enum.FillDirection.Horizontal
                gridLayout.FillDirectionMaxCells = 1
            end

            -- Conecta os outros botões do Buttons para fechar o Slide e menus
            for _, child in ipairs(ButtonsClonado:GetChildren()) do
                if child:IsA("GuiButton") then
                    child.MouseButton1Click:Connect(function()
                        if SlideClonado then
                            SlideClonado.Visible = false
                        end
                        fecharTodosOsMenus()
                    end)
                end
            end

            -- Cria o NOSSO botão dentro do Buttons
            local customButton = Instance.new("ImageButton")
            customButton.Name = "CustomImageButton"
            customButton.BackgroundTransparency = 0.6
            customButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            customButton.Parent = ButtonsClonado

            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0, 8)
            uiCorner.Parent = customButton

            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Name = "CustomIcon"
            imageLabel.Size = UDim2.new(0.85, 0, 0.85, 0)
            imageLabel.Position = UDim2.new(0, 5, 0, 5)
            imageLabel.BackgroundTransparency = 1
            imageLabel.Image = "rbxassetid://82364297327086"
            imageLabel.Parent = customButton

            -- Ação do nosso botão customizado
            customButton.MouseButton1Click:Connect(function()
                fecharTodosOsMenus()

                if SlideClonado then
                    SlideClonado.Visible = not SlideClonado.Visible
                    
                    if SlideClonado.Visible and ultimoMenuAtivo then
                        ultimoMenuAtivo.Visible = true
                    end
                end
            end)
        end
    end
})

TabScript:AddButton({
    Name = "Deletar Brookhaven News",
    Description = "Faz Muira Zuada",
    Callback = function()
        local obj = workspace:FindFirstChild("BrookavenNewsSign")

        if obj then
            obj:Destroy()
        else
        end
    end
})

TabScript:AddSection({ Name = "Scripts Universal" })

TabScript:AddButton({
    Name = "FE Emotes By SAGAZx",
    Description = "",
    Callback = function()
 loadstring(game:HttpGet("https://sagazxsitex.vercel.app/api/raw/fe-emotes-dois"))()
    end
})

TabScript:AddButton({
    Name = "Expand Hotbar",
    Description = "Expande Sua Hotbar de 10 Ate 20 Slots",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/psychoSAGAZ/SAGAZx-HUB/refs/heads/main/Expand%20Hotbar%20"))()
    end
})

local ChatConnections = {}
local ChatEnabled = false

TabScript:AddToggle({
    Name = "Oculta Chat Global ",
    Description = "Certifique de Colocar o Chat em ''Aqui'' ",
    CurrentValue = false,
    Callback = function(Value)
        ChatEnabled = Value

        -- Desconecta tudo ao desativar
        if not Value then
            for _, Connection in ipairs(ChatConnections) do
                if Connection then
                    Connection:Disconnect()
                end
            end
            table.clear(ChatConnections)
            return
        end

        local CoreGui = game:GetService("CoreGui")

        local function RemoveChatParts()
            if not ChatEnabled then return end

            local Chat = CoreGui:FindFirstChild("ExperienceChat")
            if not Chat then return end

            local AppLayout = Chat:FindFirstChild("appLayout")
            if not AppLayout then return end

            local TopPadding = AppLayout:FindFirstChild("topPadding")
            if TopPadding then
                TopPadding:Destroy()
            end

            local ChannelBar = AppLayout:FindFirstChild("channelBar")
            if ChannelBar then
                ChannelBar:Destroy()
            end
        end

        RemoveChatParts()

        table.insert(ChatConnections, CoreGui.ChildAdded:Connect(function(Child)
            if not ChatEnabled then return end

            if Child.Name == "ExperienceChat" then
                task.wait()
                RemoveChatParts()

                local AppLayout = Child:FindFirstChild("appLayout") or Child:WaitForChild("appLayout", 10)
                if AppLayout then
                    table.insert(ChatConnections, AppLayout.ChildAdded:Connect(function()
                        if ChatEnabled then
                            task.wait()
                            RemoveChatParts()
                        end
                    end))
                end
            end
        end))

        local Chat = CoreGui:FindFirstChild("ExperienceChat")
        if Chat then
            local AppLayout = Chat:FindFirstChild("appLayout")
            if AppLayout then
                table.insert(ChatConnections, AppLayout.ChildAdded:Connect(function()
                    if ChatEnabled then
                        task.wait()
                        RemoveChatParts()
                    end
                end))
            end
        end
    end
})

local FlyGui = loadstring(game:HttpGet("https://raw.githubusercontent.com/psychoSAGAZ/SAGAZx-HUB/refs/heads/main/FLY%20GUI%20V3"))()

TabScript:AddToggle({
    Name = "Fly GUI",
    Description = "Faz Você Voar",
    Default = false,
    Callback = function(Value)
        if FlyGui then
            FlyGui.Enabled = Value
        end
    end
})

TabScript:AddButton({
    Name = "Fly Car",
    Description = "Faz Você Voar Com o Carro",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/raelhubfunctions/Save-scripts/refs/heads/main/CarMobile.lua"))()
    end
})

loadstring(game:HttpGet("https://raw.githubusercontent.com/psychoSAGAZ/SAGAZx-HUB/refs/heads/main/DRONE"))()

TabScript:AddToggle({
  Name = "Drone",
  Default = false,
  Callback = function(Value)
    Frame.Visible = Value -- Se Value for true, aparece. Se for false, some.
  end
})

local InvisLoaded = false

TabScript:AddToggle({
    Name = "FE Invisível",
    Description = "Deixa Você Invisível",
    Default = false,
    Callback = function(Value)
        if Value then
            if not InvisLoaded then
                InvisLoaded = true
                loadstring(game:HttpGet("https://raw.githubusercontent.com/psychoSAGAZ/SAGAZx-HUB/refs/heads/main/FE%20Invisible%20"))()
            end

            game:GetService("CoreGui").InvisButtonGui.Enabled = true
        else
            if game:GetService("CoreGui"):FindFirstChild("InvisButtonGui") then
                game:GetService("CoreGui").InvisButtonGui.Enabled = false
            end
        end
    end
})

loadstring(game:HttpGet("https://raw.githubusercontent.com/psychoSAGAZ/SAGAZx-HUB/refs/heads/main/Shiftlock%20"))()

TabScript:AddToggle({
    Name = "Shiftlock",
    Default = true, -- Mudado para true para o design do toggle começar ativado
    Callback = function(Value)
        if getgenv().ToggleShiftlockButton then
            if Value == true then
                getgenv().ToggleShiftlockButton(true)
            else
                -- Força o botão a sumir imediatamente, independente do shiftlock estar ativo ou não
                local CoreGui = game:GetService("CoreGui")
                local gui = CoreGui:FindFirstChild("Shiftlock (CoreGui)")
                if gui then
                    gui.Enabled = false
                end
            end
        end
    end
})

TabScript:AddButton({
    Name = "Shaders V1",
    Description = "Deixa o Brookhaven Bonito",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-HDR-GRAPHICS-29409"))()
    end
})

TabScript:AddButton({
    Name = "Shaders V2",
    Description = "Deixa o Brookhaven Bonito",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Brookhaven-RP-BrookHaven-UltraFX-44718"))()
    end
})


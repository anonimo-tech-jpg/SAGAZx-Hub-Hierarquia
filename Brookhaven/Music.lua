;(function()
    local Tab9 = Window:MakeTab({"| Musicas", "music"})

    local unpack = unpack or table.unpack
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local PlayersService = game:GetService("Players")
    local HttpService = game:GetService("HttpService")

    -- ========== Remotes ==========
    local function getRE()
        return ReplicatedStorage:WaitForChild("RE", 5)
    end

    local function findRemote(RE, possibleNames)
        for _, child in ipairs(RE:GetChildren()) do
            for _, name in ipairs(possibleNames) do
                if child.Name == name or child.Name:gsub("%d", "") == name:gsub("%d", "") then
                    return child
                end
            end
        end
        return nil
    end

    -- Tocar / trocar musica (e parar com id = "")
    local function enviarRemote(id)
        local RE = getRE()
        if not RE then return end

        local radioRemote = findRemote(RE, {"PlayerToolEvent", "1Player1Tool1Event1"})
        if radioRemote then
            radioRemote:FireServer(unpack({"ToolMusicText", id}))
        end

        local casaRemote = findRemote(RE, {"1Player1sHous1e", "PlayersHouse"})
        if casaRemote then
            casaRemote:FireServer(unpack({"PickHouseMusicText", id}))
        end

        local carroRemote = findRemote(RE, {"1Player1sCa1r", "PlayersCar"})
        if carroRemote then
            carroRemote:FireServer(unpack({"PickingCarMusicText", id}))
            carroRemote:FireServer(unpack({"Picking", id}))
            carroRemote:FireServer(unpack({"WickedGramophoneMusicSelect", id}))
        end

        local scooterRemote = findRemote(RE, {"1NoMoto1rVehicle1s", "NoMotorVehicles"})
        if scooterRemote then
            scooterRemote:FireServer(unpack({"PickingScooterMusicText", id}))
        end

        local cavaloRemote = findRemote(RE, {"1Hor1seRemo1te", "HorseRemote"})
        if cavaloRemote then
            cavaloRemote:FireServer(unpack({"PickingHorseMusicText", id}))
        end

        local propsRemote = findRemote(RE, {"1Pro1ps", "Props"})
        if propsRemote then
            propsRemote:FireServer(unpack({"PropMusicText", id}))
        end
    end

    -- Pause / Play (action = "Play" ou "Stop")
    local function controlarRemote(action)
        local RE = getRE()
        if not RE then return end

        local radioRemote = findRemote(RE, {"PlayerToolEvent", "1Player1Tool1Event1"})
        if radioRemote then
            radioRemote:FireServer(unpack({"ToolMusic" .. action, ""}))
        end

        local casaRemote = findRemote(RE, {"1Player1sHous1e", "PlayersHouse"})
        if casaRemote then
            casaRemote:FireServer(unpack({"PickHouseMusic" .. action, ""}))
        end

        local carroRemote = findRemote(RE, {"1Player1sCa1r", "PlayersCar"})
        if carroRemote then
            carroRemote:FireServer(unpack({"PickingCarMusic" .. action, ""}))
        end

        local scooterRemote = findRemote(RE, {"1NoMoto1rVehicle1s", "NoMotorVehicles"})
        if scooterRemote then
            scooterRemote:FireServer(unpack({"PickingScooterMusic" .. action, ""}))
        end

        local cavaloRemote = findRemote(RE, {"1Hor1seRemo1te", "HorseRemote"})
        if cavaloRemote then
            cavaloRemote:FireServer(unpack({"PickingHorseMusic" .. action, ""}))
        end

        local propsRemote = findRemote(RE, {"1Pro1ps", "Props"})
        if propsRemote then
            propsRemote:FireServer(unpack({"PropMusic" .. action, ""}))
        end
    end

    -- Volume (5 a 100, de 5 em 5)
    local function volumeRemote(v)
        local ok, err = pcall(function()
            local req = PlayersService.LocalPlayer.PlayerGui.MainGUIHandler.MainAudio
                .Catalog.Header.VolumeContainer.VolumeChangeRequest
            req:FireServer(unpack({v}))
        end)
        if not ok then warn("[Volume] " .. tostring(err)) end
    end

    -- ========== PLAYER ==========
    local MusicPlayer = Tab9:AddMusicPlayer({
        Title = "Music Player",
        -- Mode = "Remote",  -- (opcional) trava o toggle em Remote ou Local
        Volume = 50,

        RemotePlay = enviarRemote,
        RemoteStop = function() enviarRemote("") end,
        RemotePause = function() controlarRemote("Stop") end,
        RemoteResume = function() controlarRemote("Play") end,
        RemoteVolume = volumeRemote,
    })

    -- ==================================================================
    -- FILAS (proxima/anterior)
    -- ==================================================================
    local playlistGeral = {}   -- { {id = "123", name = "Nome"}, ... } (todas as dropdowns)
    local playlistIds = {}     -- evita duplicar IDs na playlist geral
    local favoritos = {}       -- { {id = "123", name = "Nome"}, ... }
    local filaAtual = "geral"  -- "geral" ou "fav"

    -- Monta a fila do player de acordo com a origem da musica
    local function usarFila(tipo)
        filaAtual = tipo
        MusicPlayer:ClearTracks()
        local fonte = (tipo == "fav") and favoritos or playlistGeral
        for _, t in ipairs(fonte) do
            MusicPlayer:AddTrack(t.name, t.id)
        end
    end

    local function adicionarNaPlaylist(name, id)
        id = tostring(id)
        if playlistIds[id] then return end
        playlistIds[id] = true
        table.insert(playlistGeral, {id = id, name = name})
        if filaAtual == "geral" then
            MusicPlayer:AddTrack(name, id)
        end
    end

    -- ========== Tocar musica ==========
    -- Guarda a ultima musica usada/selecionada (base do sistema de favoritos)
    local ultimoSelecionado = nil -- {id = "123", name = "Nome" ou nil}
    local aoSelecionar = nil      -- definido na parte de favoritos

    -- fila: "geral" (padrao) ou "fav"
    local function tocarMusica(id, name, fila)
        if id == nil or id == "" then
            MusicPlayer:Stop()
        else
            id = tostring(id)
            ultimoSelecionado = {id = id, name = name}
            if aoSelecionar then aoSelecionar() end
            usarFila(fila or "geral")
            MusicPlayer:Play(id, name)
        end
    end

    getgenv().tocarMusica = tocarMusica
    _G.tocarMusica = tocarMusica
    getgenv().MusicPlayer = MusicPlayer

    -- ========== Validador ==========
    local function isValidMusicId(value)
        return value and value ~= ""
        and value ~= "Option 1"
        and not value:match("novas musica adds")
        and not value:match("musica brasil")
        and not value:match("musica do meu interece")
        and not value:match("musica dls por elas")
        and not value:match("meme abaixo")
        and not value:match("estourada")
    end

    getgenv().isValidMusicId = isValidMusicId
    _G.isValidMusicId = isValidMusicId

    -- ========== TextBox ==========
    Tab9:AddTextBox({
        Name = "ID da musica",
        PlaceholderText = "Digite o ID",
        Callback = function(value)
            if isValidMusicId(value) then
                tocarMusica(tostring(value))
            end
        end
    })

    -- ========== Dropdowns ==========
    local function createMusicDropdown(title, musicOptions, defaultOption)
        local musicNames = {}
        local categoryMap = {}

        local cats = {}
        for category in pairs(musicOptions) do table.insert(cats, category) end
        table.sort(cats, function(a, b) return tostring(a) < tostring(b) end)

        for _, category in ipairs(cats) do
            for _, music in ipairs(musicOptions[category]) do
                if music.name ~= "" then
                    table.insert(musicNames, music.name)
                    categoryMap[music.name] = {id = music.id, category = category}
                    if music.id and music.id ~= "" and music.id ~= "4354908569" then
                        adicionarNaPlaylist(music.name, music.id) -- fila geral p/ proxima/anterior
                    end
                end
            end
        end

        -- A lib dispara o callback uma vez ao criar a dropdown com o valor padrao.
        -- Essa flag ignora esse disparo inicial (so seleciona visualmente).
        local criando = true

        Tab9:AddDropdown({
            Name = title,
            Description = "all",
            Default = defaultOption or musicNames[1], -- primeira opcao selecionada
            MultiSelect = false,
            Options = musicNames,
            Search = true,
            Callback = function(selectedSound)
                if criando then return end
                if selectedSound and categoryMap[selectedSound] then
                    local soundId = categoryMap[selectedSound].id
                    if soundId and soundId ~= "" and soundId ~= "4354908569" then
                        tocarMusica(tostring(soundId), selectedSound, "geral")
                    end
                end
            end
        })

        task.defer(function() criando = false end)
    end

    getgenv().createMusicDropdown = createMusicDropdown
    _G.createMusicDropdown = createMusicDropdown

    -- ========== Carrega musicas ==========
    local MUSICAS_URL = "https://raw.githubusercontent.com/psychoSAGAZ/SAGAZx-HUB/refs/heads/main/Playlist/Musicas"

    local ok, err = pcall(function()
        loadstring(game:HttpGet(MUSICAS_URL))()
    end)

    if not ok then
        warn("[Musicas] Falha ao carregar musicas.lua: " .. tostring(err))
    end

    -- ==================================================================
    -- FAVORITOS
    -- ==================================================================
    local FAV_FOLDER = "SAGAZx HUB Lib"
    local FAV_FILE = FAV_FOLDER .. "/Favoritos.json"

    local function carregarFavoritos()
        if not (isfile and readfile and isfile(FAV_FILE)) then return end
        local okRead, data = pcall(function()
            return HttpService:JSONDecode(readfile(FAV_FILE))
        end)
        if okRead and type(data) == "table" then
            for _, f in ipairs(data) do
                if type(f) == "table" and f.id then
                    table.insert(favoritos, {
                        id = tostring(f.id),
                        name = tostring(f.name or ("ID " .. tostring(f.id)))
                    })
                end
            end
        end
    end

    local function salvarFavoritos()
        if not writefile then return end
        pcall(function()
            if makefolder and isfolder and not isfolder(FAV_FOLDER) then
                makefolder(FAV_FOLDER)
            end
            writefile(FAV_FILE, HttpService:JSONEncode(favoritos))
        end)
    end

    carregarFavoritos()

    -- monta a lista de nomes (nomes repetidos ganham o ID no final)
    local function montarLista()
        local nomes, mapa, usados = {}, {}, {}
        for _, f in ipairs(favoritos) do
            local label = f.name
            if usados[label] then label = label .. " (" .. f.id .. ")" end
            usados[label] = true
            table.insert(nomes, label)
            mapa[label] = f
        end
        return nomes, mapa
    end

    local nomesFav, mapaFav = montarLista()
    local favSelecionado = nil
    local atualizando = true -- true durante a criacao (ignora o callback inicial)

    -- escapa texto pro RichText do paragrafo
    local function esc(s)
        return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end

    Tab9:AddSection({"Favoritos"})

    local StatusP = Tab9:AddParagraph({"Ultimo selecionado:", "Nenhuma musica ainda..."})

    local function mostrarSelecionado()
        local s = ultimoSelecionado
        StatusP:SetDesc(s and esc(s.name or ("ID " .. s.id)) or "Nenhuma musica ainda")
    end

    aoSelecionar = mostrarSelecionado
    mostrarSelecionado()

    local avisoId = 0
    local function aviso(msg)
        StatusP:SetDesc(esc(msg))
        avisoId = avisoId + 1
        local meu = avisoId
        task.delay(2.5, function()
            if meu == avisoId then mostrarSelecionado() end
        end)
    end

    local favDropdown

    local function atualizarDropdown()
        nomesFav, mapaFav = montarLista()
        atualizando = true -- evita tocar musica quando a lista e atualizada
        favDropdown:Refresh(nomesFav)

        -- mantem a selecao atual; se nao tiver nenhuma, seleciona a primeira (sem tocar)
        local atual = favDropdown:Get()
        if (atual == nil or not mapaFav[tostring(atual)]) and nomesFav[1] then
            favDropdown:Select(nomesFav[1])
            atual = nomesFav[1]
        end
        favSelecionado = (atual ~= nil and mapaFav[tostring(atual)]) and tostring(atual) or nil
        atualizando = false

        -- se estiver tocando pelos favoritos, atualiza a fila na hora
        if filaAtual == "fav" then usarFila("fav") end
    end

    favDropdown = Tab9:AddDropdown({
        Name = "Musicas Favoritas",
        Description = "all",
        MultiSelect = false,
        Default = nomesFav[1], -- primeira favorita selecionada (sem tocar)
        Options = nomesFav,
        Search = true,
        Callback = function(selected)
            if atualizando or not selected then return end
            local f = mapaFav[selected]
            if f then
                favSelecionado = selected
                tocarMusica(f.id, f.name, "fav") -- proxima/anterior = favoritos
            end
        end
    })

    Tab9:AddButton({
        Name = "Favoritar musica",
        Description = "Favorita a ultima musica usada/selecionada",
        Callback = function()
            local s = ultimoSelecionado
            if not s then
                aviso("Nenhuma musica selecionada")
                return
            end

            for _, f in ipairs(favoritos) do
                if f.id == s.id then
                    aviso("Ja esta nos favoritos")
                    return
                end
            end

            local nome = s.name or ("ID " .. s.id)
            table.insert(favoritos, {id = s.id, name = nome})
            salvarFavoritos()
            atualizarDropdown()
            aviso("Favoritado: " .. nome)
        end
    })

    -- ja marca a primeira favorita como selecionada (para o botao de remover)
    favSelecionado = nomesFav[1]
    task.defer(function() atualizando = false end)

    Tab9:AddButton({
        Name = "Remover favorito selecionado",
        Description = "Remove da lista o favorito escolhido na dropdown",
        Callback = function()
            local f = favSelecionado and mapaFav[favSelecionado]
            if not f then
                aviso("Selecione um favorito primeiro")
                return
            end

            for i, x in ipairs(favoritos) do
                if x.id == f.id then
                    table.remove(favoritos, i)
                    break
                end
            end

            favSelecionado = nil
            salvarFavoritos()
            atualizarDropdown()
            aviso("Removido: " .. f.name)
        end
    })

  Tab9:AddSection({"Outros"})

Tab9:AddParagraph({"As Músicas Gamepass Fuciona Em:", "Cavalo, Casas Antigas, Radio e Veículos Pequenos"})

local RS = game:GetService("ReplicatedStorage")
local RE = RS:WaitForChild("RE")

-- Botão 1: PickingTools (Boombox)
Tab9:AddButton({
    Name = "Pegar Boombox",
    Callback = function()
        local args = {
            [1] = "PickingTools",
            [2] = "Boombox"
        }
        local remote = RE:FindFirstChild("1Too1l")
        if remote then
            remote:InvokeServer(unpack(args))
        else
            warn("Remote 1Too1l não encontrado!")
        end
    end
})

-- Botão 4: SegwaySmall (Small)
Tab9:AddButton({
    Name = "Hoverboard Mod (Premium)",
    Description = "Apenas Para Música",
    Callback = function()
        local args = {
            [1] = "SegwaySmall",
            [2] = "Small"
        }
        local remote = RE:FindFirstChild("1NoMoto1rVehicle1s")
        if remote then
            remote:FireServer(unpack(args))
        else
            warn("Remote 1NoMoto1rVehicle1s não encontrado!")
        end
    end
})

-- Botão 2: SkateBoard (Small)
Tab9:AddButton({
    Name = "Skate Mod",
    Description = "Apenas Para Musica",
    Callback = function()
        local args = {
            [1] = "SkateBoard",
            [2] = "Small"
        }
        local remote = RE:FindFirstChild("1NoMoto1rVehicle1s")
        if remote then
            remote:FireServer(unpack(args))
        else
            warn("Remote 1NoMoto1rVehicle1s não encontrado!")
        end
    end
})

-- Botão 3: Delete NoMotorVehicle
Tab9:AddButton({
    Name = "Deletar Veículos Mod",
    Callback = function()
        local args = {
            [1] = "Delete NoMotorVehicle"
        }
        local remote = RE:FindFirstChild("1NoMoto1rVehicle1s")
        if remote then
            remote:FireServer(unpack(args))
        else
            warn("Remote 1NoMoto1rVehicle1s não encontrado!")
        end
    end
})

end)()

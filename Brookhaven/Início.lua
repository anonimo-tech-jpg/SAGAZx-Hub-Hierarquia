local Tab1 = Window:MakeTab({ "| Início", "menu" })


Tab1:AddDiscordInvite({
    Name = "SAGAZx",
    Description = "",
    Logo = "rbxassetid://86050226751861",
    ["Tik Tok"] = "tiktok.com/@sagazx_xd",
    Discord = "https://discord.gg/JHHZUtUeT8"
})

Tab1:AddSection({Name = "Perfil"})


local function detectExecutor()
    if identifyexecutor then
        return identifyexecutor()
    elseif syn then
        return "Synapse X4"
    elseif KRNL_LOADED then
        return "KRNL4"
    elseif is_sirhurt_closure then
        return "SirHurt"
    elseif pebc_execute then
        return "ProtoSmasher"
    elseif getexecutorname then
        return getexecutorname()
    else
        return "Executor Desconhecido"
    end
end

local executorName = detectExecutor()



local Paragraph = Tab1:AddParagraph({"Execultor", executorName})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Pega nickname do jogador
local nickname = player.Name 

-- Novo bloco igual ao do Executor
Tab1:AddParagraph({"Nickname", nickname})
Tab1:AddParagraph({"Versão", "3.0.1"})

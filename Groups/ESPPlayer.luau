local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

TabGroup:AddLabel("Color"):AddColorPicker("PlayerESPColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.HighlightESPTables["Player"]) do
            esp.SetColor(Value)
        end
    end,
})

local function ApplyHESP(player: Player)
    local char = player.Character
    if not char then
        return
    end
    local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    Script.ESP.HighlightESP({
        Type = "Player",
        Object = char,
        Color = Library.Options.PlayerESPColor.Value,
    })
end

TabGroup:AddToggle("PlayerHESP", {
    Text = "Highlight",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then
                    continue
                end
                ApplyHESP(player)
            end
        else
            for _, esp in pairs(Script.HighlightESPTables["Player"]) do
                esp.Destroy()
            end
        end
    end,
})

local function SetupPlayerConnection(player: Player)
    if player == lplr then
        return
    end
    if player.Character then
        if Library.Toggles.PlayerHESP.Value then
            ApplyHESP(player)
        end
    end

    Script.Connections.PlayerCharAdded[player.Name] = player.CharacterAdded:Connect(function(newCharacter)
        task.delay(0.1, function()
            if Library.Toggles.PlayerHESP.Value then
                ApplyHESP(player)
            end
        end)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    SetupPlayerConnection(player)
end
Script.Connections.PlayerAdded = Players.PlayerAdded:Connect(SetupPlayerConnection)

local function FindPlayerStatus(object: Instance): Instance?
    if not object then
        return nil
    end
    for _, descendant in object:GetDescendants() do
        if descendant.Name == "PlayerStatus" then
            return descendant
        end
    end
    return nil
end

TabGroup:AddToggle("PlayerTESP", {
    Text = "Text",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then
                    continue
                end

                local PlayerStatus = FindPlayerStatus(player.Character)
                if PlayerStatus then
                    PlayerStatus.AlwaysOnTop = true
                    PlayerStatus.MaxDistance = Library.Options.PlayerTESPDist.Value
                end
                Script.Connections.PlayerTextAdded[player.Name] = player.CharacterAdded:Connect(function(newChar)
                    -- warn(player.name .. " Character added")
                    task.delay(1, function()
                        local PlayerStatus = FindPlayerStatus(newChar)
                        if PlayerStatus then
                            PlayerStatus.AlwaysOnTop = true
                            PlayerStatus.MaxDistance = Library.Options.PlayerTESPDist.Value
                        else
                            -- warn("playerStatus not found :(")
                        end
                    end)
                end)
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then
                    continue
                end
                if Script.Connections.PlayerTextAdded[player.Name] then
                    Script.Connections.PlayerTextAdded[player.Name]:Disconnect()
                    Script.Connections.PlayerTextAdded[player.Name] = nil
                end
                local PlayerStatus = FindPlayerStatus(player.Character)
                if PlayerStatus then
                    PlayerStatus.AlwaysOnTop = false
                    PlayerStatus.MaxDistance = 400
                end
            end
        end
    end,
})

TabGroup:AddSlider("PlayerTESPDist", {
    Text = "Text distance",
    Default = 100,
    Min = 0,
    Max = 5000,
    Rounding = 0,
    Callback = function(Value)
        if Library.Toggles.PlayerTESP.Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then
                    continue
                end

                local PlayerStatus = FindPlayerStatus(player.Character)
                if PlayerStatus then
                    PlayerStatus.MaxDistance = Library.Options.PlayerTESPDist.Value
                end
            end
        end
    end,
})

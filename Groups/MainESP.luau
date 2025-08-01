local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

local function PlayerESP(player: Player)
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

TabGroup:AddToggle("PlayerESP", {
    Text = "Player",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player == lplr then
                    continue
                end
                PlayerESP(player)
            end
        else
            for _, esp in pairs(Script.HighlightESPTable["Player"]) do
                esp.Destroy()
            end
        end
    end,
}):AddColorPicker("PlayerESPColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.HighlightESPTable["Player"]) do
            esp.SetColor(Value)
        end
    end,
})

local function SetupPlayerConnection(player: Player)
    if player == lplr then
        return
    end
    if player.Character then
        if Library.Toggles.PlayerESP.Value then
            PlayerESP(player)
        end
    end

    Script.Connections.PlayerCharAdded[player.Name] = player.CharacterAdded:Connect(function(newCharacter)
        task.delay(0.1, function()
            if Library.Toggles.PlayerESP.Value then
                PlayerESP(player)
            end
        end)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    SetupPlayerConnection(player)
end
Script.Connections.PlayerAdded = Players.PlayerAdded:Connect(SetupPlayerConnection)
Script.Connections.PlayerRemoved = Players.PlayerRemoving:Connect(function(player: Player) end)

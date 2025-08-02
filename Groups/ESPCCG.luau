local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...

local NamesCCG = {
    ["First Class Investigator"] = true,
    ["Rank 1 Investigator"] = true,
    ["Rank 2 Investigator"] = true,
}

TabGroup:AddLabel("Color"):AddColorPicker("CCGESPColor", {
    Default = Color3.fromRGB(130, 245, 255),
    Callback = function(Value)
        for _, esp in pairs(Script.HighlightESPTables["CCG"]) do
            esp.SetColor(Value)
        end
    end,
})

local function ApplyHESP(model: Model)
    if not NamesCCG[model.Name] then
        return
    end
    Script.ESP.HighlightESP({
        Type = "CCG",
        Object = model,
        Color = Library.Options.CCGESPColor.Value,
    })
end

TabGroup:AddToggle("CCGHESP", {
    Text = "Highlight",
    Default = false,
    Callback = function(Value)
        if Script.Connections.ESPCCG then
            Script.Connections.ESPCCG:Disconnect()
            Script.Connections.ESPCCG = nil
        end
        if Value then
            for _, obj in workspace.NPCSpawns:GetDescendants() do
                ApplyHESP(obj)
            end
            Script.Connections.ESPCCG = workspace.NPCSpawns.DescendantAdded:Connect(function(newObj)
                task.delay(0.1, function()
                    ApplyHESP(newObj)
                end)
            end)
        else
            for _, esp in pairs(Script.HighlightESPTables["CCG"]) do
                esp.Destroy()
            end
        end
    end,
})

local function ApplyTESP(obj)
    if NamesCCG[obj.Name] then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.NameDisplayDistance = Library.Options.CCGTESPDist.Value
            humanoid.HealthDisplayDistance = Library.Options.CCGTESPDist.Value
        end
    end
end

TabGroup:AddToggle("CCGTESP", {
    Text = "Text",
    Default = false,
    Callback = function(Value)
        if Script.Connections.CCGTESP then
            Script.Connections.CCGTESP:Disconnect()
            Script.Connections.CCGTESP = nil
        end
        if Value then
            for _, descendant in pairs(workspace.NPCSpawns:GetDescendants()) do
                ApplyTESP(descendant)
            end
            Script.Connections.CCGTESP = workspace.NPCSpawns.DescendantAdded:Connect(function(newObj)
                task.delay(0.1, function()
                    ApplyTESP(newObj)
                end)
            end)
        else
            for _, descendant in pairs(workspace.NPCSpawns:GetDescendants()) do
                if NamesCCG[descendant.Name] then
                    local humanoid = descendant:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.NameDisplayDistance = 100
                        humanoid.HealthDisplayDistance = 100
                    end
                end
            end
        end
    end,
})

TabGroup:AddSlider("CCGTESPDist", {
    Text = "Text distance",
    Default = 100,
    Min = 0,
    Max = 5000,
    Rounding = 0,
    Callback = function(Value)
        for _, descendant in pairs(workspace.NPCSpawns:GetDescendants()) do
            ApplyTESP(descendant)
        end
    end,
})

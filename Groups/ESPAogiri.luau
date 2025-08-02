local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...

local NamesAogiri = {
    ["High Rank Aogiri Member"] = true,
    ["Mid Rank Aogiri Member"] = true,
    ["Low Rank Aogiri Member"] = true,
}

TabGroup:AddLabel(""):AddColorPicker("AogiriESPColor", {
    Default = Color3.fromRGB(146, 56, 56),
    Callback = function(Value)
        for _, esp in pairs(Script.HighlightESPTables["Aogiri"]) do
            esp.SetColor(Value)
        end
    end,
})

local function ApplyHESP(model: Model)
    if not NamesAogiri[model.Name] then
        return
    end
    Script.ESP.HighlightESP({
        Type = "Aogiri",
        Object = model,
        Color = Library.Options.AogiriESPColor.Value,
    })
end

TabGroup:AddToggle("AogiriHESP", {
    Text = "Aogiri",
    Default = false,
    Callback = function(Value)
        if Script.Connections.ESPAogiri then
            Script.Connections.ESPAogiri:Disconnect()
            Script.Connections.ESPAogiri = nil
        end
        if Value then
            for _, obj in workspace.NPCSpawns:GetDescendants() do
                ApplyHESP(obj)
            end
            Script.Connections.ESPAogiri = workspace.NPCSpawns.DescendantAdded:Connect(function(newObj)
                task.delay(0.1, function()
                    ApplyHESP(newObj)
                end)
            end)
        else
            for _, esp in pairs(Script.HighlightESPTables["Aogiri"]) do
                esp.Destroy()
            end
        end
    end,
})

local function ApplyTESP(obj)
    if NamesAogiri[obj.Name] then
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.NameDisplayDistance = Library.Options.AogiriTESPDist.Value
            humanoid.HealthDisplayDistance = Library.Options.AogiriTESPDist.Value
        end
    end
end

TabGroup:AddToggle("AogiriTESP", {
    Text = "Text",
    Default = false,
    Callback = function(Value)
        if Script.Connections.AogiriTESP then
            Script.Connections.AogiriTESP:Disconnect()
            Script.Connections.AogiriTESP = nil
        end
        if Value then
            for _, descendant in pairs(workspace.NPCSpawns:GetDescendants()) do
                ApplyTESP(descendant)
            end
            Script.Connections.AogiriTESP = workspace.NPCSpawns.DescendantAdded:Connect(function(newObj)
                task.delay(0.1, function()
                    ApplyTESP(newObj)
                end)
            end)
        else
            for _, descendant in pairs(workspace.NPCSpawns:GetDescendants()) do
                if NamesAogiri[descendant.Name] then
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

TabGroup:AddSlider("AogiriTESPDist", {
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

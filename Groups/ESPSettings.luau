local TabGroup: ObsidianGroupBox, Script: ScriptType, _: Obsidian = ...

TabGroup:AddSlider("ESPFillTransparency", {
    Text = "Fill Transparency",
    Default = 0.75,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        for _, espTable in pairs(Script.HighlightESPTables) do
            for _, esp in pairs(espTable) do
                esp.SetFillTransparency(Value)
            end
        end
    end,
})

TabGroup:AddSlider("ESPOutlineTransparency", {
    Text = "Outline Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        for _, espTable in pairs(Script.HighlightESPTables) do
            for _, esp in pairs(espTable) do
                esp.SetOutlineTransparency(Value)
            end
        end
    end,
})

TabGroup:AddSlider("ESPTextSize", {
    Text = "Text Size",
    Default = 22,
    Min = 14,
    Max = 30,
    Rounding = 0,
})

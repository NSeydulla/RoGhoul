local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...

local function ChangeFOV(_)
    if not workspace.CurrentCamera then
        Script.Functions.Alert("Camera instance not found :(")
    end
    if Library.Toggles.FOVToggle.Value then
        workspace.CurrentCamera.FieldOfView = Library.Options.FOVSlider.Value :: number
        Script.Temp.OldFOV = workspace.CurrentCamera.FieldOfView
    else
        if Script.Temp.OldFOV then
            workspace.CurrentCamera.FieldOfView = Script.Temp.OldFOV
            Script.Temp.OldFOV = nil
        end
    end
end

TabGroup:AddToggle("FOVToggle", {
    Text = "FOV",
    Default = false,
    Callback = ChangeFOV,
})

TabGroup:AddSlider("FOVSlider", {
    Text = "FOV",
    Default = 60,
    Min = 10,
    Max = 120,
    Rounding = 1,
    Callback = ChangeFOV,
})

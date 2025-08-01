local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local RunService = game:GetService("RunService")

TabGroup:AddSlider("SpeedSlider", {
    Text = "Walk Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(val)
        if not Library.Toggles.SpeedToggle.Value then
            return
        end
        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
            lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
        end
    end,
})

TabGroup:AddToggle("SpeedToggle", {
    Text = "Speed",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.SpeedToggleTask then
            task.cancel(Script.Tasks.SpeedToggleTask)
            Script.Tasks.SpeedToggleTask = nil
        end
        if Value then
            Script.Functions.Alert("Speed Enabled", 3)
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                Script.Temp.OldSpeed = lplr.Character.Humanoid.WalkSpeed
                lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
            end
            Script.Tasks.SpeedToggleTask = task.spawn(function()
                repeat
                    task.wait(0.5)
                    if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                        lplr.Character.Humanoid.WalkSpeed = Library.Options.SpeedSlider.Value
                    end
                until not Library.Toggles.SpeedToggle.Value or Library.Unloaded
                Script.Tasks.SpeedToggleTask = nil
            end)
        else
            Script.Functions.Alert("Speed Disabled", 3)
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                lplr.Character.Humanoid.WalkSpeed = Script.Temp.OldSpeed
                Script.Temp.OldSpeed = nil
            end
        end
    end,
}):AddKeyPicker("SpeedKey", {
    Mode = "Toggle",
    Default = "C",
    Text = "Speed",
    SyncToggleState = true,
})

TabGroup:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(Value)
        if Script.Tasks.NoclipTask then
            task.cancel(Script.Tasks.NoclipTask)
            Script.Tasks.NoclipTask = nil
        end
        Script.Temp.NoclipParts = Script.Temp.NoclipParts or {}
        if Value then
            Script.Functions.Alert("Noclip Enabled", 3)
            Script.Tasks.NoclipTask = task.spawn(function()
                repeat
                    RunService.Heartbeat:Wait()
                    if lplr.Character then
                        for _, child in pairs(lplr.Character:GetDescendants()) do
                            if child:IsA("BasePart") and child.CanCollide == true then
                                child.CanCollide = false
                                Script.Temp.NoclipParts[child] = true
                            end
                        end
                    end
                until not Library.Toggles.Noclip.Value or Library.Unloaded
                Script.Tasks.NoclipTask = nil
            end)
        else
            Script.Functions.Alert("Noclip Disabled", 3)
            if lplr.Character and Script.Temp.NoclipParts then
                for part, _ in pairs(Script.Temp.NoclipParts) do
                    if part and part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                Script.Temp.NoclipParts = {}
            end
        end
    end,
}):AddKeyPicker("NoclipKey", {
    Mode = "Toggle",
    Default = "N",
    Text = "Noclip",
    SyncToggleState = true,
})

-- Generated automatically
local Functions = function(...)
local Script: ScriptType, Library: Obsidian = ...
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

return {
    OnLoad = function()
        Script.SaveManager:LoadAutoloadConfig()
    end,

    OnUnload = function()
        if Library._signals then
            for _, v in pairs(Library._signals) do
                pcall(function()
                    v:Disconnect()
                end)
            end
        end
        for _, conn in pairs(Script.Connections) do
            if type(conn) == "table" then
                for _, conn2 in pairs(conn) do
                    pcall(function()
                        conn2:Disconnect()
                    end)
                end
            else
                pcall(function()
                    conn:Disconnect()
                end)
            end
        end
        for _, task in pairs(Script.Tasks) do
            pcall(function()
                task.cancel(task)
            end)
        end
        for _, temp in pairs(Script.Temp) do
            pcall(function()
                if temp.Disconnect then
                    temp:Disconnect()
                elseif temp.Destroy then
                    temp:Destroy()
                elseif typeof(temp) == "thread" then
                    task.cancel(temp)
                end
            end)
        end
        for _, espType in pairs(Script.HighlightESPTables) do
            for _, esp in pairs(espType) do
                pcall(esp.Destroy)
            end
        end
        for _, espType in pairs(Script.TextESPTables) do
            for _, esp in pairs(espType) do
                pcall(esp.Destroy)
            end
        end
        Library.Unloaded = true
        getgenv().shared.RoGhoul_Library = nil
    end,

    GetRootPart = function(): Part?
        if not lplr.Character then
            Script.Functions.Alert("Character not found! try again")
            return
        end
        local hum = lplr.Character:WaitForChild("HumanoidRootPart", 1)
        if not hum then
            Script.Functions.Alert("Humanoid part not found! try again")
        end
        return hum :: Part?
    end,

    Alert = function(message: string, time: number?)
        Library:Notify(message, time or 5)

        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 2
        sound.PlayOnRemove = true
        sound:Destroy()
    end,
}
end

local ESP = function(...)
local Script: ScriptType, Library: Obsidian = ...
local RunService = game:GetService("RunService")

return {
    HighlightESP = function(args: HighlightESPArgs): HighlightESP?
        if not args.Object or not args.Object:IsA("Model") then
            return Script.Functions.Alert("ESP Object is nil or not Model")
        end

        local self: HighlightESP = {
            Type = args.Type or "None",
            Object = args.Object,
            Color = args.Color or Color3.new(),
            FillTransparency = Library.Options.ESPFillTransparency.Value,
            OutlineTransparency = Library.Options.ESPOutlineTransparency.Value,
            Highlights = {},
            Connections = {},
            Destroy = function() end,
            SetColor = function() end,
            GiveSignal = function() end,
            SetFillTransparency = function() end,
            SetOutlineTransparency = function() end,
        }

        local tableIndex = #Script.HighlightESPTables[self.Type] + 1

        local highlight = Instance.new("Highlight")
        do
            highlight.Adornee = self.Object
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = self.Color
            highlight.FillTransparency = self.FillTransparency
            highlight.OutlineColor = self.Color
            highlight.OutlineTransparency = self.OutlineTransparency
            highlight.Enabled = true
            highlight.Parent = self.Object
        end

        table.insert(self.Highlights, highlight)

        self.SetColor = function(newColor: Color3)
            self.Color = newColor

            for _, highlight in pairs(self.Highlights) do
                highlight.FillColor = newColor
                highlight.OutlineColor = newColor
            end
        end

        self.SetFillTransparency = function(newTransparency: number)
            self.FillTransparency = newTransparency

            for _, highlight in pairs(self.Highlights) do
                highlight.FillTransparency = newTransparency
            end
        end

        self.SetOutlineTransparency = function(newTransparency: number)
            self.OutlineTransparency = newTransparency

            for _, highlight in pairs(self.Highlights) do
                highlight.OutlineTransparency = newTransparency
            end
        end

        self.Destroy = function()
            for _, conn in pairs(self.Connections) do
                pcall(function()
                    conn:Disconnect()
                end)
            end

            for _, highlight in pairs(self.Highlights) do
                highlight:Destroy()
            end
            if Script.HighlightESPTables[self.Type][tableIndex] then
                Script.HighlightESPTables[self.Type][tableIndex] = nil
            end
        end

        self.GiveSignal = function(signal)
            table.insert(self.Connections, signal)
        end

        self.GiveSignal(RunService.RenderStepped:Connect(function()
            if not self.Object or not self.Object:IsDescendantOf(workspace) then
                self.Destroy()
                return
            end
        end))

        Script.HighlightESPTables[self.Type][tableIndex] = self
        return self
    end,
}
end

local GroupFunctions = {

Checkpoint = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, _: Obsidian = ...
TabGroup:AddButton("Set checkpoint", function()
    local hum = Script.Functions.GetRootPart()
    if not hum then
        return
    end
    Script.Temp.Checkpoint = CFrame.new(hum.Position)
    Script.Functions.Alert("Checkpoint set!")
end)

TabGroup:AddButton("TP to checkpoint", function()
    local hum = Script.Functions.GetRootPart()
    if not hum then
        return
    end
    Script.Temp.BackCheckpoint = CFrame.new(hum.Position)
    -- Script.Functions.SafeTeleportToCFrame(Script.Temp.Checkpoint)
end)

TabGroup:AddButton("TP back", function()
    -- Script.Functions.SafeTeleportToCFrame(Script.Temp.BackCheckpoint)
end)
end,

ESPAogiri = function(...)
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
end,

ESPCCG = function(...)
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
end,

ESPPlayer = function(...)
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
end,

ESPSettings = function(...)
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
end,

Menu = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...
TabGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})
Library.ToggleKeybind = Library.Options.MenuKeybind

TabGroup:AddToggle("KeybindMenuOpen", {
    Default = false,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

TabGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

TabGroup:AddButton("Unload Script", function()
    Library:Unload()
end)

TabGroup:AddButton("Reset Settings", function()
    Script.SaveManager:SaveAutoloadConfig("default")
    pcall(function()
        writefile("voidware_linoria/ink_game/settings/default.json", "[]")
    end)
    pcall(function()
        Library:Unload()
    end)
    local load = loadstring(game:HttpGet(Script.repo .. "inkgame.luau"))
    if load then
        load()
    end
end)
end,

Player = function(...)
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

local function ToggleFOV(Value)
    if Value and not workspace.CurrentCamera then
        Script.Functions.Alert("Camera instance not found :(")
        Library.Toggles.FOVToggle:SetValue(false)
        return
    end
    if Value then
        Script.Temp.OldFOV = workspace.CurrentCamera.FieldOfView
        workspace.CurrentCamera.FieldOfView = Library.Options.FOVSlider.Value :: number
    else
        if Script.Temp.OldFOV then
            workspace.CurrentCamera.FieldOfView = Script.Temp.OldFOV
            Script.Temp.OldFOV = nil
        end
    end
end

local function ChangeFOV(Value)
    if not workspace.CurrentCamera then
        Script.Functions.Alert("Camera instance not found :(")
        Library.Toggles.FOVToggle:SetValue(false)
        return
    end
    if Library.Toggles.FOVToggle.Value then
        workspace.CurrentCamera.FieldOfView = Value
    end
end

TabGroup:AddToggle("FOVToggle", {
    Text = "FOV",
    Default = false,
    Callback = ToggleFOV,
})

TabGroup:AddSlider("FOVSlider", {
    Text = "FOV",
    Default = 60,
    Min = 10,
    Max = 120,
    Rounding = 1,
    Compact = true,
    Callback = ChangeFOV,
})
end,
}

local repo = "https://raw.githubusercontent.com/NSeydulla/VW-Add/refs/heads/TestingMultiFile/"

--// Setup \\--
if not getgenv().shared then
    getgenv().shared = {}
end

local library = getgenv().shared.RoGhoul_Library
if library then
    local suc = pcall(function()
        library:Unload()
    end)
    if not suc then
        error("[NSeed] Something went wrong while closing another running script")
    end
    local startTime = tick()
    while getgenv().shared.RoGhoul_Library do
        if tick() - startTime > 5 then
            error("[NSeed] Timeout while waiting for another script to close")
        end
        task.wait(0.3)
    end
end

pcall(function()
    local isNew = false
    for _, v in ipairs({
        "NSeed",
        "NSeed/roghoul",
        "NSeed/roghoul/settings",
        "NSeed/roghoul/themes",
    }) do
        if not isfolder(v) then
            makefolder(v)
            isNew = true
        end
    end

    if isNew then
        writefile("NSeed/roghoul/themes/default.txt", "Jester")
        writefile("NSeed/roghoul/settings/default.json", "[]")
    end
end)

--// Library \\--
local LibraryRepo = "https://raw.githubusercontent.com/mstudio45/Obsidian/main/"
local Library: Obsidian
local SaveManager
local ThemeManager

local loadLibrary = loadstring(game:HttpGet(LibraryRepo .. "Library.lua"))
if not loadLibrary then
    error("Something wrong with Library")
end
Library = loadLibrary()
getgenv().shared.RoGhoul_Library = Library

local Window = Library:CreateWindow({
    Title = "NSeed - Ro Ghoul",
    Footer = "Open Source Ro Ghoul script",
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    TabPadding = 2,
    MenuFadeTime = 1,
})

local Tabs = {
    AutoTrain = Window:AddTab("Auto Train", "gamepad-2"),
    ESP = Window:AddTab("ESP", "eye"),
    Other = Window:AddTab("Other", "wrench"),
    Script = Window:AddTab("Script", "sliders-horizontal"),
}

local TabGroups = {
    ESPSettings = Tabs.ESP:AddLeftGroupbox("Settings", "settings"),
    ESPPlayer = Tabs.ESP:AddLeftGroupbox("Player", "person-standing"),
    ESPCCG = Tabs.ESP:AddLeftGroupbox("CCG", "bird"),
    ESPAogiri = Tabs.ESP:AddLeftGroupbox("Aogiri", "beef"),

    Player = Tabs.Other:AddLeftGroupbox("Player", "user"),
    Checkpoint = Tabs.Other:AddRightGroupbox("Checkpoint", "skull"),

    Menu = Tabs.Script:AddRightGroupbox("Menu", "menu"),
}

local loadThemeManager = loadstring(game:HttpGet(LibraryRepo .. "addons/ThemeManager.lua"))
if not loadThemeManager then
    error("Something wrong with ThemeManager")
end
ThemeManager = loadThemeManager()

local loadSaveManager = loadstring(game:HttpGet(LibraryRepo .. "addons/SaveManager.lua"))
if not loadSaveManager then
    error("Something wrong with SaveManager")
end
SaveManager = loadSaveManager()

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("NSeed/roghoul")
SaveManager:SetFolder("NSeed/roghoul")
SaveManager:BuildConfigSection(Tabs.Script)
ThemeManager:ApplyToTab(Tabs.Script)

--// Script \\--
local Script: ScriptType = {
    repo = repo,
    Connections = {
        PlayerCharAdded = {},
        PlayerTextAdded = {},
    },
    Tasks = {},
    Temp = {},
    Functions = nil,
    HighlightESPTables = {
        Player = {},
        Boss = {},
        Aogiri = {},
        CCG = {},
    },
    TextESPTables = {
        Player = {},
        Boss = {},
        Aogiri = {},
        CCG = {},
    },
    ESP = nil,
    SaveManager = SaveManager,
    ThemeManager = ThemeManager,
}

Script.Functions = Functions(Script, Library)
Script.ESP = ESP(Script, Library)

for TabName, TabGroup in pairs(TabGroups) do
    GroupFunctions[TabName](TabGroup, Script, Library)
end

Library:OnUnload(Script.Functions.OnUnload)
task.spawn(function()
    pcall(Script.Functions.OnLoad)
end)

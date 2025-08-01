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
        for _, espType in pairs(Script.HighlightESPTable) do
            for _, esp in pairs(espType) do
                pcall(esp.Destroy)
            end
        end
        for _, espType in pairs(Script.TextESPTable) do
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
local Script: ScriptType, _: Obsidian = ...
local RunService = game:GetService("RunService")

return {
    HighlightESP = function(args: HighlightESPArgs): HighlightESP?
        if not args.Object then
            return Script.Functions.Alert("ESP Object is nil")
        end

        local self: HighlightESP = {
            Type = args.Type or "None",
            Object = args.Object,
            Color = args.Color or Color3.new(),
            Highlights = {},
            Connections = {},
            Destroy = function() end,
            SetColor = function() end,
            GiveSignal = function() end,
        }

        local tableIndex = #Script.HighlightESPTable[self.Type] + 1

        local highlight = Instance.new("Highlight")
        do
            highlight.Adornee = self.Object
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = self.Color
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = self.Color
            highlight.OutlineTransparency = 0.5
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

        self.Destroy = function()
            for _, conn in pairs(self.Connections) do
                pcall(function()
                    conn:Disconnect()
                end)
            end

            for _, highlight in pairs(self.Highlights) do
                highlight:Destroy()
            end
            if Script.HighlightESPTable[self.Type][tableIndex] then
                Script.HighlightESPTable[self.Type][tableIndex] = nil
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

        Script.HighlightESPTable[self.Type][tableIndex] = self
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

FOV = function(...)
local TabGroup: ObsidianGroupBox, Script: ScriptType, Library: Obsidian = ...

local function ChangeFOV(_)
    if not workspace.CurrentCamera then
        Script.Functions.Alert("Camera instance not found :(")
    end
    if Library.Toggles.FOVToggle.Value then
        workspace.CurrentCamera.FieldOfView = Library.Options.FOVSlider.Value :: number
        Script.Temp.OldFOV = workspace.CurrentCamera.FieldOfView
    else
        workspace.CurrentCamera.FieldOfView = Script.Temp.OldFOV
        Script.Temp.OldFOV = nil
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
end,

MainESP = function(...)
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
local UserInputService = game:GetService("UserInputService")

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

TabGroup:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        if Script.Connections.InfiniteJumpConnect then
            Script.Connections.InfiniteJumpConnect:Disconnect()
        end
        if not Value then
            return
        end
        Script.Connections.InfiniteJumpConnect = UserInputService.JumpRequest:Connect(function()
            if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end,
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
    Other = Window:AddTab("Other", "settings"),
    Script = Window:AddTab("Script", "sliders-horizontal"),
}

local TabGroups = {
    Player = Tabs.Other:AddLeftGroupbox("Player", "user"),
    Checkpoint = Tabs.Other:AddRightGroupbox("Checkpoint", "skull"),
    FOV = Tabs.Other:AddRightGroupbox("FOV settings", "user"),

    MainESP = Tabs.Other:AddLeftGroupbox("Main ESP", "eye"),
    ESPSettings = Tabs.ESP:AddRightGroupbox("ESP Settings", "sliders"),

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
    },
    Tasks = {},
    Temp = {},
    Functions = nil,
    HighlightESPTable = {
        Player = {},
        Boss = {},
        Aogiri = {},
        CCG = {},
    },
    TextESPTable = {
        Player = {},
        Boss = {},
        Aogiri = {},
        CCG = {},
    },
    ESP = nil,
    SaveManager = SaveManager,
    ThemeManager = ThemeManager,
}

Script.ESP = ESP(Script, Library)
Script.Functions = Functions(Script, Library)

for TabGroup, group in pairs(GroupFunctions) do
    group(TabGroups[TabGroup], Script, Library)
end

Library:OnUnload(Script.Functions.OnUnload)
task.spawn(function()
    pcall(Script.Functions.OnLoad)
end)

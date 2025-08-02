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

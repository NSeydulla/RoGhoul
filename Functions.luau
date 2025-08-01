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

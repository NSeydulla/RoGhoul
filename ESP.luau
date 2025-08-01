local Script: ScriptType, _: Obsidian = ...
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

--!strict
export type BaseESP = {
    Type: string,
    Color: Color3,
    Object: Instance,
    Connections: {[any]: RBXScriptConnection},
    SetColor: (Color3) -> (),
    SetFillTransparency: (number) -> (),
    SetOutlineTransparency: (number) -> (),
    Destroy: () -> (),
    GiveSignal: (RBXScriptConnection) -> ()
}

export type TextESP = BaseESP & {
    Text: string,
    Offset: Vector3
}

export type HighlightESP = BaseESP & {
    Highlights: {},
    OutlineTransparency: number,
    FillTransparency: number,
}

export type BaseESPArgs = {
    Type: string?,
    Color: Color3?,
    Object: Instance,
}

export type HighlightESPArgs = BaseESPArgs & {
}

export type TextESPArgs = BaseESPArgs & {
    Text: string?,
    Offset: Vector3?,
}

export type FunctionMap = {
    Alert: (msg: string, time: number?) -> (),
    OnLoad: () -> (),
    OnUnload: () -> (),
    GetRootPart: () -> Part?,
}

export type ESPMap = {
    HighlightESP: (HighlightESPArgs) -> HighlightESP,
    TextESP: (TextESPArgs) -> TextESP,
}

export type ScriptType = {
    repo: string,
    Connections: {[string]: any},
    Tasks: {[string]: any},
	Temp: {[string]: any},
    Functions: FunctionMap,
    ESP: ESPMap,
    HighlightESPTables: {
        Player: { HighlightESP? },
        Boss: { HighlightESP? },
        Aogiri: { HighlightESP? },
        CCG: { HighlightESP? },
    },
    TextESPTables: {
        Player: { TextESP? },
        Boss: { TextESP? },
        Aogiri: { TextESP? },
        CCG: { TextESP? },
    },
    SaveManager: any,
    ThemeManager: any
}

declare getgenv: () -> {
    shared: {
        RoGhoul_Library: Obsidian?
    }
}

declare workspace: Workspace & {
    NPCSpawns: any
}

declare ESP: (Script: ScriptType, Library: Obsidian) -> ESPMap
declare Functions: (Script: ScriptType, Library: Obsidian) -> FunctionMap
declare GroupFunctions: {[string]: (TabGroupBox: ObsidianGroupBox, Script: ScriptType, Library: Obsidian) -> ()}
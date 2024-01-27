ScriptName OPGameLoad Extends ReferenceAlias

OPMain main
OPPanel panel

int Property currentVersion = -1 auto

int function GetVersion()
    return 1
endfunction

Event OnPlayerLoadGame()
    Debug.Trace("OProstitution registering events")
    main = GetOwningQuest() as OPMain
    main.RegisterEvents()
    panel = GetOwningQuest() as OPPanel
    panel.RegisterEvents()

    if currentVersion < GetVersion()
        ; Upgrade logic
    endif
    currentVersion = GetVersion()
EndEvent

Event OnCellLoad()
    ; Force recalculation of attractiveness for NPCs when player moves cell
    ; Only will happen when a new cell is actually loaded (not from cache) but should be often enough
    int clearedValueCount = StorageUtil.ClearFloatValuePrefix("ocr_attractiveness")
    Debug.Trace("Cleared attractiveness values for " + clearedValueCount + " npcs")
EndEvent
ScriptName OPGameLoad Extends ReferenceAlias

OPMain main
OPPanel panel

int Property currentVersion = -1 auto

int function GetVersion()
    return 1
endfunction

Event OnPlayerLoadGame()
    main = self.GetOwningQuest() as OPMain
    main.RegisterEvents()
    panel = self.GetOwningQuest() as OPPanel
    panel.RegisterEvents()

    if currentVersion < GetVersion()
        ; Upgrade logic
    endif
    currentVersion = GetVersion()
EndEvent
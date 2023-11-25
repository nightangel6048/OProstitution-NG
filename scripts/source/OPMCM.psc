ScriptName OPMCM Extends SKI_ConfigBase

OPMain Property Main Auto

int SetOPFreqModifier
int SetOPOverlayKey
int SetOPDebug

string OProstitution = "OProstitution.esp"
int GVOPFreqModifier = 0x807
int GVOPShowOverlayKey = 0x809
int GVOPDebug = 0xD6C

int function GetVersion()
	return 1
endfunction

Event OnInit()
    Init()
EndEvent

Event OnConfigInit()
    ModName = "OProstitution NG"
    Debug.Notification("OProstitution NG Initialized")
EndEvent

Function Init()
    Parent.OnGameReload()
EndFunction

Event OnPageReset(String Page)
    AddColoredHeader("OProstitution")
    SetOPFreqModifier = AddSliderOption("$op_freq", GetExternalInt(OProstitution, GVOPFreqModifier), "{0}")
	SetOPOverlayKey = AddKeyMapOption("$op_overlaykey", GetExternalInt(OProstitution, GVOPShowOverlayKey))
	SetOPDebug = AddToggleOption("$op_debugtoggle", GetExternalBool(OProstitution, GVOPDebug))
EndEvent

Event OnGameReload()
    Parent.OnGameReload()
EndEvent

Event OnOptionHighlight(Int Option)
    If (Option == SetOPFreqModifier)
        SetInfoText("$op_freq_tooltip")
	ElseIf (Option == SetOPOverlayKey)
		SetInfoText("$op_overlaykey_tooltip")
    EndIf
EndEvent

Bool Color1
Function AddColoredHeader(String In)
	String Blue = "#6699ff"
	String Pink = "#ff3389"
	String Color
	If Color1
		Color = Pink
		Color1 = False
	Else
		Color = Blue
		Color1 = True
	EndIf

	AddHeaderOption("<font color='" + Color +"'>" + In)
EndFunction

Function SetExternalInt(string modesp, int id, int val)
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(val)
endfunction

int Function GetExternalInt(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() 
endfunction

Event OnOptionSliderOpen(Int Option)
    If (option == SetOPFreqModifier)
		SetSliderDialogStartValue(GetExternalInt(OProstitution, GVOPFreqModifier))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-80, 80)
		SetSliderDialogInterval(1)
    EndIf
EndEvent

Event OnOptionSliderAccept(Int Option, Float Value)
    If (Option == SetOPFreqModifier)
        SetExternalInt(OProstitution, GVOPFreqModifier, Value as Int)
        SetSliderOptionValue(SetOPFreqModifier, Value as Int, "{0}")
    EndIf
EndEvent

Event OnOptionKeyMapChange(Int Option, Int keyCode, String conflictControl, string conflictName)
	If (Option == SetOPOverlayKey)
		SetExternalInt(OProstitution, GVOPShowOverlayKey, keyCode)
		SetKeyMapOptionValue(SetOPOverlayKey, keyCode)
	EndIf
EndEvent

Event OnOptionSelect(Int Option)
	If (Option == SetOPDebug)
		SetExternalBool(OProstitution, GVOPDebug, !GetExternalBool(OProstitution, GVOPDebug))
		SetToggleOptionValue(SetOPDebug, GetExternalBool(OProstitution, GVOPDebug))
	EndIf
EndEvent

bool Function GetExternalBool(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() == 1
endfunction

Function SetExternalBool(string modesp, int id, bool val)
	int set = 0
	if val
		set = 1
	endif 

	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(set)
endfunction


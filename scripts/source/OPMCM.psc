ScriptName OPMCM Extends SKI_ConfigBase

OPMain Property Main Auto

int SetOPFreqModifier

string OProstitution = "OProstitution.esp"
int GVOPFreqModifier = 0x5807

Event OnInit()
    Init()
EndEvent

Event OnConfigInit()
    ModName = "OProstitution NG"
    Debug.Trace("OProstitution NG Initialized")
EndEvent

Function Init()
    Parent.OnGameReload()
EndFunction

Event OnPageReset(String Page)
    AddColoredHeader("OProstitution")
    SetOPFreqModifier = AddSliderOption("$op_freq", GetExternalInt(OProstitution, GVOPFreqModifier), "{0}")
EndEvent

Event OnGameReload()
    Parent.OnGameReload()
EndEvent

Event OnOptionHighlight(Int Option)
    If (Option == SetOPFreqModifier)
        SetInfoText("$op_freq_tooltip")
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
        Main.FreqModifier = Value as Int
        SetSliderOptionValue(SetOPFreqModifier, Value as Int, "{0}")
    EndIf
EndEvent


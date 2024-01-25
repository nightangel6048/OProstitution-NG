ScriptName OPMCM Extends SKI_ConfigBase

OPMain Property Main Auto

int SetOPFreqModifier
int SetOPOverlayKey
int SetOPDebug
int SetOPLeftNavigationKey
int SetOPRightNavigationKey

string OProstitution = "OProstitution.esp"
; Deprecated
int GVOPFreqModifier = 0x807
int GVOPShowOverlayKey = 0x809
int GVOPDebug = 0xD6C

string FREQ_KEY = "op_freq"
string OVERLAY_KEY = "op_overlaykey"
string DEBUG_TOGGLE_KEY = "op_debug"
string LEFT_NAV_KEY = "op_left_nav"
string RIGHT_NAV_KEY = "op_right_nav"

int function GetVersion()
	return 2
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
    SetOPFreqModifier = AddSliderOption("$op_freq", StorageUtil.GetIntValue(none, FREQ_KEY, 0), "{0}")
	SetOPOverlayKey = AddKeyMapOption("$op_overlaykey", StorageUtil.GetIntValue(none, OVERLAY_KEY, 40))
	SetOPLeftNavigationKey = AddKeyMapOption("$op_navigateleftkey", StorageUtil.GetIntValue(none, LEFT_NAV_KEY, 203))
	SetOPRightNavigationKey = AddKeyMapOption("$op_navigaterightkey", StorageUtil.GetIntValue(none, RIGHT_NAV_KEY, 205))
	SetOPDebug = AddToggleOption("$op_debugtoggle", StorageUtil.GetIntValue(none, DEBUG_TOGGLE_KEY, 0) != 0)
EndEvent

event OnVersionUpdate(int newVersion)
	if (newVersion >= 2 && CurrentVersion < 2)
		; Upgrade from globals to StorageUtil
		StorageUtil.SetIntValue(none, FREQ_KEY, GetExternalInt(OProstitution, GVOPFreqModifier))
		StorageUtil.SetIntValue(none, OVERLAY_KEY, GetExternalInt(OProstitution, GVOPShowOverlayKey))
		StorageUtil.SetIntValue(none, DEBUG_TOGGLE_KEY, GetExternalInt(OProstitution, GVOPDebug))
	endif
endevent

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

Function SetExternalInt(string modesp, int id, int val) ; Deprecated
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(val)
endfunction

int Function GetExternalInt(string modesp, int id) ; Deprecated
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() 
endfunction

Event OnOptionSliderOpen(Int Option)
    If (option == SetOPFreqModifier)
		SetSliderDialogStartValue(StorageUtil.GetIntValue(none, FREQ_KEY, 0))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-80, 80)
		SetSliderDialogInterval(1)
    EndIf
EndEvent

Event OnOptionSliderAccept(Int Option, Float Value)
    If (Option == SetOPFreqModifier)
        StorageUtil.SetIntValue(none, FREQ_KEY, Value as Int)
        SetSliderOptionValue(SetOPFreqModifier, Value as Int, "{0}")
    EndIf
EndEvent

Event OnOptionKeyMapChange(Int Option, Int keyCode, String conflictControl, string conflictName)
	If (Option == SetOPOverlayKey)
		StorageUtil.SetIntValue(none, OVERLAY_KEY, keyCode)
		SetKeyMapOptionValue(SetOPOverlayKey, keyCode)
	ElseIf (Option == SetOPLeftNavigationKey)
		StorageUtil.SetIntValue(none, LEFT_NAV_KEY, keyCode)
		SetKeyMapOptionValue(SetOPLeftNavigationKey, keyCode)
	ElseIf (Option == SetOPRightNavigationKey)
		StorageUtil.SetIntValue(none, RIGHT_NAV_KEY, keyCode)
		SetKeyMapOptionValue(SetOPRightNavigationKey, keyCode)
	EndIf
EndEvent

Event OnOptionSelect(Int Option)
	If (Option == SetOPDebug)
		if (StorageUtil.GetIntValue(none, DEBUG_TOGGLE_KEY, 0) == 0)
			StorageUtil.SetIntValue(none, DEBUG_TOGGLE_KEY, 1)
		else
			StorageUtil.SetIntValue(none, DEBUG_TOGGLE_KEY, 0)
		endif
		SetToggleOptionValue(SetOPDebug, StorageUtil.GetIntValue(none, DEBUG_TOGGLE_KEY, 0) != 0)
	EndIf
EndEvent

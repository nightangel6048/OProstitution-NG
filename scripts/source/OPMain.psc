ScriptName OPMain Extends OStimAddon 
import outils 

;todo disable prost when or follower active
 
actor property client auto 
int property UpcomingPayout auto 
int property UpcomingRep auto

actor property StoreOwner auto 
float property OwnersCut auto 

OPPanel property panel auto 
OPTaskManager property taskmanager auto

oromancescript property oromance auto

form property gold  auto

ORomanceScript property or auto
OArousedScript property oa auto 

bool property DarkenBackground auto 

bool property cheat = false auto ; TODO

string property LastProstTimeKey =  "op_lastbuytime" Auto

int Property ShowOverlayKey
	int Function Get()
		return or.ORKey.GetValueInt()
	EndFunction
EndProperty

bool Property PublicLegal
	bool Function Get()
		return outils.GetNPCDataBool(PlayerRef, "op_lic")
	EndFunction

	Function Set(bool var)
		return outils.StoreNPCDataBool(PlayerRef, "op_lic", var)
	EndFunction
EndProperty



int Property FreqModifier
	int Function Get()
		return StorageUtil.GetIntValue(none, "oprostitution.freqmod") as int
	EndFunction

	Function Set(int val)
		StorageUtil.SetIntValue(none, "oprostitution.freqmod", val as int)
	EndFunction
EndProperty

OPLantern property ActiveLantern auto 

; Level 1 - starting out, 0.75 customers per night 
; Level 2 - small business, 1.75 customer per night
; Level 3 - regionally known, 3.25
; Level 4 - known across skyrim, 6 customers per night
; Level 5 - Legendary, 10 
int Property ProstitutionLevel
	int Function Get()
		return GetNPCDataInt(playerref, "op_level")
	EndFunction

	Function Set(int Variable)
		Variable = PapyrusUtil.ClampInt(Variable, 0, 5)

		StoreNPCDataInt(playerref, "op_level", Variable)
	EndFunction
EndProperty

int Property ProstitutionExp
	int Function Get()
		return GetNPCDataInt(playerref, "op_exp")
	EndFunction

	Function Set(int Variable)
		Variable = PapyrusUtil.ClampInt(Variable, 0, 99999)

		StoreNPCDataInt(playerref, "op_exp", Variable)
	EndFunction
EndProperty


float Property lanternRadius Auto
int[] property lanternColor auto 

int[] LevelExpReqs

OPMain Function Get() global
	return outils.getformfromfile(0x800, "oprostitution.esp") as OPMain
EndFunction


Event OnInit()
	or = outils.GetFormFromFile(0x000800, "ORomance.esp") as ORomanceScript
	oa = OArousedScript.GetOAroused()
	PlayerRef = game.GetPlayer()

	gold = outils.GetFormFromFile(0xf, "skyrim.esm") 

	panel = (self as quest) as OPPanel
	taskmanager = (self as quest) as OPTaskManager

	if ProstitutionLevel == -1 ; new prostitute

		ProstitutionLevel = 1
	endif 

	lanternColor = new int[3]
	lanternColor[0] = 255
	lanternColor[1] = 24
	lanternColor[2] = 52

	LevelExpReqs = new int[7]
	LevelExpReqs[0] = 1
	LevelExpReqs[1] = 1
	LevelExpReqs[2] = 200
	LevelExpReqs[3] = 1200
	LevelExpReqs[4] = 2300
	LevelExpReqs[5] = 4200
	LevelExpReqs[6] = 2147483647


	SetLanternRadius()

	DarkenBackground = true 
	ActiveLantern = none 

	oromance = game.GetFormFromFile(0x000800, "ORomance.esp") as ORomanceScript

	RegisteredEvents = StringArray("OStim_SceneChanged", "OStim_End", "OStim_Orgasm", "OStim_PreStart", "OStim_TotalEnd")
	RequiredVersion = 25
	InstallAddon("OProstitution")

	if !MiscUtil.FileExists("Data/Interface/exported/widgets/iwant/widgets/library/check.dds")
		Debug.MessageBox("ORomance is out of date or missing. Please update for OProstitution")
	endif
EndEvent

Function SetLanternRadius()
	lanternRadius = 64 + (ProstitutionLevel * 32)

	if ActiveLantern
		ActiveLantern.RenderLight()
	endif 
EndFunction

Function AddEXP(int amount)
	int LevelBarrier = LevelExpReqs[ProstitutionLevel + 1]
	int target = ProstitutionExp + amount
	
	float start = (ProstitutionExp as float / LevelBarrier as float)
	float end = (target as float / LevelBarrier as float)

	ShowExpGain(start, end)

	ProstitutionExp = target 

	if ProstitutionExp >= LevelBarrier
		ProstitutionLevelUp(ProstitutionLevel + 1)
	endif 
EndFunction 

Function ShowExpGain(float barStart, float barEnd)
	int callback = UICallback.Create("HUD Menu", "_root.HUDMovieBaseInstance.QuestUpdateBaseInstance.ShowNotification")

	string msg 
	if barStart < barEnd
		msg = "Reputation gained"
	else 
		msg = "Reputation lost"
	endif 
	UICallback.PushString(callback, msg)
	UICallback.PushString(callback, "Status")
	UICallback.PushInt(callback, 5)
	UICallback.PushInt(callback, 1)
	UICallback.PushInt(callback, 12)
	UICallback.PushInt(callback, ProstitutionLevel)
	UICallback.PushFloat(callback, barStart)
	UICallback.PushFloat(callback, barEnd)
	UICallback.PushBool(callback, false)

	

	UICallback.Send(callback)
endfunction 

Function ProstitutionLevelUp(int to)
	ProstitutionLevel = to 
	ProstitutionExp = 0

	debug.Notification("You have reached prostitution level " + to)

	if to == 3
		Debug.Notification("Talk of your services has spread around")
	elseif to == 2 
		Debug.Notification("You can now change the lantern color")
	elseif to == 4 
		debug.Notification("You are well known regionally as a prostitute")
	elseif to == 5 
		debug.Notification("Talk of your amazing service has spread all around Tamriel!")
	elseif to == 6
		Debug.Notification("You read the source code!") 
	endif 

	Debug.Notification("Popularity increased")

	SetLanternRadius()
EndFunction

bool tFollow

bool Function OfferCustomer(actor npc)
	

	client = npc 
	StoreOwner = GetStoreOwner()

	taskmanager.GenerateTasks(npc)

	StoreNPCDataFloat(npc, LastProstTimeKey, Utility.GetCurrentGameTime())

	bool result = panel.OfferChoice()

	if result 
		if !tFollow && ostim.ShowTutorials
			tFollow = true
			ostim.DisplayToastAsync(npc.GetDisplayName() + " will now follow you", 4.0)
			ostim.DisplayToastAsync("Press " + GetButtontag(oromance.ORKey.GetValueInt()) + " while facing them when you are ready to have sex" , 7.0)
		endif 

		oromance.oui.FireSuccessIncidcator(0)
		oromance.oui.SetAsLongTermFollower(npc, true)
		if oromance.oui.CacheRebuildNeeded()
			oromance.oui.RebuildCacheSilent()
		endif 
	endif 


	return result
EndFunction

Event OnKeyDown(int keyCode)
	if keyCode == ShowOverlayKey
		if osanative.trylock("op_main_key")
			int k = ShowOverlayKey

			panel.ShowPanel()

			while input.IsKeyPressed(k)
				Utility.Wait(0.33)
			endwhile 

			panel.hidepanel()

			OSANative.unlock("op_main_key")
		endif
	endif 
EndEvent

actor Function GetStoreOwner() 
	faction innkeeper = GetFormFromFile(0x5091b, "skyrim.esm") as faction
	faction merchant = GetFormFromFile(0x51596, "skyrim.esm") as faction

	cell area = PlayerRef.GetParentCell()
	if (area.GetActorOwner() == none) && (area.GetFactionOwner() == none )
		; we are not in a store 

		return none 
	endif 

	actor owner = osanative.GetActorFromBase(area.GetActorOwner())
	if owner && !owner.IsDead()
		return owner 
	endif 

	faction FacOwner = area.GetFactionOwner()

	actor[] nearby = OSANative.GetActors(PlayerRef)
	int i = 0 
	while i < nearby.Length
		actor act = nearby[i] 

		if (act.IsInFaction(innkeeper) || act.IsInFaction(merchant)) && act.IsInFaction(facowner) && !act.IsDead()

			return act 
		endif 

		i += 1
	endwhile 

	return none 
EndFunction

bool tFirstTut
Function FirstTutorial()
	if !tFirstTut && ostim.ShowTutorials
		tFirstTut = true
		ostim.DisplayToastAsync("While you are within 30 meters of the lantern, customers can approach you for sex", 7.0)
		ostim.DisplayToastAsync("As a beginner, it may take up to 1-2 full nights for your first customer to approach", 6.5)
		ostim.DisplayToastAsync("As a you do more work, customers will approach more often", 6.0)
		ostim.DisplayToastAsync("If you are having little success in one area, try switching areas", 4.0) 
	endif 
EndFunction


bool tLantern
Function LanternTut()
	if !tLantern && ostim.ShowTutorials
		tLantern = true
		ostim.DisplayToastAsync("Drop the lantern to begin prostitution", 5.0)
	endif 
EndFunction
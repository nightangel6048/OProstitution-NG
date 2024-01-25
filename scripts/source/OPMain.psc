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

ORomanceScript property oromance auto

form property gold  auto

OArousedScript property oa auto 

bool property DarkenBackground auto 

int property ActiveOStimThreadID auto

string FREQ_KEY = "op_freq"
string OVERLAY_KEY = "op_overlaykey"
string DEBUG_TOGGLE_KEY = "op_debug"
string LEFT_NAV_KEY = "op_left_nav"
string RIGHT_NAV_KEY = "op_right_nav"

ReferenceAlias Property FollowerAlias
	ReferenceAlias function Get()
		return self.GetAlias(0) as ReferenceAlias
	EndFunction
EndProperty

ReferenceAlias Property WaitAlias
	ReferenceAlias function Get()
		return self.GetAlias(2) as ReferenceAlias
	EndFunction
EndProperty

ReferenceAlias Property FastFollowerAlias
	ReferenceAlias function Get()
		return self.GetAlias(3) as ReferenceAlias
	EndFunction
EndProperty

string property LastProstTimeKey =  "op_lastbuytime" Auto

bool Property PublicLegal
	bool Function Get()
		return outils.GetNPCDataBool(PlayerRef, "op_lic")
	EndFunction
	
	Function Set(bool var)
		return outils.StoreNPCDataBool(PlayerRef, "op_lic", var)
	EndFunction
EndProperty


int Property OPFreqModifier
	int function Get()
		return StorageUtil.GetIntValue(none, FREQ_KEY, 0)
	endfunction
endproperty

int Property OPShowOverlayKey
	int function Get()
		return StorageUtil.GetIntValue(none, OVERLAY_KEY, 40)
	endfunction
EndProperty

bool Property OPDebug
	bool function Get()
		return StorageUtil.GetIntValue(none, DEBUG_TOGGLE_KEY, 0) != 0
	endfunction
EndProperty

int Property OPNavigateLeftKey
	int function Get()
		return StorageUtil.GetIntValue(none, LEFT_NAV_KEY, 203)
	endfunction
endproperty

int Property OPNavigateRightKey
	int function Get()
		return StorageUtil.GetIntValue(none, RIGHT_NAV_KEY, 205)
	endfunction
endproperty

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
	return outils.GetFormFromFile(0x800, "OProstitution.esp") as OPMain
EndFunction


Event OnInit()
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
	LoadGameEvents = false
	
	oromance = game.GetFormFromFile(0x000800, "ORomance.esp") as ORomanceScript

	UnregisterForAllModEvents()

	RegisterForModEvent("ostim_scenechanged", "OStim_SceneChanged")
	RegisterForModEvent("ostim_thread_end", "OStim_End")
	RegisterForModEvent("ostim_actor_orgasm", "OStim_Orgasm")

	;RequiredVersion = 25
	InstallAddon("OProstitution")
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
			ostim.DisplayToastAsync("Press " + GetButtontag(OPShowOverlayKey) + " while facing them when you are ready to have sex" , 7.0)
		endif 
		RegisterForKey(OPShowOverlayKey)
		isOffer = true
	endif 


	return result
EndFunction

bool isOffer = false
Event OnKeyDown(int keyCode)
	if keyCode == OPShowOverlayKey
		if isOffer
			actor target = game.GetCurrentCrosshairRef() as actor
			if client == target
				isOffer = false
				taskmanager.StartTask(PlayerRef, client)
			endif
		elseif ActiveOStimThreadID != -1 && !OThread.IsRunning(ActiveOStimThreadID) ; Something has gone wrong and the scene has ended without us getting the event.
			taskmanager.Cleanup()
		elseif osanative.trylock("op_main_key")
			int k = OPShowOverlayKey

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

	if area.GetActorOwner() != none
		actor owner = osanative.GetActorFromBase(area.GetActorOwner())
		if owner && !owner.IsDead()
			return owner 
		endif 
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

function writeLog(string logMessage)
	ConsoleUtil.PrintMessage("OProstitution: " + logMessage)
endFunction

bool Function FollowerSetThread(actor npc)
	npc.SetLookAt(playerref, abPathingLookAt = false)
	npc.SetExpressionOverride(5, 100)

	float distance = npc.GetDistance(playerref)
	utility.wait(0.1)
	if distance > 300
		SetAsFollower(npc, true) 


		int timer = 0 
		int timer2 = 0

		float oldX = npc.x 
		while distance > 300
			Utility.Wait(0.5)

			distance = npc.GetDistance(playerref)

			timer += 1
			if timer > 240 
				SetAsFollower(npc, false)
				return  false 
			endif 

			if oldX == npc.X 
				timer2 += 1 

				if timer > 20 
					SetAsFollower(npc, false)
					return false 
				endif 
			else 
				oldX = npc.X
			endif 
		endwhile 
		SetAsFollower(npc, false)
		SetAsWaiting(npc, true)
	else 
		SetAsWaiting(npc, true)
	endif

		npc.EvaluatePackage()
	return true 
EndFunction

function SetAsFollower(actor act, bool set) ; follower in literal sense, not combat ally
	if set
		FollowerAlias.ForceRefTo(act)
		;console("Setting follower")
	Else
		FollowerAlias.clear()

		;console("Unsetting follower")
	endif

	act.EvaluatePackage()
EndFunction

function SetAsWaiting(actor act, bool set)
	if set
		WaitAlias.ForceRefTo(act)
	else
		WaitAlias.Clear()
	endif

	act.EvaluatePackage()
endfunction

function SetAsLongTermFollower(actor act, bool set) ; follower in literal sense, not combat ally

	if set
		FastFollowerAlias.ForceRefTo(act)
		console("Setting long-term follower")
	Else
		FastFollowerAlias.clear()

		console("Unsetting long-term follower")
	endif

	act.EvaluatePackage()

EndFunction

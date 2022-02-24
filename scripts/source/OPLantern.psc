ScriptName OPLantern Extends ObjectReference
import outils 

light property lampLight auto
ObjectReference lightobj
actor playerref

opmain main
oromancescript oromance

ReferenceAlias Property PlayerFollowerAlias
	ReferenceAlias Function Get()
		return main.GetNthAlias(0) as ReferenceAlias
	EndFunction
EndProperty

int Property CellBonus
	int Function Get()
		return StorageUtil.GetIntValue(GetParentCell(), "op_cell", missing = 0)
	EndFunction

	Function Set(int Variable)
		StorageUtil.SetIntValue(GetParentCell(), "op_cell", Variable)
	EndFunction
EndProperty

float playerMaxDistance = 1024.0
float scanFreq 

int lastTimeOfDay 

actor owner 

string[] idles

bool inited 
Event onload()
	if !inited
		return 
	endif 
	main = opmain.Get() 
	
	playerref = game.GetPlayer()
	oromance = game.GetFormFromFile(0x000800, "ORomance.esp") as ORomanceScript

	lastTimeOfDay = gettimeofday()

	if lastTimeOfDay != 2
		debug.Notification("Prostitution is most popular at night")
	endif 
	
	scanFreq = 30.0 
	if main.cheat
		scanFreq = 1.0
	endif 
	
	

	idles = stringarray("IdleStudy", "IdleExamine")

	main.ActiveLantern = self 
	main.StoreOwner = main.GetStoreOwner()

	RenderLight()

	RegisterForSingleUpdate(scanFreq)


EndEvent

Function Initialize()
	inited = true 
	onload()

	main.FirstTutorial()
EndFunction

Function RenderLight()
	lightobj.Disable()
	lightobj.Delete()

	PO3_SKSEFunctions.SetLightRadius(lampLight, main.lanternRadius)
	PO3_SKSEFunctions.SetLightRGB(lampLight, main.lanternColor)


	lightobj = self.PlaceAtMe(lampLight, abForcePersist = true)
	lightobj.MoveTo(self, afXOffset = 0.0, afYOffset = 0.0, afZOffset = 25.0, abMatchRotation = true)

endfunction 



Event OnUpdate()
	if self.Is3DLoaded()
		if (playerref.GetDistance(self) < playerMaxDistance) && !main.oromance.oui.PlayerIsFollowed() && !main.ostim.isactoractive(playerref); player is in range, no active ORomance people, not in a scene


			if GetTimeOfDay() != lastTimeOfDay
				lastTimeOfDay = GetTimeOfDay() 
			endif 

			; night is 25 minutes. Update freq is 30 secs. Thus 50 scan chances per night before other factors. 

			int chance
			int prostLVL = main.ProstitutionLevel

			if prostLVL == 1
				chance = 10
			elseif prostLVL == 2
				chance = 15
			elseif prostLVL == 3
				chance = 22
			elseif prostLVL == 4
				chance = 30
			else 
				chance = 60
			endif 

			if lastTimeOfDay != 2 
				chance /= 4
			endif 

			if ChanceRoll(13) || main.cheat ; + 60 / 2hrs in cell
				CellBonus += 2
			endif 

			chance += CellBonus

			chance += main.FreqModifier

			chance = PapyrusUtil.ClampInt(chance, 0, 90)
			if main.cheat
				console("Rolling scan with chance " + chance)
			endif 
			if ChanceRoll(chance) || main.cheat
				;Console("Scan success")
				scan()
			endif 

		else 

		endif 

		RegisterForSingleUpdate(scanFreq)
	endif 
EndEvent

; 	Scan results
; No close friends - 100%
;  Arousal average of random npcs - 37.5%
;   Prude req for single NPCs - 18.75 (1/5 roughly)
;
;


Function Scan()
	if !OSANative.TryLock("op_scan")
		return 
	endif 

	actor[] nearby = OSANative.GetActors(playerref, Radius = 2048.0)
		nearby = outils.ShuffleActorArray(nearby)

	int plevel = main.ProstitutionLevel
	int prudeMax = 50 + (plevel * 3) ; 65 at max


	int i = 0 
	int l = nearby.Length
	while i < l 
		actor npc = nearby[i]

		if main.cheat
			Console("Trying: " + npc.getdisplayname())
		endif 

		if npc.IsGuard() && !main.PublicLegal && !npc.isdead() && !main.StoreOwner
			FollowerSetThread(npc)
			Debug.Notification("License required to prostitute in public")
			debug.SendAnimationEvent(npc, "IdleWave")
			OSANative.unlock("op_scan")
			PickUp()
			return 
		endif 	

		if !(npc.GetSleepState() == 3) && !outils.IsChild(npc) && !main.ostim.isactoractive(npc) && !npc.IsDead() && (main.StoreOwner != npc) && (npc.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC"))); not sleeping or child or active
			
			if npc.GetRelationshipRank(playerref) < 3 ;not close friends
				if !npc.IsHostileToActor(playerref)
					
					
					if GetArousalChance(npc) > -15

						main.or.SeedIfNeeded(npc)
						int prude = main.or.getPrudishnessStat(npc)

						if main.or.getMonogamyDesireStat(npc) > 30
							if main.or.IsMarried(npc)
								prude += 50
							endif 

							if main.or.HasGFBF(npc)
								prude += 25
							endif 
						endif 

						if (prude <= prudeMax) ; only npcs who like prostitution 
							if (utility.getcurrentgametime() - GetNPCDataFloat(npc, main.LastProstTimeKey)) > 1 ; exclude recent customers
								if CheckOutGoods(npc)
									; that's all, NPC selected.

									OSANative.unlock("op_scan")
									return 
								else 
									if !main.cheat
										Utility.Wait(OSANative.RandomFloat(10.0, 45.0))
									endif 
								endif 
							endif 
						endif 
					endif

				endif 
			endif 
		endif

		if !Is3DLoaded()
			OSANative.unlock("op_scan")
			return 
		endif 

		i += 1
	endwhile

	if ChanceRoll(20)
		Debug.Notification("Seems nobody around is interested in you..")
	endif 

	OSANative.unlock("op_scan")
EndFunction



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
		main.oromance.oui.SetAsWaiting(npc, true)
	else 
		main.oromance.oui.SetAsWaiting(npc, true)
	endif
		
		npc.EvaluatePackage()
	return true 
EndFunction

function SetAsFollower(actor act, bool set) ; follower in literal sense, not combat ally
	if set
		PlayerFollowerAlias.ForceRefTo(act)
		;console("Setting follower")
	Else
		PlayerFollowerAlias.clear()

		;console("Unsetting follower")
	endif

	act.EvaluatePackage()
EndFunction

bool Function CheckOutGoods(actor act)
{NPC approaches player and thinks about buying them}
	oromance.OUI.ExitDialogue(0)
	oromance.oui.npc = act 
	if !FollowerSetThread(act)
		;Console("Rejecting stuck " + act.GetDisplayName())
		return false 
	endif 

	bool selected = false

	if act.Is3DLoaded() ; npc is now loaded and standing in front of the player


		debug.SendAnimationEvent(act, idles[osanative.RandomInt(0, idles.Length - 1)])


		

		int like = main.oromance.getlikestat(act) as int + (main.oromance.getlovestat(act) * 3) as int 
		int dislike = main.oromance.getdislikestat(act) as int + (main.oromance.gethatestat(act) * 3) as int 

		int chance = like - dislike 

		chance *= 4
		chance += 75

		if chance < 25 
			chance = 0
		endif 

		;console(chance)
		;Console(GetArousalChance(act))
		if ChanceRoll(chance) && ChanceRoll(GetArousalChance(act))
			Utility.Wait(osanative.RandomFloat(1.0, 3.0))
			selected = main.OfferCustomer(act)  
		else 
			Utility.Wait(osanative.RandomFloat(4.0, 7.0))
		endif 

	endif

	
	oromance.oui.SetAsFollower(act, false)
	oromance.oui.SetAsWaiting(act, false)
	
	

	debug.SendAnimationEvent(act, "IdleForceDefaultState")

	return selected
EndFunction



int Function GetArousalChance(actor act)
	int arousal = main.oa.GetArousal(act) as int 

		bool playerGender = AppearsFemale(playerref)

		if AppearsFemale(act)
			arousal -= 75
		endif 

		int sexuality = main.or.GetSexuality(act)
		if sexuality != 1
			if sexuality == 0
				if playergender == AppearsFemale(act)
					arousal -= 95
				endif 
			elseif sexuality == 2
				if playerGender != AppearsFemale(act)
					arousal -= 95
				else 
					arousal += 15
				endif 
			endif 
		endif 

		int sexDesire = main.or.getSexDesireStat(act)

		arousal += ((50.0 * (sexDesire as float / 100.0)) - 25.0) as int ; sex desire adds permanent +-/25 mod

		arousal += 25 

		return arousal 

EndFunction














Event OnActivate(ObjectReference akActionRef)
	MainMenu()
EndEvent

Function MainMenu()
	outils.SetUIVisible(false)

	UIMenuBase wheelMenu = UIExtensions.GetMenu("UIWheelMenu")

	Int exit = 7
	int lic = 5
	Int PickUp = 1
	int area = 4 
	int rgb = 3

	wheelMenu.SetPropertyIndexString("optionLabelText", exit, "Exit")
	if !main.PublicLegal
		wheelMenu.SetPropertyIndexString("optionLabelText", lic, "Buy license")
	endif 
	wheelMenu.SetPropertyIndexString("optionLabelText", pickup, "Pick up")
	wheelMenu.SetPropertyIndexString("optionLabelText", area, "Area info")
	if main.ProstitutionLevel > 1
		wheelMenu.SetPropertyIndexString("optionLabelText", 3, "Color")
	endif 

	wheelMenu.SetPropertyIndexBool("optionEnabled", exit, true)
	wheelMenu.SetPropertyIndexBool("optionEnabled", lic, !main.PublicLegal)
	wheelMenu.SetPropertyIndexBool("optionEnabled", pickup, true)
	wheelMenu.SetPropertyIndexBool("optionEnabled", area, true)
	if main.ProstitutionLevel > 1
	wheelMenu.SetPropertyIndexBool("optionEnabled", rgb, true)
	endif 


	int ret = wheelMenu.OpenMenu()

	if ret == pickup 
		pickup()
	elseif ret == lic 
		GoLegal()
	elseif ret == area 
		AreaInfo()
	elseif ret == rgb 
		LightMenu()
	endif 

	outils.SetUIVisible(true)
EndFunction

Function GoLegal()
	Debug.MessageBox("Purchasing a prostitution license for 2500 septims will allow you to work in public areas legally.")

	while OUtils.MenuOpen()
		Utility.Wait(0.1)
	endwhile 

	UIMenuBase wheelMenu = UIExtensions.GetMenu("UIWheelMenu")

	Int exit = 7
	Int Buy = 1

	wheelMenu.SetPropertyIndexString("optionLabelText", exit, "Exit")
	wheelMenu.SetPropertyIndexString("optionLabelText", buy, "Buy (2500 gold)")


	wheelMenu.SetPropertyIndexBool("optionEnabled", exit, true)
	wheelMenu.SetPropertyIndexBool("optionEnabled", buy, true)


	int ret = wheelMenu.OpenMenu()

	if ret == buy 
		if playerref.GetItemCount(main.gold) > 2500
			playerref.RemoveItem(main.gold, 2500)
			main.PublicLegal = true 
			Debug.Notification("You can now work in public areas")

		else 
			Debug.Notification("Not enough gold")
		endif 
	endif 
endfunction 

Function PickUp()
	playerref.AddItem(GetFormFromFile(0x1803, "oprostitution.esp"))

		UnregisterForUpdate()

		lightobj.Disable()
		lightobj.Delete()


		Disable()
		Delete()
endfunction 

Function LightMenu()
	outils.SetUIVisible(true)

	debug.Notification("Enter red value (0-255)")
	main.lanternColor[0] = PapyrusUtil.ClampInt(GetIntFromPlayer(), 0, 255)

	debug.Notification("Enter green value (0-255)")
	main.lanternColor[1] = PapyrusUtil.ClampInt(GetIntFromPlayer(), 0, 255)

	debug.Notification("Enter blue value (0-255)")
	main.lanternColor[2] = PapyrusUtil.ClampInt(GetIntFromPlayer(), 0, 255)

	RenderLight()

	Debug.Notification("Color changed. Default color is (255, 24, 52)")

EndFunction

Function AreaInfo()
	string a 
	string b 

	if main.GetStoreOwner()
		a = main.GetStoreOwner().GetDisplayName() + " owns this property"
	else 
		a = "Nobody owns this property"
	endif 

	int lev = CellBonus 

	string temp 
	if lev < 2 
		temp = "not known at all"
	elseif lev < 4 
		temp = "not well known"
	elseif lev < 6 
		temp = "slightly known"
	elseif lev < 10 
		temp = "somewhat known" 
	elseif lev < 18 
		temp = "known"
	elseif lev < 24 
		temp = "fairly well known"
	elseif lev < 30 
		temp = "very well known"
	else 
		temp = "extremely well known"
	endif 
	b = "You are " + temp + " in this area"

	Debug.MessageBox(a + "\n\n" + b)

	while OUtils.MenuOpen()
		Utility.Wait(0.1)
	endwhile 
EndFunction



int Function GetIntFromPlayer()
	uimenubase searchbar = uiextensions.GetMenu("UITextEntryMenu")
	searchbar.OpenMenu()

	string str = searchbar.GetResultString()
	int ret = str as int

	if str == ""
		ret = -600
	endif 

	return ret
EndFunction

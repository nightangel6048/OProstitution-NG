ScriptName optaskmanager Extends quest
import PapyrusUtil
import OUtils
opmain main 

OSexIntegrationMain ostim 

float lastSceneChangeTime

bool hasAnal

bool gay 
Event OnInit()
	ostim = getostim()

	main = (self as quest) as opmain

	Actor[] dummyActors = new Actor[2]
	dummyActors[0] = None
	dummyActors[1] = None
	hasAnal = OLibrary.GetRandomSceneWithAction(dummyActors, "analsex") != ""

	InitAllTasks()
EndEvent

string[] property activeTasks auto 
bool[] property taskCompletionState auto 
float[] property TimeTracking auto 

string[] property AllTasks auto
string[] property TaskIcons auto
string[] property TaskNames auto
int[] property TaskColor auto 


Function InitAllTasks()
	AllTasks = PapyrusUtil.StringArray(0)
	TaskIcons = PapyrusUtil.StringArray(0)
	TaskColor = PapyrusUtil.IntArray(0)

	LoadTask(cuminsidemouth, "sperm", "Cum inside mouth", 0)
	LoadTask(CumInsideVag, "impreg", "Cum inside vagina", 0)
	LoadTask(CumInsideAnus, "sperm", "Cum inside ass", 0)
	LoadTask(ClientOrgasm, "heart", "Client orgasm", 3)
	LoadTask(PlayerOrgasm, "heart", "Prostitute orgasm", 2)

	LoadTask(OralSex, "penis", "Blowjob ", 0)
	LoadTask(VaginalSex, "vagina", "Vaginal intercourse", 1)
	LoadTask(AnalSex, "ass", "Anal sex", 1)
	LoadTask(HandjobSex, "hand", "Handjob ", 2)
	LoadTask(EatPussySex, "vagina", "Cunnilingus ", 1)
	LoadTask(VagPlaySex, "vagina", "Vaginal play ", 1)

	LoadTask(CowgirlSex, "female", "Cowgirl ", 1)
	LoadTask(KissingSex, "lips", "Make out", 2)
	LoadTask(sixninesex, "penis", "69 ", 3)

	LoadTask(AnythingGoes, "heart", "Anything goes", 2)
	LoadTask(PlayerVictim, "anger", "Dominate you", 3)
EndFunction

Function GenerateTasks(actor npc)
	int sexdesire = main.oromance.getSexDesireStat(npc)
    if ChanceRoll(15)
    	activeTasks = PapyrusUtil.StringArray(1, AnythingGoes)

    	main.UpcomingRep = 90
    	main.UpcomingPayout = 200

    elseif (sexdesire > 60 && sexdesire < 69) && ChanceRoll(80) && main.GetStoreOwner()
    	activeTasks = PapyrusUtil.StringArray(1, PlayerVictim)

    	main.UpcomingRep = 350
    	main.UpcomingPayout = 500

    else 
    	int prude = main.or.getPrudishnessStat(npc)

    	int taskCount
    	if prude < 34
    		taskcount = OSANative.RandomInt(1, 2)
    	elseif prude < 67
    		taskcount = OSANative.RandomInt(1, 4)
    	elseif prude < 86
    		taskcount = OSANative.RandomInt(2, 6)
    	else 
    		taskcount = OSANative.RandomInt(3, 6)
    	endif

    	activeTasks = PapyrusUtil.StringArray(0, "")

    	


    	; ---- generate tasks

    	int i = 1
    	while i <= taskCount

    		if i == 1
    			if ChanceRoll(75)
    				Loadinorgasmtask()
    			else 
    				LoadInSexTask()
    			endif 
    		elseif i == 2
    			LoadInSexTask()
    		elseif i < 5 
    			if ChanceRoll(50)
    				LoadInActTask()
    			else 
    				LoadInSexTask()
    			endif 
    		elseif i == 5
    			if ChanceRoll(75)
    				LoadInActTask()
    			else 
    				LoadInSexTask()
    			endif 
    		elseif i == 6 
    			LoadInActTask()
    		endif 

    		i += 1
    	EndWhile 		

    	if activeTasks.Length < 1
    		activeTasks = PapyrusUtil.StringArray(1, AnythingGoes)
    	endif 


    	; ----


    	main.UpcomingRep = taskCount * OSANative.RandomInt(95, 105)
    	main.UpcomingPayout = 150 + (taskCount * osanative.Randomint(45, 55))
    endif 

    main.UpcomingRep += osanative.randomint(-25, 25)
    main.UpcomingPayout += osanative.randomint(-50, 50)


    if main.StoreOwner
    	main.oromance.SeedIfNeeded(main.storeowner)
    	float ownerPrude = main.oromance.getPrudishnessStat(main.StoreOwner)
    	if ownerPrude > 93
    		main.OwnersCut = 1.0
    	else 
    		ownerPrude /= 100.0 
    		ownerPrude /= 2.0 
    		ownerPrude += 0.05
    		main.OwnersCut = ownerPrude
    	endif 

    	main.UpcomingPayout = main.UpcomingPayout - (main.OwnersCut * main.UpcomingPayout as float) as int 
    endif 

    taskCompletionState = BoolArray(activeTasks.Length, false)
    

    ;bool array bugged and always returns true?
    int i = 0
    int l = taskCompletionState.Length
    While i < l 
    	 taskCompletionState[i] = false 
    
    	i += 1
    EndWhile

    float TimeNeeded = OSANative.RandomFloat(40.0, 70.0)
    TimeNeeded /= ostim.SexExcitementMult
    TimeTracking = FloatArray(activeTasks.Length, TimeNeeded)

    



    Console(activeTasks as string)
EndFunction


Function LoadInOrgasmTask()
	if ostim.isfemale(main.client)

		if ostim.isfemale(main.playerref) ; no males, less possiblity. 
			if ChanceRoll(75)
				SetTaskAsActive(ClientOrgasm)
			else 
				SetTaskAsActive(PlayerOrgasm)
			endif 

			return 
		endif 

		

		if ChanceRoll(75)
			SetTaskAsActive(ClientOrgasm)
			
		elseif ChanceRoll(50)
			SetTaskAsActive(PlayerOrgasm)
		else 
			if ChanceRoll(50)
				SetTaskAsActive(CumInsideMouth)
			else 
				SetTaskAsActive(CumInsideVag)
			endif 
		endif 

	else
		if main.or.getSexDesireStat(main.client) > 50
			if ChanceRoll(45) && (main.ostim.IsFemale(main.PlayerRef))
				SetTaskAsActive(CumInsideVag)
				main.UpcomingRep += 100
				main.UpcomingPayout += 100 
				return
			endif 
		endif 


		if chanceroll(50)
			SetTaskAsActive(ClientOrgasm)
		elseif ChanceRoll(50)
			SetTaskAsActive(CumInsideMouth)
		else 
			if ChanceRoll(50) && hasAnal
				SetTaskAsActive(CumInsideAnus)
				
			else 
				SetTaskAsActive(PlayerOrgasm)
			endif 
		endif 

	endif 
endfunction 

Function LoadInSexTask()
	if ostim.isfemale(main.client)
		if ChanceRoll(50)
			if ChanceRoll(50)
				SetTaskAsActive(EatPussySex)
			else 
				SetTaskAsActive(VagPlaySex)
			endif 
		elseif ChanceRoll(50)
			SetTaskAsActive(VagPlaySex)
		else 
			if ChanceRoll(30) && hasAnal
				SetTaskAsActive(AnalSex)
			else 
				SetTaskAsActive(OralSex)
			endif 
		endif 

	else 
		if (main.or.getSexDesireStat(main.client) > 25)
			if ChanceRoll(60) && (main.ostim.IsFemale(main.PlayerRef))
				SetTaskAsActive(VaginalSex)
				return
			endif 
		endif 

		if ChanceRoll(75)
			if ChanceRoll(50)
				SetTaskAsActive(OralSex)
			else 
				settaskasactive(HandjobSex)
			endif 
		elseif ChanceRoll(75) && (main.ostim.IsFemale(main.PlayerRef))
			if ChanceRoll(50)
				SetTaskAsActive(EatPussySex)
			else 
				settaskasactive(VagPlaySex)
			endif 
		else 
			if chanceroll(35) && hasAnal
				SetTaskAsActive(AnalSex)
			else 
				SetTaskAsActive(OralSex)
			endif 

		endif 
	endif 

endfunction 

Function LoadInActTask()
	if ChanceRoll(50)
		if ChanceRoll(50)
			SetTaskAsActive(CowgirlSex)
		else 
			SetTaskAsActive(KissingSex)
		endif 
	else 
		if ChanceRoll(50)
			SetTaskAsActive(SixNineSex)
		else 

		endif 
	endif 
endfunction

Function SetTaskAsActive(string taskID)
	if HasTask(taskid)
		Console("Task already loaded: " + taskID)
		return 
	endif 
	activeTasks = PapyrusUtil.PushString(activeTasks, taskID)
EndFunction

bool bAiControl

bool tSex
Event OStim_PreStart(string eventName, string strArg, float numArg, Form sender)
	if ostim.IsPlayerInvolved() && ostim.IsActorInvolved(main.client)
		ostim.AddSceneMetadata("oprostitution") 

		bAiControl = ostim.UseAIControl
		ostim.UseAIControl = false 

		main.panel.RenderPanel()

		RegisterForKey(main.ShowOverlayKey)

		lastSceneChangeTime = Utility.GetCurrentRealTime()

		gay = !(ostim.IsFemale(main.playerref)) && !(ostim.IsFemale(main.client)) 


		if HasTask(PlayerVictim)
			; Normally, we would never want to start an aggressive type scene like this
			; However, marking it as true aggressive will make npcs and guards attack with OCrime
			; So instead, we fake an aggressive scene. 
			;
			; This is a hack, Never do this!

			ostim.DisableOSAControls = true 
			while !ostim.IsActorActive(main.PlayerRef)
				Utility.Wait(0.75)
			endwhile 

			ostim.FadeToBlack(1)
			
			while !ostim.IsActorActive(main.playerref)
				Utility.wait(1.0)
			endwhile 

			Actor[] actors = new Actor[2]
			actors[0] = main.PlayerRef
			actors[1] = main.client
			String aggressiveScene = OLibrary.GetRandomSceneWithSingleActorTag(actors, 1, "aggressor")
			if aggressiveScene == ""
				aggressiveScene = OLibrary.GetRandomScene(actors)
			endif
			ostim.WarpToAnimation(aggressiveScene)

			

			ostim.FadeFromBlack(1)
		endif 

		CompleteIfHas(AnythingGoes)
    	RegisterForSingleUpdate(4)

    	if !tSex && ostim.ShowTutorials
			tSex = true
			outils.SetUIVisible(true)
			outils.DisplayToastText("Hold " + GetButtontag(main.oromance.ORKey.GetValueInt()) + " to view the task panel", 7.0)
			outils.DisplayToastText("Tasks will be marked in the panel as you complete them" , 4.0)
			outils.DisplayToastText("Some tasks like sex positions may take some time to complete" , 5.0)
			outils.SetUIVisible(false)
		endif
	endif 

EndEvent 

Event OStim_Orgasm(string eventName, string strArg, float numArg, Form sender)
    if ostim.hasscenemetadata("oprostitution") 
    	actor orgasmer = ostim.GetMostRecentOrgasmedActor()
    	if !ostim.isfemale(orgasmer)

    		if HasTask(CumInsideVag)
    			if ostim.IsVaginal()
    				SetTaskComplete(CumInsideVag)
    			endif 
    		endif 

    		if HasTask(CumInsideAnus)
    			if OMetadata.FindAction(OThread.GetScene(0), "analsex") != -1 || (gay && (ostim.IsVaginal()))
    				SetTaskComplete(CumInsideAnus)
    			endif 
    		endif 

    		if HasTask(CumInsideMouth)
    			if ostim.IsOral()
    				SetTaskComplete(CumInsideMouth)
    			endif 
    		endif 

 
    	else 
    		
    	endif 

    	if orgasmer == main.PlayerRef
    		CompleteIfHas(PlayerOrgasm)
    	elseif orgasmer == main.client 
    		CompleteIfHas(ClientOrgasm)
    	endif 


    endif 
EndEvent 

Event OStim_End(string eventName, string strArg, float numArg, Form sender)
    if ostim.hasscenemetadata("oprostitution") 


    	if HasTask(PlayerVictim)
    		if ostim.EndedProper
    			SetTaskComplete(PlayerVictim)
    		endif 
    	endif 

    	UnregisterForKey(main.ShowOverlayKey)
    	main.panel.HidePanel()

    	ostim.UseAIControl = bAiControl
    endif 
EndEvent

Event OStim_TotalEnd(string eventName, string strArg, float numArg, Form sender)
	if ostim.hasscenemetadata("oprostitution") 
		if AllTasksComplete()
			main.addexp(main.UpcomingRep)
			main.PlayerRef.AddItem(main.gold, main.UpcomingPayout)
			main.oromance.increaselikestat(main.client, OSANative.RandomInt(3, 9))

			if chanceroll(20)
				Debug.Notification("Recieved a tip!")
				main.PlayerRef.AddItem(main.gold, OSANative.RandomInt(5, main.UpcomingPayout/3))
				main.oromance.increaselovestat(main.client, 1)
				main.oromance.oui.FireSuccessIncidcator(0)
			endif 
		else 
			Debug.Notification("You missed some things...")

			int rep = OSANative.RandomInt(1, 100)
			main.addexp(-rep)
			Debug.Notification("Lost " + rep + " reputation")

			if ChanceRoll(50)
				int goldc = OSANative.RandomInt(1, main.UpcomingPayout/2)
				main.PlayerRef.AddItem(main.gold, goldc)
			else 
				Debug.Notification("The client refuses to pay")
				main.oromance.increasehatestat(main.client, 1)
			endif 
			main.oromance.oui.FireSuccessIncidcator(1)

			main.oromance.increasedislikestat(main.client, OSANative.RandomInt(9, 15))
		endif
		main.client = none
	endif 
EndEvent


Event OStim_SceneChanged(string eventName, string strArg, float numArg, Form sender)
    if ostim.hasscenemetadata("oprostitution") 
    	RegisterForSingleUpdate(4)

    	lastSceneChangeTime = Utility.GetCurrentRealTime()
    endif 
EndEvent

Event OnUpdate()
	if ostim.AnimationRunning()
		CheckTimeTasks()

		RegisterForSingleUpdate(4)
	endif 
EndEvent

Bool Function SceneHasAction(String actionTag)
	return OMetadata.FindAction(OThread.GetScene(0), actionTag) != -1
EndFunction

Function CheckTimeTasks()

		if ostim.IsVaginal()
			TickDownTime(VaginalSex)
		elseif SceneHasAction("analsex") || (gay && ostim.IsVaginal())
			TickDownTime(AnalSex)
		elseif ostim.IsOral()
			TickDownTime(OralSex)
		elseif SceneHasAction("handjob")
			TickDownTime(HandjobSex)
		elseif SceneHasAction("cunnilingus") || SceneHasAction("lickingvagina")
			TickDownTime(EatPussySex)
			TickDownTime(VagPlaySex)
		elseif SceneHasAction("vaginalfingering") || SceneHasAction("rubbingclitoris")
			TickDownTime(VagPlaySex)
		endif 

		if OMetadata.HasSceneTag(OThread.GetScene(0), "cowgirl")
			TickDownTime(CowgirlSex)
		endif

		if SceneHasAction("kissing")
			TickDownTime(KissingSex)
		endif

		if OMetadata.HasSceneTag(OThread.GetScene(0), "sixtynine") || OMetadata.HasSceneTag(OThread.GetScene(0), "69")
			TickDownTime(SixNineSex)
		endif 




endfunction 

Function TickDownTime(string task)
	int pos = activeTasks.find(task)
	if pos != -1
		TimeTracking[pos] = TimeTracking[pos] - 4 

		if TimeTracking[pos] < 0 
			SetTaskComplete(task)
		endif 
	endif 
endfunction 

Function CompleteIfHas(string task)
	if HasTask(task)
		settaskcomplete(task)
	endif 
endfunction

Bool Function HasTask(string task)
	return StringArrayContainsValue(activeTasks, task)
EndFunction

Function SetTaskComplete(string task)
	int taskID = activeTasks.Find(task)
	if !taskCompletionState[taskid]
		main.oromance.oui.FireSuccessIncidcator(3)
	endif 
	taskCompletionState[taskid] = true
EndFunction

bool Function AllTasksComplete()
	return taskCompletionState.Find(false) == -1
EndFunction

string property CumInsideMouth = "oral_ejac" auto
string property CumInsideVag = "vaginal_ejac" auto
string property CumInsideAnus = "anal_ejac" auto 
string property ClientOrgasm = "client_ejac" auto 
string property PlayerOrgasm = "player_ejac" auto 


string property OralSex = "oral_sex" auto 
string property VaginalSex = "vaginal_sex" auto
string property AnalSex = "anal_sex" auto 
string property HandjobSex = "handjob_sex" auto 
string property EatPussySex = "cunn_sex" auto 
string property VagPlaySex = "vagplay_sex" auto 

string property CowgirlSex = "cowgirl_sex" auto 
string property KissingSex = "kiss_sex" auto 
string property SixNineSex = "69_sex" auto 


string property AnythingGoes = "special_anything" auto 
string property PlayerVictim = "special_aggressive" auto

Function LoadTask(string taskId, string Icon, string name, int colorType)
	AllTasks = PapyrusUtil.PushString(AllTasks, taskid)
	TaskIcons = PapyrusUtil.PushString(TaskIcons, icon)
	TaskNames = PapyrusUtil.PushString(TaskNames, name)
	TaskColor = PapyrusUtil.pushint(TaskColor, colortype)
EndFunction


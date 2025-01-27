ScriptName OPPanel Extends quest 
import OUtils
import osanative

opmain main 
OPTaskManager manager
iwant_widgets property iWidgets auto

int hCenter = 360
int wCenter = 640

;-------------------- widgets
int background 

int name

int payout
int payoutAmount
int exp
int expAmount
int fee 
int feeAmount 

int divider

int[] task0
int[] task1
int[] task2
int[] task3
int[] task4
int[] task5
;--------------------

int[] colorPink
int[] colorGreen 
int[] colorLightRed
int[] colorBlue

int SlotCenter = 1
int SlotLeftMiddle = 3
int SlotRightMiddle = 2

int SlotQuarter = 4
int SlotQuarterSecond = 5
int SlotQuarterThird = 6
int SlotQuarterFourth = 7

int SlotLeftFar = 8
int SlotLeftClose = 9
int SlotRightClose = 10
int SlotRightFar = 11

Event OnInit()
	main = (self as quest) as opmain
	manager = (self as quest) as OPTaskManager
	
	colorPink = new int[3]
	colorPink[0] = 119
	colorPink[1] = 6
	colorPink[2] = 54
	
	colorGreen = new int[3]
	colorGreen[0] = 62
	colorGreen[1] = 162
	colorGreen[2] = 90
	
	colorLightRed = new int[3]
	colorLightRed[0] = 128
	colorLightRed[1] = 0
	colorLightRed[2] = 33
	
	colorBlue = new int[3]
	colorBlue[0] = 6
	colorBlue[1] = 73
	colorBlue[2] = 128

	RegisterEvents()
	
EndEvent

Function RegisterEvents()
	RegisterForModEvent("op_success", "SuccessIndicatorThread")
	RegisterForModEvent("iWantWidgetsReset", "OniWantWidgetsReset")
EndFunction

Event OniWantWidgetsReset(String eventName, String strArg, Float numArg, Form sender)
	iWidgets = sender as iwant_widgets
EndEvent

bool Function OfferChoice()
	RenderPanel()
	RenderSelection()

	bool bUIToggle = false 
	if IsUIVisible()
		bUIToggle = true 
		SetUIVisible(false )
	endif 
	game.DisablePlayerControls(false, false, false, false, false, true, abActivate = true,  abJournalTabs = false, aiDisablePOVType = 0)

	waitingForSelection = true 

	showPanel()
	ShowSelection()

	while waitingForSelection
		Utility.Wait(0.1)
	endwhile 

	HideSelection()	

	if bUIToggle
		SetUIVisible(true)
	endif 
	game.EnablePlayerControls()

	return selection as bool  
EndFunction


int[] nobutton
int[] yesbutton

Function RenderSelection()
	nobutton = RenderElement(3, "op_cross", colorLightRed, "Decline")
	yesbutton = RenderElement(2, "op_checkmark", colorGreen, "Accept")
endfunction 

Function RenderPanel()
	int leftside = wcenter - 100
	int titleLeft = leftside + 40
	int infoLeft = leftside + 20
	
	int infoStart = hcenter - 30
	int spacing  = 45
	int titleSpacing = 20

	int titleSize = 14
	int infoSize = 18

	name = iWidgets.loadText(padstring( OSANative.GetDisplayName(main.client), 23, 1 ), font = "$EverywhereFont", size = 26 )
		iWidgets.setPos(name,  leftside + 5  , infoStart - (spacing / 4))
		iwidgets.setTransparency(name, 0)

	
	payout = iWidgets.loadText(padstring("Payout +", 25, 1), font = "$EverywhereFont", size = titleSize )
		iWidgets.setPos(payout, titleLeft , infoStart + (spacing ) - titleSpacing)
		iwidgets.setTransparency(payout, 0)

	payoutAmount = iWidgets.loadText(padstring(main.UpcomingPayout + " Septims", 25, 1), font = "$EverywhereFont", size = infoSize )
		iWidgets.setPos(payoutAmount, infoLeft , infoStart + (spacing))
		iwidgets.setTransparency(payoutAmount, 0)

	exp = iWidgets.loadText(padstring("Reputation +", 25, 1), font = "$EverywhereFont", size = titleSize )
		iWidgets.setPos(exp, titleLeft , infoStart + (spacing * 2) - titleSpacing)
		iwidgets.setTransparency(exp, 0)

	expAmount = iWidgets.loadText(padstring(main.UpcomingRep + " points", 25, 1), font = "$EverywhereFont", size = infoSize )
		iWidgets.setPos(expAmount, infoLeft , infoStart + (spacing * 2))
		iwidgets.setTransparency(expAmount, 0)

	if main.StoreOwner
		fee = iWidgets.loadText(padstring(main.StoreOwner.GetDisplayName() + "'s fee -", 25, 1), font = "$EverywhereFont", size = titleSize )
			iWidgets.setPos(fee, titleLeft , infoStart + (spacing * 3) - titleSpacing)
			iwidgets.setTransparency(fee, 0)

		feeAmount = iWidgets.loadText(padstring((main.OwnersCut * 100) as int + " %", 25, 1), font = "$EverywhereFont", size = infoSize )
			iWidgets.setPos(feeamount, infoLeft , infoStart + (spacing * 3))
			iwidgets.setTransparency(feeamount, 0)
	endif 

	divider = iWidgets.loadLibraryWidget("op_box")
		iWidgets.setPos(divider, wCenter , hCenter)
		iwidgets.setTransparency(divider, 0)
		iwidgets.setSize(divider, 240, 1)
		iWidgets.setRGB(divider, 255, 255, 255)

	if main.DarkenBackground
		background = iWidgets.loadLibraryWidget("op_box")
		iwidgets.setSize(background, 920, 1280)
		iWidgets.setPos(background,  640, 360)
		iwidgets.setTransparency(background, 0)
		iWidgets.setRGB(background, 0, 0, 0)
	endif 

	rendertasks()
EndFunction

Function RenderTasks()
	int l = manager.activeTasks.Length
	int i = 0 
	while i < l 
		RenderTask(i, manager.activeTasks[i], l)

		i += 1
	endwhile 

	while i < 6
		SetTaskByID(i, PapyrusUtil.IntArray(0))

		i += 1
	endwhile 
EndFunction

Function RenderTask(int id, string taskID, int taskTotalCount)
	; 240 pixels total 

	int h = hcenter
	if taskTotalCount > 1
		h = (hcenter - ((taskTotalCount) * 15)) + (id * 45)
	endif 



	int w = wcenter + 115

	int[] task = new int[3]

	int idnum = manager.AllTasks.find(taskid)

	task[0] = iWidgets.loadText(padstring( manager.TaskNames[idnum], 25, 0), font = "$EverywhereFont", size = 20 )
		iWidgets.setPos(task[0],  w + 15, H)
		iwidgets.setTransparency(task[0], 0)

	task[1] = iWidgets.loadLibraryWidget(manager.TaskIcons[idnum])
		iWidgets.setPos(task[1],  w - 88 , H)
		iwidgets.setTransparency(task[1], 0)
		iwidgets.setSize(task[1], 35, 35)
		int[] color 
		int cache
		if manager.TaskColor[idnum] == 2 
			if AppearsFemale(main.PlayerRef)
				cache = 1
			else 
				cache = 0
			endif
		elseif manager.TaskColor[idnum] == 3
			if AppearsFemale(main.client)
				cache = 1
			else 
				cache = 0
			endif
		else 
			cache = manager.TaskColor[idnum]
		endif 

		if cache == 0
			color = colorBlue
		else 
			color = colorPink
		endif 
		iWidgets.setRGB(task[1], color[0], color[1], color[2])

	task[2] = iWidgets.loadLibraryWidget("op_checkmark") 
		iWidgets.setPos(task[2],  w - 88 , H)
		iwidgets.setTransparency(task[2], 0)
		iwidgets.setSize(task[2], 45, 45)
		iWidgets.sendToFront(task[2])
		iWidgets.setRGB(task[2], colorGreen[0], colorGreen[1], colorGreen[2])

	SetTaskByID(id, task)
endfunction 


bool tChoice
Function ShowSelection()
	selection = 1
	DeselectElement(yesbutton)
	DeselectElement(nobutton)
	SelectElement(yesbutton)

	RegisterForKey(main.OPNavigateLeftKey)
	RegisterForKey(main.OPNavigateRightKey)
	RegisterForKey(Input.GetMappedKey("Activate"))
	RegisterForKey(Input.GetMappedKey("Tween Menu"))

	if !tChoice && main.ostim.ShowTutorials
		tChoice = true
		outils.SetUIVisible(true)

		int leftside = wcenter - 100
		int titleLeft = leftside + 40
		int infoLeft = leftside + 20
	
		int infoStart = hcenter - 10
		int spacing  = 45
		int titleSpacing = 20

		iWidgets.setPos(name,  leftside , infoStart - (spacing / 4))
		iWidgets.setPos(payout, titleLeft , infoStart + (spacing ) - titleSpacing)
		iWidgets.setPos(payoutAmount, infoLeft , infoStart + (spacing))
		iWidgets.setPos(exp, titleLeft , infoStart + (spacing * 2) - titleSpacing)
		iWidgets.setPos(expAmount, infoLeft , infoStart + (spacing * 2))
		iWidgets.setPos(fee, titleLeft , infoStart + (spacing * 3) - titleSpacing)
		iWidgets.setPos(feeamount, infoLeft , infoStart + (spacing * 3))

		outils.DisplayToastText("You are being offered a prostitution job", 3.0)
		outils.DisplayToastText("On the right are the tasks you will have to complete during sex", 4.5)
		outils.DisplayToastText("On the left is information about rewards", 4.0)
		outils.DisplayToastText("Navigate your choices with " + GetButtontag(main.OPNavigateLeftKey) + " and " +  GetButtontag(main.OPNavigateRightKey) + ", and accept with " + GetButtontag(Input.GetMappedKey("Activate")), 6.0)

		outils.SetUIVisible(false)
		
	endif 
endfunction 

Function HideSelection()  
	UnregisterForKey(main.OPNavigateLeftKey)
	UnregisterForKey(main.OPNavigateRightKey)
	UnRegisterForKey(Input.GetMappedKey("Activate"))
	UnRegisterForKey(Input.GetMappedKey("Tween Menu"))

	FadeElementOut(nobutton)
	FadeElementOut(yesbutton)

	HidePanel()
EndFunction

Function HidePanel()  
	FadeWidgetOut(name)
	FadeWidgetOut(payout)
	FadeWidgetOut(payoutAmount)
	FadeWidgetOut(exp)
	FadeWidgetOut(expAmount)
	if main.StoreOwner
		FadeWidgetOut(fee)
		FadeWidgetOut(feeAmount)
	endif 
	FadeWidgetOut(divider)

	int i = 0 
	int l = 6 
	while i < l 

		int[] task = GetTaskByID(i)
		
		if task.length > 0
			FadeWidgetOut(task[0])
			FadeWidgetOut(task[1])
			if main.taskmanager.taskCompletionState[i]
				FadeWidgetOut(task[2])
			endif 
		endif 

		i += 1
	endwhile

	if main.DarkenBackground
		FadeWidgetOut(background)
	endif
EndFunction

int selection
bool waitingForSelection
Event OnKeyDown(int keyCode)
	if main.ostim.DisableOSAControls && main.ostim.isactoractive(main.playerref)
		Return
	endif 
	if OUtils.MenuOpen()
		return 
	endif 
	outils.lock("op_panel_key", 0.033)
	
	if keyCode == main.OPNavigateLeftKey
		DeselectElement(yesbutton)
		SelectElement(nobutton)

		selection = 0 
	elseif keycode == main.OPNavigateRightKey
		DeselectElement(nobutton)
		SelectElement(yesbutton)

		selection = 1
	elseif keycode == Input.GetMappedKey("Activate")
		waitingForSelection = false
	elseif keycode == Input.GetMappedKey("Tween Menu")
		selection = 0 
		waitingForSelection = false
	endif 

	osanative.unlock("op_panel_key")
EndEvent

Function ShowPanel()
	FadeWidgetIn(name)
	FadeWidgetIn(payoutAmount)
	FadeWidgetIn(payout)
	FadeWidgetIn(exp)
	FadeWidgetIn(expAmount)
	if main.StoreOwner
		FadeWidgetIn(fee)
		FadeWidgetIn(feeAmount)
	endif 
	FadeWidgetIn(divider, 50)

	if main.DarkenBackground
		iWidgets.sendToBack(background)
		FadeWidgetIn(background, 50)
	endif 

	int i = 0 
	int l = 6 
	while i < l 

		int[] task = GetTaskByID(i)
		
		if task.length > 0
			FadeWidgetIn(task[0])
			FadeWidgetIn(task[1])
			if main.taskmanager.taskCompletionState[i]
				FadeWidgetIn(task[2])
			endif 
		endif 

		i += 1
	endwhile
EndFunction


Function FadeWidgetIn(int widget, int alpha = 100)
	iWidgets.setVisible(widget)
	iWidgets.doTransitionByTime(widget, alpha, seconds = 1.0, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndFunction

Function FadeWidgetOut(int widget)
	iWidgets.doTransitionByTime(widget, 0, seconds = 0.5, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndFunction

int[] Function GetTaskByID(int id)
	if id == 0
		return task0
	elseif id == 1 
		return task1 
	elseif id == 2
		return task2 
	elseif id == 3 
		return task3 
	elseif id == 4
		return task4 
	elseif id == 5 
		return task5
	endif 
EndFunction

Function SetTaskByID(int id, int[] task)
	if id == 0
		task0 = task
	elseif id == 1 
		task1 = task
	elseif id == 2
		task2 = task
	elseif id == 3 
		task3 = task
	elseif id == 4
		task4 = task
	elseif id == 5 
		task5 = task
	endif 
EndFunction


;-------------- From ORomance OUI --------------

int Y_OFFSET = 200
int SIZE = 150
int[] Function RenderElement(int slot, string icon, int[] color, string Textstr) 
	
	int[] coords = GetElementCordsBySlot(slot)
	
	Int Bracket = iWidgets.loadLibraryWidget("op_selection")
	iwidgets.setVisible(Bracket, 0)
	iWidgets.setSize(Bracket, SIZE, SIZE)
	iWidgets.setPos(Bracket, coords[0] , coords[1])
	
	int core = iWidgets.loadLibraryWidget(icon)
	iWidgets.setSize(core, SIZE/4, SIZE/4)
	iWidgets.setPos(core, coords[0] , coords[1])
	iWidgets.setRGB(core, color[0], color[1], color[2])

	int text = iWidgets.loadText(textstr, size = 24 )
	iWidgets.setPos(text, coords[0] , coords[1] - 45)

	iwidgets.setTransparency(bracket, 0)
	iwidgets.setTransparency(core, 0)
	iwidgets.setTransparency(text, 0)

	iWidgets.setVisible(Bracket)
	iWidgets.setVisible(core)
	iWidgets.setVisible(text)

	int[] Element = new int[4]
	Element[0] = Bracket
	Element[1] = core
	Element[2] = text
	Element[3] = -1

	return Element
EndFunction

int[] function GetElementCordsBySlot(int slot)
	int[] coords = new int[2]

	
	if slot == slotCenter 
		coords[0] = (1280/2)
	elseif slot == SlotLeftMiddle
		coords[0] = (1280/2) - (1280/6)
	elseif slot == SlotRightMiddle
		coords[0] = (1280/2) + (1280/6)
	elseif slot == SlotQuarter
		coords[0] = (1280/2) - (1280/4)
	elseif slot == SlotQuarterSecond
		coords[0] = (1280/2) - ((1280/4) / 3)
	elseif slot == SlotQuarterThird
		coords[0] = (1280/2) + ((1280/4) / 3)
	elseif slot == SlotQuarterFourth
		coords[0] = (1280/2) + (1280/4)

	elseif slot == SlotLeftFar
		coords[0] = (1280/2) - (1280/4)
	elseif slot == SlotLeftClose 
		coords[0] = (1280/2) - (1280/8)
	elseif slot == SlotRightClose
		coords[0] = (1280/2) + (1280/8)
	elseif slot == slotRightFar
		coords[0] = (1280/2) + (1280/4)
	endif

	coords[1] =  (720/2) + Y_OFFSET
	return coords
EndFunction

function DeselectElement(int[] element)
	iwidgets.setSize(element[0], (SIZE * 0.75) as int, (SIZE * 0.75) as int)
	iwidgets.setSize(element[1], ((SIZE/4) * 0.75) as int, ((SIZE/4) * 0.75) as int)


	iWidgets.doTransitionByTime(element[0], 50, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	iWidgets.doTransitionByTime(element[1], 50, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	iWidgets.doTransitionByTime(element[2], 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
	iWidgets.doTransitionByTime(element[3], 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
EndFunction

function SelectElement(int[] element)
	iwidgets.setSize(element[0], SIZE , SIZE)
	iwidgets.setSize(element[1], (SIZE/4), (SIZE/4))

	int i = 0
	int l = element.Length

	while i < l
		iWidgets.doTransitionByTime(element[i], 100, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
		i += 1
	EndWhile
EndFunction

function FadeElementOut(int[] element)
	int i = 0
	int l = element.Length

	while i < l
		iWidgets.doTransitionByTime(element[i], 0, seconds = 0.25, targetAttribute = "alpha", easingClass = "none", easingMethod = "none", delay = 0.0)
		i += 1
	EndWhile
endfunction

function FireSuccessIncidcator(int type)
	;int handle = ModEvent.Create("op_success")

	;ModEvent.PushInt(handle, type)


	;ModEvent.Send(handle)
	Debug.Trace("OProstitution fired success indicator type " + type)
	SuccessIndicatorThread(type)
endfunction 

Int nameX = 640
int nameY = 660
Event SuccessIndicatorThread(int type) 
	Debug.Trace("OProstitution got success indicator type " + type)
	string icon
	int[] color
	if type == 0
		icon = "op_heart"
		color = colorPink
	elseif type == 1
		icon = "op_cross"
		color = colorlightRed 
	elseif type == 2
		icon = "op_checkmark"
		color = colorGreen
	endif 

	Int Indicator = iWidgets.loadLibraryWidget(icon)
	iWidgets.setRGB(Indicator, color[0], color[1], color[2])
	iWidgets.setSize(Indicator, size/6, size/6)
	iWidgets.setPos(Indicator, nameX, nameY - 10)
	iwidgets.setTransparency(Indicator, 100)
	iWidgets.setVisible(Indicator)
	float time = 0.5

	iwidgets.doTransitionByTime(Indicator,  nameY - 40,  seconds = time,  targetAttribute = "y",  easingClass = "strong",  easingMethod = "out",  delay = 0.0)
	Utility.Wait(time)

	Utility.Wait(time/2)

	iwidgets.doTransitionByTime(Indicator,  0,  seconds = time,  targetAttribute = "alpha",  easingClass = "none",  easingMethod = "none",  delay = 0.0)
	Utility.wait(time)

	iwidgets.destroy(Indicator)
EndEvent
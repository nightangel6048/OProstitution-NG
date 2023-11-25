Scriptname opinventorylanternscript extends ObjectReference  

Furniture Property lanternBase Auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	OPMain main = OPMain.Get()
	Actor player = Game.GetPlayer()
	if (akNewContainer == None) && (akOldContainer == player) && (main.ActiveLantern == none || !main.ActiveLantern.Is3DLoaded()) ; dumped from inventory 
		Disable()
		objectreference lantern = player.PlaceAtMe(lanternBase, abForcePersist = true)
		lantern.setangle(0, 0, lantern.getanglez())

		lantern.SetPosition(lantern.x, lantern.y, lantern.z + 2)
		Utility.Wait(1.0)
		(lantern as OPLantern).Initialize()
		DropFix()

		Delete() 
	elseif (akNewContainer == player)
		main.LanternTut()
	endif 
EndEvent



Function DropFix()
	quest wi = outils.GetFormFromFile(0x18965, "skyrim.esm") as quest 

	wi.stop()
EndFunction
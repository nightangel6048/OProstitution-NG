ScriptName OPUtils

Bool Function SceneHasAction(String actionTag, int tId) Global
	return OMetadata.FindAction(OThread.GetScene(tId), actionTag) != -1
EndFunction
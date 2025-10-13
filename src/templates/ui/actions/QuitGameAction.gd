class_name QuitGameAction extends ButtonAction

func execute(base: ClickableButton) -> void:
	base.get_tree().quit()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.close();")
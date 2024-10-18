extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSystemDeckManager.loading_system_decks.connect(func(): 
		text = ""
		editable = false
	)
	GlobalSystemDeckManager.loading_system_decks_done.connect(func():
		editable = true
	)


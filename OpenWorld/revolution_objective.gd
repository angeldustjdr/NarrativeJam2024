extends Objective

@onready var openworld = get_parent().get_parent()

func _ready():
	Radio.connect("interaction",interaction)
	GameState.connect("revolutionAdvanced",ON_OFF)
	GameState.connect("denialAdvanced",ON_OFF)
	$Area2D.monitoring = false

func interaction(interactable):
	if interactable == self :
		#Radio.emit_signal("setObjective") # Not needed because objective change only when going back to openworld after ilot or hub.
		openworld.showIntermediateDialog("tl_05mission5_pirate_porposition")

func ON_OFF():
	$Area2D.monitoring = !$Area2D.monitoring

extends Objective

# Schlag
@onready var openworld = get_parent().get_parent()

func _ready():
	Radio.connect("interaction",interaction)
	$Area2D.set_deferred("monitoring",self.needs_monitoring())

func needs_monitoring():
	return GameState.is_bernard_calling()

func interaction(interactable):
	if interactable == self :
		if GameState.is_bernard_calling() and not GameState.is_destruction_launched():
			#Radio.emit_signal("setObjective") # Not needed because objective change only when going back to openworld after ilot or hub.
			openworld.showIntermediateDialog("tl_05mission5_pirate_porposition")
			# Ending des la fin du dialogue avec l'ami bernard
			await(Dialogic.timeline_ended)
			if GameState.is_destruction_launched():
				GameState.launch_ending(GameState.PIRATE_ENDING)
			else:
				self.ON_OFF()
				self.visible = false
				openworld.get_node("player").revolutionObjective = null
		#elif GameState.is_bernard_calling() and GameState.is_destruction_launched():
		#	if not GameState.check_beacon_destruction():
		#		print("ENCORE DES BEACONS")
		#	else:
		#		GameState.launch_ending(GameState.PIRATE_ENDING)

func monotoring_ON():
	$Area2D.set_deferred("monitoring",true)
	
func ON_OFF():
	$Area2D.set_deferred("monitoring",!$Area2D.monitoring)

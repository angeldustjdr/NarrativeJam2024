extends Objective

# Schlag
@onready var openworld = get_parent().get_parent()

func _ready():
	Radio.connect("interaction",interaction)
	if self.needs_monitoring():
		self.visible = true
		%player.revolutionObjective = self
		$Area2D.set_deferred("monitoring",true)

func needs_monitoring():
	return GameState.is_bernard_calling()

func interaction(interactable):
	if interactable == self :
		if GameState.is_bernard_calling() and not GameState.is_destruction_launched():
			%player.movable = false
			#Radio.emit_signal("setObjective") # Not needed because objective change only when going back to openworld after ilot or hub.
			openworld.showIntermediateDialog("tl_05mission5_pirate_porposition")
			await(Dialogic.timeline_ended)
			# Ending des la fin du dialogue avec l'ami bernard
			if GameState.is_destruction_launched():
				GameState.launch_ending(GameState.PIRATE_ENDING)
			else:
				self.ON_OFF()
				self.visible = false
				%player.revolutionObjective = null
		#elif GameState.is_bernard_calling() and GameState.is_destruction_launched():
		#	if not GameState.check_beacon_destruction():
		#		print("ENCORE DES BEACONS")
		#	else:
		#		GameState.launch_ending(GameState.PIRATE_ENDING)

func monotoring_ON():
	$Area2D.set_deferred("monitoring",true)
	
func ON_OFF():
	$Area2D.set_deferred("monitoring",!$Area2D.monitoring)

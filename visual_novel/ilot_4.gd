extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	var mission_diff = GameState.get_current_mission_idx() - self._get_ilot_number()
	if mission_diff > 0:
		self._current_time_line = "tl_05mission5_gamers_influenced"
	else:
		self._current_time_line = "tl_04mission4_gamer_normal" # a complexifier au besoin

extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	var mission_diff = GameState.get_current_mission_idx() - self._get_ilot_number()
	if mission_diff > 0:
		match mission_diff:
			_ : self._current_time_line = "tl_05mission5_hacktivist_normal"
	else:
		self._current_time_line = "tl_05mission5_hacktivist_normal" # a complexifier au besoin

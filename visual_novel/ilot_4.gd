extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		match GameState.mission_corrupted["mission_4"] :
			0 : self._current_time_line = "tl_gamer_influenced"
			1 : self._current_time_line = "tl_gamer_influenced"
			_ : self._current_time_line = "tl_gamer_influenced"
	else:
		self._current_time_line = "tl_04mission4_gamer_normal" # a complexifier au besoin

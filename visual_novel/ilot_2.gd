extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		self._current_time_line = "tl_jcd_influenced"
	else:
		self._current_time_line = "tl_02mission2_jcd_normal" # a complexifier au besoin

extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		match GameState.mission_corrupted["mission_3"] :
			0 : self._current_time_line = "tl_04mission4_marginal_influenced2"
			_ : self._current_time_line = "tl_05mission5_outcast_influenced2"
	else:
		self._current_time_line = "tl_03mission3_outcast_normal" # a complexifier au besoin	

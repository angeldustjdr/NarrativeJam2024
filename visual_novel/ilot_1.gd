extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		match GameState.mission_corrupted["mission_1"] :
			0 : self._current_time_line = "tl_02mission2_galerien2_influenced"
			1 : self._current_time_line = "tl_03mission3_galerien_ influenced2"
			2 : self._current_time_line = "tl_04mission4_galerien_influenced3"
			_ : self._current_time_line = "tl_05mission5_galerien_influenced4"
	else:
		self._current_time_line = "tl_mission1_galerien1_normal" # a complexifier au besoin

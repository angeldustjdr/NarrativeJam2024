extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		match GameState.mission_corrupted["mission_2"] :
			0 : self._current_time_line = "tl_03mission3_jcd_ influenced"
			1 : self._current_time_line = "tl_04mission4_jcd_influenced3"
			_ : self._current_time_line = "tl_05mission5_jcd_influenced03"
	else:
		self._current_time_line = "tl_02mission2_jcd_normal" # a complexifier au besoin

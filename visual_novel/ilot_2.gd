extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		if GameState.mission_corrupted["mission_2"] == false :
			self._current_time_line = "tl_03mission3_jcd_ influenced"
		else :
			self._current_time_line = "tl_04mission4_jcd_influenced3"
	else:
		self._current_time_line = "tl_02mission2_jcd_normal" # a complexifier au besoin

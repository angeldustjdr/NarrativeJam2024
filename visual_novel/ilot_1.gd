extends IlotGeneric

func _update_time_line(): # determine what dialog is available in clickable character
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		if GameState.mission_corrupted["mission_1"] == false :
			self._current_time_line = "tl_02mission2_galerien2_influenced"
		else :
			self._current_time_line = "tl_03mission3_galerien_ influenced2"
	else:
		self._current_time_line = "tl_mission1_galerien1_normal" # a complexifier au besoin

extends ReferenceRect

var target_signal_properties = {"ampl":0.0,
								"mean":0.0,
								"period":0.0,
								"phase":0.0}

var property_activated = {"ampl":1,
						  "mean":1,
						  "period":1,
						  "phase":1}

var _saturation_factor = 0.8 # at _saturation_factor similarity there is no white_noise left

var _victory_ceil = 90.0 # ceil at which the victory in earned in %

signal victory

var signal_color : Color = Color.BLUE
var previous_s = 0

var rng = RandomNumberGenerator.new()
var intemperie : int = GameState.NONE
var intemperie_timer : Timer =  Timer.new()
var min_max_weak_disappear = [5.0,7.0]
var min_max_strong_disappear = [7.0,9.0]
var min_max_weak_appear = [3.0,4.0]
var min_max_strong_appear = [2.0,3.0]

# Called when the node enters the scene tree for the first time.
func _ready():
	self._init_intemperie_timer()
	$emit_button.pressed.connect(self._on_emit_button_pressed)
	self._deactivation_of_sliders()
	$OscilloScreen.set_target_signal_properties(self.target_signal_properties)
	$OscilloScreen.set_property_activated(self.property_activated)
	self._init_sliders()
	self._update_similarity()
	self._init_audio()

func _init_intemperie_timer():
	match GameState.check_intemperie():
		GameState.WEAK:
			self.add_child(self.intemperie_timer)
			self.intemperie_timer.timeout.connect(self._on_intemperie_timer_timeout)
			self.intemperie_timer.wait_time = randi_range(min_max_weak_appear[0],min_max_weak_appear[1])
			self.intemperie_timer.start()
		GameState.STRONG:
			self.add_child(self.intemperie_timer)
			self.intemperie_timer.timeout.connect(self._on_intemperie_timer_timeout)
			self.intemperie_timer.wait_time = randi_range(min_max_strong_appear[0],min_max_strong_appear[1])
			self.intemperie_timer.start()
		_:
			pass

func _on_intemperie_timer_timeout():
	match GameState.check_intemperie():
		GameState.WEAK:
			if $OscilloScreen/target_signal_shader.visible:
				$OscilloScreen/target_signal_shader.visible = false
				self.intemperie_timer.wait_time = randi_range(min_max_weak_disappear[0],min_max_weak_disappear[1])
				self.intemperie_timer.start()
			else:
				$OscilloScreen/target_signal_shader.visible = true
				self.intemperie_timer.wait_time = randi_range(min_max_weak_appear[0],min_max_weak_appear[1])
				self.intemperie_timer.start()
		GameState.STRONG:
			if $OscilloScreen/target_signal_shader.visible:
				$OscilloScreen/target_signal_shader.visible = false
				self.intemperie_timer.wait_time = randi_range(min_max_strong_disappear[0],min_max_strong_disappear[1])
				self.intemperie_timer.start()
			else:
				$OscilloScreen/target_signal_shader.visible = true
				self.intemperie_timer.wait_time = randi_range(min_max_strong_appear[0],min_max_strong_appear[1])
				self.intemperie_timer.start()
		_:
			pass

func set_difficulty(difficulty : int):
	match difficulty:
		0:
			self.property_activated = {"ampl":1,"mean":1,"period":0,"phase":0}
		1:
			self.property_activated = {"ampl":1,"mean":1,"period":1,"phase":0}
		2:
			self.property_activated = {"ampl":1,"mean":1,"period":1,"phase":1}
		_:
			push_error("Unknown difficulty")

func set_signal_color(s_color : Color):
	$background.color = s_color
	self.signal_color = s_color
	$OscilloScreen.set_target_signal_color(s_color)

func _on_emit_button_pressed():
	if GameState._debug: 
		victory.emit(self)
	else : 
		if $ProgressBar.value > self._victory_ceil:
			victory.emit(self)
	if $ProgressBar.value >= 99.0 : Achievements.genericCheck("Instrumentation master")

func _deactivation_of_sliders():
	for property_name in $OscilloScreen.properties:
		if self.property_activated[property_name] < 1:
			var p_range = $OscilloScreen.get_uniform_property_range(property_name)
			var p_val = 0.5 *(p_range[0]+p_range[1])
			self.target_signal_properties[property_name] = p_val
			self.get_node(property_name+"_slider").editable = false
			self.get_node(property_name+"_slider").modulate.a = 0.5
			self.get_node(property_name+"_slider").set_block_signals(true)

func _init_sliders():
	for property_name in $OscilloScreen.properties:
		var current_slider = self.get_node(property_name+"_slider")
		var prop_range = $OscilloScreen.get_uniform_property_range(property_name)
		current_slider.min_value = prop_range[0] #set range of slider
		current_slider.max_value = prop_range[1] #set range of slider
		current_slider.step = (prop_range[1]-prop_range[0])/1000.0
		current_slider.value = $OscilloScreen.get_property_value(property_name) #set value of slider regarding signal
	$ampl_slider.value_changed.connect(self._amplitude_changed)
	$phase_slider.value_changed.connect(self._phase_changed)
	$mean_slider.value_changed.connect(self._mean_changed)
	$period_slider.value_changed.connect(self._frequence_changed)



func _update_amplification():
	var idx_bus_wn = AudioServer.get_bus_index("oscillo_white_noise")
	var idx_bus_c = AudioServer.get_bus_index("oscillo_crowd")
	var similarity_factor = $ProgressBar.value / 100.0
	# correction for similarity
	var white_noise_volume = max(self._saturation_factor - similarity_factor,0.0) * (1.0/self._saturation_factor)
	AudioServer.get_bus_effect(idx_bus_wn,0).volume_db = SoundManager.get_db_from_lin(white_noise_volume)
	AudioServer.get_bus_effect(idx_bus_c,0).volume_db = SoundManager.get_db_from_lin(similarity_factor)

func _init_audio():
	$white_noise_loop.set_bus("oscillo_white_noise")
	$white_noise_loop.set_sound("white_noise",true)
	$white_noise_loop.play()
	$crowd_loop.set_bus("oscillo_crowd")
	$crowd_loop.set_sound("crowd",true)
	$crowd_loop.play()
	self._update_amplification()

func _update_similarity():
	var sim = $OscilloScreen.compute_similarity()
	$ProgressBar.value=sim
	if sim > _victory_ceil : 
		$emit_button.disabled = false
		$emit_button.modulate.a = 1.0
		$emit_button/AnimationPlayer.play("flicker")
		if previous_s < _victory_ceil : 
			SoundManager.playSoundNamed("oscillo_bleep")
	else : 
		$emit_button.disabled = true
		$emit_button.modulate.a = 0.5
		$emit_button/AnimationPlayer.stop()
	previous_s = sim
	if GameState._debug : 
		$emit_button.disabled = false

func _update_after_slider_changed():
	self._update_similarity()
	self._update_amplification()
	
func _amplitude_changed(value):
	$OscilloScreen.set_pilotable_property_value("ampl",value)
	self._update_after_slider_changed()
	
func _phase_changed(value):
	$OscilloScreen.set_pilotable_property_value("phase",value)
	self._update_after_slider_changed()

func _mean_changed(value):
	$OscilloScreen.set_pilotable_property_value("mean",value)
	self._update_after_slider_changed()
	
func _frequence_changed(value):
	$OscilloScreen.set_pilotable_property_value("period",value)
	self._update_after_slider_changed()

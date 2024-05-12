extends ReferenceRect

# Called when the node enters the scene tree for the first time.
func _ready():
	self._init_sliders()
	self._update_similarity()
	self._init_audio()

func _init_sliders():
	var properties_names = ["ampl","phase","mean","freq"]
	for property_name in properties_names:
		var current_slider = self.get_node(property_name+"_slider")
		var prop_range = $OscilloScreen.get_uniform_property_range(property_name)
		current_slider.min_value = prop_range[0] #set range of slider
		current_slider.max_value = prop_range[1] #set range of slider
		current_slider.step = (prop_range[1]-prop_range[0])/1000.0
		current_slider.value = $OscilloScreen.get_property_value(property_name) #set value of slider regarding signal
	$ampl_slider.value_changed.connect(self._amplitude_changed)
	$phase_slider.value_changed.connect(self._phase_changed)
	$mean_slider.value_changed.connect(self._mean_changed)
	$freq_slider.value_changed.connect(self._frequence_changed)

func _get_db_from_lin(x):
	return 10.0*(log(x)/log(10.0))
	
func _get_lin_from_db(x):
	return 10.0**(x/10.0)

func _update_amplification():
	var idx_bus_wn = AudioServer.get_bus_index("oscillo_white_noise")
	var idx_bus_c = AudioServer.get_bus_index("oscillo_crowd")
	var similarity_factor = $ProgressBar.value / 100.0
	AudioServer.get_bus_effect(idx_bus_wn,0).volume_db = self._get_db_from_lin(1.0-similarity_factor)
	AudioServer.get_bus_effect(idx_bus_c,0).volume_db = self._get_db_from_lin(similarity_factor)

func _init_audio():
	$white_noise_loop.set_bus("oscillo_white_noise")
	$white_noise_loop.set_sound("white_noise",true)
	$white_noise_loop.play()
	$crowd_loop.set_bus("oscillo_crowd")
	$crowd_loop.set_sound("crowd",true)
	$crowd_loop.play()
	var idx_bus_wn = AudioServer.get_bus_index("oscillo_white_noise")
	var idx_bus_c = AudioServer.get_bus_index("oscillo_crowd")
	AudioServer.add_bus_effect(idx_bus_wn,AudioEffectAmplify.new(),0)
	AudioServer.add_bus_effect(idx_bus_c,AudioEffectAmplify.new(),0)
	self._update_amplification()

func _update_similarity():
	var sim = $OscilloScreen.compute_similarity()
	$ProgressBar.value=sim

func _update_after_slider_changed():
	self._update_similarity()
	self._update_amplification()
	
func _amplitude_changed(value):
	$OscilloScreen.set_pilotable_amplitude(value)
	self._update_after_slider_changed()
	
func _phase_changed(value):
	$OscilloScreen.set_pilotable_phase(value)
	self._update_after_slider_changed()

func _mean_changed(value):
	$OscilloScreen.set_pilotable_mean(value)
	self._update_after_slider_changed()
	
func _frequence_changed(value):
	$OscilloScreen.set_pilotable_frequence(value)
	self._update_after_slider_changed()

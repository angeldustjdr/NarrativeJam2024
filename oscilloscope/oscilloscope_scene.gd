extends ReferenceRect

# Called when the node enters the scene tree for the first time.
func _ready():
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

func _update_similarity():
	var sim = $OscilloScreen.compute_similarity()
	$ProgressBar.value=sim

func _amplitude_changed(value):
	$OscilloScreen.set_pilotable_amplitude(value)
	self._update_similarity()
	
func _phase_changed(value):
	$OscilloScreen.set_pilotable_phase(value)
	self._update_similarity()

func _mean_changed(value):
	$OscilloScreen.set_pilotable_mean(value)
	self._update_similarity()
	
func _frequence_changed(value):
	$OscilloScreen.set_pilotable_frequence(value)
	self._update_similarity()
	

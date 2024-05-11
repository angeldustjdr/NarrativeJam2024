class_name OscilloscopeScreen

extends ColorRect

var signal_color = Color(0.0, 1.0, 0.0, 8.0) # Pilotable signal color
var target_signal_color = Color(0.0, 0.0, 1.0, 1.0) # Target signal color
var target_freq = 12.0 # Target signal frequency (omega)
var target_ampl = 1.0 # Target signal amplitude (alpha)
var target_mean = 0.0 # Target signal mean (mu)
var target_phase = 1.0 # Target signal amplitude (alpha)
var target_velo = 5.0 # Target signal velocity
var target_tightness = 10 # Target signal tighness

#RNG
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.init_pilotable_signal()
	self.update_target_signal()

func init_pilotable_signal(): # Randomly initialize the pilotable signal between the bounds of the parameters.
	$pilotable_signal_shader.set_color(self.signal_color)
	var properties = ["ampl","mean","phase","freq"]
	for property_name in properties:
		var property_range = self.get_uniform_property_range(property_name)
		var property_value = rng.randf_range(property_range[0],property_range[1])
		$pilotable_signal_shader.material.set_shader_parameter(property_name,property_value)

func set_pilotable_property_value(property_name,value):
	$pilotable_signal_shader.material.set_shader_parameter(property_name,value)
	
func set_pilotable_frequence(frequence):
	$pilotable_signal_shader.set_frequence(frequence)

func set_pilotable_mean(mean):
	$pilotable_signal_shader.set_mean(mean)
	
func set_pilotable_phase(phase):
	$pilotable_signal_shader.set_phase(phase)

func set_pilotable_amplitude(amplitude):
	$pilotable_signal_shader.set_amplitude(amplitude)

func get_uniform_property_range(uniform_property_name):
	return $pilotable_signal_shader.get_uniform_property_range(uniform_property_name)
	
func get_property_value(property_name):
	return $pilotable_signal_shader.get_property_value(property_name)

func update_target_signal():
	$target_signal_shader.set_color(self.target_signal_color)
	$target_signal_shader.set_frequence(self.target_freq)
	$target_signal_shader.set_amplitude(self.target_ampl)
	$target_signal_shader.set_phase(self.target_phase)
	$target_signal_shader.set_mean(self.target_mean)
	$target_signal_shader.set_tightness(self.target_tightness)
	$target_signal_shader.set_velocity(self.target_velo)
	#$target_signal_shader.set_clean()


# Computation of R2 as a similarity coefficient! It seems to work!
func compute_similarity(): 
	
	var a1 = $pilotable_signal_shader.get_property_value("ampl")
	var mu1 = $pilotable_signal_shader.get_property_value("mean")
	var phi1 = $pilotable_signal_shader.get_property_value("phase")
	var omega1 = $pilotable_signal_shader.get_property_value("freq")
	var a2 = $target_signal_shader.get_property_value("ampl")
	var mu2 = $target_signal_shader.get_property_value("mean")
	var phi2 = $target_signal_shader.get_property_value("phase")
	var omega2 = $target_signal_shader.get_property_value("freq")
	var score_num = 0.0
	var score_denom = 0.0
	var mean_w2 = 0.0
	var step = (PI/16.0)/omega2
	var x = 0.0 + phi2
	var c = 0
	while x < 2.0*PI/omega2 + phi2:
		mean_w2 += a2*sin(omega2*x+phi2)+mu2
		x += step
		c += 1
	mean_w2 /= c
	#print("ECART? %f - %f" % [mu2,mean_w2])
	x = 0.0 + phi2
	c = 0
	while x < 2.0*PI/omega2 + phi2:
		var w1 = a1*sin(omega1*x+phi1)+mu1
		var w2 = a2*sin(omega2*x+phi2)+mu2
		score_num += (w2-w1)**2
		score_denom += (w2-mean_w2)**2
		x += step
		c += 1
	var R2 = 1.0-(score_num/score_denom)
	#print("R2 = %f" % R2)
	return 100.0*R2

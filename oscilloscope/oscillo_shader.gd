extends TextureRect

func get_uniform_property_range(uniform_property_name):
	var properties=self.material.get_property_list()
	var the_hint_range:String
	for i in range (properties.size()):
		var property = properties[i]
		if property.name == "shader_parameter/"+uniform_property_name:
			the_hint_range=property.hint_string
			break
	var ranges=the_hint_range.split(",")
	return [float(ranges[0]), float(ranges[1])]

func print_all_properties_values():
	print("mean = %s" % self.get_property_value("mean"))
	print("phase = %s" % self.get_property_value("phase"))
	print("ampl = %s" % self.get_property_value("ampl"))
	print("freq = %s" % self.get_property_value("freq"))

func get_property_value(property_name):
	return self.material.get_shader_parameter(property_name)

func set_color(color):
	self.material.set_shader_parameter("modulate",color)

func set_frequence(frequence):
	self.material.set_shader_parameter("freq",frequence)

func set_mean(mean):
	self.material.set_shader_parameter("mean",mean)
	
func set_phase(phase):
	self.material.set_shader_parameter("phase",phase)

func set_velocity(velocity):
	self.material.set_shader_parameter("vel",velocity)

func set_amplitude(amplitude):
	self.material.set_shader_parameter("ampl",amplitude)
	
func set_tightness(tightness):
	self.material.set_shader_parameter("tightness",tightness)

#func set_clean():
#	self.material.set_shader_parameter("quality_signal",true)
	
#func set_noisy():
#	self.material.set_shader_parameter("quality_signal",false)


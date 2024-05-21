extends ColorRect

@onready var intensity = 0

func _process(delta):
	intensity = (intensity + 5*delta)
	if intensity>360 : intensity = 0.0
	self.material.set("shader_parameter/rotation_offset",intensity)

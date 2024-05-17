extends Sprite2D

@onready var intensity = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	intensity = (intensity + 5*delta)
	if intensity>360 : intensity = 0.0
	self.material.set("shader_parameter/rotation_offset",intensity)

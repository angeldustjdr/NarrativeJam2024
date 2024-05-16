extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_intemperie(intemperie_level : int):
	match intemperie_level:
		GameState.STRONG:
			self.visible = true
			$texture.material.set_shader_parameter("samples",4)
			$texture.material.set_shader_parameter("crease_noise",2.0)
			$texture.material.set_shader_parameter("crease_opacity",1.0)
		GameState.WEAK:
			self.visible = true
			$texture.material.set_shader_parameter("samples",2)
			$texture.material.set_shader_parameter("crease_noise",1.0)
			$texture.material.set_shader_parameter("crease_opacity",0.1)
		GameState.NONE:
			self.visible = false
			$texture.set_process(false)

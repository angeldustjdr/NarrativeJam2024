extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_duration(anim_name):
	return $scene_transition.get_duration(anim_name)

func reveal_scene():
	$scene_transition.reveal_scene()

func transition_to_packed_scene(next_packed_scene):
	$scene_transition.transition_to_packed_scene(next_packed_scene)
	
func transition_to_file_scene(next_packed_scene):
	$scene_transition.transition_to_file_scene(next_packed_scene)

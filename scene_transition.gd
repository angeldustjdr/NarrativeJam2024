extends ColorRect

@onready var _anim_player = $AnimationPlayer
@onready var _next_packed_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self._anim_player.play("fade_in")

func get_duration():
	return self._anim_player.current_animation_length

func transition_to_packed_scene(next_packed_scene):
	self._anim_player.animation_finished.connect(self._on_animation_finished_packed_scene)
	# Plays the Fade animation and wait until it finishes
	self._next_packed_scene = next_packed_scene
	self._anim_player.play("fade_out")
	
func transition_to_file_scene(next_packed_scene):
	self._anim_player.animation_finished.connect(self._on_animation_finished_file_scene)
	# Plays the Fade animation and wait until it finishes
	self._next_packed_scene = next_packed_scene
	self._anim_player.play("fade_out")
	
func _on_animation_finished_packed_scene(anime_name):
	if anime_name == "fade_out":
		get_tree().change_scene_to_packed(self._next_packed_scene)

func _on_animation_finished_file_scene(anime_name):
	if anime_name == "fade_out":
		get_tree().change_scene_to_file(self._next_packed_scene)

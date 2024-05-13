extends VisualNovelGeneric
class_name IlotGeneric

var ilot_name

@onready var _openworld_scene = preload("res://OpenWorld/open_world.tscn")
@onready var _oscillo_scene = preload("res://oscilloscope/oscilloscope_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$get_out_button.pressed.connect(self._on_button_pressed)
	if not(GameState.ilot_states[self.ilot_name]["revealed"]):
		$clickable_oscilloscope.oscilloclicked.connect(self._on_oscillo_clicked)
		$clickable_character.is_clickable = false
		$get_out_button.disabled = true
	else:
		$clickable_character.is_clickable = true
		$get_out_button.disabled = false

func _on_button_pressed():
	$scene_transition.transition_to_packed_scene(self._openworld_scene)

func _on_oscillo_clicked():
	for node in self.get_children():
		node.set_process(false)
	var oscillo_scene = self._oscillo_scene.instantiate()
	var v_port_size = get_viewport().size
	var oscillo_size = oscillo_scene.size
	var oscillo_scale = oscillo_scene.scale
	if oscillo_scale[0] != oscillo_scale[1]:
		push_warning("non isotrope scale.")
	var o_scale = oscillo_scale[0]
	oscillo_scene.position = Vector2(0.5*v_port_size[0]-0.5*o_scale*oscillo_size[0],
									 0.5*v_port_size[1]-0.5*o_scale*oscillo_size[1])
	self.add_child(oscillo_scene)
	oscillo_scene.victory.connect(self._on_oscillo_victory)
	
func _on_oscillo_victory(oscillo_scene):
	self.remove_child(oscillo_scene)
	GameState.ilot_states[self.ilot_name]["revealed"] = true
	$clickable_character.is_clickable = true
	$get_out_button.disabled = false
	$clickable_oscilloscope.oscilloclicked.disconnect(self._on_oscillo_clicked)
	for node in self.get_children():
		node.set_process(true)

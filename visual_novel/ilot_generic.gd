extends VisualNovelGeneric
class_name IlotGeneric

@export var ilot_color : Color
@export var difficulty : int

@onready var _openworld_scene = preload("res://OpenWorld/open_world.tscn")
@onready var _oscillo_scene = preload("res://oscilloscope/oscilloscope_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/scene_transition.visible = true
	$visual_novel_scene/get_out_button.pressed.connect(self._on_button_pressed)
	Radio.connect("clickObject",clickObject)
	if not(GameState.ilot_states[self.name]["revealed"]):
		$visual_novel_scene/CanvasModulate.visible = true
		$visual_novel_scene/oscillo_light.visible = true
		$visual_novel_scene/clickable_character.is_clickable = false
		$visual_novel_scene/clickable_oscilloscope.is_clickable = true
		$visual_novel_scene/get_out_button.disabled = true
	else:
		$visual_novel_scene/CanvasModulate.visible = false
		$visual_novel_scene/visual_novel_ward.visible = false
		$visual_novel_scene/clickable_character.is_clickable = true
		$visual_novel_scene/get_out_button.disabled = false
		$visual_novel_scene/clickable_oscilloscope.is_clickable = false
	$visual_novel_scene/oscillo_light.position = $visual_novel_scene/clickable_oscilloscope.position

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			self._on_button_pressed()

func clickObject(which):
	match which:
		"oscilloscope":
			self._on_oscillo_clicked()
		_ : 
			push_warning("clickable not recognized")

func _on_button_pressed():
	if GameState.ilot_states[self.name]["revealed"]:
		$CanvasLayer/scene_transition.transition_to_packed_scene(self._openworld_scene)

func _on_oscillo_clicked():
	for node in self.get_children():
		node.set_process(false)
	var oscillo_scene = self._oscillo_scene.instantiate()
	oscillo_scene.set_signal_color(self.ilot_color)
	oscillo_scene.set_difficulty(self.difficulty)
	var v_port_size = get_viewport().size
	var oscillo_size = oscillo_scene.size
	var oscillo_scale = oscillo_scene.scale
	if oscillo_scale[0] != oscillo_scale[1]:
		push_warning("non isotrope scale.")
	var o_scale = oscillo_scale[0]*GameState.get_current_window_ratio()
	oscillo_scene.position = Vector2(0.5*v_port_size[0]-0.5*o_scale*oscillo_size[0],
									 0.5*v_port_size[1]-0.5*o_scale*oscillo_size[1])
	$CanvasLayer.add_child(oscillo_scene)
	oscillo_scene.victory.connect(self._on_oscillo_victory)
	
func _on_oscillo_victory(oscillo_scene):
	$visual_novel_scene/clickable_oscilloscope.is_clickable = false
	$CanvasLayer.remove_child(oscillo_scene)
	GameState.ilot_states[self.name]["revealed"] = true
	$visual_novel_scene/clickable_character.is_clickable = true
	$visual_novel_scene/get_out_button.disabled = false
	self._reveal_ilot()
	
	for node in self.get_children():
		node.set_process(true)

func _reveal_ilot():
	var duration = 0.5
	var tween_1 = get_tree().create_tween()
	var tween_2 = get_tree().create_tween()
	tween_1.tween_property($visual_novel_scene/CanvasModulate, "color", Color.WHITE, duration).set_trans(Tween.TRANS_LINEAR)
	tween_2.tween_property($visual_novel_scene/oscillo_light, "color", Color.BLACK, duration).set_trans(Tween.TRANS_LINEAR)
	tween_1.tween_callback(self._hide_lightening_effect)

func _hide_lightening_effect():
	$visual_novel_scene/CanvasModulate.visible = false
	$visual_novel_scene/oscillo_light.visible = false

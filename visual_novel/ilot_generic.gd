extends VisualNovelGeneric
class_name IlotGeneric

@export var ilot_color : Color
@export var difficulty : int
@export var target_signal_prop : Dictionary = {"ampl":0.0,"mean":0.0,"period":0.0,"phase":0.0}

var _current_time_line : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$visual_novel_scene/get_out_button.pressed.connect(self._on_button_pressed)
	# DIALOG ASPECTS
	self._update_time_line()
	# VISUAL_NOVEL
	Radio.connect("clickObject",clickObject)
	if not(GameState.ilot_states[self.name]["revealed"]):
		$wave_timer.timeout.connect(self._on_wave_timer_timeout)
		self._on_wave_timer_timeout()
		$wave_timer.start()
		$visual_novel_scene/CanvasModulate.visible = true
		$visual_novel_scene/oscillo_light.visible = true
		$visual_novel_scene/clickable_character.is_clickable = false
		$visual_novel_scene/clickable_oscilloscope.is_clickable = true
		$visual_novel_scene/get_out_button.disabled = true
	else:
		if GameState.get_current_mission_idx() > self._get_ilot_number():
			MusicManager.playMusicNamed("ilot_corrupted",SceneTransitionLayer.get_duration("fade_in"))
		else:
			MusicManager.playMusicNamed(self.name,SceneTransitionLayer.get_duration("fade_in"))
		$visual_novel_scene/CanvasModulate.visible = false
		$visual_novel_scene/oscillo_light.visible = false
		$visual_novel_scene/clickable_character.is_clickable = true
		$visual_novel_scene/get_out_button.disabled = false
		$visual_novel_scene/clickable_oscilloscope.is_clickable = false
	$visual_novel_scene/oscillo_light.position = $visual_novel_scene/clickable_oscilloscope.position
	SceneTransitionLayer.reveal_scene()

func _on_wave_timer_timeout():
	SoundManager.playSoundNamed("wave_8bit")

func _update_time_line():
	self._set_current_time_line()

func _get_ilot_number():
	return int(self.name.split("_")[-1]) - 1

func _set_current_time_line():
	push_error("Must be surchaged in inherited scene")

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			self._on_button_pressed()

func clickObject(which):
	match which:
		"oscilloscope":
			self._on_oscillo_clicked()
		"character":
			self._on_character_clicked()
		_ : 
			push_warning("clickable not recognized")

func _on_character_clicked():
	if Dialogic.current_timeline == null:
		Dialogic.start(self._current_time_line)

func _on_button_pressed():
	if GameState.ilot_states[self.name]["revealed"]:
		GameState.coffeeCredit = 3
		MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
		SceneTransitionLayer.transition_to_packed_scene(GameState.openworld_packed_scene)

func _on_oscillo_clicked():
	$wave_timer.stop()
	for node in self.get_children():
		node.set_process(false)
	var oscillo_scene = GameState.oscillo_packed_scene.instantiate()
	oscillo_scene.set_signal_color(self.ilot_color)
	oscillo_scene.set_difficulty(self.difficulty)
	oscillo_scene.target_signal_properties = self.target_signal_prop
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
	MusicManager.playMusicNamed(self.name,1.0)
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

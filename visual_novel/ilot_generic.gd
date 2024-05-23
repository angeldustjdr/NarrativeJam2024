extends VisualNovelGeneric
class_name IlotGeneric

@export var ilot_color : Color
@export var ilot_color_corrupted : Color
@export var ilot_color_normal : Color
@export var difficulty : int
@export var target_signal_prop : Dictionary = {"ampl":0.0,"mean":0.0,"period":0.0,"phase":0.0}
@export var numero_ilot = 0

var _current_time_line : String
var _ilot_corrupted : bool = false

@onready var unlock = preload("res://achivement_unlocked.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$intemperie_texture.set_intemperie(GameState.check_intemperie())
	MusicManager.set_bus("music")
	Achievements.connect("unlock",showUnlock)
	GameState.pause_ether_timer()
	$visual_novel_scene/get_out_button.pressed.connect(self._on_button_pressed)
	# DIALOG ASPECTS
	self._update_corruption()
	self._update_background()
	self._update_oscillo_icon()
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
		# si la destruction a commence mais que le beacon de cet ilot n'est pas 
		if (GameState.is_destruction_launched() and 
			not GameState.ilot_states[self.name]["beacon_destroyed"]):
			$visual_novel_scene/clickable_oscilloscope.is_clickable = true
		else:
			$visual_novel_scene/clickable_oscilloscope.is_clickable = false
	$visual_novel_scene/oscillo_light.position = $visual_novel_scene/clickable_oscilloscope.position
	SceneTransitionLayer.reveal_scene()
	GameState.start_ilot_dialog_navigator(numero_ilot)

func _update_oscillo_icon():
	var texture_name = "res://assets/graphics/items/oscillo_icon_"+str(self._get_ilot_number()+1)+".png"
	if self._ilot_corrupted:
		texture_name = "res://assets/graphics/items/oscillo_icon_"+str(self._get_ilot_number()+1)+"_corrupted.png"
	$visual_novel_scene/clickable_oscilloscope/Sprite2D.texture = load(texture_name)

func _update_corruption():
	if GameState.get_current_mission_idx() > self._get_ilot_number():
		self._ilot_corrupted = true
	else:
		self._ilot_corrupted = false # a complexifier au besoin

func _update_background():
	if self._ilot_corrupted:
		$visual_novel_scene/Background.visible = false
		$visual_novel_scene/Background_corrupted.visible = true
	else:
		$visual_novel_scene/Background.visible = true
		$visual_novel_scene/Background_corrupted.visible = false
		
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
			if not GameState.is_destruction_launched():
				self._on_oscillo_clicked()
			else:
				$visual_novel_scene/clickable_oscilloscope.is_clickable = false
				GameState.ilot_states[self.name]["beacon_destroyed"] = true
				GameState.start_time_line("tl_beacon_destroyed")
				await(Dialogic.timeline_ended)
				GameState.check_pirate_ending()
		"character":
			self._on_character_clicked()
			
		_ : 
			push_warning("clickable not recognized")

func _on_character_clicked():
	GameState.start_time_line("tl_ask_to_talk_ilot")
	Dialogic.timeline_ended.connect(self._on_ask_to_talk_ilot_ended)

func _on_ask_to_talk_ilot_ended():
	Dialogic.timeline_ended.disconnect(self._on_ask_to_talk_ilot_ended)
	if Dialogic.VAR.talk_to_ilot:
		GameState.decrement_ether_timer()
		await get_tree().create_timer(0.1).timeout #FUCKING DIALOGIC : my guess : si t'as pas attendu suffisamment y a des trucs qui sont pas decharges ça fout la merde.
		# MAIS CURRENT_TIMELINE est quand même NULL haha!
		GameState.start_time_line(self._current_time_line)
		await(Dialogic.timeline_ended)

func _on_button_pressed():
	if GameState.ilot_states[self.name]["revealed"]:
		GameState.coffeeCredit = 3
		MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
		GameState.coming_from = GameState.ILOT
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
	SceneTransitionLayer.play_black_flash()
	await(SceneTransitionLayer.mid_flash)
	$OscilloLayer.add_child(oscillo_scene)
	oscillo_scene.victory.connect(self._on_oscillo_victory)
	
func _on_oscillo_victory(oscillo_scene):
	MusicManager.playMusicNamed(self.name,SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.play_black_flash()
	await(SceneTransitionLayer.mid_flash)
	$OscilloLayer.remove_child(oscillo_scene)
	$visual_novel_scene/clickable_oscilloscope.is_clickable = false
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

func showUnlock(message):
	var u = unlock.instantiate()
	u.text = "Achivement unlocked : " + message
	u.position = Vector2(64,1020-u.size.y)
	add_child(u)

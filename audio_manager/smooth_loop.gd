extends Node
class_name MySmoothLoop

# variables accessible through GUI
@export var sound_name: String = "white_noise"
@export var overlap: float = 0.2
@export var effective_bus: String = "master"
@export var volume_min: float = -80.0
@export var volume_max: float = -20.0

# internal variables
var _playing_channel: int = -1
var _tween_fade_in = null
var _tween_fade_out = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self._load_sound()
	self._update_bus()
	var bus_idx = AudioServer.get_bus_index(self.effective_bus)
	if AudioServer.get_bus_effect_count(bus_idx) == 0:
		push_error("smooth_loop bus must have amplify effect")
	else:
		if not AudioServer.get_bus_effect(bus_idx,0) is AudioEffectAmplify:
			push_error("smooth_loop bus first effect must be amplify")
	$song_timer.timeout.connect(_on_timer_timeout)

func set_volume(volume):
	var bus_idx = AudioServer.get_bus_index(self.effective_bus)
	AudioServer.get_bus_effect(bus_idx,0).volume_db = SoundManager.get_db_from_lin(volume)
	
func get_volume():
	var bus_idx = AudioServer.get_bus_index(self.effective_bus)
	return SoundManager.get_lin_from_db(AudioServer.get_bus_effect(bus_idx,0).volume_db)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	print("CHANNEL PLAYING : ", self._playing_channel)
#	print($channel_1.playing, " ",$channel_2.playing)
#	print($channel_1.volume_db, " ",$channel_2.volume_db)

func is_playing():
	return $channel_1.playing or $channel_2.playing

func set_bus(bus_name):
	self.effective_bus = bus_name
	self._update_bus()
	
func _update_bus():
	$channel_1.bus = self.effective_bus
	$channel_2.bus = self.effective_bus

func _on_timer_timeout():
	if self._tween_fade_in != null:
		self._tween_fade_in.kill()
	if self._tween_fade_out != null:
		self._tween_fade_out.kill()
	self._tween_fade_in = self.create_tween()
	self._tween_fade_out = self.create_tween()
	self._tween_fade_in.set_ease(Tween.EASE_OUT)
	self._tween_fade_out.set_ease(Tween.EASE_IN)
	if self._playing_channel == 1:
		self._playing_channel = 2
		self._tween_fade_in.tween_property($channel_2,"volume_db",volume_max,overlap).set_trans(Tween.TRANS_EXPO)
		self._tween_fade_out.tween_property($channel_1,"volume_db",volume_min,overlap).set_trans(Tween.TRANS_EXPO)
		$channel_2.play()
	elif self._playing_channel == 2:
		self._playing_channel = 1
		self._tween_fade_in.tween_property($channel_1,"volume_db",volume_max,overlap).set_trans(Tween.TRANS_EXPO)
		self._tween_fade_out.tween_property($channel_2,"volume_db",volume_min,overlap).set_trans(Tween.TRANS_EXPO)
		$channel_1.play()
	else:
		push_warning("invalid channel number playing.")
	$song_timer.start()

func set_sound(s_name,load_bool=false):
	self.sound_name = s_name
	if load_bool:
		self._load_sound()

func _load_sound():
	if self.sound_name == "":
		push_warning("sound_name not set.")
	else:
		var sound_path = SoundManager.sound_paths[self.sound_name]
		var sound_pitch = SoundManager.base_pitches[self.sound_name]
		var sound_volume = SoundManager.base_volumes[self.sound_name]
		self.volume_max = sound_volume
		$channel_1.stream = load(sound_path)
		$channel_2.stream = load(sound_path)
		$channel_1.pitch_scale = sound_pitch
		$channel_2.pitch_scale = sound_pitch
		$song_timer.wait_time = $channel_2.stream.get_length()*(1.0/sound_pitch) - self.overlap

func play():
	if $channel_1.stream == null or $channel_2.stream == null:
		push_warning("No sound to play.")
	self._playing_channel = 1
	$channel_1.volume_db = volume_max
	$channel_2.volume_db = volume_min
	$channel_1.play()
	$song_timer.start()

func stop():
	$song_timer.stop()
	if self._playing_channel == 1:
		$channel_1.stop()
	elif self._playing_channel == 2:
		$channel_2.stop()
	else:
		push_warning("trying to stop smooth_loop which is not playing.")

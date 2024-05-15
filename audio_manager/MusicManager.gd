extends Node

var musics_names = {"placehold":"res://assets/musics/1-05. Negative Mass.mp3"}
var musics_base_volumes = {"placehold":0.0}
var musics_loops = {"placehold":true}
var _streams = {}
var _current_music_name = null
var _bus_name = "music"

# Called when the node enters the scene tree for the first time.
func _ready():
	var p = MyAudioStreamPlayer.new()
	p.name = "music_player"
	p.volume_db = 0.0
	p.bus = self._bus_name
	p.stream = null
	self.add_child(p)
	for music_name in musics_names:
		self._streams[music_name] = load(musics_names[music_name])

func playMusicNamed(music_name,fade_in=-1.0):
	self.stopCurrent(fade_in) # à modifier pour faire un blend si besoin
	var ap = self.get_node("music_player")
	ap.stream = self._streams[music_name]
	ap.volume_db = musics_base_volumes[music_name]
	self._current_music_name = music_name
	ap.finished.connect(self.musicIsFinished)
	# play with fade_in
	if (fade_in > 0.0):
		self._play_fade_in(self._bus_name,fade_in)
	ap.play()

func _play_fade_out(bus_name,duration):
	var idx_bus = AudioServer.get_bus_index(bus_name)
	var effect = AudioServer.get_bus_effect(idx_bus,0)
	if not effect is AudioEffectAmplify:
		push_error("effect for fade in should be amplify")
	if effect.volume_db < 0.0:
		push_error("unexpected behavior")
	var tween = get_tree().create_tween()
	tween.tween_property(effect,"volume_db",-80.0,duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self._stop)

func _play_fade_in(bus_name,duration):
	var idx_bus = AudioServer.get_bus_index(bus_name)
	var effect = AudioServer.get_bus_effect(idx_bus,0)
	if not effect is AudioEffectAmplify:
		push_error("effect for fade in should be amplify")
	effect.volume_db = -80.0
	var tween = get_tree().create_tween()
	tween.tween_property(effect,"volume_db",0.0,duration).set_trans(Tween.TRANS_SINE)

func stopCurrent(fade_out=-1.0):
	var ap = self.get_node("music_player")
	if ap.stream != null:
		if fade_out > 0.0:
			self._play_fade_out(self._bus_name,fade_out)
		else:
			self._stop()

func _stop():
	var ap = self.get_node("music_player")
	ap.stop()
	ap.finished.disconnect(self.musicIsFinished)
	ap.stream = null
	self._current_music_name = null

func musicIsFinished():
	var ap = self.get_node("music_player")
	if musics_loops[self._current_music_name]:
		ap.play()
	else:
		ap.stop()
		ap.stream = null
		self._current_music_name = null

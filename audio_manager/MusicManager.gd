extends Node

var musics_names = {"placehold":"res://assets/musics/1-05. Negative Mass.mp3",
					"navigation":"res://assets/musics/Music - Explo.wav",
					"ilot_1":"res://assets/musics/eathersea/ilot/galeriens/spring drive manufacturing process-AlexGrohl.mp3",
					"ilot_2":"res://assets/musics/eathersea/ilot/jcd/hypnosphere-Evgeny_Bardyuzha.mp3",
					"ilot_3":"res://assets/musics/eathersea/ilot/marginaux/taj mahal-Lesfm.mp3",
					"ilot_4":"res://assets/musics/eathersea/ilot/gamers/techno driver-TazDev_music.mp3",
					"ilot_5":"res://assets/musics/eathersea/ilot/activistes/trailer sport stylish-Anton_Vlasov.mp3",
					"Hub":"res://assets/musics/hub/hub/elegant ambient science-Coma Media.mp3",
					"ilot_corrupted":"res://assets/musics/eathersea/ilot/ilot corrompu/glitch abstract trap-QubeSounds.mp3",
					"title_corpo":"res://assets/musics/reserve/space epic cinematic journey-Rockot.mp3",
					"title_pirate":"res://assets/musics/reserve/dark cyberpunk mechanical robotic future industrial dubstep-SoundGalleryDT.mp3",
					"motivational":"res://assets/musics/hub/intro discours/starfleet command-geoffharvey.mp3"}

var musics_base_volumes = {"placehold":0.0,
						   "navigation":0.0,
						   "ilot_1":0.0,
						   "ilot_2":0.0,
						   "ilot_3":0.0,
						   "ilot_4":0.0,
						   "ilot_5":0.0,
						   "Hub":0.0,
						   "ilot_corrupted":0.0,
						   "title_corpo":0.0,
						   "title_pirate":0.0,
						   "motivational":0.0}

var musics_base_offset = {"placehold":0.0,
						  "navigation":0.0,
						  "ilot_1":0.0,
						  "ilot_2":0.0,
						  "ilot_3":0.0,
						  "ilot_4":0.0,
						  "ilot_5":0.0,
						  "Hub":0.0,
						  "ilot_corrupted":0.0,
						  "title_corpo":0.0,
						  "title_pirate":0.0,
						  "motivational":0.0}
						
var musics_loops = {"placehold":true,
					"navigation":true,
					"ilot_1":true,
					"ilot_2":true,
					"ilot_3":true,
					"ilot_4":true,
					"ilot_5":true,
					"Hub":true,
					"ilot_corrupted":true,
					"title_corpo":true,
					"title_pirate":true,
					"motivational":true}
					
var _current_music_name = null
var _bus_name = "music"

# Called when the node enters the scene tree for the first time.
func _ready():
	var p = MyAudioStreamPlayer.new()
	p.name = "music_player"
	p.volume_db = 0.0
	p.bus = self._bus_name
	p.stream = null
	p.finished.connect(self.musicIsFinished)
	self.add_child(p)

func set_intemperie(intemperie_level : int):
	match intemperie_level:
		GameState.STRONG:
			self.set_bus("intemperie_strong") 
		GameState.WEAK:
			self.set_bus("intemperie_weak")
		GameState.NONE:
			self.set_bus("music")
		_:
			self.set_bus("music")

func playMusicNamed(music_name,fade_in=-1.0):
	self.stopCurrent(fade_in) # à modifier pour faire un blend si besoin
	var ap = self.get_node("music_player")
	ap.stream = load(self.musics_names[music_name])
	ap.volume_db = musics_base_volumes[music_name]
	self._current_music_name = music_name
	# play with fade_in
	if (fade_in > 0.0):
		self._play_fade_in(fade_in)
	ap.play(self.musics_base_offset[music_name])

func _play_fade_out(duration):
	var idx_bus = AudioServer.get_bus_index("music")
	var effect = AudioServer.get_bus_effect(idx_bus,0)
	if not effect is AudioEffectAmplify:
		push_error("effect for fade in should be amplify")
	if effect.volume_db < 0.0:
		push_warning("amplify effect volume not zero! value : ",effect.volume_db)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(effect,"volume_db",-80.0,duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self._stop)

func _play_fade_in(duration):
	var idx_bus = AudioServer.get_bus_index("music")
	var effect = AudioServer.get_bus_effect(idx_bus,0)
	if not effect is AudioEffectAmplify:
		push_error("effect for fade in should be amplify")
	effect.volume_db = -80.0
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(effect,"volume_db",0.0,duration).set_trans(Tween.TRANS_SINE)

func stopCurrent(fade_out=-1.0):
	var ap = self.get_node("music_player")
	if ap.stream != null:
		if fade_out > 0.0:
			self._play_fade_out(fade_out)
		else:
			self._stop()

func _stop():
	var ap = self.get_node("music_player")
	ap.stop()
	ap.stream = null
	self._current_music_name = null

func musicIsFinished():
	var ap = self.get_node("music_player")
	if musics_loops[self._current_music_name]:
		ap.play(self.musics_base_offset[self._current_music_name])
	else:
		ap.stop()
		ap.stream = null
		self._current_music_name = null
		
func set_bus(bus_name):
	self._bus_name = bus_name
	self.get_node("music_player").bus = bus_name

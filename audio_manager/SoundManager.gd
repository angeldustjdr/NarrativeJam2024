extends Node

var num_players = 8
var bus = "sound_effect"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.
var queue_vol = []  # Volume of the queued sounds.
var queue_pitch = []  # Pitch of the queued sounds.
var queue_name = []  # name of the sound playing

var sound_paths = {	"white_noise":"res://assets/sounds/white-noise-8117_cut.wav",
					"crowd":"res://assets/sounds/mixkit-big-crowd-talking-loop-364.wav",
					"wave_8bit":"res://assets/sounds/8-bit_wave.wav",
					"bounce":"res://assets/sounds/sfx/explosion/SUB_DROP_DEEP Shapeforms  .wav",
					"rocket":"res://assets/sounds/mixkit-space-rocket-full-power-turbine-1720.wav"}

var sound_loops = {"white_noise":true,
				   "crowd":true,
				   "wave_8bit":false,
				   "bounce":false,
				   "rocket":true}

var base_volumes = {"white_noise":-20.0,
					"crowd":0.0,
					"wave_8bit":-10.0,
					"bounce":-5.0,
					"rocket":-15.0}

var base_pitches = {"white_noise":1.0,
					"crowd":1.0,
					"wave_8bit":0.9,
					"bounce":1.5,
					"rocket":1.5}

func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = MyAudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.myfinished.connect(self._on_stream_finished)
		p.bus = bus

func get_db_from_lin(x):
	return 10.0*(log(x)/log(10.0))
	
func get_lin_from_db(x):
	return 10.0**(x/10.0)

func _on_stream_finished(stream):
		# When finished playing a stream, make the player available again.
		if self.sound_loops[stream.stream_name]:
			stream.stream_paused = false
			stream.play()
		else:
			available.append(stream)

func play(sound_path):
	queue.append(sound_path)

func playSoundNamed(sound_name):
	self.play(self.sound_paths[sound_name])
	self.queue_vol.append(self.base_volumes[sound_name])
	self.queue_pitch.append(self.base_pitches[sound_name])
	self.queue_name.append(sound_name)

func _process(_delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].volume_db = queue_vol.pop_front()
		available[0].pitch_scale = queue_pitch.pop_front()
		available[0].stream_name = queue_name.pop_front()
		available[0].play()
		available.pop_front()

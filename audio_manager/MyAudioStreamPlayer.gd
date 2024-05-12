extends AudioStreamPlayer
class_name MyAudioStreamPlayer

signal myfinished(stream)

@onready var stream_name = "default"

func _ready():
	self.finished.connect(self._emit_my_finished)
	
func _emit_my_finished():
	self.myfinished.emit(self)

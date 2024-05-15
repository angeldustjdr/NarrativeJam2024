extends Node

@export_enum("none", "weak", "strong") var _Intemperie

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.set_intemperie(self._Intemperie)
	MusicManager.playMusicNamed("navigation")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

extends Label

var withSound = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if withSound : SoundManager.playSoundNamed("achievement")

extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	setTexture()

func setTexture():
	if Achievements.get_status_of_achievement("Employee of the month"):
		self.texture = load("res://assets/graphics/items/diploma-tide.png")
	else:
		self.texture = load("res://assets/graphics/items/diploma-warden.png")

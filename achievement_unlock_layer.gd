extends CanvasLayer

var unlock_message_scene = preload("res://achivement_unlocked.tscn")

func _ready():
	self.layer = 10

func showMessage(isAchivement,message,where,sound):
	var u = unlock_message_scene.instantiate()
	if isAchivement : u.text = "Achievement unlocked : " 
	u.text += message
	u.position = where
	u.withSound = sound
	self.add_child(u)

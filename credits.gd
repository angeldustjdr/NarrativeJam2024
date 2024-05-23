extends Control

@onready var unlock = preload("res://achivement_unlocked.tscn")

var speed = 100.

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransitionLayer.reveal_scene()
	Achievements.connect("unlock",showUnlock)
	var ending
	match GameState.ending_speech :
		GameState.TRY_NEXT_MONTH_ENDING : ending = "YOU HAVE UNLOCKED THE ENDING #1 (/4) : Maybe next month\n\n\n---\n\n\n"
		GameState.EMPLOYEE_OF_THE_MONTH_ENDING : ending = "YOU HAVE UNLOCKED THE ENDING #2 (/4) : Employee of the month\n\n\n---\n\n\n"
		GameState.FIRED_ENDING : ending = "YOU HAVE UNLOCKED THE ENDING #3 (/4) : You're fired!\n\n\n---\n\n\n"
		GameState.PIRATE_ENDING : ending = "YOU HAVE UNLOCKED THE ENDING #4 (/4) : Rage against the machine\n\n\n---\n\n\n"
		_ : ending = ""
	var old = $Label.text
	$Label.text = ending+ old


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.position.y -= speed*delta



func _on_area_2d_area_entered(area):
	backToMain()


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			backToMain()

func backToMain():
	SceneTransitionLayer.transition_to_file_scene("res://main.tscn")
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))

func showUnlock(message):
	var u = unlock.instantiate()
	u.text = "Achivement unlocked : " + message
	u.position = Vector2(1920/2+200,100)
	add_child(u)

extends Control

var speed = 100.

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransitionLayer.reveal_scene()


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

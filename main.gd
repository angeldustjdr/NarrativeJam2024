extends Control

@onready var focus = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match focus:
		0:
			$AnimationPlayer.play("Play")
		1:
			$AnimationPlayer.play("Achievements")
		2:
			$AnimationPlayer.play("Credits")


func _on_play_mouse_entered():
	focus = 0
	


func _on_achievements_mouse_entered():
	focus = 1
	


func _on_credits_mouse_entered():
	focus = 2
	


func _on_play_mouse_exited():
	focus = -1


func _on_achievements_mouse_exited():
	focus = -1


func _on_credits_mouse_exited():
	focus = -1

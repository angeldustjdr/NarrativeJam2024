extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.ilot_states["ilot_5"]["revealed"] and GameState.mission_states["mission_5"]["started"] and !GameState.mission_states["mission_5"]["finished"]:
		$BernardCall.monitoring = true
	else :
		$BernardCall.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bernard_call_body_entered(body):
	if body==%player :
		GameState.start_time_line("tl_05mission5_anonymous")

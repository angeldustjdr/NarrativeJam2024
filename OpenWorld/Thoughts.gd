extends Node2D

var messageToughts = {
	GameState.thoughts.DEPRIME : [
	"C'est la déprime message 1",
	"C'est la déprime message 2",
	"C'est la déprime message 3",
	"C'est la déprime message 4"
	],
	GameState.thoughts.COLERE : [
	"C'est la colère message 1",
	"C'est la colère message 2",
	"C'est la colère message 3",
	"C'est la colère message 4"
	],
	GameState.thoughts.PEUR : [
	"C'est la peur message 1",
	"C'est la peur message 2",
	"C'est la peur message 3",
	"C'est la peur message 4"
	]
}

var deltaT : float = 4.0
var desiredText : Array

var player = get_parent()

func activateThoughts(which):
	desiredText = messageToughts[which]
	$Timer.wait_time = randf_range(2.0,deltaT)
	$Timer.start()

func desactivateThoughts():
	$Timer.stop()

func _on_timer_timeout():
	Radio.emit_signal("sendThoughts",desiredText.pick_random())


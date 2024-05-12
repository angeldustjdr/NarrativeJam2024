extends Label

func _ready():
	Radio.connect("showAlertMessage",showAlertMessage)


func _on_timer_timeout():
	visible = false

func showAlertMessage(myMessage):
	visible = true
	$Timer.wait_time = 1.0
	$Timer.start()
	text = myMessage

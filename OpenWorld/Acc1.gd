extends Area2D


func _on_body_entered(body):
	Radio.emit_signal("bodyEnteredAccelerationZone",body)


func _on_body_exited(body):
	Radio.emit_signal("bodyExitedAccelerationZone",body)

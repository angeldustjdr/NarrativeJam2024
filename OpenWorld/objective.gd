extends Node2D

func _ready():
	Radio.connect("interaction",interaction)

func _on_area_2d_body_entered(body):
	Radio.emit_signal("bodyEnteredObjective",self,body)


func _on_area_2d_body_exited(body):
	Radio.emit_signal("bodyExitedObjective",self,body)

func interaction(interactable):
	if interactable == self :
		Radio.emit_signal("setObjective",null)
		Radio.emit_signal("showAlertMessage","Objective completed!")
		queue_free()

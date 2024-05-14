extends Node2D

var _next_scene = null # scene to which the objective 

signal scene_need_changing

func set_next_scene(next_scene):
	self._next_scene = next_scene

func _ready():
	Radio.connect("interaction",interaction)

func _on_area_2d_body_entered(body):
	Radio.emit_signal("bodyEnteredObjective",self,body)

func _on_area_2d_body_exited(body):
	Radio.emit_signal("bodyExitedObjective",self,body)

func interaction(interactable):
	if interactable == self :
		Radio.emit_signal("setObjective")
		if self._next_scene == null:
			push_error("next_scene not defined")
		else:
			self.scene_need_changing.emit(self._next_scene)

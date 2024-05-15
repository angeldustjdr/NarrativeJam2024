extends Node2D

var is_clickable : bool = false

signal oscilloclicked

# Called when the node enters the scene tree for the first time.
func _ready():
	$oscilloscope_scene.property_activated = {"ampl":0,"mean":0,"period":0,"phase":0}
	$oscilloscope_scene._deactivation_of_sliders()
	$oscilloscope_scene/emit_button.disabled
	$area.input_event.connect(self._on_input)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_input(_node,event,_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print(self.is_clickable)
			if self.is_clickable:
				oscilloclicked.emit()

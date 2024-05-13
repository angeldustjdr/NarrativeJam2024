extends Node2D

signal oscilloclicked

# Called when the node enters the scene tree for the first time.
func _ready():
	$area.input_event.connect(self._on_input)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_input(_node,event,_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			oscilloclicked.emit()

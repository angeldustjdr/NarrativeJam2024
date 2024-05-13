extends Node2D

var dialogic_time_line = "Test_timeline"

var is_clickable

# Called when the node enters the scene tree for the first time.
func _ready():
	$area.input_event.connect(self._on_input)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_input(_node,event,_idx):
	if is_clickable:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if Dialogic.current_timeline == null:
					Dialogic.start(self.dialogic_time_line)

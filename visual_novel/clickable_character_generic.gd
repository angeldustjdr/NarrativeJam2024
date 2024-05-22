extends Node2D

var dialogic_time_line = "Test_timeline"

@export var is_clickable : bool
var _clickable_true : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameState._debug: 
		self._clickable_true = false
	else:
		self._clickable_true = true
	SceneTransitionLayer.fade_in_finished.connect(self._on_transition_fade_in_finished)
	SceneTransitionLayer.transition_out.connect(self._on_transition_fade_out_started)
	$area.input_event.connect(self._on_input)

func _on_transition_fade_in_finished():
	self._clickable_true = true

func _on_transition_fade_out_started():
	self._clickable_true = false

func _on_input(_node,event,_idx):
	if is_clickable and _clickable_true:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if Dialogic.current_timeline == null:
					Dialogic.start(self.dialogic_time_line)

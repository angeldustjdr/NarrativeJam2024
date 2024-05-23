extends Node2D

@export var is_clickable : bool # is effectively clickable in current gamestate
@export var imageModulate : Color
@export var which : String

var _sprite_2d_name : String

@onready var _outline_base_width = 3.0
var _clickable_true : bool # actually at this frame

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransitionLayer.fade_in_finished.connect(self._on_transition_fade_in_finished)
	SceneTransitionLayer.transition_out.connect(self._on_transition_fade_out_started)
	if not GameState._debug: 
		self._clickable_true = false
	else:
		self._clickable_true = true
	$area.input_event.connect(self._on_input)
	self._udpate_sprite_2d_name()
	var myRect = RectangleShape2D.new()
	var sprite2d_node = self.get_node(self._sprite_2d_name)
	myRect.size = Vector2(sprite2d_node.get_rect().size*sprite2d_node.scale)
	self.global_position = sprite2d_node.global_position
	sprite2d_node.position = Vector2(0.0,0.0)
	$area/CollisionShape2D.shape = myRect 

func _on_transition_fade_in_finished():
	print(self.name + ",CLICKABLE TRUE : ", true)
	self._clickable_true = true

func _on_transition_fade_out_started():
	self._clickable_true = false
	print(self.name + ", CLICKABLE TRUE : ", false)

func _udpate_sprite_2d_name():
	self._sprite_2d_name = ""
	for child in self.get_children():
		if child is Sprite2D:
			self._sprite_2d_name = child.name
			child.material = ShaderMaterial.new()
			child.material.shader = load("res://assets/shaders/Outline.gdshader")
			child.material.set_shader_parameter("width",0.0)
			break
	if self._sprite_2d_name == "":
		push_error("must add sprite2D node to clickable object")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_input(_node,event,_idx):
	if is_clickable and _clickable_true :
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if Dialogic.current_timeline == null:
					Radio.emit_signal("clickObject",which)

func _on_area_mouse_entered():
	if self.is_clickable and _clickable_true:
		var node = self.get_node(self._sprite_2d_name)
		node.material.set_shader_parameter("width",self._outline_base_width*1.0/(node.scale[0]))

func _on_area_mouse_exited():
	var node = self.get_node(self._sprite_2d_name)
	node.material.set_shader_parameter("width",0.0)

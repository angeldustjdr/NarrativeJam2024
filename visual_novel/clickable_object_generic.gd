extends Node2D

@export var is_clickable : bool
@export var imageModulate : Color
@export var which : String

var _sprite_2d_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$area.input_event.connect(self._on_input)
	self._udpate_sprite_2d_name()
	var myRect = RectangleShape2D.new()
	var sprite2d_node = self.get_node(self._sprite_2d_name)
	myRect.size = Vector2(sprite2d_node.get_rect().size*sprite2d_node.scale)
	self.global_position = sprite2d_node.global_position
	sprite2d_node.position = Vector2(0.0,0.0)
	$area/CollisionShape2D.shape = myRect 

func _udpate_sprite_2d_name():
	self._sprite_2d_name = ""
	for child in self.get_children():
		if child is Sprite2D:
			self._sprite_2d_name = child.name
			break
	if self._sprite_2d_name == "":
		push_error("must add sprite2D node to clickable object")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_input(_node,event,_idx):
	if is_clickable:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if Dialogic.current_timeline == null:
					Radio.emit_signal("clickObject",which)

func _on_area_mouse_entered():
	if self.is_clickable:
		self.get_node(self._sprite_2d_name).modulate = imageModulate


func _on_area_mouse_exited():
	self.get_node(self._sprite_2d_name).modulate = Color.WHITE

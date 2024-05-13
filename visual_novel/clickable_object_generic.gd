extends Node2D

@export var is_clickable : bool
@export var image : Texture2D
@export var myScale : Vector2
@export var imageModulate : Color
@export var which : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$area.input_event.connect(self._on_input)
	$Sprite2D.texture = image
	$Sprite2D.scale = myScale
	var myRect = RectangleShape2D.new()
	myRect.extents = Vector2($Sprite2D.texture.get_width(),$Sprite2D.texture.get_height())
	$area/CollisionShape2D.shape = myRect 

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
	$Sprite2D.modulate = imageModulate


func _on_area_mouse_exited():
	$Sprite2D.modulate = Color.WHITE

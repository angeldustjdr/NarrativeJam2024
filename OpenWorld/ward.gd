extends Node2D

@export var withRipples = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if withRipples == false : 
		$Waves.visible = false
		$PointBlanc.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setPortable():
	$PointLight2D.scale = Vector2(15,15)

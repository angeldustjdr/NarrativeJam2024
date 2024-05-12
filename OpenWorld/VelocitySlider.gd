extends HSlider

var initial_value

func _ready():
	initial_value = value

func _process(_delta):
	if %Anchor.button_pressed : 
		editable = false
		value = initial_value
	else : editable = true

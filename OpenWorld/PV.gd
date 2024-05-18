extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	GameState.connect("damageTaken",update)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update():
	self.value = GameState.PV
	if value == 0 :
		self.modulate = Color("red")
	else :
		self.modulate = Color("white")

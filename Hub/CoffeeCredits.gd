extends Node2D

func _ready():
	updateCoffe()


func updateCoffe():
	var i = 0 
	for elem in get_children() : 
		if i<GameState.coffeeCredit : 
			elem.visible = true
		else :
			elem.visible = false
		i += 1

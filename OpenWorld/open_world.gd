extends Node2D

var nb_available_wards = 2
var wardbutton = preload("res://OpenWorld/ward_button.tscn")
var ward = preload("res://OpenWorld/ward.tscn")

@onready var objectiveArray = [$Objective,$Objective2,$Objective3,$Objective4,$Objective5]
@onready var iObjective = 0

func _ready():
	Radio.connect("poserWard",poserWard)
	Radio.connect("setObjective",setObjective)
	
	for i in range(nb_available_wards) : 
		var w = wardbutton.instantiate()
		w.setText(i+1)
		%VBoxContainer_Ward.add_child(w)
	setObjective(objectiveArray[iObjective])

func poserWard():
	var w = ward.instantiate()
	w.global_position = $player.global_position
	$Ward.add_child(w)

func setObjective(objective):
	if objective==null:
		iObjective += 1
		if iObjective>len(objectiveArray)-1: $player.objective = objective
		else : $player.objective = objectiveArray[iObjective]
	else : $player.objective = objective

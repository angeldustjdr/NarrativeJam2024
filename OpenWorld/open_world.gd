extends Node2D

var nb_available_wards = 2
var wardbutton = preload("res://OpenWorld/ward_button.tscn")
var ward = preload("res://OpenWorld/ward.tscn")

func _ready():
	Radio.connect("poserWard",poserWard)
	for i in range(nb_available_wards) : 
		var w = wardbutton.instantiate()
		w.setText(i+1)
		%VBoxContainer_Ward.add_child(w)

func _process(_delta):
	# control panel
	$player.speed_factor = %VelocitySlider.value / %VelocitySlider.max_value
	%VelocityLabel.text = "Velocity : " + str(%VelocitySlider.value) + "%"
	$player.rotation_target = %RotationSlider.value-50
	%RotationLabel.text = "Rotation : " + str(%RotationSlider.value-50) + "%"

func poserWard():
	var w = ward.instantiate()
	w.global_position = $player.global_position
	$Ward.add_child(w)

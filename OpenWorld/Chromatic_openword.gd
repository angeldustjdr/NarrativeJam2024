extends Node2D

@onready var chromatic = preload("res://OpenWorld/chromatic.tscn")

func _ready():
	pass
	# faire TOUT PETER ! A mettre au bon moment
	#var chrom = chromatic.instantiate()
	#add_child(chrom)

func _process(delta): #c'est du postprocessing, on ne peut pas l'attacher directement au player --'
	self.global_position = %player.global_position
	self.rotation = %player.rotation

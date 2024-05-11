extends Line2D

var N = 50

func _process(_delta):
	global_position = Vector2.ZERO
	global_rotation = 0.0
	
	add_point(get_parent().global_position)
	if get_point_count()>N : remove_point(0)

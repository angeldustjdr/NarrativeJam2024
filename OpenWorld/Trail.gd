extends Line2D

var N = 50
var trail_threshold = 30

func _process(_delta):
	global_position = Vector2.ZERO
	global_rotation = 0.0
	
	var norm = (get_parent().velocity.x**2 + get_parent().velocity.y**2)**0.5
	if norm > trail_threshold:
		add_point(get_parent().global_position)
		while get_point_count()>N : remove_point(0)
	else :
		points = []

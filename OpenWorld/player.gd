extends CharacterBody2D

var speed = 200
var acceleration = 0.01
var rotation_speed = 0.5
var rotation_target = 0.0
var speed_factor = 0.0

func _physics_process(delta):
	# Movement manager
	var ahead_vector = Vector2(0.0,-1.0).rotated(rotation)
	velocity = velocity.lerp(ahead_vector.normalized() * speed*speed_factor, acceleration)
	rotation_degrees += rotation_target *delta * rotation_speed
	
	var temp_velocity = velocity*0.75
	move_and_slide()
	
	# Bouncy bounce
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		if collision != null:
			velocity = temp_velocity.bounce(collision.get_normal())


func _on_friction_zone_body_entered(body):
	if body==self : 
		speed /= 4

func _on_friction_zone_body_exited(body):
	if body==self : 
		speed *= 4

func _on_accelaration_zone_body_entered(body):
	if body==self : 
		speed *= 4

func _on_accelaration_zone_body_exited(body):
	if body==self : 
		speed /= 4
		velocity /=4

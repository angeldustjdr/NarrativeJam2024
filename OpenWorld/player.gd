extends CharacterBody2D

var speed = 400
var friction = 0.01
var acceleration = 0.02
var rotation_speed = 1.0
var rotation_acc = 0.1

func _physics_process(delta):
	# Movement manager
	var ahead_vector = Vector2(0.0,-1.0).rotated(rotation)
	var direction = Vector2.ZERO
	var rotation_diretion = 0.0
	if Input.is_action_pressed('ui_right'):
		rotation_diretion = 1
	if Input.is_action_pressed('ui_left'):
		rotation_diretion = -1
	if Input.is_action_pressed('ui_down'):
		direction -= ahead_vector
	if Input.is_action_pressed('ui_up'):
		direction += ahead_vector
		
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	if velocity != Vector2.ZERO : 
		rotation += rotation_diretion*rotation_speed*delta
	
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

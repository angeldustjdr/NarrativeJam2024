extends CharacterBody2D

var speed = 400
var friction = 0.01
var acceleration = 0.01
var rotation_speed = 0.5
var rotation_acc = 0.1

func _physics_process(delta):
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
	move_and_slide()

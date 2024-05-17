extends CharacterBody2D

var speed = 300
var friction = 0.01
var acceleration = 0.02
var rotation_speed = 0.5
var rotation_acc = 0.1

var objective = null
var interactable = null

@onready var _rocket_volume = 0.0
@onready var _rocket_volume_incr = 0.01

func _ready():
	pass

func player_connect():
	self._set_rocket_volume()
	self.global_position = GameState.player_position
	Radio.connect("bodyEnteredObjective",bodyEnteredObjective)
	Radio.connect("bodyExitedObjective",bodyExitedObjective)
	Radio.connect("bodyEnteredAccelerationZone",_on_accelaration_zone_body_entered)
	Radio.connect("bodyExitedAccelerationZone",_on_accelaration_zone_body_exited)
	Radio.connect("bodyEnteredDepressionZone",_on_friction_zone_body_entered)
	Radio.connect("bodyExitedDepressionZone",_on_friction_zone_body_exited)

func _set_rocket_volume():
	var prev_volume = $rocket_loop.get_volume()
	$rocket_loop.set_volume(self._rocket_volume)
	if prev_volume <= 0.0 and self._rocket_volume > 0.0:
		$rocket_loop.play()
	elif self._rocket_volume <= 0.0 and prev_volume > 0.0:
		$rocket_loop.stop()
	

func _physics_process(delta):
	self._set_rocket_volume()
	# Movement manager
	var ahead_vector = Vector2(0.0,-1.0).rotated(rotation)
	var direction = Vector2.ZERO
	var rotation_diretion = 0.0
	#if !%Anchor.button_pressed :
	if Input.is_action_pressed('ui_right'):
		rotation_diretion = 1
	if Input.is_action_pressed('ui_left'):
		rotation_diretion = -1
	if Input.is_action_pressed('ui_down'):
		direction -= ahead_vector
		self._rocket_volume = min(1.0,self._rocket_volume + self._rocket_volume_incr)
	if Input.is_action_pressed('ui_up'):
		direction += ahead_vector
	#Rocket volume management
	if Input.is_action_pressed('ui_up') or Input.is_action_pressed('ui_down'):
		self._rocket_volume = min(1.0,self._rocket_volume + self._rocket_volume_incr)
	else:
		self._rocket_volume = max(0.0,self._rocket_volume - self._rocket_volume_incr)
	
	#if %Anchor.button_pressed and (Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_down') or Input.is_action_pressed('ui_up')):
	#	Radio.emit_signal("showAlertMessage","Can't move, Anchor down !")
	
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
		
	var norm = (velocity.x**2 + velocity.y**2)**0.5
	if norm/speed > 0.01 : rotation += rotation_diretion*rotation_speed*delta
		
	var temp_velocity = velocity*0.75
	var collision_before = self.get_slide_collision_count()
	move_and_slide()
	var collision_after = self.get_slide_collision_count()
	if collision_after > 0  and collision_after - collision_before > 0:
		SoundManager.playSoundNamed("bounce")
	
	# Bouncy bounce
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		if collision != null:
			velocity = temp_velocity.bounce(collision.get_normal())
			
	# reticule objectif
	if objective != null :
		$Fleche.visible = true
		var direction_to_obj = objective.position - position
		$Fleche.rotation = ahead_vector.angle_to(direction_to_obj)
	else :
		$Fleche.visible = false


func _on_friction_zone_body_entered(body):
	if body==self : 
		$RainEffect/AnimationPlayer.play("rainAppear")
		Radio.emit_signal("showAlertMessage","Entering Depression zone")
		speed /= 2

func _on_friction_zone_body_exited(body):
	if body==self : 
		$RainEffect/AnimationPlayer.play("rainDisappear")
		speed *= 2

func _on_accelaration_zone_body_entered(body):
	Achievements.genericCheck("Fun slide")
	if body==self : 
		speed *= 4

func _on_accelaration_zone_body_exited(body):
	if body==self : 
		speed /= 4
		velocity /=4

func bodyEnteredObjective(interactableObjective,whoEntered):
	if whoEntered == self:
		#print("WESH : ", whoEntered, "entered ", interactableObjective)
		#print("player : ", whoEntered.position, " global ", whoEntered.global_position)
		#print("cshape : ", whoEntered.get_node("CollisionShape2D").position, " global ", whoEntered.get_node("CollisionShape2D").global_position)
		interactable = interactableObjective
		$Message.visible = true

func bodyExitedObjective(_interactableObjective,whoEntered):
	#print("WESH : ", whoEntered, " exited ", interactableObjective)
	#print("player : ", whoEntered.position, " global ", whoEntered.global_position)
	#print("cshape : ", whoEntered.get_node("CollisionShape2D").position, " global ", whoEntered.get_node("CollisionShape2D").global_position)
	if whoEntered == self:
		interactable = null
		$Message.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("Interact") :
		if interactable !=null :
			Radio.emit_signal("interaction",interactable)

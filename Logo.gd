extends Control

var _next_packed_scene = preload("res://main.tscn")
var nombre_de_coup_de_casserole = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransitionLayer.reveal_scene()
	Radio.click_enabled = false
	await get_tree().create_timer(SceneTransitionLayer.get_duration("fade_in")).timeout 
	for i in range(0,nombre_de_coup_de_casserole):
		$Sprite2D/AnimationPlayer.play("ping")
		await get_tree().create_timer(0.1).timeout 
		SoundManager.playSoundNamed("casserole_one_hit")
		await $Sprite2D/AnimationPlayer.animation_finished
	await get_tree().create_timer(0.2).timeout
	SceneTransitionLayer.transition_to_packed_scene(self._next_packed_scene)

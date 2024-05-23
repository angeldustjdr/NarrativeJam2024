extends PointLight2D

signal shining
var _tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	self._tween = self.create_tween().set_loops()
	self._tween.tween_property(self,"texture_scale",7,1.0).set_trans(Tween.TRANS_SINE)
	self._tween.tween_property(self,"texture_scale",6,1.0).set_trans(Tween.TRANS_SINE)
	pass # Replace with function body.

func play_growth():
	self._tween.kill()
	self._tween = self.create_tween()
	self._tween.tween_property(self,"texture_scale",50,0.1)
	self._tween.tween_callback(self.emit_shining)
	self._tween.tween_property(self,"texture_scale",800,2.0)
	self._tween.tween_callback(self._tween.kill)

func emit_shining():
	shining.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

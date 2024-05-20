extends Node
class_name Chrono
# un petit chrono pour mesurer le temps passer dans les missions

@onready var _current_time = 0.0
@onready var _stopped = true
@onready var _paused = true

func stop():
	self._stopped = true

func stop_and_get_current_time(): # stop the and returns current_time
	self.stop()
	return self._current_time

func start(): # reset current time and start the chrono
	if self._stopped:
		self._current_time = 0.0
		self._stopped = false
	else:
		push_warning("trying to stop an already stopped chrono")

func increment(value):
	self._current_time += value
	
func decrement(value):
	self.increment(-value)

func pause():
	if not self._stopped:
		if self._paused == false:
			self._paused = true
	
func unpause():
	if self._paused == true:
		self._paused = false
	else:
		push_warning("trying to pause an already paused chrono")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not self._stopped and not self._paused:
		self._current_time += delta

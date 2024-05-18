extends VBoxContainer

signal coffee_credit_update

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func display():
	self.visible = true
	if GameState.coffeeCredit > 0 :
		$TalkToShipgirl.visible =true
		$TalkToNavigator1.visible =true
		$TalkToNavigator2.visible =true
		$TalkToCaptain.visible =true
		$Leave.visible =true
		$Label.visible =false
	else :
		$TalkToShipgirl.visible =false
		$TalkToNavigator1.visible =false
		$TalkToNavigator2.visible =false
		$TalkToCaptain.visible =false
		$Leave.visible =true
		$Label.visible =true

func _on_leave_pressed():
	self.visible = false
	coffee_credit_update.emit(false)

func _on_talk_to_shipgirl_pressed():
	self.talk_to_character(GameState.SHIPGIRL)

func _on_talk_to_navigator_1_pressed():
	self.talk_to_character(GameState.NAVIGATOR2)


func _on_talk_to_navigator_2_pressed():
	self.talk_to_character(GameState.NAVIGATOR2)


func _on_talk_to_captain_pressed():
	self.talk_to_character(GameState.CAPTAIN)

func talk_to_character(character):
	self.visible = false
	if Dialogic.current_timeline == null :
		GameState.nbInteractions[character] += 1
		Achievements.checkInteraction(character)
		Dialogic.start(GameState.get_current_timeline(character))
		self._decrease_coffee_credit()

func _decrease_coffee_credit():
	if GameState.coffeeCredit > 0 :
		GameState.nbCoffee += 1
		GameState.coffeeCredit = max(0,GameState.coffeeCredit-1)
		Achievements.checkCoffee(GameState.nbCoffee)
	coffee_credit_update.emit(true)

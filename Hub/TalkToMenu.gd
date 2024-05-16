extends VBoxContainer


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

func _on_talk_to_shipgirl_pressed():
	self.visible = false
	if Dialogic.current_timeline == null :
		GameState.nbInteractions["Shipgirl"] += 1
		Achievements.checkInteraction("Shipgirl")
		Dialogic.start("Test_timeline")


func _on_talk_to_navigator_1_pressed():
	self.visible = false
	if Dialogic.current_timeline == null :
		GameState.nbInteractions["Navigator1"] += 1
		Achievements.checkInteraction("Navigator1")
		#Dialogic.start("Test_timeline")


func _on_talk_to_navigator_2_pressed():
	self.visible = false
	if Dialogic.current_timeline == null :
		GameState.nbInteractions["Navigator2"] += 1
		Achievements.checkInteraction("Navigator2")
		#Dialogic.start("Test_timeline")


func _on_talk_to_captain_pressed():
	self.visible = false
	if Dialogic.current_timeline == null :
		GameState.nbInteractions["Captain"] += 1
		Achievements.checkInteraction("Captain")
		#Dialogic.start("Test_timeline")

extends Node

var AchievementsList = []
var AchievementDescription = {
	"Morning routine" : ["Drink 5 coffees",false],
	#"Heavy lifting" : ["Lift the anchor for the first time",false],
	"Fun slide" : ["Take the accelerator for the first time",false],
	"Idol of youth" : ["Talk to the shipgirl 6 times",false],
	"Good soldier" : ["Talk to the captain 6 times",false],
	"Old friend" : ["Talk to your navigator 4 times",false],
	"New friend" : ["Talk to your new navigator 3 times",false],
	"Hi everyone !" : ["Talk to all characters once",false],
}

signal unlock

func _ready():
	AchievementsList = AchievementDescription.keys()

func checkCoffee(howMuch):
	if howMuch>=5 :
		genericCheck("Morning routine")

func genericCheck(title):
	if AchievementDescription[title][1]==false : 
		AchievementDescription[title][1] =  true
		emit_signal("unlock",title)

func checkInteraction(who):
	var nbInteractionNeeded = {
		"Shipgirl":6,
		"Navigator1":4,
		"Navigator2":3,
		"Captain":6
	}
	var interactionAchievementTitles = {
		"Shipgirl":"Idol of youth",
		"Navigator1":"Old friend",
		"Navigator2":"New friend",
		"Captain":"Good soldier"
	}
	if GameState.nbInteractions[who]>=nbInteractionNeeded[who]:
		genericCheck(interactionAchievementTitles[who])
	
	if GameState.nbInteractions["Shipgirl"]>=1 and GameState.nbInteractions["Navigator1"]>=1 and GameState.nbInteractions["Navigator2"]>=1 and GameState.nbInteractions["Captain"]>=1:
		genericCheck("Hi everyone !")

extends Node

var AchievementsList = []
var AchievementDescription = {
	"Morning routine" : ["Drink 5 coffees",false,"Need more cafein?"],
	#"Heavy lifting" : ["Lift the anchor for the first time",false],
	"Fun slide" : ["Take the accelerator for the first time",false,"What's the limit speed again?"],
	"Idol of youth" : ["Talk to the shipgirl 6 times",false,"Create bonds with a younger person."],
	"Good soldier" : ["Talk to the captain 6 times",false,"Create bonds with an officier."],
	"Old friend" : ["Talk to your navigator 4 times",false,"Create bonds with someone you know for a long time."],
	"New friend" : ["Talk to your new navigator 3 times",false,"Create bonds with someone new."],
	"Hi everyone !" : ["Talk to all characters once",false,"Be sociable in your workplace."],
	"True pioneer" : ["Drop 5 wards",false,"Enlighten your way when exploring."],
	"Safe return" : ["Finish a mission before the Ethertimer ends",false,"Don't risk your life on the Ethersea."],
	"Better late than sorry" : ["Finish a mission with no time left on the Ethertimer",false,"Take your time... or not."]
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

func checkWard():
	if GameState.nbWard >= 5 :
		genericCheck("True pioneer")

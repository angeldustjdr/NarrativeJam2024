extends Node

var AchievementsList = []
var AchievementDescription = {
	"Morning routine" : ["Drink 5 coffees",false]
}

signal unlock

func _ready():
	AchievementsList = AchievementDescription.keys()

func checkCoffee(howMuch):
	if howMuch>=5 and AchievementDescription["Morning routine"][1]==false : 
		AchievementDescription["Morning routine"][1]=true
		emit_signal("unlock","Morning routine")

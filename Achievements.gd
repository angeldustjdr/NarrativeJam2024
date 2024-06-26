extends Node

var AchievementsList = []
var AchievementDescription = {
	"Good listener" : ["Listen to the motivational speech until the end",false,"Isn't the Captain a good orator?"],
	"Morning routine" : ["Drink 5 coffees",false,"Need more cafein?"],
	#"Heavy lifting" : ["Lift the anchor for the first time",false],
	"Fun slide" : ["Take the accelerator for the first time",false,"What's the speed limit again?"],
	"Idol of youth" : ["Talk to the Shipgirl 6 times",false,"Create bonds with a younger person."],
	"Good soldier" : ["Talk to the Captain 6 times",false,"Create bonds with an officier."],
	"Old friend" : ["Talk to your navigator 4 times",false,"Create bonds with someone who can be trusted."],
	#"New friend" : ["Talk to your new navigator 3 times",false,"Create bonds with someone new."],
	"Hi everyone !" : ["Talk to all characters once",false,"Be sociable in your workplace."],
	"True pioneer" : ["Drop 5 wards",false,"Enlighten your way when exploring."],
	"Safe return" : ["Finish a mission before the timer ends",false,"Don't risk your life on the Cognisea."],
	"Better late than sorry" : ["Finish a mission with no time left on the timer",false,"Take your time... or not."],
	#"True pilot" : ["Finish a mission without damaging the ship",false,"Take care of your ship. Repairs are expensive!"],
	#"Sabotage" : ["Finish a mission with fully damaged ship",false,"Take care of your ship. Repairs are expensive (bis)!"],
	"Instrumentation master" : ["Get over 99% beacon compatibility",false,"Sometimes 90% isn't enough."],
	#ENDING ACHIEVEMENTS
	"Maybe next month" : ["Don't meet the rebellion and complete less than 3 mission in time",false,"???"],
	"Employee of the month" : ["Don't meet the rebellion and complete at least 3 missions in time",false,"???"],
	#"Cosmic denial" : ["Refuse to join the rebellion",false,"???"],
	"You're fired!" : ["Get fired after joining the rebellion",false,"???"],
	"Rage against the machine" : ["Join the rebellion",false,"???"]
}

signal unlock

var _updated_descr = false

func _ready():
	AchievementsList = AchievementDescription.keys()
	self.load_achievements()

func get_status_of_achievement(ach_name):
	return self.AchievementDescription[ach_name][1]

func update_character_names():
	if not self._updated_descr:
		self._updated_descr = true
		self.AchievementDescription["Idol of youth"][0] = "Talk to " + Dialogic.VAR.shipgirl_name + " 5 times"
		self.AchievementDescription["Good soldier"][0] = "Talk to " + Dialogic.VAR.captain_name + " 5 times"
		self.AchievementDescription["Old friend"][0] = "Talk to " + Dialogic.VAR.navigator1_code + " 4 times"
		#self.AchievementDescription["New friend"][0] = "Talk to " + Dialogic.VAR.navigator2_name + " 2 times"

################################################################################
#ACHIEVEMENTS ##################################################################
################################################################################

func save_achievements():
	var achievement_file = FileAccess.open("user://achievements.save",FileAccess.WRITE)
	achievement_file.store_var(GameState.nbCoffee)
	achievement_file.store_var(GameState.nbInteractions)
	achievement_file.store_var(GameState.nbWard)
	achievement_file.store_var(GameState.nbRetourHub)
	achievement_file.store_var(GameState._title_screen_state)
	achievement_file.store_var(self.AchievementDescription)
	
func load_achievements():
	var file_name = "user://achievements.save"
	if FileAccess.file_exists(file_name):
		var achievement_file = FileAccess.open(file_name, FileAccess.READ)
		GameState.nbCoffee = achievement_file.get_var()
		GameState.nbInteractions = achievement_file.get_var()
		GameState.nbWard = achievement_file.get_var()
		GameState.nbRetourHub = achievement_file.get_var()
		GameState._title_screen_state = achievement_file.get_var()
		self.AchievementDescription = achievement_file.get_var()

func checkCoffee(howMuch):
	if howMuch>=5 :
		genericCheck("Morning routine")

func genericCheck(title):
	if title in AchievementsList :
		if AchievementDescription[title][1]==false : 
			AchievementDescription[title][1] =  true
			emit_signal("unlock",title)
		self.save_achievements()

func checkInteraction(who):
	self.save_achievements()
	var nbInteractionNeeded = {
		GameState.SHIPGIRL:5,
		GameState.NAVIGATOR1:4,
		GameState.NAVIGATOR2:2,
		GameState.CAPTAIN:5
	}
	var interactionAchievementTitles = {
		GameState.SHIPGIRL:"Idol of youth",
		GameState.NAVIGATOR1:"Old friend",
		GameState.NAVIGATOR2:"New friend",
		GameState.CAPTAIN:"Good soldier"
	}
	if GameState.nbInteractions[who]>=nbInteractionNeeded[who]:
		genericCheck(interactionAchievementTitles[who])
	
	if (GameState.nbInteractions[GameState.SHIPGIRL]>=1 
	and GameState.nbInteractions[GameState.NAVIGATOR1]>=1 
	and GameState.nbInteractions[GameState.NAVIGATOR2]>=1 
	and GameState.nbInteractions[GameState.CAPTAIN]>=1):
		genericCheck("Hi everyone !")

func checkWard():
	self.save_achievements()
	if GameState.nbWard >= 5 :
		genericCheck("True pioneer")

extends VBoxContainer

var availableCharacters = ["Shipgirl"] # doit dépendre de la mission. A modifier
var talkbutton = preload("res://Hub/talk_to.tscn")

func _ready():
	for character in availableCharacters : addCharacter(character)

func addCharacter(who):
	var b = talkbutton.instantiate()
	b.talk_to = who
	b.text = "Talk to "+who
	add_child(b)
	

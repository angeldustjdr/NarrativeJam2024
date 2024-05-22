extends Node2D

var messageToughts = {
	GameState.thoughts.DEPRIME : [
	"It's pouring rain. It's so depressing.",
	"Sigh... I'll have to cancel my plans.",
	"Why is life so difficult?",
	"Sometimes you just can't fit in.",
	"Can't get up from bed today.",
	"My socks are wet. Sigh...",
	"Work. Sleep. Do it again. Why even bother?",
	"Everything feels so pointless.",
	"Nobody would notice if I disappeared.",
	"I'm a burden to everyone around me.",
	"Nobody understands what I'm going through.",
	"I hate looking in the mirror and not recognizing myself."
	],
	GameState.thoughts.COLERE : [
	"Wow, I almost got killed in this terrorist attack.",
	"It's all because of MindSail. Their greed is unlimited.",
	"I'm pissed too, but a terrorist attack... that's maybe too much.",
	"A good news at last! They deserved it!",
	"One attack is not enough. We need to kill them all!",
	"This will never be enough to take MindSail down!",
	"A first step towards the end of the system.",
	"I had assets in this company! I need to sell them fast.",
	"Who's going to pay for the repairs? Hopefully not the tax payers!",
	"I knew that this company was shady.",
	"I'm so pissed right now!",
	"I want to join the hacktivists too! Where can I contact them?"
	],
	GameState.thoughts.PEUR : [
	"I might not be good enough for this.",
	"What if she doesn't like me?",
	"It seems inevitable. I always mess things up.",
	"Why are they laughing? Is it me?",
	"What if they aren't happy with my work?",
	"Will they approve my choices?",
	"They are all better than me. Why?",
	"Shit, I won't make it in time!",
	"My heartbeat is so high right now! WTF was that?!?",
	"I made it home without this creepy dude assaulting me...\nHoly shit what was wrong with him?",
	"Why are there so many cops? It's just a pacific protest.",
	"They haven't come home yet. Should I call the cops?"
	]
}

var deltaT : float = 4.0
var desiredText : Array

var player = get_parent()

func activateThoughts(which):
	desiredText = messageToughts[which]
	$Timer.wait_time = randf_range(2.0,deltaT)
	$Timer.start()

func desactivateThoughts():
	$Timer.stop()

func _on_timer_timeout():
	Radio.emit_signal("sendThoughts",desiredText.pick_random())


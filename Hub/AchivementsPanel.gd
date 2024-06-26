extends Control

var myFont = preload("res://Forum-Regular.ttf")

func _ready():
	updatePanel()
	

func updatePanel():
	for elem in %AchivementsItems.get_children() : elem.queue_free()
	var nb_ach = 0
	
	for item in Achievements.AchievementsList:
		var c = CheckBox.new()
		c.text = item
		c.add_theme_font_override("font",myFont)
		c.add_theme_font_size_override("font_size",36)
		if Achievements.AchievementDescription[item][1] == true : 
			c.text += " --- " + Achievements.AchievementDescription[item][0]
			c.button_pressed = true
			nb_ach += 1
		else :
			c.text += " --- " + Achievements.AchievementDescription[item][2]
		c.disabled = true
		%AchivementsItems.add_child(c)
	
	%AchivementTitle.text = "Achievements - " + str(nb_ach) + "/" + str(len(Achievements.AchievementsList))

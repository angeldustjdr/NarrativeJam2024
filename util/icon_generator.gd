extends SubViewportContainer

@export var num_ilot : int = 0
@export var corrupted : bool = false

var ilot_scenes_path = ["res://visual_novel/ilot_1.tscn",
						"res://visual_novel/ilot_2.tscn",
						"res://visual_novel/ilot_3.tscn",
						"res://visual_novel/ilot_4.tscn",
						"res://visual_novel/ilot_5.tscn"]
func _ready():
	var oscillo_scene = GameState.oscillo_packed_scene.instantiate()
	var ilot_scene = load(ilot_scenes_path[num_ilot]).instantiate()
	var icon_name = "oscillo_icon_"+str(num_ilot+1)
	if corrupted:
		icon_name += "_corrupted"
		oscillo_scene.set_signal_color(ilot_scene.ilot_color_corrupted)
	else:
		oscillo_scene.set_signal_color(ilot_scene.ilot_color)
	oscillo_scene.set_difficulty(ilot_scene.difficulty)
	oscillo_scene.target_signal_properties = ilot_scene.target_signal_prop
	oscillo_scene.scale = Vector2(1.0,1.0)
	self.generate_icon(oscillo_scene,icon_name)

func _generate_icon(icon_name):
	await RenderingServer.frame_post_draw
	var img = $IconGeneratorVP.get_texture().get_image()
	img.save_png("res://assets/graphics/items/"+icon_name+".png")

func generate_icon(node,icon_name):
	$IconGeneratorVP.add_child(node)
	self.size = node.size*node.scale
	$IconGeneratorVP.size = node.size*node.scale
	self._generate_icon(icon_name)

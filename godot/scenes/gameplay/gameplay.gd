extends Node

@export var kelp_scene: PackedScene
@export var kelp_textures: Array[Texture2D] 
@export var fish_scene: PackedScene
@export var fish_textures: Array[Texture2D]

@onready var scoreLabel = $Score

var t = 0
var active_kelp: Array[Node2D] = []
const max_kelp = 10
var active_fish: Array = []
var score = 0;
var currentMult = 1.0

func _ready() -> void:
	var scene_data = GGT.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)


	if GGT.is_changing_scene(): # this will be false if starting the scene with "Run current scene" or F6 shortcut
		await GGT.scene_transition_finished

	print("GGT/Gameplay: scene transition animation finished")
	spawn_kelp()
	

func _process(delta):
	
	update_score_label()

func spawn_kelp():
	var new_kelp = kelp_scene.instantiate()

	# Set Texture & Generate Collision
	var tex = kelp_textures.pick_random()
	if new_kelp.has_method("set_kelp_texture"):
		new_kelp.set_kelp_texture(tex)
	
	# Calculate screen dimensions
	var screen_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	
	# Set the "grown" height
	new_kelp.target_y = screen_size.y - randf_range(20, 80)
	
	# Set the initial spawn position (Screen bottom + offset)
	var spawn_x = randf_range(screen_size.x * 0.66, screen_size.x - tex.get_width())
	var spawn_y = screen_size.y + 100 # Start 100px off-screen
	new_kelp.global_position = Vector2(spawn_x, spawn_y)
	
	$KelpContainer.add_child(new_kelp)
	
	new_kelp.harvested.connect(add_food)
	active_kelp.append(new_kelp)

func spawn_fish():
	var new_fish = fish_scene.instantiate()
	
	if new_fish.has_method("set_fish_texture") and !fish_textures.is_empty():
		new_fish.set_fish_texture(fish_textures.pick_random())
	
	
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_x = randf_range(50, screen_size.x * 0.4)
	var spawn_y = randf_range(100, screen_size.y - 100)
	new_fish.position = Vector2(spawn_x, spawn_y)
	
	
	active_fish.append(new_fish)
	$FishContainer.add_child(new_fish)
	print("Spawned fish at: ", new_fish.position)

# This is called by the fish when it eats kelp
func request_new_kelp():
	# Wait a tiny bit so the old kelp can finish queue_free()
	get_tree().create_timer(1.5).timeout.connect(spawn_kelp)

func add_food(baseVal):
	score += baseVal * currentMult

func update_score_label():
	scoreLabel.text = "Score: " + str(score)



func _on_grow_button_button_down() -> void:
	spawn_kelp()


func _on_spawn_button_button_down() -> void:
	spawn_fish()

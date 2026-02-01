extends Node

@export var kelp_scene: PackedScene
@export var kelp_textures: Array[Texture2D] 

@onready var sprite_2d: Sprite2D = $Sprite2D

var t = 0
var active_kelp: Array[Node2D] = []

var score = 0;
var currentMult = 1.0

func _ready() -> void:
	var scene_data = GGT.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)

	sprite_2d.position = get_viewport().get_visible_rect().size / 2

	if GGT.is_changing_scene(): # this will be false if starting the scene with "Run current scene" or F6 shortcut
		await GGT.scene_transition_finished

	print("GGT/Gameplay: scene transition animation finished")
	spawn_kelp()
	

func _process(delta):
	var size = get_viewport().get_visible_rect().size
	t += delta * 1.5
	sprite_2d.position.x = size.x / 2.0 + 200.0 * sin(t * 0.8)
	sprite_2d.position.y = size.y / 2.0 + 140.0 * sin(t)
	


func spawn_kelp():
	var new_kelp = kelp_scene.instantiate()

	# Set Texture & Generate Collision
	if new_kelp.has_method("set_kelp_texture"):
		new_kelp.set_kelp_texture(kelp_textures.pick_random())
	
	# Calculate screen dimensions
	var screen_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	
	# Set the "grown" height
	new_kelp.target_y = screen_size.y - randf_range(20, 80)
	
	# Set the initial spawn position (Screen bottom + offset)
	var spawn_x = randf_range(screen_size.x * 0.66, screen_size.x)
	var spawn_y = screen_size.y + 100 # Start 100px off-screen
	new_kelp.global_position = Vector2(spawn_x, spawn_y)
	
	# 2. FINALLY ADD TO TREE
	# Now that position/target/texture are all set, it will start growth smoothly
	$KelpContainer.add_child(new_kelp)
	
	# 3. CONNECT SIGNALS
	new_kelp.harvested.connect(add_food)
	active_kelp.append(new_kelp)
	
func add_food(baseVal):
	score += baseVal * currentMult
	

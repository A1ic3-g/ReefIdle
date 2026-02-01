extends Node2D

@onready var sprite = find_child("Sprite2D") 
@onready var collision_poly = $Area2D/CollisionPolygon2D
signal harvested(amount)
var grow_speed = 500
var sway_speed = 1.5
var sway_amplitude = 0.1 # Radians
var target_y = 0.0

var time_offset = 0.0

func _ready():
	# Randomize sway slightly so they don't all move in perfect unison
	time_offset = randf() * TAU
	sway_speed += randf_range(-0.2, 0.2)
	
	# Start below the screen
	# We assume 'target_y' will be passed by the spawner
	global_position.y += 300
	print("Spawned Kelp")
	print(global_position.y)
	print(target_y)

func _process(delta):
	# 1. Growth Logic (Move Upwards)
	# Move towards target_y without overshooting
	if global_position.y > target_y:
		global_position.y = max(target_y, global_position.y - grow_speed * delta)
	
	# 2. Sway Logic (Sin wave rotation)
	var sway = sin(Time.get_ticks_msec() * 0.001 * sway_speed + time_offset)
	rotation = sway * sway_amplitude

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	# Only trigger if it's a left-click press
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		harvest()
		print("clicked")

func harvest():
	# Emit signal to Gameplay.gd
	harvested.emit(200)
	# Destroy this kelp
	queue_free()

func set_kelp_texture(tex: Texture2D):
	var sprite_node = get_node("Sprite2D")
	var poly_node = get_node("Area2D/CollisionPolygon2D")
	
	sprite_node.texture = tex
	
	# 1. Get the image data
	var img = tex.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(img)
	
	# 2. Convert to polygons
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, tex.get_size()), 2.0) # 2.0 simplifies the shape for performance
	
	if polygons.size() > 0:
		# We set the polygon points
		poly_node.set_deferred("polygon", polygons[0])
		
		# 3. ALIGNMENT: 
		# If the sprite is NOT centered, poly_node.position = sprite_node.offset is correct.
		# If the sprite IS centered, poly_node.position = Vector2.ZERO should be used.
		if not sprite_node.centered:
			poly_node.position = sprite_node.offset
		else:
			poly_node.position = Vector2.ZERO
			
		print("Polygon assigned and offset to: ", poly_node.position)

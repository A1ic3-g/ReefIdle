extends Area2D

@onready var sprite = $Sprite2D

var speed = 120.0
var current_velocity = Vector2.ZERO
var move_timer = 0.0
var screen_size = Vector2.ZERO

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	pick_new_direction()

func _process(delta):
	# 1. Movement
	position += current_velocity * delta
	
	# 2. Mirror Flip logic
	# If moving left (negative X), flip_h is true. 
	# If moving right (positive X), flip_h is false.
	if current_velocity.x != 0:
		sprite.flip_h = current_velocity.x < 0
	
	# 3. Jiggle about the center
	sprite.position.y = sin(Time.get_ticks_msec() * 0.008) * 3.0
	
	# 4. Change direction based on time or boundaries
	move_timer -= delta
	if move_timer <= 0 or is_out_of_bounds():
		pick_new_direction()

func is_out_of_bounds() -> bool:
	# Keep fish in the left half as requested (0 to screen_size.x * 0.5)
	return position.x < 20 or position.x > (screen_size.x * 0.5) - 20 or \
		   position.y < 20 or position.y > screen_size.y - 20
func set_fish_texture(tex: Texture2D):
	var sprite_node = get_node("Sprite2D")
	var poly_node = get_node_or_null("CollisionPolygon2D")
	
	sprite_node.texture = tex
	
	if poly_node:
		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(tex.get_image())
		var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, tex.get_size()))
		
		if polygons.size() > 0:
			poly_node.set_deferred("polygon", polygons[0])
	
			poly_node.position = -tex.get_size() / 2.0
func pick_new_direction():
	var random_angle = randf() * TAU
	current_velocity = Vector2.RIGHT.rotated(random_angle) * speed
	move_timer = randf_range(1.5, 4.0)
	
func _on_area_entered(area):
	# Look for kelp (assuming kelp is the parent of the Area2D hit-box)
	var kelp = area.get_parent()
	
	if kelp.has_method("harvest"):
		kelp.harvest()
		
		current_velocity = -current_velocity
		
		move_timer = 1.0 
		
		get_tree().call_group("gameplay", "request_new_kelp")

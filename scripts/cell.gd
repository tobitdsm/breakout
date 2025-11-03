extends Sprite2D

var contaminated = false

var rot = randf() * 360

const scared_distance = 50.0
const speed = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	rot += (randf() - 0.5) * 0.5

	if position.x < scared_distance:
		rot = lerp_angle(rot, 0, 0.1)
	elif position.x > viewport_size.x - scared_distance:
		rot = lerp_angle(rot, PI, 0.1)

	if position.y < scared_distance:
		rot = lerp_angle(rot, PI/2, 0.1)
	elif position.y > viewport_size.y - scared_distance:
		rot = lerp_angle(rot, -PI/2, 0.1)

	position += Vector2(cos(rot), sin(rot)) * speed * delta

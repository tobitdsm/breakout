extends Sprite2D

var contaminated = false

const healed_cooldown = 5
var healed = 0

const sick_cooldown = 20
var sick = 0

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
	
	var areas = self.get_child(0).get_overlapping_areas()
	for area in areas:
		if area.is_in_group("cell"):
			if self.contaminated and not area.get_parent().contaminated and area.get_parent().healed <= 0:
				area.get_parent().modulate = self.modulate
				area.get_parent().contaminated = true
				area.get_parent().sick = sick_cooldown
				get_parent().contaminated += 1
			elif not self.contaminated and healed > 0 and area.get_parent().contaminated:
				area.get_parent().modulate = Color(1,1,1)
				area.get_parent().contaminated = false
				area.get_parent().healed = healed_cooldown
				area.get_parent().sick = 0
				get_parent().contaminated -= 1
	
	if healed > 0:
		healed -= delta
		self.get_child(1).scale.x = healed * 100
	
	if sick > 0:
		sick -= delta
		self.get_child(1).scale.x = sick * 25
	elif contaminated:
		contaminated = false
		self.modulate = Color(1,1,1)
		self.get_parent().contaminated -= 1
	self.get_child(1).modulate = self.modulate

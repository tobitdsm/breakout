extends Sprite2D

var contaminated = false

var time = 0

var color = Color(1,1,1)

const healed_cooldown = 5
var healed = 0

const sick_cooldown = 15
var sick = 0

var rot = randf() * 360

const scared_distance = 50.0
const speed = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var base_color = Color(1.5,1.5,1.5)
	var left = 0
	if contaminated:
		left = ((sick_cooldown - sick) * 1.) / sick_cooldown
		base_color = color + Color(.25,.25,.25)
	elif healed > 0:
		left = ((healed_cooldown - healed) * 1.) / healed_cooldown
		base_color = color + Color(.25,.25,.25)
	var r = base_color.r + (-2 if contaminated else 1) * (1.5 - base_color.r) * (left)
	var g = base_color.g + (-2 if contaminated else 1) * (1.5 - base_color.g) * (left)
	var b = base_color.b + (-2 if contaminated else 1) * (1.5 - base_color.b) * (left)
	self.modulate = Color(r,g,b)
	
	var viewport_size = get_viewport_rect().size
	rot += (randf() - 0.5) * 0.5

	var at_left   = position.x < scared_distance
	var at_right  = position.x > viewport_size.x - scared_distance
	var at_top    = position.y < scared_distance
	var at_bottom = position.y > viewport_size.y - scared_distance

	if (at_left or at_right) and (at_top or at_bottom):
		# Corner case
		var corner_dir = Vector2(
			1 if at_left else -1,
			1 if at_top else -1
		).normalized()
		rot = lerp_angle(rot, corner_dir.angle(), 0.2)
	else:
		if at_left:
			rot = lerp_angle(rot, 0, 0.1)
		elif at_right:
			rot = lerp_angle(rot, PI, 0.1)

		if at_top:
			rot = lerp_angle(rot, PI/2, 0.1)
		elif at_bottom:
			rot = lerp_angle(rot, -PI/2, 0.1)

	position += Vector2(cos(rot), sin(rot)) * speed * delta
	
	var areas = self.get_child(0).get_overlapping_areas()
	for area in areas:
		if area.is_in_group("cell"):
			if self.contaminated and not area.get_parent().contaminated and area.get_parent().healed <= 0:
				area.get_parent().color = color
				area.get_parent().contaminated = true
				area.get_parent().sick = sick_cooldown
				get_parent().contaminated += 1
			elif not self.contaminated and healed > 0 and area.get_parent().contaminated:
				area.get_parent().color = color
				area.get_parent().contaminated = false
				area.get_parent().healed = healed_cooldown
				area.get_parent().sick = 0
				get_parent().contaminated -= 1
	
	if healed > 0:
		healed -= delta
	elif not contaminated and color != Color(1,1,1):
		color = Color(1,1,1)
	
	if sick > 0:
		sick -= delta
	elif contaminated:
		self.get_parent().contaminated -= 1
		self.get_parent().cells -= 1
		self.queue_free()

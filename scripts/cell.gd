extends RigidBody2D

var contaminated = false

var time = 0

var color = Color(1,1,1)

const healed_cooldown = 5
var healed = 0

const sick_cooldown = 15
var sick = 0

var rot = randf() * 360

const scared_distance = 50.0
const speed = .75

var colliding = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5



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
	
	rot += (randf() - 0.5) * 0.5
	linear_velocity = Vector2(cos(rot), sin(rot)) * speed
	var collision = move_and_collide(linear_velocity)
	if collision:
		rot = 2 * collision.get_normal().angle() - rot + 180
	
	
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
	
	if is_colliding():
		get_parent().max_cells -= 1
		get_parent().cells -= 1
		if contaminated:
			get_parent().contaminated -= 1
		self.queue_free()

func is_colliding() -> bool:
	var tml: TileMapLayer = get_parent().get_child(0)
	var cell := tml.local_to_map(position)
	var tiledata: TileData = tml.get_cell_tile_data(cell)
	if tiledata:
		return tiledata.terrain == 1
	else:
		return true

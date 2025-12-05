extends Node2D

const end_map = preload("res://scenes/empty_map.tscn")

const maps = [
	preload("res://scenes/maps/clash_royale.tscn"),
	preload("res://scenes/maps/flappy_bird.tscn"),
	preload("res://scenes/maps/pacman.tscn"),
	preload("res://scenes/maps/the_skeld.tscn")
]

const virus = preload("res://scenes/virus.tscn")
const wbc = preload("res://scenes/whitebloodcell.tscn")
const cell = preload("res://scenes/cell.tscn")

var contaminated = 0
const init_cells = 500
var max_cells = init_cells
var cells = max_cells
var vi = -1

var points = 0

var roundtime = 90
var scores = [
	0, # red
	0, # green
	0, # blue
	0  # yellow
]
const rounds = 8
var curr_round = 0

var init_children = 0

var text_cooldown = 0

var end_cooldown = 0

var red = false
var green = false
var blue = false
var yellow = false

var started = false
var ended = false

const keys = [
	[
		Key.KEY_W,
		Key.KEY_A,
		Key.KEY_S,
		Key.KEY_D,
		Key.KEY_SPACE
	], [
		Key.KEY_T,
		Key.KEY_F,
		Key.KEY_G,
		Key.KEY_H,
		Key.KEY_V
	], [
		Key.KEY_I,
		Key.KEY_J,
		Key.KEY_K,
		Key.KEY_L,
		Key.KEY_M
	], [
		Key.KEY_KP_8,
		Key.KEY_KP_4,
		Key.KEY_KP_5,
		Key.KEY_KP_6,
		Key.KEY_KP_0
	]
]

const colors = [
	Color("red"),
	Color("green"),
	Color("blue"),
	Color("yellow")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(f(0,0) == -1)
	assert(f(0,1) == -1.5)
	assert(f(1,0) == 1)
	assert(f(1,1) == 1.5)
	assert(f(0.5,0.5) == 0)
	assert(f(0.25,0.5) < 0)
	assert(f(0.75,0.5) > 0)
	%virus_score.visible = false
	%red_score.visible = false
	%green_score.visible = false
	%blue_score.visible = false
	%yellow_score.visible = false
	%time.visible = false
	init_children = get_child_count() - 1
	cells = 0

func init() -> int:
	%virus_score.visible = true
	%red_score.visible = true
	%green_score.visible = true
	%blue_score.visible = true
	%yellow_score.visible = true
	%time.visible = true
	
	for i in get_child_count():
		if i >= init_children:
			get_child(i).queue_free()
	
	get_child(0).queue_free()
	
	curr_round += 1
	if curr_round > rounds:
		return -1
	
	var ind = randi_range(0, len(maps) - 1)
	var map = maps[ind]
	map = map.instantiate()
	add_child(map)
	move_child(map,0)
	
	max_cells = make_cells(init_cells)
	cells = max_cells
	contaminated = 0
	
	vi += 1
	vi %= 4
	for i in 4:
		var c = wbc.instantiate()
		if i == vi:
			c = virus.instantiate()
			%virus_score.modulate = colors[vi]
		add_child(c)
		c.init(i)
		var valid = false
		var pos
		while not valid:
			pos = Vector2(
				randf_range(c.size.x, get_viewport_rect().size.x - c.size.x),
				randf_range(c.size.y, get_viewport_rect().size.y - c.size.y)
			)
			valid = is_valid(pos)
		c.position = pos
	
	%won.text = ["Red","Green","Blue","yellow"][vi] + " is virus"
	%won.modulate = colors[vi]
	text_cooldown = 2
	%time.label_settings.font_size = 23
	%time.label_settings.font_color.a = 1
	
	roundtime = 90
	
	# play intro sound (map-related)
	
	return 0

func end() -> void:
	var map = end_map.instantiate()
	add_child(map)
	move_child(map, 0)
	var woni = scores.find(scores.max())
	%won.text = ["Red","Green","Blue","yellow"][woni] + " wins!"
	%won.modulate = colors[woni];
	%time.visible = false
	%virus_score.visible = false
	%red_score.label_settings.font_size = 100
	%green_score.label_settings.font_size = 100
	%blue_score.label_settings.font_size = 100
	%yellow_score.label_settings.font_size = 100

func make_cells(i) -> int:
	var cs = 0
	for _i in i:
		var pos = Vector2(
			randf_range(0, get_viewport_rect().size.x),
			randf_range(0, get_viewport_rect().size.y)
		)
		if is_valid(pos):
			var c = cell.instantiate()
			add_child(c)
			c.position = pos
			cs += 1
	return cs

func is_valid(pos: Vector2) -> bool:
	if pos.x <= 0 or pos.y <= 0 or pos.x >= get_viewport_rect().size.x or pos.y >= get_viewport_rect().size.y:
		return false
	var tilemap = get_child(0)
	var cellpos = tilemap.local_to_map(pos)
	if not cellpos and cellpos != Vector2i(0,0):
		return false
	var tiledata: TileData = tilemap.get_cell_tile_data(cellpos)
	if not tiledata or tiledata.terrain != 0:
		return false
	
	var cell_origin = tilemap.map_to_local(cellpos)
	var local_pos = pos - cell_origin
	
	for i in range(tiledata.get_collision_polygons_count(0)):
		var shape_data := tiledata.get_collision_polygon_points(0, i)
		
		if Geometry2D.is_point_in_polygon(local_pos, shape_data):
			return false
	
	return true


func f(x: float, y: float) -> float:
	# This function calculates a score in [-1,1] based on
	# x = total contaminated/dead cell rate (x ∈ [0,1])
	# y = time left in the round in minutes (y ∈ [0,1.5])
	# This function is made to meet the following constraints:
	# f(0,0) = -1  -- time's up and no cells were contaminated or killed
	# f(0,1) = -1.5  -- no cells were contaminated or killed after 30sec, the earliest time the game can end
	# f(1,0) = 1  -- time's up and all cells were contaminated or killed
	# f(1,1) = 1.5  -- all cells were contaminated or killed in 30sec, the earliest time the game can end
	# f(0.5, y<1) < 0  -- the round is lasting longer than 30sec, and exactly half the cells were contaminated/killed
	# f(x>0.5, y<1) > 0  -- the round is lasting longer than 30sec, and many cells were contaminated/killed
	# f(x<0.5, y<1) < 0  -- the round is lasting longer than 30sec, and not much cells were contaminated/killed
	# The full mathematical expression in polynomial form is as follows:
	# f(x,y) = 2x - y/2 - 1 + xy
	# If the round is over, so y = 0, this function simplifies to:
	# f(x,0) = 2x - 1
	# which is a rescaling of x ∈ [0,1] to [-1,1] in linear form to give points purely based on the contaminated+killed ratio.
	# For a given score s, the function can be interpreted as a Conic section:
	# xy + 2x - y/2 - 1 - s = 0
	# This Conic section is a Hyperbola, and will be degenerate if and only if s = 0, so when the game is perfectly balanced.
	# A degenerate Hyperbola consists of two intersecting straight lines, in this case:
	# (x - 1/2)(y + 2) = 0
	# l1: x = 1/2
	# l2: y = -2
	# Since y > 0 in the defined domain, s = 0 will only happen if x = 1/2, so when exactly half of all cells were contaminated or killed.
	return 2*x - y/2 - 1 + x*y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if end_cooldown > 0:
		end_cooldown -= delta
		if end_cooldown <= 0:
			[%red_score,%green_score,%blue_score,%yellow_score][vi].label_settings.font_size = 23
			if (init()):
				end()
				ended = true
	elif not ended:
		if not started and cells < init_cells and randf() < (1./50):
			cells += make_cells(1)
		if started and cells != get_child_count() - init_children - 4:
			cells += 1
			max_cells += 1
		
		if started:
			roundtime -= delta
		if roundtime <= 15:
			%time.label_settings.font_size = 100
			%time.label_settings.font_color.a = .5
		
		text_cooldown -= delta
		if text_cooldown < 0 and started and %won.text.ends_with("virus"):
			%won.text = ""
		
		
		var x = ((contaminated + max_cells - cells) * 1. / max_cells) # 0 - 1
		var y = (roundtime * 1. / 60) # 0 - 1.5
		points = clampi(int(100 * f(x, y)), -150, 150)
		%virus_score.text = str(points)
		%time.text = str(int(ceil(roundtime) / 60)).pad_zeros(2) + ":" + str(int(ceil(roundtime)) % 60).pad_zeros(2)
		
		if %won.text.contains("win"):
			end_cooldown = 2
			[%red_score,%green_score,%blue_score,%yellow_score][vi].label_settings.font_size = 100
		
		else:
			if started and roundtime <= 60:
				if roundtime <= 0 or contaminated == cells or (contaminated == 0 and cells < max_cells):
					scores[vi] += points
					%won.modulate = Color(1,1,1)
					text_cooldown = 2
					if points == 0:
						%won.text = "Tie!"
					elif points > 0:
						%won.text = "Virus wins!"
					else:
						%won.text = "White Bloodcells win!"
			
			%red_score.text = str(scores[0])
			%green_score.text = str(scores[1])
			%blue_score.text = str(scores[2])
			%yellow_score.text = str(scores[3])
			
			if not red and any_key_pressed(keys[0]) and not started:
				red = true
				var c = virus.instantiate()
				add_child(c)
				c.init(0)
				c.position = Vector2(100, 100)
				%red_score.visible = true
			if not green and any_key_pressed(keys[1]) and not started:
				green = true
				var c = virus.instantiate()
				add_child(c)
				c.init(1)
				c.position = Vector2(get_viewport_rect().size.x - 100, get_viewport_rect().size.y - 100)
				%green_score.visible = true
			if not blue and any_key_pressed(keys[2]) and not started:
				blue = true
				var c = virus.instantiate()
				add_child(c)
				c.init(2)
				c.position = Vector2(get_viewport_rect().size.x - 100, 100)
				%blue_score.visible = true
			if not yellow and any_key_pressed(keys[3]) and not started:
				yellow = true
				var c = virus.instantiate()
				add_child(c)
				c.init(3)
				c.position = Vector2(100, get_viewport_rect().size.y - 100)
				%yellow_score.visible = true
			
			if red and green and blue and yellow and started:
				red = false
				green = false
				blue = false
				yellow = false
				curr_round = 0
				init()
			
			if red and green and blue and yellow and not started:
				started = true

func any_key_pressed(check_keys) -> bool:
	for key in check_keys:
		if Input.is_physical_key_pressed(key):
			return true
	return false

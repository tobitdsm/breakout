extends Node2D

var contaminated = 0
const init_cells = 500
var max_cells = init_cells
var cells = max_cells
var vi = randi() % 4

#var old_cells = 0

var roundtime = 90
var scores = [
	0, # red
	0, # green
	0, # blue
	0  # purple
]

var init_children = 0

var text_cooldown = 0

var red = false
var green = false
var blue = false
var purple = false

var started = false

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
	Color("purple")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%cells.visible = false
	%contaminated.visible = false
	%red_score.visible = false
	%green_score.visible = false
	%blue_score.visible = false
	%purple_score.visible = false
	%time.visible = false
	init_children = get_child_count() - 1
	cells = 0

func init() -> void:
	%cells.visible = true
	%contaminated.visible = true
	%red_score.visible = true
	%green_score.visible = true
	%blue_score.visible = true
	%purple_score.visible = true
	%time.visible = true
	
	for i in get_child_count():
		if i >= init_children:
			get_child(i).queue_free()
	
	get_child(0).queue_free()
	var maps := DirAccess.open("res://scenes/maps")
	var ind = randi_range(0, len(maps.get_files()) - 1)
	var map = load("res://scenes/maps/" + maps.get_files()[ind])
	map = map.instantiate()
	add_child(map)
	move_child(map,0)
	
	max_cells = make_cells(init_cells)
	cells = max_cells
	contaminated = 0
	
	var virus = preload("res://scenes/virus.tscn")
	var wbc = preload("res://scenes/whitebloodcell.tscn")
	vi = randi() % 4
	for i in 4:
		var c = wbc.instantiate()
		if i == vi:
			c = virus.instantiate()
			%contaminated.modulate = colors[vi]
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
	
	%won.text = ["Red","Green","Blue","Purple"][vi] + " is virus"
	%won.modulate = colors[vi]
	text_cooldown = 2
	%time.label_settings.font_size = 23
	#print("init")
	#print(max_cells)
	#print(cells)
	#print(contaminated)
	#print()
	roundtime = 90
	
	# play intro sound (map-related)

func make_cells(i) -> int:
	var cs = 0
	var cell = preload("res://scenes/cell.tscn")
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
	var cell = tilemap.local_to_map(pos)
	if not cell:
		return false
	var tiledata: TileData = tilemap.get_cell_tile_data(cell)
	if not tiledata or tiledata.terrain != 0:
		return false
	
	var cell_origin = tilemap.map_to_local(cell)
	var local_pos = pos - cell_origin
	
	for i in range(tiledata.get_collision_polygons_count(0)):
		var shape_data := tiledata.get_collision_polygon_points(0, i)
		
		if Geometry2D.is_point_in_polygon(local_pos, shape_data):
			return false
	
	return true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started and cells < init_cells and randf() < (1./50):
		cells += make_cells(1)
	if started and cells != get_child_count() - init_children - 4:
		cells += 1
		max_cells += 1
	
	if started:
		roundtime -= delta
	if roundtime <= 15:
		%time.label_settings.font_size = 100
	
	text_cooldown -= delta
	if text_cooldown < 0 and started and %won.text.ends_with("virus"):
		%won.text = ""
	
	%contaminated.text = str(round(contaminated * 1000. / cells) / 10.) + "%"
	%cells.text = str(round(cells * 1000. / max_cells) / 10.) + "%"
	%time.text = str(int(roundtime / 60)).pad_zeros(2) + ":" + str(int(ceil(roundtime)) % 60).pad_zeros(2)
	
	if %won.text.contains("win"):
		init()
	
	if started and roundtime <= 60:
		if roundtime < 0:
			if contaminated >= (cells * 1. / 2):
				%won.text = "Virus wins!"
				%won.modulate = Color(1,1,1)
				text_cooldown = 2
				scores[vi] += (contaminated + max_cells - cells) * 1. / max_cells
			else:
				%won.text = "White Bloodcells win!"
				%won.modulate = Color(1,1,1)
				text_cooldown = 2
				scores[vi] -= .5 - (contaminated * 1. / cells)
		if contaminated == cells:
			%won.text = "Virus wins!"
			%won.modulate = Color(1,1,1)
			text_cooldown = 2
			scores[vi] += roundtime * 1. / 100
		if contaminated == 0 and cells < max_cells:
			%won.text = "White Bloodcells win!"
			%won.modulate = Color(1,1,1)
			text_cooldown = 2
			scores[vi] -= cells * 1. / max_cells
	
	%red_score.text = str(int(scores[0] * 100))
	%green_score.text = str(int(scores[1] * 100))
	%blue_score.text = str(int(scores[2] * 100))
	%purple_score.text = str(int(scores[3] * 100))
	
	if not red and any_key_pressed(keys[0]) and not started:
		red = true
		var c = preload("res://scenes/whitebloodcell.tscn").instantiate()
		add_child(c)
		c.init(0)
		c.position = Vector2(100, 100)
		%red_score.visible = true
	if not green and any_key_pressed(keys[1]) and not started:
		green = true
		var c = preload("res://scenes/whitebloodcell.tscn").instantiate()
		add_child(c)
		c.init(1)
		c.position = Vector2(get_viewport_rect().size.x - 100, get_viewport_rect().size.y - 100)
		%green_score.visible = true
	if not blue and any_key_pressed(keys[2]) and not started:
		blue = true
		var c = preload("res://scenes/whitebloodcell.tscn").instantiate()
		add_child(c)
		c.init(2)
		c.position = Vector2(get_viewport_rect().size.x - 100, 100)
		%blue_score.visible = true
	if not purple and any_key_pressed(keys[3]) and not started:
		purple = true
		var c = preload("res://scenes/whitebloodcell.tscn").instantiate()
		add_child(c)
		c.init(3)
		c.position = Vector2(100, get_viewport_rect().size.y - 100)
		%purple_score.visible = true
	
	if red and green and blue and purple and started:
		red = false
		green = false
		blue = false
		purple = false
		init()
	
	if red and green and blue and purple and not started:
		started = true

func any_key_pressed(check_keys) -> bool:
	for key in check_keys:
		if Input.is_physical_key_pressed(key):
			return true
	return false

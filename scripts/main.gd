extends Node2D

var contaminated = 0
const init_cells = 500
var max_cells = init_cells
var cells = max_cells
var vi = randi() % 4

var init_children = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_children = get_child_count()
	init()

func init() -> void:
	for i in get_child_count():
		if i >= init_children:
			get_child(i).queue_free()
	
	if get_child(0).is_in_group("tile"):
		get_child(0).queue_free()
	var maps := DirAccess.open("res://scenes/maps")
	var ind = randi_range(0, len(maps.get_files()) - 1)
	var map = load("res://scenes/maps/" + maps.get_files()[ind])
	map = map.instantiate()
	add_child(map)
	move_child(map,0)
	
	max_cells = init_cells
	cells = max_cells
	contaminated = 0
	var cell = preload("res://scenes/cell.tscn")
	for _i in init_cells:
		var pos = Vector2(
			randf_range(0, get_viewport_rect().size.x),
			randf_range(0, get_viewport_rect().size.y)
		)
		if is_valid(pos):
			var c = cell.instantiate()
			add_child(c)
			c.position = pos
		else:
			max_cells -= 1
			cells -= 1
	
	var virus = preload("res://scenes/virus.tscn")
	var wbc = preload("res://scenes/whitebloodcell.tscn")
	vi = randi() % 4
	for i in 4:
		var c = wbc.instantiate()
		if i == vi:
			c = virus.instantiate()
			%contaminated.modulate = c.colors[vi]
		c.init(i)
		add_child(c)
		var valid = false
		while not valid:
			c.position = Vector2(
				randf_range(c.size.x, get_viewport_rect().size.x - c.size.x),
				randf_range(c.size.y, get_viewport_rect().size.y - c.size.y)
			)
			valid = is_valid(c.position)
	
	%won.text = ""
	# play intro sound (map-related)

func is_valid(pos: Vector2) -> bool:
	if pos.x <= 0 or pos.y <= 0 or pos.x >= get_viewport_rect().size.x or pos.y >= get_viewport_rect().size.y:
		return false
	var cell = get_child(0).local_to_map(pos)
	var tiledata: TileData = get_child(0).get_cell_tile_data(cell)
	return tiledata.terrain == 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	%contaminated.text = str(round(contaminated * 1000. / cells) / 10.) + "%"
	%cells.text = str(round(cells * 1000. / max_cells) / 10.) + "%"
	
	if %won.text != "":
		init()
	
	if contaminated == cells:
		%won.text = "Virus wins!"	
	if contaminated == 0 and cells < max_cells:
		%won.text = "White Bloodcells win!"

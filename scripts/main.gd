extends Node2D

var contaminated = 0
var max_cells = 500
var cells = 500
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
	
	cells = max_cells
	contaminated = 0
	var cell = preload("res://scenes/cell.tscn")
	for _i in cells:
		var c = cell.instantiate()
		add_child(c)
		var colliding = true
		while colliding:
			c.position = Vector2(
				randf_range(0, get_viewport_rect().size.x - c.scale.x),
				randf_range(0, get_viewport_rect().size.y - c.scale.x)
			)
			colliding = is_colliding(c)
	
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
		var colliding = true
		while colliding:
			c.position = Vector2(
				randf_range(0, get_viewport_rect().size.x - c.scale.x),
				randf_range(0, get_viewport_rect().size.y - c.scale.x)
			)
			colliding = is_colliding(c)
	
	%won.text = ""

func is_colliding(c: RigidBody2D) -> bool:
	var cell = get_child(0).local_to_map(c.position)
	var tiledata: TileData = get_child(0).get_cell_tile_data(cell)
	return tiledata.terrain == 1

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

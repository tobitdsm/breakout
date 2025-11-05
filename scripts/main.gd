extends Node2D

var contaminated = 0
const max_cells = 1000
var cells = 1000
var vi = randi() % 4

var init_children = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_children = get_child_count()
	init()

func init() -> void:
	cells = max_cells
	contaminated = 0
	for i in get_child_count():
		if i >= init_children:
			get_child(i).queue_free()
	var cell = preload("res://scenes/cell.tscn")
	for _i in cells:
		var c = cell.instantiate()
		add_child(c)
		c.position = Vector2(
			randf_range(0, get_viewport_rect().size.x - c.scale.x),
			randf_range(0, get_viewport_rect().size.y - c.scale.x)
		)
	
	var virus = preload("res://scenes/virus.tscn")
	var wbc = preload("res://scenes/whitebloodcell.tscn")
	vi = randi() % 4
	for i in 4:
		var c = wbc.instantiate()
		if i == vi:
			c = virus.instantiate()
		c.init(i)
		add_child(c)
		c.position = Vector2(
			randf_range(0, get_viewport_rect().size.x - c.scale.x),
			randf_range(0, get_viewport_rect().size.y - c.scale.x)
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	%contaminated.label_settings.font_size = get_viewport_rect().size.x / 50
	%contaminated.position.x = (get_viewport_rect().size.x - %contaminated.label_settings.font_size) / 2
	
	%cells.label_settings.font_size = get_viewport_rect().size.x / 50
	%cells.position.x = %cells.position.x - len(%cells.text) * %cells.label_settings.font_size
	
	%contaminated.text = str(round(contaminated * 1000. / cells) / 10.) + "%"
	%cells.text = str(round(cells * 1000. / max_cells) / 10.) + "%"
	
	if contaminated == cells:
		print("Virus wins!")
		init()
	
	if contaminated == 0 and cells < max_cells:
		print("White Bloodcells win!")
		init()

extends Node2D

var contaminated = 0
var cells = 20
var vi = randi() % 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cell = preload("res://scenes/cell.tscn")
	for _i in cells:
		var c = cell.instantiate()
		add_child(c)
		c.position = Vector2(randf() * get_viewport_rect().size.x, randf() * get_viewport_rect().size.y)
	
	var virus = preload("res://scenes/virus.tscn")
	var wbc = preload("res://scenes/whitebloodcell.tscn")
	for i in 4:
		var c = wbc.instantiate()
		if i == vi:
			c = virus.instantiate()
		c.init(i)
		add_child(c)
		c.position = Vector2(randf() * get_viewport_rect().size.x, randf() * get_viewport_rect().size.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if contaminated == cells:
		print("Virus wins!")
		self.queue_free()
	
	if get_child(cells + vi).health == 0:
		print("White Bloodcells win!")
		self.queue_free()

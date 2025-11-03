extends "player.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super.init(
		Key.KEY_I,
		Key.KEY_J,
		Key.KEY_K,
		Key.KEY_L,
		Key.KEY_COMMA,
		speed
	)
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

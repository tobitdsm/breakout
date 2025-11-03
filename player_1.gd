extends "player.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super.init(
		Key.KEY_Z,
		Key.KEY_Q,
		Key.KEY_S,
		Key.KEY_D,
		Key.KEY_SPACE,
		speed
	)
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

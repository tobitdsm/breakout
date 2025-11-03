extends "player.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super.init(
		Key.KEY_T,
		Key.KEY_F,
		Key.KEY_G,
		Key.KEY_H,
		Key.KEY_V,
		speed
	)
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

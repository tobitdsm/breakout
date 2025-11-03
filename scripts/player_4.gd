extends "player.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super.init(
		Key.KEY_KP_8,
		Key.KEY_KP_4,
		Key.KEY_KP_5,
		Key.KEY_KP_6,
		Key.KEY_KP_0,
		speed
	)
	color = Color("purple")
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

extends "player.gd"

const max_health = 10.
var health = max_health
const max_size = 0.1

func init(i):
	super.init(i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown = 10
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	var size = max_size * ((1. / max_health) * health)
	self.scale = Vector2(size, size)
	if wait > 0:
		wait -= delta
	elif Input.is_key_pressed(keyaction):
		var areas = self.get_child(0).get_overlapping_areas()
		for area in areas:
			if area.is_in_group("cell") and not area.get_parent().contaminated:
				wait = cooldown
				var c = color
				c.s *= (2./3.)
				area.get_parent().modulate = c
				area.get_parent().contaminated = true
				get_parent().contaminated += 1

extends "player.gd"

func init(i):
	super.init(i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown = 5
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if wait > 0:
		wait -= delta
	elif Input.is_key_pressed(keyaction):
		var areas = self.get_child(0).get_overlapping_areas()
		for area in areas:
			if area.is_in_group("cell") and area.get_parent().contaminated:
				wait = cooldown
				area.get_parent().modulate = Color(1,1,1)
				area.get_parent().contaminated = false
				area.get_parent().healed = area.get_parent().healed_cooldown
				area.get_parent().sick = 0
				get_parent().contaminated -= 1
			elif area.is_in_group("virus"):
				area.get_parent().health -= 1
				wait = cooldown

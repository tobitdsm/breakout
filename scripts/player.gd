extends RigidBody2D

var color = Color(0.5, 0.5, 0.5)

var speed = 1.5

var cooldown = 5
var wait = 0

var checkwall = true

var size

var keyup = Key.KEY_UP
var keyleft = Key.KEY_LEFT
var keydown = Key.KEY_DOWN
var keyright = Key.KEY_RIGHT
var keyaction = Key.KEY_SHIFT

const keys = [
	[
		Key.KEY_Z,
		Key.KEY_Q,
		Key.KEY_S,
		Key.KEY_D,
		Key.KEY_SPACE
	], [
		Key.KEY_T,
		Key.KEY_F,
		Key.KEY_G,
		Key.KEY_H,
		Key.KEY_V
	], [
		Key.KEY_I,
		Key.KEY_J,
		Key.KEY_K,
		Key.KEY_L,
		Key.KEY_COMMA
	], [
		Key.KEY_KP_8,
		Key.KEY_KP_4,
		Key.KEY_KP_5,
		Key.KEY_KP_6,
		Key.KEY_KP_0
	]
]

const colors = [
	Color("red"),
	Color("green"),
	Color("blue"),
	Color("purple")
]

func init(i) -> void:
	keyup = keys[i][0]
	keyleft = keys[i][1]
	keydown = keys[i][2]
	keyright = keys[i][3]
	keyaction = keys[i][4]
	color = colors[i]
	self.modulate = color + Color(.75,.75,.75)
	self.get_child(1).modulate = color + Color(.5,.5,.5)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	
	size = self.get_child(2).scale * 500

func colliding_wall() -> bool:
	var bodies := self.get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("tile"):
			return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if checkwall:
		var valid = get_parent().is_valid(self.position) and not self.colliding_wall()
		if not valid:
			self.position += Vector2(
				randf_range(-1,1),
				randf_range(-1,1)
			)
			valid = get_parent().is_valid(self.position) and not self.colliding_wall()
		checkwall = not valid
	
	self.get_child(1).scale.x = floor(((wait*1.) / (cooldown*1.)) * 25) if wait > 0 else 0
	var viewport_size = get_viewport_rect().size
	var vel := Vector2.ZERO

	if Input.is_key_pressed(keyup) and position.y > 0:
		vel.y -= 1
	if Input.is_key_pressed(keydown) and position.y < viewport_size.y:
		vel.y += 1

	if Input.is_key_pressed(keyleft) and position.x > 0:
		vel.x -= 1
	if Input.is_key_pressed(keyright) and position.x < viewport_size.x:
		vel.x += 1

	vel = vel.normalized() * speed
	linear_velocity = vel
	
	move_and_collide(vel)

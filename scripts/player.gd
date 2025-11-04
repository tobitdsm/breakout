extends Sprite2D

var color = Color(0.5, 0.5, 0.5)

var speed = 1

var cooldown = 5
var wait = 0

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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.get_child(1).scale.x = floor(((wait*1.) / (cooldown*1.)) * 500) if wait > 0 else 0
	if Input.is_key_pressed(keyup) and self.position.y > 0:
		self.position.y -= speed
	if Input.is_key_pressed(keydown) and self.position.y < self.get_viewport_rect().size.y:
		self.position.y += speed
	
	if Input.is_key_pressed(keyleft) and self.position.x > 0:
		self.position.x -= speed
	if Input.is_key_pressed(keyright) and self.position.x < self.get_viewport_rect().size.x:
		self.position.x += speed

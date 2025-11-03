extends Sprite2D

var color = Color(0.5, 0.5, 0.5)

var speed = 1

var virus = false

var keyup = Key.KEY_UP
var keyleft = Key.KEY_LEFT
var keydown = Key.KEY_DOWN
var keyright = Key.KEY_RIGHT
var keyaction = Key.KEY_SHIFT

func init(up, left, down, right, action, spd) -> void:
	keyup = up
	keydown = down
	keyleft = left
	keyright = right
	keyaction = action
	speed = spd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var virusimg = preload("res://assets/virus.png")
	var wbcimg = preload("res://assets/whitebloodcell.png")
	if virus:
		self.texture = virusimg
		self.get_child(0).get_child(0).shape.radius = 250
	else:
		self.texture = wbcimg
		self.get_child(0).get_child(0).shape.radius = 150
	self.scale = Vector2(0.1, 0.1)
	self.modulate = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_key_pressed(keyup) and self.position.y > 0:
		self.position.y -= speed
	if Input.is_key_pressed(keydown) and self.position.y < self.get_viewport_rect().size.y:
		self.position.y += speed
	
	if Input.is_key_pressed(keyleft) and self.position.x > 0:
		self.position.x -= speed
	if Input.is_key_pressed(keyright) and self.position.x < self.get_viewport_rect().size.x:
		self.position.x += speed
	
	if Input.is_key_pressed(keyaction):
		if virus:
			pass

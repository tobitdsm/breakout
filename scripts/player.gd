extends CharacterBody2D

var color = Color(0.5, 0.5, 0.5)

var speed = 100

var cooldown = 5
var wait = 0

var checkwall = true

var size

var keyup = Key.KEY_UP
var keyleft = Key.KEY_LEFT
var keydown = Key.KEY_DOWN
var keyright = Key.KEY_RIGHT
var keyaction = Key.KEY_SHIFT

func init(i) -> void:
	keyup = get_parent().keys[i][0]
	keyleft = get_parent().keys[i][1]
	keydown = get_parent().keys[i][2]
	keyright = get_parent().keys[i][3]
	keyaction = get_parent().keys[i][4]
	color = get_parent().colors[i]
	self.modulate = color + Color(.75,.75,.75)
	self.get_child(1).modulate = color + Color(.5,.5,.5)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = self.get_child(2).scale * 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if get_parent().end_cooldown <= 0:	
		self.get_child(1).scale.x = floor(((wait*1.) / (cooldown*1.)) * 25) if wait > 0 else 0
		var viewport_size = get_viewport_rect().size
		var vel := Vector2.ZERO

		if Input.is_physical_key_pressed(keyup) and position.y > 0:
			vel.y -= 1
		if Input.is_physical_key_pressed(keydown) and position.y < viewport_size.y:
			vel.y += 1

		if Input.is_physical_key_pressed(keyleft) and position.x > 0:
			vel.x -= 1
		if Input.is_physical_key_pressed(keyright) and position.x < viewport_size.x:
			vel.x += 1

		vel = vel.normalized() * speed
		velocity = vel
		
		move_and_slide()

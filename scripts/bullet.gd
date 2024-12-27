extends CharacterBody2D
const SPEED := 550
var direction : Vector2

func _ready():
	direction = Vector2(1,0).rotated(rotation)

func _physics_process(_delta):
	velocity = SPEED * direction
	move_and_slide()

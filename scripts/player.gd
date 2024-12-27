extends CharacterBody2D

@export var bullet :PackedScene

@onready var gun_rotation: Node2D = $GunRotation
@onready var bullet_spawn: Node2D = $GunRotation/BulletSpawn
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer


const SPEED = 250.0
const JUMP_VELOCITY = -350.0

func _ready() -> void:
	multiplayer_synchronizer.set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		gun_rotation.look_at(get_global_mouse_position())
		
		if Input.is_action_just_pressed("fire"):
			shoot.rpc()
		
		if not is_on_floor():
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
	
@rpc("any_peer","call_local")
func shoot():
	var blt = bullet.instantiate()
	blt.global_position = bullet_spawn.global_position
	blt.rotation_degrees = gun_rotation.rotation_degrees
	get_tree().root.add_child(blt)

extends CharacterBody2D

@onready var child_sprite: Sprite2D = $ChildSprite
@onready var torchlight: Node2D = $Torchlight
@onready var torchlight_sprite: Sprite2D = $Torchlight/TorchlightSprite
@onready var torchlight_light: Area2D = $Torchlight/TorchlightLight

const SPEED = 300.0
const JUMP_VELOCITY = -615.0

var health := 100.0
var DAMAGE_RATE := 5.0
signal fear_depleted
@onready var fear_bar: ProgressBar = %FearBar
@onready var hurt_box: Area2D = %HurtBox

@onready var ladder_in_range: bool = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("move_down"):
		position.y += 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

	if direction < 0.0:
		child_sprite.flip_h = true
		#torchlight.rotation_degrees = 180
		#torchlight_sprite.flip_v = true
	elif direction > 0.0:
		child_sprite.flip_h = false
		#torchlight.rotation_degrees = 0
		#torchlight_sprite.flip_v = false

	var attacking_ghosts : Array[Node2D] = hurt_box.get_overlapping_bodies()
	if attacking_ghosts.size() > 0:
		health -= DAMAGE_RATE * attacking_ghosts.size() * delta
		fear_bar.value = health
		if health <= 0.0:
			fear_depleted.emit()

extends CharacterBody2D

@onready var child_sprite: AnimatedSprite2D = $ChildSprite

@onready var flashlight: Node2D = $Flashlight
@onready var is_holding_flashlight: bool = false

@onready var teddy_bear: Node2D = $TeddyBear
@onready var animation_player: AnimationPlayer = $TeddyBear/AnimationPlayer
var is_cuddling:bool = false

var SPEED := 200.0
var JUMP_VELOCITY := -450.0
var direction: float
var direction_vertical: float

var health := 100.0
var DAMAGE_RATE := 5.0
signal courage_depleted
@onready var courage_bar: ProgressBar = %CourageBar
@onready var hurt_box: Area2D = %HurtBox

@onready var ladder_detector: Area2D = %LadderDetector
@onready var is_climbing:bool = false

@onready var window_detector: Area2D = %WindowDetector

@onready var door_detector: Area2D = %DoorDetector
@onready var key_detector: Area2D = %KeyDetector
signal key_updated
var key_counter := 0

var battery := 100.0
const MAX_BATTERY := 100.0
const BATTERY_DEPLETE_RATE := 10.0
const BATTERY_CHARGE_RATE := 20.0

signal flashlight_used

func _physics_process(delta: float) -> void:
#region Animations
	# Air animations
	if is_climbing:
		if velocity.y != 0:
			child_sprite.play("climb")
		else:
			child_sprite.play("idle_climb")
	elif velocity.y > 0:
			child_sprite.play("fall")
	elif velocity.y < 0:
		child_sprite.play("jump")
	# Ground animations
	elif (velocity.x > 1 || velocity.x < -1):
		child_sprite.play("run")
		if child_sprite.frame == 0 || child_sprite.frame == 4:
			$Footsteps.play()
	else:
		child_sprite.play("idle")

	#Flip sprite depend where facing or faced last
	if direction < 0.0:
		child_sprite.flip_h = true
		teddy_bear.rotation_degrees = 180.0
		$TeddyBear/TeddyBearSprite.flip_v = true
	elif direction > 0.0:
		child_sprite.flip_h = false
		teddy_bear.rotation_degrees = 0.0
		$TeddyBear/TeddyBearSprite.flip_v = false

#endregion
	# Add the gravity, deactivated on climbing
	if not is_on_floor() and not is_climbing:
		velocity += get_gravity() * delta
	# Turn off climbing once we touch floor
	if is_on_floor():
		is_climbing = false
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	# Get down platform
	if Input.is_action_just_pressed("move_down"):
		position.y += 1
	# Move on ladder
	if ladder_detector.has_overlapping_bodies() && Input.is_action_pressed("move_up"):
		is_climbing = true
	if ladder_detector.has_overlapping_bodies() && is_climbing:
		direction_vertical = Input.get_axis("move_up", "move_down")
		if direction_vertical:
			is_climbing = true
			velocity.y = direction_vertical * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		is_climbing = false

	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	#Turn on/off the flashlight
	if Input.is_action_just_pressed("flashlight"):
		toggle_flashlight()
	# Points the flashlight
	# Mouse support
	if Input.get_last_mouse_velocity() != Vector2.ZERO:
		flashlight.look_at(get_global_mouse_position())
	# Controler support
	if Input.get_connected_joypads():
		var controllerangle := Vector2.ZERO.angle()
		var xAxisRL := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var yAxisUD := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		controllerangle = Vector2(xAxisRL, yAxisUD).angle()
		if abs(xAxisRL) > 0.3 || abs(yAxisUD) > 0.3:
			flashlight.rotation = controllerangle

	if Input.is_action_just_pressed("cuddle"):
		start_cuddle()
	if Input.is_action_just_released("cuddle"):
		stop_cuddle()

	#Calculate damage according to how many shadow are in range
	var attacking_shadows : Array[Node2D] = hurt_box.get_overlapping_bodies()
	if attacking_shadows.size() > 0:
		damage(DAMAGE_RATE * attacking_shadows.size() * delta)

	var show_interactable_popup := false

	#Check if there is a window in range
	#if interact opens it
	if window_detector.has_overlapping_bodies():
		show_interactable_popup = true
		if Input.is_action_just_pressed("interact"):
			var window := window_detector.get_overlapping_bodies()[0]
			window.open()

	#Detects key and pick up it
	if key_detector.has_overlapping_bodies():
		key_detector.get_overlapping_bodies()[0].queue_free()
		update_key_counter(key_counter + 1)
		$PickupKey.play()
	#Check if there is a door next to the player
	#if interact tries to open
	#only opens if there is a key, else emit signal to start a sound
	if door_detector.has_overlapping_bodies():
		show_interactable_popup = true
		if Input.is_action_just_pressed("interact"):
			if key_counter > 0:
				update_key_counter(key_counter - 1)
				var door := door_detector.get_overlapping_bodies()[0]
				door.open()
				$DoorOpened.play()
			else:
				$DoorLocked.play()

	$InteractablePopup.visible = show_interactable_popup

	if flashlight.visible:
		battery -= BATTERY_DEPLETE_RATE * delta
		battery = max(0, battery)
		if battery == 0:
			toggle_flashlight()
	elif battery != MAX_BATTERY:
		battery += BATTERY_CHARGE_RATE * delta
		battery = min(MAX_BATTERY, battery)

	%BatteryBar.value = battery
	%BatteryBar.visible = battery != MAX_BATTERY

func update_key_counter(new_key_counter: int) -> void:
	key_counter = new_key_counter
	emit_signal("key_updated", key_counter)

	$Key.visible = key_counter >= 1
	$Key2.visible = key_counter >= 2

	if key_counter >= 3:
		print('More than 3 keys are not supported by UI!')

func jump() -> void:
	is_climbing = false
	velocity.y = JUMP_VELOCITY
	$Jump.play()

func thunder_damage(amount: float) -> void:
	if not is_cuddling:
		damage(amount)


func damage(amount: float) -> void:
	health -= amount
	courage_bar.value = health
	if health <= 0.0:
		courage_depleted.emit()

func toggle_flashlight() -> void:
	if is_cuddling:
		stop_cuddle()
	emit_signal("flashlight_used")
	$Flashlight/FlashlightAudio.play()
	flashlight.visible = !flashlight.visible
	$Flashlight/TorchlightLight/CollisionPolygon2D.disabled = !$Flashlight/TorchlightLight/CollisionPolygon2D.disabled

#if shadow gets in range tells it so it stops getting closer
func _on_hurt_box_body_entered(body: Node2D) -> void:
	body.is_in_range = true

#if shadow gets out of range range tells it so it chases again
func _on_hurt_box_body_exited(body: Node2D) -> void:
	body.is_in_range = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "get_closer":
		animation_player.play("cuddling")

func start_cuddle() -> void:
	if flashlight.visible:
		toggle_flashlight()
	is_cuddling = true
	SPEED -= 100
	JUMP_VELOCITY += 150
	animation_player.play("get_closer")

func stop_cuddle() -> void:
	# if state to cover edge case when we use flashlight while cuddling
	if is_cuddling:
		is_cuddling = false
		SPEED += 100
		JUMP_VELOCITY -= 150
		animation_player.play("put_away")

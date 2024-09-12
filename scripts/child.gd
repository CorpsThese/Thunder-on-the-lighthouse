extends CharacterBody2D

@onready var child_sprite: Sprite2D = $ChildSprite
@onready var flashlight: Node2D = $Flashlight

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

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

	# Add the gravity, deactivated on climbing
	if not is_on_floor() and not is_climbing:
		velocity += get_gravity() * delta
	# Turn off climbing once we touch floor
	if is_on_floor():
		is_climbing = false
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_climbing = false
		velocity.y = JUMP_VELOCITY
	# Get down platform
	if Input.is_action_just_pressed("move_down"):
		position.y += 1
	# Move on ladder
	if ladder_detector.has_overlapping_bodies() && Input.is_action_pressed("move_up"):
		is_climbing = true
	if ladder_detector.has_overlapping_bodies() && is_climbing:
		var direction_vertical := Input.get_axis("move_up", "move_down")
		if direction_vertical:
			is_climbing = true
			velocity.y = direction_vertical * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		is_climbing = false

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

	#Flip sprite depend where the face or faced last
	if direction < 0.0:
		child_sprite.flip_h = true
	elif direction > 0.0:
		child_sprite.flip_h = false

	#Turn on/off the flashlight
	if Input.is_action_just_pressed("flashlight"):
		toggle_flashlight()
	#Points the flashlight
	flashlight.look_at(get_global_mouse_position())


	#Calculate damage according to how many shadow are in range
	var attacking_shadows : Array[Node2D] = hurt_box.get_overlapping_bodies()
	if attacking_shadows.size() > 0:
		health -= DAMAGE_RATE * attacking_shadows.size() * delta
		courage_bar.value = health
		if health <= 0.0:
			courage_depleted.emit()
	
	var show_interactable_popup := false
	
	#Check if there is a window in range
	#if interact opens it
	if window_detector.has_overlapping_bodies():
		show_interactable_popup = true
		if Input.is_action_just_pressed("interact"):
			var window := window_detector.get_overlapping_bodies()[0]
			window.open()

	#Detects key and gather it
	if key_detector.has_overlapping_bodies():
		key_detector.get_overlapping_bodies()[0].queue_free()
		key_counter += 1
		emit_signal("key_updated", key_counter)
	#Check if there is a door next to the player
	#if interact tries to open
	#only opens if there is a key, else emit signal to start a sound
	if door_detector.has_overlapping_bodies():
		show_interactable_popup = true
		if Input.is_action_just_pressed("interact"):
			if key_counter > 0:
				key_counter -= 1
				emit_signal("key_updated", key_counter)
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


func toggle_flashlight() -> void:
	emit_signal("flashlight_used")
	$Flashlight/FlashlightAudio.play()
	flashlight.visible = !flashlight.visible
	$Flashlight/TorchlightLight/CollisionPolygon2D.disabled = !$Flashlight/TorchlightLight/CollisionPolygon2D.disabled

#if shadow gets in range tells it so it stops getting closer
func _on_hurt_box_body_entered(body: Node2D) -> void:
	body.is_in_range = true
	pass # Replace with function body.


#if shadow gets out of range range tells it so it chases again
func _on_hurt_box_body_exited(body: Node2D) -> void:
	body.is_in_range = false
	pass # Replace with function body.

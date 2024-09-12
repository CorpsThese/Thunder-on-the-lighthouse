extends CharacterBody2D
class_name shadow

const SPEED = 100.0
var player : CharacterBody2D
var is_in_range := false

var light_value := 0.0
var DAMAGE_RATE := 10.0
signal shadow_defeated
@onready var light_bar: ProgressBar = %LightBar
@onready var hurt_box: Area2D = %HurtBox


func _physics_process(delta: float) -> void:
	#if not in range of the player follow it
	if !is_in_range:
		var direction := global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		move_and_slide()

	# Manage damage if in the area of the flashlight
	var light : Array[Area2D] = hurt_box.get_overlapping_areas()
	if light.size() > 0:
		light_value += DAMAGE_RATE * light.size()* delta
		light_bar.value = light_value
		if light_value >= 10.0:
			shadow_defeated.emit(self)

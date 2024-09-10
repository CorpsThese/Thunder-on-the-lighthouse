extends CharacterBody2D

const SPEED = 150.0
var player : CharacterBody2D

var health := 10.0
var DAMAGE_RATE := 5.0
signal ghost_defeated
@onready var hurt_box: Area2D = %HurtBox


func _physics_process(delta: float) -> void:
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	move_and_slide()


	var lighted : Array[Node2D] = hurt_box.get_overlapping_bodies()
	if lighted.size() > 0:
		health -= DAMAGE_RATE
		if health <= 0.0:
			ghost_defeated.emit(self)

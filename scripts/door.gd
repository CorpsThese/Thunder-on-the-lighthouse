extends StaticBody2D

@export var is_flip: bool= false

# Opens the door, changing the sprite
# and hiding the collision shape to stop blocking & avoid interactions
func open() -> void:
	$DoorSprite.texture = load("res://ressources/textures/door_opened.png")
	$CollisionShape2D.disabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_flip:
		$DoorSprite.flip_h = is_flip
		$CollisionShape2D.position.x = 12.5

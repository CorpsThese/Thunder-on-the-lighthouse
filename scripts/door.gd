extends StaticBody2D

@export var is_flip: bool= false

# Opens the door, changing the sprite
# and hiding the collision shape to stop blocking & avoid interactions
func open() -> void:
	$DoorSprite.texture = load("res://ressources/textures/door_opened.png")
	$CollisionShape2D.disabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DoorSprite.flip_h = is_flip
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

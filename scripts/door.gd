extends StaticBody2D


# Opens the door, changing the sprite
# and hiding the collision shape to stop blocking & avoid interactions
func open() -> void:
	$DoorSprite.texture = load("res://ressources/textures/opened_window.png")
	$CollisionShape2D.hide()
	$InteractionArea.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D

func _ready() -> void:
	if len(Input.get_connected_joypads()) > 0:
		$GamepadB.visible = true
	else:
		$FKey.visible = true

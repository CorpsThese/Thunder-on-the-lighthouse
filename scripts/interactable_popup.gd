extends Node2D

func _input(event: InputEvent) -> void:
	if len(Input.get_connected_joypads()) > 0:
		$FKey.visible = false
		$GamepadB.visible = true
	if event is InputEventKey or event is InputEventMouse:
		$FKey.visible = true
		$GamepadB.visible = false

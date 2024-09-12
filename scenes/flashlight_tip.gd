extends Label

var used := false

func _on_child_flashlight_used() -> void:
	if used:
		return
	
	$AnimationPlayer.play("fadeout")
	used = true

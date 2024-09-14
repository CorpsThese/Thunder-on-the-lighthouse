extends CanvasLayer
@onready var exit: Button = $Control/VBoxContainer/Exit
@onready var v_box_container: VBoxContainer = $Control/VBoxContainer


func _ready() -> void:
	if OS.has_feature("web"):
		exit.visible = false
		v_box_container.size.y = v_box_container.size.y/2
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lighthouse.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	$Control/CreditsPanel.visible = !$Control/CreditsPanel.visible
	pass # Replace with function body.

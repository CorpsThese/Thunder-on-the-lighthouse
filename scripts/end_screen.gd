extends Node
@onready var exit: Button = $Control/HBoxContainer/VBoxContainer/Exit
@onready var v_box_container: VBoxContainer = $Control/HBoxContainer/VBoxContainer


func _ready() -> void:
	if OS.has_feature("web"):
		exit.visible = false
		v_box_container.size.y = v_box_container.size.y/2
	$ThunderTimer.start(randfn(8, 2))

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lighthouse.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	$Control/CreditsPanel.visible = !$Control/CreditsPanel.visible
	$Control/EndText.visible = !$Control/EndText.visible


func _on_thunder_timer_timeout() -> void:
	$ThunderSound.play()
	$ThunderTimer.start(randfn(8, 2))
	pass # Replace with function body.

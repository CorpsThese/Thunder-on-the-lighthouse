extends Control

@onready var exit: Button = $VBoxContainer/Exit
@onready var v_box_container: VBoxContainer = $VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("web"):
		exit.visible = false
		v_box_container.size.y = v_box_container.size.y/2
	pass

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().quit()

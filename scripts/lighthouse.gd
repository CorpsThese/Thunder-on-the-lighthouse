extends Node

@onready var game_ui: Control = $GameUI
@onready var ghost_spawn_position: PathFollow2D = %GhostSpawnPosition
@onready var child: CharacterBody2D = %Child

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_ghost() -> void:
	var new_ghost := preload("res://scenes//ghost.tscn").instantiate()
	ghost_spawn_position.progress_ratio = randf()
	new_ghost.global_position = ghost_spawn_position.global_position
	new_ghost.player = child
	add_child(new_ghost)
	new_ghost.connect("ghost_defeated", delete_ghost)


func _on_ghost_spawn_timer_timeout() -> void:
	spawn_ghost()

func delete_ghost(ghost: CharacterBody2D) -> void:
	ghost.queue_free()

func _on_child_fear_depleted() -> void:
	%GameOver.show()
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		%Pause.show()

func _on_continue_pressed() -> void:
	get_tree().paused = false
	%Pause.hide()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

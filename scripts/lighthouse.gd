extends Node

@onready var game_ui: Control = $GameUI
@onready var child: CharacterBody2D = %Child

@onready var shadow_spawn_position: PathFollow2D = %ShadowSpawnPosition
var shadow_counter := 0
@export var max_shadow := 5
@export var wave_objective := 5
var is_objective_complete := false
var shadow_killed := 0

@onready var window: StaticBody2D = $Level/Window

var is_wave_on := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_shadow() -> void:
	var new_shadow := preload("res://scenes//shadow.tscn").instantiate()
	shadow_spawn_position.progress_ratio = randf()
	new_shadow.global_position = shadow_spawn_position.global_position
	new_shadow.player = child
	shadow_counter += 1
	add_child(new_shadow)
	new_shadow.connect("shadow_defeated", delete_shadow)


func _on_shadow_spawn_timer_timeout() -> void:
	if is_wave_on:
		if shadow_counter < max_shadow && not is_objective_complete:
			spawn_shadow()

func delete_shadow(shadow_node: CharacterBody2D) -> void:
	shadow_counter -= 1
	shadow_node.queue_free()
	shadow_killed += 1
	if shadow_killed >= wave_objective:
		if shadow_counter == 0:
			is_wave_on = false
		else:
			is_objective_complete = true

func _on_window_window_opened() -> void:
	is_objective_complete = false
	is_wave_on = true
	$WaveTimer.start()

func _on_lighting_timer_timeout() -> void:
	if not is_wave_on:
		var proba := randf()
		if proba > 0.33:
			proba = randf()
			if proba < 0.5:
				window.light_up(1)
			elif proba < 0.8:
				window.light_up(2)
			else:
				window.light_up(3)

func _on_wave_timer_timeout() -> void:
	is_wave_on = false

func _on_child_courage_depleted() -> void:
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

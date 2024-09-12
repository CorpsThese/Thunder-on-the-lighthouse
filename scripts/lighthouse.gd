extends Node

@onready var child: CharacterBody2D = %Child

@onready var shadow_spawn_position: PathFollow2D = %ShadowSpawnPosition
var shadow_counter := 0
@export var max_shadow := 5
@export var wave_objective := 5
var is_wave_on := false
var is_objective_complete := false
var shadow_killed := 0

@onready var window: StaticBody2D = $Level/Window
var is_thunder := false
@onready var key_label: Label = %KeyLabel

@export var next_level: PackedScene = preload("res://scenes/lighthouse.tscn")


@onready var music_fader: AnimationPlayer = $MusicFader

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
	if not is_objective_complete:
		if shadow_counter < max_shadow:
			spawn_shadow()

func delete_shadow(shadow_node: CharacterBody2D) -> void:
	shadow_counter -= 1
	shadow_node.queue_free()
	shadow_killed += 1
	if shadow_killed == wave_objective:
		is_objective_complete = true
	if is_objective_complete:
		is_wave_on = false
		$ShadowSpawnTimer.stop()
		music_fader.play("fade_into_calm")



func _on_window_window_opened() -> void:
	shadow_killed = 0
	is_objective_complete = false
	is_wave_on = true
	$ShadowSpawnTimer.start()
	music_fader.play("fade_into_fight")


# On timer out there is a chance to have lighting
# If so, there is 3 possible lighting level
# Set timer for thunder according to level
func _on_lighting_timer_timeout() -> void:
	if not is_wave_on:
		$LightingTimer.stop()
		var proba := randf()
		if proba > 0.33:
			proba = randf()
			if proba < 0.5:
				window.light_up(1)
				setup_thunder(1)
			elif proba < 0.8:
				window.light_up(2)
				setup_thunder(2)
			else:
				window.light_up(3)
				setup_thunder(3)

# Init thunder timer according to level
func setup_thunder(level: int) -> void:
	match level:
		1:
			$ThunderTimer.wait_time = 6
		2:
			$ThunderTimer.wait_time = 4
		3:
			$ThunderTimer.wait_time = 2
	$ThunderTimer.start()

# When timer is over play sound & set is_thunder ot true
func _on_thunder_timer_timeout() -> void:
	$ThunderSound.play()
	is_thunder = true

# When sound is over set is_thunder to false
func _on_thunder_sound_finished() -> void:
	is_thunder = false
	$LightingTimer.start(randf_range(6, 12))

func _on_child_courage_depleted() -> void:
	%GameOver.show()
	get_tree().paused = true

# Used to pause
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

# Supposedly only leaving the tutoral => lighhouse the lighthouse => end
# next_level is an export value you can change in editor
func _on_exit_level_body_entered(body: Node2D) -> void:
	if body.name == "Child":
		get_tree().change_scene_to_packed(next_level)

# Updates key label
func _on_child_key_updated(key_counter: int) -> void:
	key_label.text = "Key : %s" % key_counter

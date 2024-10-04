extends Node

@onready var child: CharacterBody2D = %Child

@onready var shadow_spawn_position: PathFollow2D = %ShadowSpawnPosition
var shadow_counter := 0
@export var max_shadow := 1
@export var wave_objective := 5
var is_wave_on := false
var shadow_killed := 0

@onready var windows: Array[Node]
var is_thunder := false
@onready var key_label: Label = %KeyLabel

@export var next_level: PackedScene


@onready var music_fader: AnimationPlayer = $MusicFader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	windows = $Level/Windows.get_children()
	$LightingTimer.start(randfn(10, 2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_thunder:
		%Child.thunder_damage(15*delta)
		$Child/Camera2D.apply_shake()


func spawn_shadow() -> void:
	var new_shadow := preload("res://scenes//shadow.tscn").instantiate()
	shadow_spawn_position.progress_ratio = randf()
	new_shadow.global_position = shadow_spawn_position.global_position
	new_shadow.player = child
	shadow_counter += 1
	add_child(new_shadow)
	new_shadow.connect("shadow_defeated", delete_shadow)

func _on_shadow_spawn_timer_timeout() -> void:
	if shadow_counter < max_shadow:
		spawn_shadow()
		$ShadowSpawnTimer.start()
	else:
		$ShadowSpawnTimer.stop()

func delete_shadow(shadow_node: CharacterBody2D) -> void:
	shadow_node.queue_free()
	$ShadowDefeated.play()
	%Child.damage(-7)
	shadow_counter -= 1
	$ShadowSpawnTimer.start()
	if is_wave_on:
		shadow_killed += 1
	if shadow_killed == wave_objective:
		is_wave_on = false
		$ShadowSpawnTimer.set_wait_time(5)
		max_shadow -= 1
		wave_objective += 1
		music_fader.play("fade_into_calm")

func start_wave() -> void:
	shadow_killed = 0
	max_shadow += 3
	is_wave_on = true
	$ShadowSpawnTimer.start(1.5)
	music_fader.play("fade_into_fight")

func _on_window_window_opened() -> void:
	start_wave()

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
				for window in windows:
					window.light_up(1)
					setup_thunder(1)
			elif proba < 0.8:
				for window in windows:
					window.light_up(2)
					setup_thunder(2)
			else:
				for window in windows:
					window.light_up(3)
					setup_thunder(3)
		else:
			$LightingTimer.start(randfn(10, 2))


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
	$LightingTimer.start(randfn(10, 2))

func _on_child_courage_depleted() -> void:
	$GameUI/GameOverUI.show()
	get_tree().paused = true

# Supposedly only leaving the tutoral => lighhouse the lighthouse => end
# next_level is an export value you can change in editor
func _on_exit_level_body_entered(body: Node2D) -> void:
	if body.name == "Child":
		get_tree().change_scene_to_packed(next_level)

# Updates key label
func _on_child_key_updated(key_counter: int) -> void:
	key_label.text = "Key : %s" % key_counter

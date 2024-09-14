extends StaticBody2D

signal window_opened
var is_opened: bool = false
@onready var timer: Timer = $Timer
@export var max_repeat := 3
var repeat := 0

@onready var permanent_light: PointLight2D = $WindowSprite/PermanentLight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Opens the window by changing the sprite
# change the value of is_opened so it can light_up and
# Signal used by lighthouse.gd to start a wave
func open() -> void:
	$WindowSprite.texture = load("res://ressources/textures/opened_window.png")
	emit_signal("window_opened")
	is_opened = true
	$CollisionShape2D.disabled = true
	permanent_light.scale = Vector2(1.6, 1.6)

# Called by lighthouse.gd when a thunder is incoming
# Light up the window according to the current level
func light_up(level: int) -> void:
	if is_opened:
		match level:
			1:
				$LightingSprite.texture = load("res://ressources/textures/lighting_level_1.png")
			2:
				$LightingSprite.texture = load("res://ressources/textures/lighting_level_2.png")
			3:
				$LightingSprite.texture = load("res://ressources/textures/lighting_level_3.png")
		$LightingSprite.show()
		repeat = 0
		timer.wait_time = 0.4
		timer.start()


func _on_timer_timeout() -> void:
	if repeat == max_repeat:
		timer.wait_time = 0.4
		timer.start()
		repeat += 1
	elif repeat > max_repeat:
		$LightingSprite.hide()
		timer.stop()
	else:
		timer.wait_time = 0.15
		if $LightingSprite.visible:
			$LightingSprite.hide()
			timer.wait_time = 0.15
			timer.start()
		else:
			$LightingSprite.show()
			repeat += 1
			timer.wait_time = 0.15
			timer.start()

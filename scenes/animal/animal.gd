extends RigidBody2D
class_name Animal

enum AnimalState {Ready, Drag, Release}

const DRAG_MAX: Vector2 = Vector2(0, 60)
const DRAG_MIN: Vector2 = Vector2(-60, 0)
const IMPULSE_MULT: float = -20.0
const IMPULSE_MAX: float = 1200.0

@onready var arrow: Sprite2D = $Arrow
@onready var stretch_sound: AudioStreamPlayer2D = $StretchSound
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound
@onready var kick_sound: AudioStreamPlayer2D = $KickSound
@onready var debug_label: Label = $DebugLabel

var _state: AnimalState = AnimalState.Ready
var _start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _arrow_scale: float = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if _state == AnimalState.Drag and event.is_action_released("drag"):
		call_deferred("change_state", AnimalState.Release)

func _ready() -> void:
	setup()


func setup() -> void:
	_arrow_scale = arrow.scale.x
	arrow.hide()
	_start = global_position


func _physics_process(_delta: float) -> void:
	update_debug_label()
	update_state()

func die():
	SignalManager.emit_on_animal_died()
	queue_free()

func update_debug_label() -> void:
	var debug_string = "ST: %s SL: %s FR: %s\n" % [
		AnimalState.keys()[_state], sleeping, freeze
	]
	debug_string += "_drag_start: %.1f, %.1f\n" % [_drag_start.x, _drag_start.y]
	debug_string += "_dragged_vector: %.1f, %.1f" % [_dragged_vector.x, _dragged_vector.y]
	
	debug_label.text = debug_string


func update_state() -> void:
	match _state:
		AnimalState.Drag:
			handle_dragging()

func change_state(new_state: AnimalState) -> void:
	if _state == new_state:
		return
	
	_state = new_state
	
	match new_state:
		AnimalState.Drag:
			start_dragging()
		AnimalState.Release:
			start_release()
			

func calc_impulse() -> Vector2:
	return _dragged_vector * IMPULSE_MULT
 
func start_release() -> void:
	SignalManager.emit_on_attempt_made()
	
	arrow.hide()
	launch_sound.play()
	freeze = false
	apply_central_impulse(calc_impulse())


func update_arrow_scale() -> void:
	var imp_len: float = calc_impulse().length()
	var percent: float = clamp(imp_len / IMPULSE_MAX, 0.0, 1.0)
	arrow.scale.x = lerp(_arrow_scale, _arrow_scale * 2, percent)
	arrow.rotation = (_start - position).angle()


func handle_dragging() -> void:
	var new_drag_vect: Vector2 = (get_global_mouse_position() - _drag_start).clamp(
		DRAG_MIN, DRAG_MAX
	)
	
	var diff: Vector2 = new_drag_vect - _dragged_vector
	
	if diff.length() > 0 and stretch_sound.playing == false:
		stretch_sound.play()
	
	_dragged_vector = new_drag_vect
	
	position = _start + _dragged_vector
	
	update_arrow_scale()

func start_dragging() -> void:
	arrow.show()
	_drag_start = get_global_mouse_position()



func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("drag") && _state == AnimalState.Ready:
		change_state(AnimalState.Drag)


func _on_notifier_2d_screen_exited() -> void:
	die()


func _on_sleeping_state_changed() -> void:
	if sleeping == true:
		for body in get_colliding_bodies():
			if body is Cup:
				body.vanish()
	call_deferred("die")


func _on_body_entered(body: Node) -> void:
	if body is Cup and kick_sound.playing == false:
		kick_sound.play()

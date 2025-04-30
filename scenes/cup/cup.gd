extends StaticBody2D
class_name Cup

static var _num_cups: int = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_num_cups += 1

func vanish() -> void:
	animation_player.play("vanish")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	_num_cups -= 1
	SignalManager.emit_on_cup_destroyed(_num_cups)
	queue_free()

extends Control

@onready var attempts_label: Label = $MarginContainer/Main/AttemptsLabel
@onready var music: AudioStreamPlayer = $Music
@onready var complete: VBoxContainer = $MarginContainer/Complete

var _attempts: int = -1

func _ready() -> void:
	on_attempt_made()
	

func _enter_tree() -> void:
	SignalManager.on_attempt_made.connect(on_attempt_made)
	SignalManager.on_cup_destroyed.connect(on_cup_destroyed)


func on_attempt_made() -> void:
	_attempts += 1
	attempts_label.text = "Attempts %s" % _attempts

func on_cup_destroyed(remaining_cups: int):
	if remaining_cups > 0:
		return
	music.play()
	complete.show()

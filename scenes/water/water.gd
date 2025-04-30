extends Area2D

@onready var splash_sound: AudioStreamPlayer2D = $SplashSound

func _on_body_entered(body: Node2D) -> void:
	if body is Animal:
		splash_sound.position = body.position
		splash_sound.play()

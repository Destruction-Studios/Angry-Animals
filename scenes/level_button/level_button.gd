extends TextureButton



func _on_mouse_entered() -> void:
	scale = Vector2(1.15, 1.15)


func _on_mouse_exited() -> void:
	scale = Vector2(1, 1)

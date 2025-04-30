extends Node2D

const ANIMAL = preload("res://scenes/animal/animal.tscn")

@onready var animal_spawn: Marker2D = $AnimalSpawn

func _ready() -> void:
	spawn_animal()
	
func _enter_tree() -> void:
	SignalManager.on_animal_died.connect(on_animal_died)

func spawn_animal() -> void:
	var animal = ANIMAL.instantiate()
	animal.position = animal_spawn.position
	add_child(animal)


func on_animal_died() -> void:
	spawn_animal()

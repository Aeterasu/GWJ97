extends Node2D

@export var particles: Array[CPUParticles2D] = []

var count: int = 0

signal on_all_finished

func fire() -> void:
	for p in particles:
		p.emitting = true
		count += 1

		p.finished.connect(func(): 
			count -= 1
			
			if count <= 0:
				on_all_finished.emit())

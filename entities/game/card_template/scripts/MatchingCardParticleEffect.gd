extends GPUParticles2D

func _ready() -> void:
	emitting = false
	one_shot = true
	finished.connect(queue_free)

func trigger() -> void:
	reparent(get_parent().get_parent())
	emitting = true

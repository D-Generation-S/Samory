extends GPUParticles2D

func _ready():
	emitting = false
	one_shot = true
	finished.connect(queue_free)

func trigger():
	reparent(get_parent().get_parent())
	emitting = true

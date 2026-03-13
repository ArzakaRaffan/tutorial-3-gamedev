extends CharacterBody2D

signal collected

func _on_collect_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if not collected.is_connected(body._on_coin_collected):
			collected.connect(body._on_coin_collected)
		$collect2.play()
		collected.emit()
		$animation.stop()
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
		tween.tween_callback(queue_free)

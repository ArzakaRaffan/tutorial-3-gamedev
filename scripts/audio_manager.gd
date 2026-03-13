extends Node

var audio_stream_player: AudioStreamPlayer

func _ready() -> void:
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = load("res://assets/16 Bit Music.wav")
	audio_stream_player.volume_db = -10.0
	audio_stream_player.play()

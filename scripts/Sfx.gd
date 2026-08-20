extends Node

# Small sound pool. Every clip is a CC0 file from Kenney, see CREDITS.md.

var _players: Array = []
var _sounds: Dictionary = {}
var music: AudioStreamPlayer
var current_track: String = ""

func _ready() -> void:
	for i in range(10):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	music = AudioStreamPlayer.new()
	music.volume_db = -19.0
	add_child(music)

# name is the file in res://audio without the extension, e.g. "music_rock".
func play_music(name: String) -> void:
	if current_track == name and music.playing:
		return
	var path: String = "res://audio/%s.ogg" % name
	if not ResourceLoader.exists(path):
		return
	var s = load(path)
	if s is AudioStreamOggVorbis:
		s.loop = true
	music.stream = s
	music.play()
	current_track = name

func stop_music() -> void:
	music.stop()
	current_track = ""

func play(name: String, volume_db: float = -6.0, pitch: float = 1.0) -> void:
	if not _sounds.has(name):
		var path: String = "res://audio/%s.ogg" % name
		_sounds[name] = load(path) if ResourceLoader.exists(path) else null
	var s = _sounds[name]
	if s == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = s
			p.volume_db = volume_db
			p.pitch_scale = pitch
			p.play()
			return

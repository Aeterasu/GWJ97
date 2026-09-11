class_name SaveManager extends RefCounted

const SAVE_PATH = "user://save"

func save() -> void:
	push_warning("Save functionality is not yet implemented. Too bad!")
	return

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	var dict = {
		"nothing here": "oops!"
	}

	var json = JSON.stringify(dict)
	var result = save_file.store_line(json)

func load() -> void:
	push_warning("Save functionality is not yet implemented. Too bad!")
	return

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	var json = JSON.new()
	var json_string = save_file.get_line()

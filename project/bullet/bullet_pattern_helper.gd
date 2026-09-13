class_name BulletPatternHelper

static func get_angle_to_player(global_pos : Vector2) -> float:
	var player: Player = Game.get_player()

	if not player:
		return 0.0

	return global_pos.angle_to_point(player.global_position)

static func get_arc(angle : float, spread : float, count : int) -> Array[float]:
	var ret: Array[float] = []
	
	var step = (spread * 2.0) / (count - 1)

	if count <= 1:
		return [angle]

	for i in count:
		var angle_mod = -spread + step * i
		var result_angle = angle + angle_mod
		ret.append(result_angle)

	return ret

static func get_circle(angle : float, count : int) -> Array[float]:
	var ret: Array[float] = []

	if count <= 1:
		return [angle]

	var step = TAU / float(count)
	for i in range(count):
		var angle_mod = step * i
		ret.append(angle + angle_mod)
	
	return ret

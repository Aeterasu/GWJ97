class_name Utils

static func round_place(num, places):
	return (round(num * pow(10, places)) / pow(10, places))

static func clamp_vector2_to_circle(target_pos: Vector2, center_pos: Vector2, radius: float) -> Vector2:
	var offset = target_pos - center_pos
	var clamped_offset = offset.limit_length(radius)

	return center_pos + clamped_offset

static func random_point_in_circle(radius: float) -> Vector2:
	var angle : float = randf() * TAU
	var dist : float = sqrt(randf()) * radius
	return Vector2(cos(angle), sin(angle)) * dist

static func circles_overlap(pos1: Vector2, r1: float, pos2: Vector2, r2: float) -> bool:
	var distance = pos1.distance_to(pos2)
	return distance <= (r1 + r2)

static func get_random_square_perimeter_pos(side_length: float) -> Vector2:
	var half_n = side_length / 2.0
	var side = randi() % 4
	var pos = randf_range(-half_n, half_n)
	
	match side:
		0: # top
			return Vector2(pos, -half_n)
		1: # bottom
			return Vector2(pos, half_n)
		2: # left
			return Vector2(-half_n, pos)
		3: # right
			return Vector2(half_n, pos)
		_:
			return Vector2.ZERO

static func get_random_rectangle_perimeter_pos(size: Vector2, center: Vector2 = Vector2.ZERO) -> Vector2:
	var half_x = size.x / 2.0
	var half_y = size.y / 2.0
	
	var perimeter = 2.0 * (size.x + size.y)
	var r = randf() * perimeter
	
	var pos: Vector2
	
	if r < size.x:
		# top
		pos = Vector2(-half_x + r, -half_y)
	elif r < size.x + size.y:
		# right
		pos = Vector2(half_x, -half_y + (r - size.x))
	elif r < 2.0 * size.x + size.y:
		# bottom
		pos = Vector2(half_x - (r - size.x - size.y), half_y)
	else:
		# left
		pos = Vector2(-half_x, half_y - (r - 2.0 * size.x - size.y))
	
	return center + pos

static func format_thousands(value: int) -> String:
	var s = str(value)
	var res = ""
	for i in range(s.length()):
		if i != 0 and (s.length() - i) % 3 == 0:
			res += ","
		res += s[i]
	return res

static func get_ellipse_point(size: Vector2, angle: float) -> Vector2:
	var radius_x = size.x / 2.0
	var radius_y = size.y / 2.0
	
	var x = radius_x * cos(angle)
	var y = radius_y * sin(angle)
	
	return Vector2(x, y)

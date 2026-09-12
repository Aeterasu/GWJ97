class_name BulletSkinManager extends Node

@export var skins: Dictionary[BulletSkin.Type, BulletSkin] = {}

static var instance: BulletSkinManager = null

func _ready() -> void:
	instance = self

static func get_skin_by_type(type: BulletSkin.Type) -> BulletSkin:
	if not instance:
		push_error("Bullet skin could not be resolved...!")
		return null

	if instance.skins.has(type):
		return instance.skins[type]

	return null

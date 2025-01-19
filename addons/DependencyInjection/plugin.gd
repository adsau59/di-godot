@tool
extends EditorPlugin



func _enable_plugin():
	add_autoload_singleton("DI", "res://addons/DependencyInjection/DI.gd")


func _disable_plugin():
	remove_autoload_singleton("DI")

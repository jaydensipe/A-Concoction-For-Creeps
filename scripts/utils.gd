extends Node
class_name Utils

static func print_symbol(symbol: Array) -> void:
	print("%d %d %d" % [symbol[0], symbol[1], symbol[2]])
	print("%d %d %d" % [symbol[3], symbol[4], symbol[5]])
	print("%d %d %d \n" % [symbol[6], symbol[7], symbol[8]])

static func parse_symbol_name_and_tier(symbol_name: StringName) -> PackedStringArray:
	return symbol_name.split(":", true)

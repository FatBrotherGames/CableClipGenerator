@tool
class_name Gc extends Node

const all_parts : Array[PARTS] = [
	PARTS.SPACER,
	PARTS.SPACER_CUT,
	PARTS.PART25,
	PARTS.PART30,
	PARTS.PART35,
	PARTS.PART40,
	PARTS.PART45,
	PARTS.PART50,
	PARTS.PART55,
	PARTS.PART60,
	PARTS.PART65,
	PARTS.PART65_CUT,
	PARTS.PART70,
	PARTS.PART70_CUT,
	PARTS.PART75,
	PARTS.PART75_CUT,
	PARTS.PART80,
	PARTS.PART80_CUT
]

enum PARTS {
	SPACER=0,
	SPACER_CUT=1,
	PART25=2,
	PART30=3,
	PART35=4,
	PART40=5,
	PART45=6,
	PART50=7,
	PART55=8,
	PART60=9,
	PART65=10,
	PART65_CUT=11,
	PART70=12,
	PART70_CUT=13,
	PART75=14,
	PART75_CUT=15,
	PART80=16,
	PART80_CUT=17,
}

static func get_parts_list()->Array[PARTS]: 
	return all_parts

static func get_part_name(id:Gc.PARTS)->String:
	var part_name: String = ""
	match id:
		Gc.PARTS.SPACER:
			part_name = 'Spacer'
		Gc.PARTS.SPACER_CUT:
			part_name = 'Spacer W/ Hole'
		Gc.PARTS.PART25:
			part_name = '2,5mm'
		Gc.PARTS.PART30:
			part_name = '3mm'
		Gc.PARTS.PART35:
			part_name = '3,5mm'
		Gc.PARTS.PART40:
			part_name = '4mm'
		Gc.PARTS.PART45:
			part_name = '4,5mm'
		Gc.PARTS.PART50:
			part_name = '5mm'
		Gc.PARTS.PART55:
			part_name = '5,5mm'
		Gc.PARTS.PART60:
			part_name = '6mm'
		Gc.PARTS.PART65:
			part_name = '6,5mm'
		Gc.PARTS.PART65_CUT:
			part_name = '6,5mm W/ Hole'
		Gc.PARTS.PART70:
			part_name = '7mm'
		Gc.PARTS.PART70_CUT:
			part_name = '7mm W/ Hole'
		Gc.PARTS.PART75:
			part_name = '7,5mm'
		Gc.PARTS.PART75_CUT:
			part_name = '7,5mm W/ Hole'
		Gc.PARTS.PART80:
			part_name = '8mm'
		Gc.PARTS.PART80_CUT:
			part_name = '8mm W/ Hole'
	return part_name

static func get_part_shortcut(id:Gc.PARTS)->String:
	var shortcut: String = ""
	match id:
		Gc.PARTS.SPACER:
			shortcut = 'S'
		Gc.PARTS.SPACER_CUT:
			shortcut = 'So'
		Gc.PARTS.PART25:
			shortcut = '25'
		Gc.PARTS.PART30:
			shortcut = '3'
		Gc.PARTS.PART35:
			shortcut = '35'
		Gc.PARTS.PART40:
			shortcut = '4'
		Gc.PARTS.PART45:
			shortcut = '45'
		Gc.PARTS.PART50:
			shortcut = '5'
		Gc.PARTS.PART55:
			shortcut = '55'
		Gc.PARTS.PART60:
			shortcut = '6'
		Gc.PARTS.PART65:
			shortcut = '65'
		Gc.PARTS.PART65_CUT:
			shortcut = '65o'
		Gc.PARTS.PART70:
			shortcut = '7'
		Gc.PARTS.PART70_CUT:
			shortcut = '7o'
		Gc.PARTS.PART75:
			shortcut = '75'
		Gc.PARTS.PART75_CUT:
			shortcut = '75o'
		Gc.PARTS.PART80:
			shortcut = '8'
		Gc.PARTS.PART80_CUT:
			shortcut = '8o'
	return shortcut

static func get_part_path(id:Gc.PARTS)->String:
	var path: String = ""
	match id:
		Gc.PARTS.SPACER:
			path = 'res://default_clips/new_clips/spacer.stl'
		Gc.PARTS.SPACER_CUT:
			path = 'res://default_clips/precut/spacer.stl'
		Gc.PARTS.PART25:
			path = 'res://default_clips/new_clips/2,5.stl'
		Gc.PARTS.PART30:
			path = 'res://default_clips/new_clips/3.stl'
		Gc.PARTS.PART35:
			path = 'res://default_clips/new_clips/3,5.stl'
		Gc.PARTS.PART40:
			path = 'res://default_clips/new_clips/4.stl'
		Gc.PARTS.PART45:
			path = 'res://default_clips/new_clips/4,5.stl'
		Gc.PARTS.PART50:
			path = 'res://default_clips/new_clips/5.stl'
		Gc.PARTS.PART55:
			path = 'res://default_clips/new_clips/5,5.stl'
		Gc.PARTS.PART60:
			path = 'res://default_clips/new_clips/6.stl'
		Gc.PARTS.PART65:
			path = 'res://default_clips/new_clips/6,5.stl'
		Gc.PARTS.PART65_CUT:
			path = 'res://default_clips/precut/6,5.stl'
		Gc.PARTS.PART70:
			path = 'res://default_clips/new_clips/7.stl'
		Gc.PARTS.PART70_CUT:
			path = 'res://default_clips/precut/7.stl'
		Gc.PARTS.PART75:
			path = 'res://default_clips/new_clips/7,5.stl'
		Gc.PARTS.PART75_CUT:
			path = 'res://default_clips/precut/7,5.stl'
		Gc.PARTS.PART80:
			path = 'res://default_clips/new_clips/8.stl'
		Gc.PARTS.PART80_CUT:
			path = 'res://default_clips/precut/8.stl'
	return path

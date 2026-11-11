/proc/init_erp_sprite_accessories()
	var/list/branches = list(
		/datum/sprite_accessory/penis	 = GLOB.cock_shapes_list,
		/datum/sprite_accessory/testicles = GLOB.balls_shapes_list,
		/datum/sprite_accessory/vagina	= GLOB.vagina_shapes_list,
		/datum/sprite_accessory/breasts   = GLOB.breasts_shapes_list,
		/datum/sprite_accessory/butt	  = GLOB.butt_shapes_list,
		/datum/sprite_accessory/belly	 = GLOB.belly_shapes_list,
		/datum/sprite_accessory/anus	  = GLOB.anus_shapes_list,
	)
	for(var/branch in branches)
		var/list/target_list = branches[branch]
		for(var/path in subtypesof(branch))
			var/datum/sprite_accessory/instance = new path()
			if(!instance.name || !instance.icon_state) // форма без иконки — не форма
				qdel(instance)
				continue
			target_list[lowertext(instance.name)] = instance

///////////////////////////////////////////////////////////////////////////////////////////////////
// ERP PORT Wave 2, ШАГ 1В — базовый класс гениталий на парашном API.
// Кладётся: code/modules/erp/genital_base.dm
//
// Источник: BM genitals.dm (Citadel база + Sandstorm + SPLURT-надстройка), порт по референсу
// (цит_гениталии_база, 710 строк) на органное API Paradise SS220 (organ.dm / organ_internal.dm).
//
//  - у базового /obj/item/organ Пары Insert() НЕТ вовсе (вставка инт-ветки — replaced()/insert()).
//	Наш Insert — СВОЙ proc (обязательно proc/); в internal_organs пишем сами.
//  - базовый remove() сам: чистит internal_organs, шлёт COMSIG_CARBON_LOSE_ORGAN/ORGAN_REMOVED,
//	forceMove на турф владельца, START_PROCESSING (декей на полу), owner = null внутри →
//	моба захватываем ДО ..()
//  - ТИК: handle_organs()/handle_dead_organs() (carbon_life.dm) зовут on_life()/dead_process()
//	у всего internal_organs без тип-фильтра — держим оба стаба. process() НЕ оверрайдим:
//	это SSobj-декей органа вне тела.
//
// СЛОТЫ гениталий — строковые ("penis"/"testicles"/...), конвенция Пары. ORGAN_SLOT_* не портируем.
// Фичи храним в H.genital_features (у Пары нет dna.features); точка выдачи — хук в create_organs.
///////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/organ/genital
	name = "genital"
	parent_organ = "groin"
	color = "#fcccb3"
	w_class = WEIGHT_CLASS_SMALL
	// max_damage/min_broken_damage — парашные дефолты /obj/item/organ/internal (60/30):
	// гениталии можно "задушить" повреждениями до ORGAN_DEAD, как любую инт-органу Пары.

	var/shape
	var/sensitivity = 1
	var/genital_flags = 0 // см. erp_defines.dm
	var/masturbation_verb = "стимулировать"
	var/orgasm_verb = "cumming" //present continous
	var/arousal_verb = "You feel aroused"
	var/unarousal_verb = "You no longer feel aroused"
	var/fluid_transfer_factor = 0 //How much would a partner get in them if they climax using this?
	var/size = 2 //can vary between num or text, just used in icon_state strings
	var/datum/reagent/fluid_id = null // в БМе здесь хранился ПУТЬ реагента — сохраняем конвенцию
	var/fluid_max_volume = 50
	var/fluid_efficiency = 1 // not being used. consider deleting or implementing it.
	var/fluid_rate = CUM_RATE
	var/fluid_mult = 1
	var/last_orgasmed = 0
	var/aroused_state = FALSE //Boolean used in icon_state strings
	var/obj/item/organ/genital/linked_organ
	var/linked_organ_slot //used for linking an apparatus' organ to its other half on update_link().
	var/layer_index = GENITAL_LAYER_INDEX //Order should be very important. FIRST vagina, THEN testicles, THEN penis, as this affects the order they are rendered in.

	// ——— SPLURT ———
	var/max_size = 6
	var/min_size = 1
	var/datum/reagents/climax_fluids
	var/datum/reagent/original_fluid_id
	var/datum/reagent/default_fluid_id
	var/writtentext = ""
	var/list/obj/item/equipment = list()

	// ——— Sandstorm ———
	/// Controls whenever a genital is always accessible
	var/always_accessible = FALSE

	var/slot = null // [ERP PORT] строковый ключ слота ("penis"/"testicles"/"breasts"/...) — ключ GLOB.genital_slot_dna_features

/obj/item/organ/genital/Initialize(mapload, mob/living/carbon/holder, do_update = TRUE)
	. = ..(mapload, holder, null) // НЕ пробрасывать do_update: третья позиция базы — species_override,
	// иначе new type() (do_update=TRUE по умолчанию) даст dna.species = new TRUE → краш
	if(do_update)
		update()

/obj/item/organ/genital/Destroy()
	if(owner)
		remove(owner, TRUE) // снимаем сами; двойной вызов гасится !owner-гвардом remove()
	QDEL_NULL(climax_fluids)
	QDEL_LIST_CONTENTS(equipment)
	if(linked_organ?.linked_organ == src)
		linked_organ.linked_organ = null
	linked_organ = null
	return ..()

// ТИКИ (carbon_life.dm): handle_organs() у живых и handle_dead_organs() у мёртвых обходят
// internal_organs без тип-фильтра и зовут O.on_life() / O.dead_process(). Базовый organ этих
// proc'ов не имеет (они у инт-ветки) — объявляем СВОИ, обязательно с proc/.
// process() НЕ трогаем: это SSobj-декей органа ВНЕ тела (Insert его стопает, базовый
// remove стартует обратно).
/obj/item/organ/genital/proc/on_life()
	return

/obj/item/organ/genital/proc/dead_process()
	return

/datum/character_save/copy_to(mob/living/carbon/human/character)
	. = ..()
	character.init_genital_features(TRUE) // дефолты заново, ПОД финальный гендер
	character.give_genitals(TRUE)		 // clean-ветка: снесёт лишнее (обход по Copy!), додаст недостающее

/mob/living/carbon/human/change_gender(new_gender, update_dna = TRUE)
	. = ..()
	if(.) // родитель вернёт TRUE только при реальной смене; ранний return при том же гендере — null
		// ERP: набор гениталий следует за гендером
		init_genital_features(TRUE)
		give_genitals(TRUE)

// Пара рендерит аугменты инт-органов из update_int_organs (human_update_icons.dm):
// цикл по internal_organs БЕЗ тип-фильтра зовёт O.render() / O.extra_render(). У базового
// organ этих proc'ов нет (только у internal) — заглушки обязательны, иначе undefined proc
// на каждом update_body/regenerate_icons. FALSE = «нечего рисовать» (как у инт-органов
// без аугментов — update_int_organs проверяет результат перед добавлением в оверлеи).
/obj/item/organ/genital/proc/render()
	return FALSE

/obj/item/organ/genital/proc/extra_render()
	return FALSE

/obj/item/organ/genital/proc/set_aroused_state(new_state, cause = "manual toggle")
	if(!(genital_flags & GENITAL_CAN_AROUSE))
		return FALSE
	if(!((HAS_TRAIT(owner, TRAIT_PERMABONER) && !new_state) || (HAS_TRAIT(owner, TRAIT_NEVERBONER) && new_state)))
		aroused_state = new_state
	// BM писал каждый вызов в LOG_EMOTE (30% его game.log); у Пары LOG_EMOTE нет, а
	// автоматика (климакс/ароузал) молчит — пишем в game log только ручные тогглы.
	if(cause == "manual toggle" && owner)
		log_game("ERP: [key_name(owner)] genital arousal [new_state ? "on" : "off"]")
	return aroused_state

/obj/item/organ/genital/proc/update()
	if(QDELETED(src))
		return
	update_size()
	update_appearance_genitals()
	if(genital_flags & UPDATE_OWNER_APPEARANCE && owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.update_genitals()
	if(linked_organ_slot || (linked_organ && !owner))
		update_link()

// Оверхрайдится типами (шаг 2: иконка предмета из plain-*.dmi по shape/size/aroused_state).
// [ERP PORT][FIX rg#10] Атомный /atom/proc/update_appearance(updates=ALL) НЕ перекрываем:
// рендер гениталий живёт в update_appearance_genitals(), иконку самого органа ядро обновляет само.

//exposure and through-clothing code
/mob/living/carbon
	/// Реестр "торчащих" гениталий — кэш для интеракций волны 3 (не итерировать все органы)
	var/list/exposed_genitals = list()

/obj/item/organ/genital/proc/is_exposed()
	if(!owner || genital_flags & (GENITAL_INTERNAL|GENITAL_HIDDEN))
		return FALSE
	if(genital_flags & GENITAL_THROUGH_CLOTHES)
		return TRUE
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/H = owner
	switch(parent_organ)
		if("chest")
			return H.is_chest_exposed()
		if("groin")
			return H.is_groin_exposed()
	return FALSE

/obj/item/organ/genital/proc/toggle_visibility(visibility, update = TRUE)
	genital_flags &= ~(GENITAL_THROUGH_CLOTHES|GENITAL_HIDDEN|GENITAL_UNDIES_HIDDEN)
	if(owner)
		owner.exposed_genitals -= src
	// update = FALSE бывает только при переприменении сохранённых фич (get_features) —
	// это не действие игрока. У БМа такие вызовы тоже писали в лог и давали 29.5% game.log.
	var/log_action = update && owner && owner.client
	switch(visibility)
		if(GEN_VISIBLE_ALWAYS)
			genital_flags |= GENITAL_THROUGH_CLOTHES
			if(owner)
				if(log_action)
					log_game("ERP: [key_name(owner)] exposed their [name]")
				owner.exposed_genitals += src
		if(GEN_VISIBLE_NO_CLOTHES)
			if(log_action)
				log_game("ERP: [key_name(owner)] hid their [name] under clothes")
		if(GEN_VISIBLE_NO_UNDIES)
			genital_flags |= GENITAL_UNDIES_HIDDEN
			if(log_action)
				log_game("ERP: [key_name(owner)] hid their [name] under underwear")
		if(GEN_VISIBLE_NEVER)
			genital_flags |= GENITAL_HIDDEN
			if(log_action)
				log_game("ERP: [key_name(owner)] hid their [name] completely")

	if(update && owner && ishuman(owner)) //recast to use update genitals proc
		var/mob/living/carbon/human/H = owner
		H.update_genitals()

/obj/item/organ/genital/proc/pick_cum_overlay()
	var/result = pick(CUM_STATES_NEUTRAL)

	if(istype(src, /obj/item/organ/genital/penis) || istype(src, /obj/item/organ/genital/testicles))
		var/obj/item/organ/genital/testicles/balls
		if(istype(src, /obj/item/organ/genital/testicles))
			balls = src
		else if(istype(linked_organ, /obj/item/organ/genital/testicles))
			balls = linked_organ

		if(!balls)
			return result

		var/list/states = CUM_STATES
		for(var/i in 1 to states.len) // Делаем список с весом
			var/key = states[i]
			states -= key
			states[key] = 1

		var/const/state_large = "cum_large" // Подменяем вес у state_large в зависимости от размера
		if(state_large in states)
			if(balls.size < BALLS_SIZE_3)
				states -= state_large
			else if(balls.size == BALLS_SIZE_3)
				states[state_large] = 4
			else
				states[state_large] = 10

		result = pickweight(states) // Выбираем state

	return result

// ——— Sandstorm: доступность гениталии независимо от её состояния ———
/obj/item/organ/genital/proc/toggle_accessibility(accessibility)
	always_accessible = isnull(accessibility) ? !always_accessible : accessibility

///////////////////////////////////////////////////////////////////////////////////////////////////
// ВЕРБЫ (IC)
///////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/verb/toggle_genitals()
	set category = "IC"
	set name = "Expose/Hide genitals"
	set desc = "Allows you to toggle which genitals should show through clothes or not."

	if(stat != CONSCIOUS)
		to_chat(usr, SPAN_WARNING("You can't toggle genitals visibility right now..."))
		return

	var/list/genital_list = list()
	for(var/obj/item/organ/genital/G in internal_organs)
		if(!(G.genital_flags & GENITAL_INTERNAL))
			genital_list += G
	if(!length(genital_list)) //There is nothing to expose
		return
	var/obj/item/organ/genital/picked_organ = input(src, "Choose which genitalia to expose/hide", "Expose/Hide genitals") as null|anything in genital_list
	if(!picked_organ || !(picked_organ in internal_organs)) //орган могли удалить, пока открыто меню
		return
	var/picked_visibility = input(src, "Choose visibility setting", "Expose/Hide genitals") as null|anything in GLOB.genitals_visibility_toggles
	if(picked_visibility && (picked_organ in internal_organs))
		picked_organ.toggle_visibility(picked_visibility)

/mob/living/carbon/verb/toggle_arousal_state()
	set category = "IC"
	set name = "Toggle genital arousal"
	set desc = "Allows you to toggle which genitals are showing signs of arousal."
	var/list/genital_list = list()
	for(var/obj/item/organ/genital/G in internal_organs)
		if(G.genital_flags & GENITAL_CAN_AROUSE)
			genital_list += G
	if(!length(genital_list))
		to_chat(src, SPAN_NOTICE("You have nothing to arouse."))
		return
	var/obj/item/organ/genital/picked_organ = input(src, "Choose which genitalia to toggle arousal on", "Set genital arousal", null) as null|anything in genital_list
	if(!picked_organ || !(picked_organ in internal_organs)) // орган могли удалить, пока открыто меню
		return
	if(istype(picked_organ, /obj/item/organ/genital/penis))
		//SPLURT: клетка и импотенция не дают встать вручную
		if(CHECK_BITFIELD(picked_organ.genital_flags, GENITAL_CHASTENED))
			to_chat(src, SPAN_NOTICE("Your [pick(GLOB.dick_nouns)] twitches against its cage!"))
			return
		if(CHECK_BITFIELD(picked_organ.genital_flags, GENITAL_IMPOTENT))
			to_chat(src, SPAN_NOTICE("Your [pick(GLOB.dick_nouns)] simply won't go up!"))
			return
	var/original_state = picked_organ.aroused_state
	picked_organ.set_aroused_state(!picked_organ.aroused_state)
	if(original_state != picked_organ.aroused_state)
		to_chat(src, SPAN_NOTICE("[picked_organ.aroused_state ? picked_organ.arousal_verb : picked_organ.unarousal_verb]."))
	else
		to_chat(src, SPAN_NOTICE("You can't make that genital [picked_organ.aroused_state ? "unaroused" : "aroused"]!"))
	picked_organ.update_appearance_genitals()
	if(ishuman(src))
		var/mob/living/carbon/human/human = src
		human.update_genitals()
	return

///////////////////////////////////////////////////////////////////////////////////////////////////
// РАЗМЕРЫ
///////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/organ/genital/proc/modify_size(modifier, min = -INFINITY, max = INFINITY)
	fluid_max_volume += modifier * 2.5
	fluid_rate += modifier / 10
	return

/obj/item/organ/genital/proc/update_size()
	return

/obj/item/organ/genital/proc/size_to_state()
	return size

/obj/item/organ/genital/proc/update_appearance_genitals()
	if(!owner || owner.stat == DEAD)
		aroused_state = FALSE

///////////////////////////////////////////////////////////////////////////////////////////////////
// ФЛЮИДЫ (SPLURT)
///////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/organ/genital/proc/generate_fluid(datum/reagents/R)
	var/amount = get_fluid()
	R.clear_reagents()
	if(fluid_id)
		R.maximum_volume = fluid_max_volume
		// BM держит в fluid_id ПУТЬ реагента и скармливал TG-шному add_reagent.
		// Пара кладёт реагенты по строковым id → конвертируем initial(path.id).
		R.add_reagent(initial(fluid_id.id), amount)
	else if(linked_organ?.fluid_id)
		R.maximum_volume = linked_organ.fluid_max_volume
		R.add_reagent(initial(linked_organ.fluid_id.id), amount)
	return TRUE

/obj/item/organ/genital/proc/get_fluid()
	if(CHECK_BITFIELD(genital_flags, GENITAL_FUID_PRODUCTION))
		return clamp(fluid_rate * ((world.time - last_orgasmed) / (10 SECONDS)) * fluid_mult, 0, fluid_max_volume)
	else if(linked_organ && CHECK_BITFIELD(linked_organ.genital_flags, GENITAL_FUID_PRODUCTION))
		return linked_organ.get_fluid()
	return 0

/obj/item/organ/genital/proc/get_fluid_fraction()
	if(CHECK_BITFIELD(genital_flags, GENITAL_FUID_PRODUCTION))
		return get_fluid() / fluid_max_volume
	else if(linked_organ && CHECK_BITFIELD(linked_organ.genital_flags, GENITAL_FUID_PRODUCTION))
		return linked_organ.get_fluid_fraction()
	return 0

/obj/item/organ/genital/proc/climax_modify_size(mob/living/partner, obj/item/organ/genital/source_gen)
	return

/obj/item/organ/genital/proc/get_fluid_id()
	if(fluid_id)
		return fluid_id
	else if(linked_organ?.fluid_id)
		return linked_organ.fluid_id
	return

/obj/item/organ/genital/proc/splash_cum(mob/living/carbon/human/orgasming, target_orifice, atom/partner, cumin, genital)
	SIGNAL_HANDLER
	return !(!owner || cumin || genital != src)

/obj/item/organ/genital/proc/get_fluid_name()
	var/datum/reagent/ftype = get_fluid_id()
	if(!ftype) //No milkies??
		return
	var/datum/reagent/R = GLOB.chemical_reagents_list[initial(ftype.id)]
	return R?.name

/obj/item/organ/genital/proc/get_default_fluid()
	if(default_fluid_id)
		return default_fluid_id
	else if(linked_organ?.default_fluid_id)
		return linked_organ.default_fluid_id
	return

/obj/item/organ/genital/proc/set_fluid_id(new_fluidtype)
	if(genital_flags & GENITAL_FUID_PRODUCTION)
		fluid_id = new_fluidtype
	else if(linked_organ?.genital_flags & GENITAL_FUID_PRODUCTION)
		linked_organ?.fluid_id = new_fluidtype

///////////////////////////////////////////////////////////////////////////////////////////////////
// СВЯЗКИ ПАРНЫХ ОРГАНОВ (vagina↔womb, penis↔testicles)
///////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/organ/genital/proc/update_link()
	if(owner)
		if(linked_organ)
			return FALSE
		linked_organ = owner.get_genital_slot(linked_organ_slot) // ← присваивание на месте
		if(linked_organ)
			linked_organ.linked_organ = src
			linked_organ.upon_link()
			upon_link()
			return TRUE
	if(linked_organ)
		linked_organ.linked_organ = null
		linked_organ = null
	return FALSE

//post organ duo making arrangements.
/obj/item/organ/genital/proc/upon_link()
	return

///////////////////////////////////////////////////////////////////////////////////////////////////
// МОСТ ВСТАВКИ/СНЯТИЯ (парашные insert/remove)
///////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/organ/genital/proc/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	if(!istype(M))
		return FALSE
	if(owner && owner != M) // пересадок гениталий нет, но висячее состояние не оставляем
		remove(owner, TRUE)
	// Конвенция Пары (internal/insert): орган "внутри", loc = null. НЕ loc = M,
	// иначе гениталия — предмет в contents моба, и gib/дроп-лупы вывалят её на пол.
	loc = null
	owner = M
	M.internal_organs |= src
	STOP_PROCESSING(SSobj, src) // как у internal/insert: внутри тела SSobj-декей (гермы) не нужен
	return TRUE

/obj/item/organ/genital/remove(mob/living/carbon/M, special = 0)
	if(!owner)
		return src // повторный вызов (qdel → Destroy → базовый Remove уже всё сделал): молча,
	// иначе базовый Remove уронит stack_trace "called without an owner"
	var/mob/living/carbon/C = owner // захватываем ДО ..() — парашный remove обнуляет owner
	C.internal_organs -= src // базовый Remove списками не занимается — чистим сами (сверить по organ.dm)
	. = ..()
	update() // внутри QDELETED-гвард; owner уже null → update_link() отвяжет пару
	C.exposed_genitals -= src
	if(!QDELETED(C) && (genital_flags & UPDATE_OWNER_APPEARANCE) && ishuman(C))
		var/mob/living/carbon/human/H = C
		H.update_genitals()
	return src

///////////////////////////////////////////////////////////////////////////////////////////////////
// ВЫДАЧА ГЕНИТАЛИЙ (give_genitals) + хранилище фич
///////////////////////////////////////////////////////////////////////////////////////////////////

///Тип генитального органа -> признак фич, который его включает. Порядок важен:
///парные органы (вагина/матка, член/яйца) связываются через update_link()
///и рассчитывают на эту последовательность создания.
GLOBAL_LIST_INIT(genital_type_dna_features, list(
	/obj/item/organ/genital/vagina = "has_vag",
	/obj/item/organ/genital/womb = "has_womb",
	/obj/item/organ/genital/testicles = "has_balls",
	/obj/item/organ/genital/breasts = "has_breasts",
	/obj/item/organ/genital/penis = "has_cock",
	/obj/item/organ/genital/butt = "has_butt",
	/obj/item/organ/genital/belly = "has_belly",
	/obj/item/organ/genital/anus = "has_anus",
))

///То же соответствие, но по слоту органа - выводится из genital_type_dna_features.
GLOBAL_LIST_EMPTY(genital_slot_dna_features)

// ШАГ 2: заменить GLOBAL_LIST_EMPTY -> GLOBAL_LIST_INIT с наполнением ПРЯМО ЗДЕСЬ,
// повторное объявление в файлах шага 2 даст duplicate.
GLOBAL_LIST_EMPTY(cock_shapes_list)
GLOBAL_LIST_EMPTY(balls_shapes_list)
GLOBAL_LIST_EMPTY(vagina_shapes_list)
GLOBAL_LIST_EMPTY(breasts_shapes_list)
GLOBAL_LIST_EMPTY(butt_shapes_list)
GLOBAL_LIST_EMPTY(belly_shapes_list)
GLOBAL_LIST_EMPTY(anus_shapes_list)

/proc/get_genital_slot_dna_features()
	if(!length(GLOB.genital_slot_dna_features))
		for(var/obj/item/organ/genital/genital_type as anything in GLOB.genital_type_dna_features)
			GLOB.genital_slot_dna_features[initial(genital_type.slot)] = GLOB.genital_type_dna_features[genital_type]
	return GLOB.genital_slot_dna_features

/mob/living/carbon/human
	/// ERP: хранилище генитальных фич (has_* / *_shape / *_size / *_color / genitals_use_skintone).
	/// У Пары нет dna.features (как у БМа) — держим своё; источник — шаг префов, дефолты ниже.
	var/list/genital_features

/// MVP-дефолты фич по полу. Точка входа для префов (шаг префов заменит наполнение).
/mob/living/carbon/human/proc/init_genital_features(force = FALSE)
	if(genital_features && !force)
		return genital_features
	genital_features = list()
	var/flesh = "fcccb3"
	if(dna?.species?.flesh_color && length(dna.species.flesh_color) >= 7)
		flesh = copytext(dna.species.flesh_color, 2) // храним БЕЗ "#" (так же, как БМ в features)
	var/herm = (gender == PLURAL)
	var/male = (gender == MALE) || herm
	var/female = (gender == FEMALE) || herm
	genital_features["has_anus"] = TRUE
	genital_features["has_butt"] = TRUE
	if(male)
		genital_features["has_cock"] = TRUE
		genital_features["has_balls"] = TRUE
	if(female)
		genital_features["has_vag"] = TRUE
		genital_features["has_womb"] = TRUE
		genital_features["has_breasts"] = TRUE
	for(var/color_key in list("cock_color", "balls_color", "breasts_color", "vag_color", "butt_color", "belly_color", "anus_color"))
		genital_features[color_key] = flesh
	// Формы — ключи датумов шага 2; размеры — числовые, синхронизируем с префами позже.
	genital_features["cock_shape"] = "human"
	genital_features["balls_shape"] = "single"
	genital_features["vag_shape"] = "human"
	genital_features["breasts_shape"] = "pair"
	genital_features["butt_shape"] = "pair"
	genital_features["belly_shape"] = "pair"
	genital_features["anus_shape"] = "donut"
	genital_features["cock_size"] = 2
	genital_features["balls_size"] = 2
	genital_features["breasts_size"] = 2
	genital_features["butt_size"] = 2
	genital_features["belly_size"] = 2
	genital_features["anus_size"] = 2
	return genital_features

/mob/living/carbon/human/proc/give_genitals(clean = FALSE)//clean will remove all pre-existing genitals. proc will then give them any genitals that are enabled in their features
	var/no_genitals = (NOGENITALS in dna.species.species_traits)
	var/list/kept_genitals
	var/list/features = init_genital_features()
	if(clean)
		// Раньше комплект безусловно сносился и создавался заново. Каждый Remove
		// и каждый Insert тянет за собой полный update_genitals() — сносим только то,
		// чего быть не должно, уцелевшим подтягиваем фичи, а перерисовку делаем один раз.
		var/list/slot_features = get_genital_slot_dna_features()
		//обход по копии: qdel органа вычищает его из internal_organs, а правка
		//списка прямо в цикле по нему сдвигает хвост и пропускает следующий элемент
		for(var/obj/item/organ/genital/genital in internal_organs.Copy())
			var/feature_key = slot_features[genital.slot]
			if(no_genitals || !feature_key || !features[feature_key])
				qdel(genital)
				continue
			LAZYADD(kept_genitals, genital)
		if(no_genitals)
			return
	for(var/genital_type in GLOB.genital_type_dna_features)
		if(features[GLOB.genital_type_dna_features[genital_type]])
			give_genital(genital_type)
	if(LAZYLEN(kept_genitals))
		for(var/obj/item/organ/genital/genital as anything in kept_genitals)
			genital.get_features(src)
			genital.update_size()
			genital.update_appearance_genitals()
			if(genital.linked_organ_slot)
				genital.update_link()
	update_genitals()

///ERP: поиск гениталии по строковому слоту. НЕ парашный get_organ_slot(): тот работает
///по /obj/item/organ/internal и internal_organs_slot, а гениталии — базовая ветка organ.
/mob/living/carbon/proc/get_genital_slot(slot)
	for(var/obj/item/organ/genital/G in internal_organs)
		if(G.slot == slot)
			return G
	return null

/mob/living/carbon/human/proc/give_genital(obj/item/organ/genital/G)
	if(!dna || (NOGENITALS in dna.species.species_traits) || get_genital_slot(initial(G.slot)))
		return FALSE
	//Гвард парашного insert(): он стектрейсится, если parent_organ-лимбы нет
	//(создаётся при create_organs с bodyparts_to_omit — не выдаём орган без места)
	if(!get_organ(initial(G.parent_organ)))
		return FALSE
	G = new G(null, src, FALSE) // holder: базовый Initialize склонирует ДНК хозяина в орган
	G.get_features(src)
	G.Insert(src)
	G.update() // Insert не зовёт update(): здесь связи пар и первичная перерисовка
	return G

//proc to give a player their genitals and stuff when they log in
/obj/item/organ/genital/proc/get_features(mob/living/carbon/human/H)
	return // оверхрайдится типами (шаг 2: форма/размер/цвет/флаги из H.genital_features)

///////////////////////////////////////////////////////////////////////////////////////////////////
// РЕНДЕР НА ТЕЛЕ (update_genitals) — MVP
//
// Вырезано из MVP (вернём шагами 2-4): strapon-рендер (игрушки, волна 4), hardlight
// (is_genital_forced_visible/layers_for_apply_effect/GENITAL_EFFECT_LAYER), emissive_copy,
// taur-ветка (тауры вырезаны), keep_genitals_below (шаг 2: парашная одежда),
// TRAIT_HUSK (не подтверждён у Пары), taur/emissive-части стейтов.
// Слои: GENITALS_BEHIND/FRONT/EXPOSED — см. патч misc_defines.dm (ШАГ 1Б).
//
// HAS_TRAIT(X, TRAIT_HUSK) → (X.stat == DEAD). Дефайн не добавляем
///////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/human/proc/update_genitals()
	if(QDELETED(src))
		return
	init_genital_features() // страховка: рендер может дёрнуться раньше give_genitals (insert-мост)
	var/static/list/relevant_layers = list("[GENITALS_BEHIND_LAYER]" = "BEHIND", "[GENITALS_FRONT_LAYER]" = "FRONT")
	var/static/list/layers_num
	if(!layers_num)
		for(var/L in relevant_layers)
			LAZYSET(layers_num, L, text2num(L))
	for(var/L in relevant_layers) //Less hardcode
		remove_overlay(layers_num[L])
	remove_overlay(GENITALS_EXPOSED_LAYER)
	if(!LAZYLEN(internal_organs) || (NOGENITALS in dna.species.species_traits))
		return

	//start scanning for genitals
	var/list/gen_index[GENITAL_LAYER_INDEX_LENGTH]
	var/list/genitals_to_add
	for(var/obj/item/organ/genital/G in internal_organs)
		//SPLURT: клетку не рисуем
		if(CHECK_BITFIELD(G.genital_flags, GENITAL_CHASTENED))
			continue
		if(G.is_exposed())
			LAZYADD(gen_index[G.layer_index], G)
	for(var/L in gen_index)
		if(L) //skip nulls
			LAZYADD(genitals_to_add, L)
	if(!genitals_to_add)
		return

	var/list/fully_exposed
	//start applying overlays
	for(var/layer in relevant_layers)
		var/list/standing = list()
		var/layertext = relevant_layers[layer]
		for(var/A in genitals_to_add)
			var/obj/item/organ/genital/G = A
			var/datum/sprite_accessory/S
			var/size = G.size_to_state()
			switch(G.type)
				if(/obj/item/organ/genital/penis)
					S = GLOB.cock_shapes_list[G.shape]
				if(/obj/item/organ/genital/testicles)
					S = GLOB.balls_shapes_list[G.shape]
				if(/obj/item/organ/genital/vagina)
					S = GLOB.vagina_shapes_list[G.shape]
				if(/obj/item/organ/genital/breasts)
					S = GLOB.breasts_shapes_list[G.shape]
				if(/obj/item/organ/genital/butt)
					S = GLOB.butt_shapes_list[G.shape]
				if(/obj/item/organ/genital/belly)
					S = GLOB.belly_shapes_list[G.shape]
				if(/obj/item/organ/genital/anus)
					S = GLOB.anus_shapes_list[G.shape]

			if(!S || S.icon_state == "none")
				continue
			var/aroused_state = G.aroused_state && S.alt_aroused
			var/mutable_appearance/genital_overlay = mutable_appearance(S.icon, layer = -layers_num[layer])
			if(S.center)
				genital_overlay = center_image(genital_overlay, S.dimension_x, S.dimension_y)
				if(genital_features && genital_features["genitals_use_skintone"])
					// "_s"-стейты — под дефолтные скинтоны, колор не множим
					genital_overlay.icon_state = "[G.slot]_[S.icon_state]_[size]_s_[aroused_state]_[layertext]"
			else
				switch(S.color_src)
					if("cock_color")
						genital_overlay.color = "#[genital_features["cock_color"]]"
					if("balls_color")
						genital_overlay.color = "#[genital_features["balls_color"]]"
					if("breasts_color")
						genital_overlay.color = "#[genital_features["breasts_color"]]"
					if("vag_color")
						genital_overlay.color = "#[genital_features["vag_color"]]"
					if("butt_color")
						genital_overlay.color = "#[genital_features["butt_color"]]"
					if("belly_color")
						genital_overlay.color = "#[genital_features["belly_color"]]"
					if("anus_color")
						genital_overlay.color = "#[genital_features["anus_color"]]"
				genital_overlay.icon_state = "[G.slot]_[S.icon_state]_[size]_[aroused_state]_[layertext]"

			// Check if the flag is on, or the genitals are exposed with no uniform on.
			// (MVP: gear_harness-исключение и keep_genitals_below вырезаны — шаг 2 одежды)
			var/should_promote = (G.genital_flags & GENITAL_THROUGH_CLOTHES) || (G.is_exposed() && !w_uniform)
			// Если гениталия "по-настоящему" открыта — рисуем на GENITALS_EXPOSED_LAYER,
			// чтобы её не перекрывали обувь/рюкзак; иначе остаётся под одеждой.
			if(layers_num[layer] == GENITALS_FRONT_LAYER && should_promote)
				genital_overlay.layer = -GENITALS_EXPOSED_LAYER
				LAZYADD(fully_exposed, genital_overlay)
			else
				standing += genital_overlay

		if(length(standing))
			overlays_standing[layers_num[layer]] = standing

	if(LAZYLEN(fully_exposed))
		overlays_standing[GENITALS_EXPOSED_LAYER] = fully_exposed
		apply_overlay(GENITALS_EXPOSED_LAYER)

	for(var/L in relevant_layers)
		apply_overlay(layers_num[L])

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_GENITALS)

//Checks to see if organs are new on the mob, and changes their colours so that they don't get crazy colours.
//MVP: сохранена только ветка "органов нет вообще" — в БМе else-ветка наполовину мёртвая
//(присваивает значения сами себе). Точка вызова придёт с шагом префов (BM зовёт из лайфа логина).
/mob/living/carbon/human/proc/emergent_genital_call()
	if(!client) // BM: !client.prefs.arousable — парашный преф arousable появится в шаге префов
		return FALSE

	var/organCheck = locate(/obj/item/organ/genital) in internal_organs

	if(!organCheck)
		var/features = init_genital_features()
		//So people who haven't set stuff up don't get rainbow surprises.
		var/mc = dna?.species?.flesh_color ? copytext(dna.species.flesh_color, 2) : "fcccb3"
		features["cock_color"] = mc
		features["breasts_color"] = mc
		features["butt_color"] = mc
		features["balls_color"] = mc
		features["belly_color"] = mc
		features["anus_color"] = mc
	return TRUE

///////////////////////////////////////////////////////////////////////////////////////////////////
// is_*_exposed — РЕКОНСТРУКЦИЯ из _cit_helpers (оригинал утерян с контекстом — сверить при
// перекидке). Логика: зона открыта, если её не прикрывает ни униформа, ни бельё.
// body_parts_covered + биты GROIN/CHEST у Пары есть (сверено в 2-2).
//
//UPD: «Проверено rg#6: бельё строками (underwear/undershirt), пустые ключи Nude/None».
///////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/human/proc/is_groin_exposed()
	if(!w_uniform && !ERP_UNDERWEAR_COVERS(src))
		return TRUE
	if(w_uniform && !(w_uniform.body_parts_covered & LOWER_TORSO) && !ERP_UNDERWEAR_COVERS(src))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/is_chest_exposed()
	if(!w_uniform && !ERP_UNDERSHIRT_COVERS(src))
		return TRUE
	if(w_uniform && !(w_uniform.body_parts_covered & UPPER_TORSO) && !ERP_UNDERSHIRT_COVERS(src))
		return TRUE
	return FALSE

///////////////////////////////////////////////////////////////////////////////////////////////////
// ПАРШИЕ VAR-ДОБАВКИ ДЛЯ ДАТУМОВ ФОРМ
//
// ⚠ Вериф-греп #1: если у Пары НЕТ базового /datum/sprite_accessory (маркинги на строках) —
// этот блок удаляем, а 4 вар-а уезжают в создаваемый нами базовый датум шага 2.
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory
	/// ERP: у органа "встал" и датум имеет альт-стейт
	var/alt_aroused = FALSE
	/// ERP: центрировать широкий спрайт (center_image)
	var/center = FALSE
	var/dimension_x = 32
	var/dimension_y = 32
	/// BM-конвенция: строка-ключ цвета из H.genital_features ("cock_color"/"balls_color"/...).
	/// У парашного базового датума color_src нет — добавляем сами; шаг 2 проставит в датумах форм.
	var/color_src = null

///////////////////////////////////////////////////////////////////////////////////////////////////
// МИНИМАЛЬНЫЕ ТИПЫ — компиляционный скелет Шага 1.
// Тела (update_appearance/on_life/get_features/modify_size/climax_modify_size/флюиды)
// придут в Шаге 2 из BM organs-файлов. ФЛАГИ — MVP-дефолты, СВЕРИТЬ с оригиналом в шаге 2!
///////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/organ/genital/penis
	name = "penis"
	desc = "a male genital"
	slot = "penis"
	organ_tag = "penis"
	parent_organ = "groin"
	layer_index = PENIS_LAYER_INDEX
	linked_organ_slot = "testicles"
	genital_flags = GENITAL_CAN_AROUSE|UPDATE_OWNER_APPEARANCE

/obj/item/organ/genital/testicles
	name = "testicles"
	desc = "a male reproductive organ"
	slot = "testicles"
	organ_tag = "testicles"
	parent_organ = "groin"
	layer_index = TESTICLES_LAYER_INDEX
	linked_organ_slot = "penis"
	genital_flags = GENITAL_FUID_PRODUCTION|UPDATE_OWNER_APPEARANCE

/obj/item/organ/genital/vagina
	name = "vagina"
	desc = "a female genital"
	slot = "vagina"
	organ_tag = "vagina"
	parent_organ = "groin"
	layer_index = VAGINA_LAYER_INDEX
	linked_organ_slot = "womb"
	genital_flags = GENITAL_FUID_PRODUCTION|UPDATE_OWNER_APPEARANCE

/obj/item/organ/genital/womb
	name = "womb"
	desc = "a female reproductive organ"
	slot = "womb"
	organ_tag = "womb"
	parent_organ = "groin"
	// Минимальный порт: резервуар флюида для пары vagina↔womb (беременность вырезана).
	layer_index = VAGINA_LAYER_INDEX
	linked_organ_slot = "vagina"
	genital_flags = GENITAL_INTERNAL|GENITAL_FUID_PRODUCTION

/obj/item/organ/genital/breasts
	name = "breasts"
	desc = "a female chest organ"
	slot = "breasts"
	organ_tag = "breasts"
	parent_organ = "chest"
	layer_index = BREASTS_LAYER_INDEX
	genital_flags = GENITAL_FUID_PRODUCTION|UPDATE_OWNER_APPEARANCE
	fluid_rate = MILK_RATE

/obj/item/organ/genital/butt
	name = "butt"
	desc = "a butt"
	slot = "butt"
	organ_tag = "butt"
	parent_organ = "groin"
	layer_index = BUTT_LAYER_INDEX
	genital_flags = UPDATE_OWNER_APPEARANCE

/obj/item/organ/genital/belly
	name = "belly"
	desc = "a belly"
	slot = "belly"
	organ_tag = "belly"
	parent_organ = "groin"
	layer_index = BELLY_LAYER_INDEX
	genital_flags = UPDATE_OWNER_APPEARANCE

/obj/item/organ/genital/anus
	name = "anus"
	desc = "an anus"
	slot = "anus"
	organ_tag = "anus"
	parent_organ = "groin"
	layer_index = ANUS_LAYER_INDEX
	genital_flags = UPDATE_OWNER_APPEARANCE


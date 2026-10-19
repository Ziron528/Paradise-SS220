#define AREA_EDIT_SELMODE_AREA 1
#define AREA_EDIT_SELMODE_POINT 2

/datum/buildmode_mode/area_edit
	key = "areaedit"
	var/area/stored_area
	var/image/area_image

	/// AREA_EDIT_SELMODE_AREA или AREA_EDIT_SELMODE_POINT
	var/selection_mode = AREA_EDIT_SELMODE_AREA

	/// TRUE когда кнопкой "New Zone" включили режим создания новой зоны
	var/creating_new_zone = FALSE

	/// Первый угол при Area-выделении
	var/turf/pending_corner
	var/image/corner_marker_img
	var/image/hover_marker_img
	var/list/obj/effect/buildmode_line/border_line_objs = list()

	/// Визуальные оверлеи выделенных тайлов (пока нет — визуал идёт через area_image)
	var/list/image/selection_overlay_imgs = list()

	/// Undo/Redo стеки. Каждый элемент — ассоциативный список turf -> area/old_area.
	var/list/action_stack = list()
	var/list/redo_stack = list()

/datum/buildmode_mode/area_edit/New()
	area_image = image('icons/turf/areas.dmi', null, "yellow")
	..()

/datum/buildmode_mode/area_edit/enter_mode(datum/click_intercept/buildmode/BM)
	BM.holder.images += area_image
	BM.holder.screen += new /atom/movable/screen/buildmode/area_edit_undo(BM)
	BM.holder.screen += new /atom/movable/screen/buildmode/area_edit_redo(BM)
	BM.holder.screen += new /atom/movable/screen/buildmode/area_edit_modetoggle(BM)
	BM.holder.screen += new /atom/movable/screen/buildmode/area_edit_newzone(BM)

/datum/buildmode_mode/area_edit/exit_mode(datum/click_intercept/buildmode/BM)
	area_image.loc = null
	BM.holder.images -= area_image
	for(var/atom/movable/screen/buildmode/B in BM.holder.screen)
		if(istype(B, /atom/movable/screen/buildmode/area_edit_undo) || \
			istype(B, /atom/movable/screen/buildmode/area_edit_redo) || \
			istype(B, /atom/movable/screen/buildmode/area_edit_modetoggle) || \
			istype(B, /atom/movable/screen/buildmode/area_edit_newzone))
			BM.holder.screen -= B
			qdel(B)
	// При выходе из БМ — сбрасываем незаконченное создание новой зоны без сохранения
	if(creating_new_zone)
		_cancel_new_zone()
	Reset()
	return ..()

/datum/buildmode_mode/area_edit/Reset()
	stop_area_drag()
	BM.holder.images -= selection_overlay_imgs
	QDEL_LIST_CONTENTS(selection_overlay_imgs)
	selection_overlay_imgs = list()
	action_stack = list()
	redo_stack = list()

/datum/buildmode_mode/area_edit/Destroy()
	QDEL_NULL(area_image)
	return ..()

/datum/buildmode_mode/area_edit/show_help(mob/user)
	to_chat(user, SPAN_NOTICE("***********************************************************"))
	to_chat(user, SPAN_NOTICE("ПКМ по тайлу          = выбрать зону этого тайла как активную"))
	to_chat(user, SPAN_NOTICE("ЛКМ (Area-режим)      = первый клик - угол, второй - прямоугольник"))
	to_chat(user, SPAN_NOTICE("ЛКМ (Point-режим)     = переключить выделение тайла"))
	to_chat(user, SPAN_NOTICE("Кнопка New Zone       = начать создавать новую зону"))
	to_chat(user, SPAN_NOTICE("  В режиме новой зоны: ЛКМ добавляет тайлы, ПКМ — завершить и назвать"))
	to_chat(user, SPAN_NOTICE("Undo/Redo             = отменить/повторить последнее действие"))
	to_chat(user, SPAN_NOTICE("Toggle                = переключить Area/Point режим"))
	to_chat(user, SPAN_NOTICE("***********************************************************"))

/datum/buildmode_mode/area_edit/change_settings(mob/user)
	var/target_path = tgui_input_text(user, "Enter typepath:", "Typepath", "/area")
	var/area_type = text2path(target_path)
	if(!ispath(area_type, /area))
		return
	var/area_name = tgui_input_text(user, "Enter area name:", "Area name", "Area")
	if(!area_name || !length(area_name))
		return
	var/area/new_area = new area_type
	new_area.name = area_name
	stored_area = new_area
	area_image.loc = stored_area
	creating_new_zone = FALSE
	action_stack = list()
	redo_stack = list()
	stop_area_drag()
	to_chat(user, SPAN_NOTICE("Created and selected: [area_name]"))

// ============================================================================
// Клики
// ============================================================================

/datum/buildmode_mode/area_edit/handle_click(user, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/turf/T = get_turf(object)
	if(!T)
		return

	if(right_click)
		if(creating_new_zone)
			// ПКМ в режиме новой зоны — завершить и спросить название
			_finalize_new_zone(user)
		else
			// ПКМ в обычном режиме — выбрать зону тайла
			_select_area(user, T)
		return

	if(!left_click)
		return

	if(!stored_area)
		to_chat(user, SPAN_WARNING("Select an area first (right click on a tile)!"))
		return

	if(pending_corner)
		var/list/turf/rect = block(pending_corner, T)
		stop_area_drag()
		do_action(user, rect)
		return

	if(selection_mode == AREA_EDIT_SELMODE_POINT)
		do_action(user, list(T))
		return

	// Первый угол Area-режима
	pending_corner = T
	if(corner_marker_img)
		BM.holder.images -= corner_marker_img
	var/overlay = creating_new_zone ? "blueOverlay" : "greenOverlay"
	corner_marker_img = image('icons/turf/overlays.dmi', T, overlay)
	corner_marker_img.alpha = 220
	corner_marker_img.layer = ABOVE_ALL_MOB_LAYER
	corner_marker_img.plane = GAME_PLANE
	BM.holder.images += corner_marker_img

/datum/buildmode_mode/area_edit/proc/_select_area(mob/user, turf/T)
	var/area/clicked_area = get_area(T)
	if(!clicked_area)
		return
	// Сбрасываем стек при смене зоны
	stored_area = clicked_area
	area_image.loc = stored_area
	creating_new_zone = FALSE
	action_stack = list()
	redo_stack = list()
	stop_area_drag()
	to_chat(user, SPAN_NOTICE("Now editing: [stored_area.name] ([stored_area.type])"))

/datum/buildmode_mode/area_edit/proc/start_new_zone(mob/user)
	if(creating_new_zone)
		to_chat(user, SPAN_WARNING("Already creating a new zone. Right-click to confirm, or click New Zone again to cancel."))
		// Второе нажатие = отмена
		_cancel_new_zone()
		to_chat(user, SPAN_NOTICE("New zone creation cancelled."))
		return
	creating_new_zone = TRUE
	// Временная area для накопления тайлов
	stored_area = new /area
	stored_area.name = "New Area (pending)"
	area_image.loc = stored_area
	action_stack = list()
	redo_stack = list()
	stop_area_drag()
	to_chat(user, SPAN_NOTICE("New zone mode: click tiles to add them. Right-click anywhere to confirm and name."))

/datum/buildmode_mode/area_edit/proc/_finalize_new_zone(mob/user)
	var/area_name = tgui_input_text(user, "Name for the new area?", "New Area", "")
	if(!area_name || !length(area_name))
		_cancel_new_zone()
		to_chat(user, SPAN_WARNING("New area cancelled, changes reverted."))
		return
	stored_area.name = area_name
	creating_new_zone = FALSE
	to_chat(user, SPAN_NOTICE("New area '[area_name]' created with [length(stored_area.contents)] tiles."))
	// Оставляем её как активную для дальнейшего редактирования

/datum/buildmode_mode/area_edit/proc/_cancel_new_zone()
	if(!stored_area)
		creating_new_zone = FALSE
		return
	// Откатить все тайлы обратно в их старые зоны через стек
	while(length(action_stack))
		var/list/before = action_stack[length(action_stack)]
		action_stack.Cut(length(action_stack), length(action_stack) + 1)
		for(var/turf/T in before)
			var/area/old_area = before[T]
			old_area.contents.Add(T)
	qdel(stored_area)
	stored_area = null
	area_image.loc = null
	creating_new_zone = FALSE
	redo_stack = list()

// ============================================================================
// Выделение / Undo / Redo
// ============================================================================

/datum/buildmode_mode/area_edit/proc/update_hover(turf/T)
	if(!pending_corner || T == pending_corner)
		return
	if(hover_marker_img)
		BM.holder.images -= hover_marker_img
	hover_marker_img = image('icons/turf/overlays.dmi', T, "blueOverlay")
	hover_marker_img.alpha = 180
	hover_marker_img.layer = ABOVE_ALL_MOB_LAYER
	hover_marker_img.plane = GAME_PLANE
	BM.holder.images += hover_marker_img

	QDEL_LIST_CONTENTS(border_line_objs)
	border_line_objs = list()
	var/turf/bend_h = locate(pending_corner.x, T.y, T.z)
	var/turf/bend_v = locate(T.x, pending_corner.y, T.z)
	for(var/endpoints in list(list(bend_h, T), list(bend_v, T), list(pending_corner, bend_h), list(pending_corner, bend_v)))
		var/list/ep = endpoints
		var/obj/effect/buildmode_line/L = new(BM.holder, ep[1], ep[2], "area_edit_border")
		L.I.alpha = 150
		border_line_objs += L

/datum/buildmode_mode/area_edit/proc/stop_area_drag()
	pending_corner = null
	if(corner_marker_img)
		BM.holder.images -= corner_marker_img
		corner_marker_img = null
	if(hover_marker_img)
		BM.holder.images -= hover_marker_img
		hover_marker_img = null
	QDEL_LIST_CONTENTS(border_line_objs)
	border_line_objs = list()

/datum/buildmode_mode/area_edit/proc/toggle_selection_mode(mob/user)
	stop_area_drag()
	selection_mode = (selection_mode == AREA_EDIT_SELMODE_AREA) ? AREA_EDIT_SELMODE_POINT : AREA_EDIT_SELMODE_AREA
	to_chat(user, SPAN_NOTICE("Selection mode: [selection_mode == AREA_EDIT_SELMODE_POINT ? "Point" : "Area"]"))

/datum/buildmode_mode/area_edit/proc/do_action(mob/user, list/turf/tiles)
	if(!stored_area || !length(tiles))
		return

	var/list/before = list()
	for(var/turf/T in tiles)
		before[T] = get_area(T)

	if(creating_new_zone)
		// В режиме новой зоны — всегда добавляем в новую зону
		for(var/turf/T in tiles)
			stored_area.contents.Add(T)
	else
		// В обычном режиме — toggle: наша зона → убрать, чужая → добавить
		for(var/turf/T in tiles)
			if(get_area(T) == stored_area)
				// Убрать из нашей зоны — вернуть в базовый /area/space
				// (не подтип вроде centcomm/nearstation)
				var/area/target = null
				for(var/area/A in world)
					if(A.type == /area/space)
						target = A
						break
				if(!target)
					target = new /area/space
				target.contents.Add(T)
			else
				stored_area.contents.Add(T)

	action_stack += list(before)
	redo_stack = list()

/datum/buildmode_mode/area_edit/proc/undo_action(mob/user)
	if(!length(action_stack))
		to_chat(user, SPAN_WARNING("Nothing to undo."))
		return
	var/list/before = action_stack[length(action_stack)]
	action_stack.Cut(length(action_stack), length(action_stack) + 1)
	var/list/current = list()
	for(var/turf/T in before)
		current[T] = get_area(T)
	for(var/turf/T in before)
		var/area/old_area = before[T]
		old_area.contents.Add(T)
	redo_stack += list(current)

/datum/buildmode_mode/area_edit/proc/redo_action(mob/user)
	if(!length(redo_stack))
		to_chat(user, SPAN_WARNING("Nothing to redo."))
		return
	var/list/after = redo_stack[length(redo_stack)]
	redo_stack.Cut(length(redo_stack), length(redo_stack) + 1)
	var/list/current = list()
	for(var/turf/T in after)
		current[T] = get_area(T)
	for(var/turf/T in after)
		var/area/target_area = after[T]
		target_area.contents.Add(T)
	action_stack += list(current)

// ============================================================================
// Кнопки HUD — добавить в buildmode_hud.dm
// ============================================================================

/atom/movable/screen/buildmode/area_edit_undo
	name = "Undo"
	icon_state = "buildmode_undo"
	screen_loc = "NORTH,WEST+4"

/atom/movable/screen/buildmode/area_edit_undo/Click()
	var/datum/buildmode_mode/area_edit/S = bd.mode
	if(!istype(S))
		return TRUE
	S.undo_action(usr)
	return TRUE

/atom/movable/screen/buildmode/area_edit_redo
	name = "Redo"
	icon_state = "buildmode_redo"
	screen_loc = "NORTH,WEST+5"

/atom/movable/screen/buildmode/area_edit_redo/Click()
	var/datum/buildmode_mode/area_edit/S = bd.mode
	if(!istype(S))
		return TRUE
	S.redo_action(usr)
	return TRUE

/atom/movable/screen/buildmode/area_edit_modetoggle
	name = "Toggle Point/Area"
	icon_state = "buildmode_areapoint"
	screen_loc = "NORTH,WEST+6"

/atom/movable/screen/buildmode/area_edit_modetoggle/Click()
	var/datum/buildmode_mode/area_edit/S = bd.mode
	if(!istype(S))
		return TRUE
	S.toggle_selection_mode(usr)
	update_icon()
	return TRUE

/atom/movable/screen/buildmode/area_edit_newzone
	name = "New Zone"
	icon_state = "buildmode_newzone" // TODO: спрайт
	screen_loc = "NORTH,WEST+7"

/atom/movable/screen/buildmode/area_edit_newzone/Click()
	var/datum/buildmode_mode/area_edit/S = bd.mode
	if(!istype(S))
		return TRUE
	S.start_new_zone(usr)
	update_icon()
	return TRUE

// ============================================================================
// MouseEntered — добавить вызовы в существующие хуки save.dm:
//   buildmode_area_edit_mouse_entered(src)
// рядом с buildmode_save_mouse_entered(src)
// ============================================================================

/proc/buildmode_area_edit_mouse_entered(atom/hovered)
	if(!usr?.client)
		return
	if(istype(hovered, /obj/effect/buildmode_line))
		return
	var/datum/click_intercept/buildmode/BM = usr.client.click_intercept
	if(!istype(BM))
		return
	var/datum/buildmode_mode/area_edit/S = BM.mode
	if(!istype(S) || !S.pending_corner)
		return
	S.update_hover(get_turf(hovered))

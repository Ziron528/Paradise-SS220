// [ERP PORT] Минимальная версия грантера (волна 1).
// Вырезано: гениталии/префы/люст/кастомы/фавориты (волны 2-5).
// Оставлено: верб + CtrlShift-сигнал (без патча ядра не стреляет), мультипанели,
// авто-интеракция, скорость, скрытие, пиксель-шифт.

/mob/verb/interact_with()
    set name = "Interact With"
    set desc = "Perform an interaction with someone."
    set category = "IC"
    set src in view(usr.client)

    var/mob/clicker = usr
    if(!clicker.client)
        return
    var/datum/component/interaction_menu_granter/menu = clicker.GetComponent(/datum/component/interaction_menu_granter)
    if(!menu)
        menu = clicker.AddComponent(/datum/component/interaction_menu_granter)

    // [ERP PORT] ПКМ/Ctrl+Shift: src — конкретная цель ≠ кликер → сразу на неё.
    // Панельный вызов приходит с src == usr → строим выбор вручную.
    // Причина ручного списка: BYOND-chooser ключуется по имени и сворачивает
    // одноимённых (клоны/манекены), а при единственном кандидате не показывает
    // окно вовсе. Ассоц-список с уникальными дисплеями — детерминированный выбор.
    var/mob/living/target = src
    if(!istype(target) || target == clicker)
        // [ERP PORT] Сид себя явный: на этой сборке view(клиент) моб-носителя
        // в перебор не отдаёт (эмпирика: «меня в списке нет»), поэтому кликер
        // добавляется принудительно, остальные — из view(моб).
        var/list/candidates = list(clicker)
        for(var/mob/living/L in view(clicker))
            if(L != clicker)
                candidates += L
        var/list/datum/labels = list()
        for(var/mob/living/L in candidates)
            var/label = L.name
            if(L == clicker)
                label = "[label] (ты)"
            if(labels[label])
                var/n = 2
                while(labels["[label] ([n])"])
                    n++
                label = "[label] ([n])"
            labels[label] = L
        if(!length(labels))
            return
        var/choice = input(clicker, "Кого выбираем?", "Взаимодействие") as null|anything in labels
        if(isnull(choice) || QDELETED(labels[choice]))
            return
        target = labels[choice]

    menu.open_menu(clicker, target)

/datum/component/interaction_menu_granter
    dupe_mode = COMPONENT_DUPE_UNIQUE // [ERP PORT] повторный грант (релогин/верб/VV) не плодит экземпляры
    /// Открытые панели взаимодействия, по одной на цель
    var/list/panels = list()
    var/list/hidden_interactions = list()
    var/mob/living/auto_interaction_target
    var/datum/interaction/currently_active_interaction
    var/next_interaction_time
    var/auto_interaction_pace = 1 SECONDS
    var/pixel_shift_x = 0
    var/pixel_shift_y = 0
    var/pixel_shift_speed = 30
    var/pixel_shift_animating = FALSE

/datum/component/interaction_menu_granter/Initialize(...)
    if(!ismob(parent))
        return COMPONENT_INCOMPATIBLE
    var/mob/parent_mob = parent
    if(!parent_mob.client)
        return COMPONENT_INCOMPATIBLE
    return ..()

/datum/component/interaction_menu_granter/RegisterWithParent()
    . = ..()
    RegisterSignal(parent, COMSIG_MOB_CTRLSHIFTCLICKON, PROC_REF(open_menu))

/datum/component/interaction_menu_granter/Destroy(force, ...)
    STOP_PROCESSING(SSinteractions, src)
    for(var/datum/interaction_menu_panel/panel as anything in panels)
        UnregisterSignal(panel.panel_target, COMSIG_PARENT_QDELETING)
        qdel(panel)
    panels = null
    auto_interaction_target = null
    currently_active_interaction = null
    return ..()

/datum/component/interaction_menu_granter/UnregisterFromParent()
    UnregisterSignal(parent, COMSIG_MOB_CTRLSHIFTCLICKON)
    return ..()

/datum/component/interaction_menu_granter/process(delta_time)
    if(QDELETED(parent) || !isliving(parent))
        auto_interaction_target = null
        currently_active_interaction = null
        return PROCESS_KILL
    if(!currently_active_interaction || QDELETED(auto_interaction_target))
        auto_interaction_target = null
        currently_active_interaction = null
        return PROCESS_KILL
    if(world.time <= next_interaction_time)
        return
    next_interaction_time = world.time + auto_interaction_pace
    var/interaction_key = currently_active_interaction.custom_interaction_key || "[currently_active_interaction.type]"
    var/check_hidden = hidden_interactions && (interaction_key in hidden_interactions) ? !!hidden_interactions[interaction_key] : FALSE
    var/mob/living/granter = parent
    if(!currently_active_interaction.do_action(granter, auto_interaction_target, apply_cooldown = FALSE, is_hidden = check_hidden))
        auto_interaction_target = null
        currently_active_interaction = null
        return PROCESS_KILL
    play_pixel_shift_animation(granter)

/datum/component/interaction_menu_granter/proc/open_menu(mob/living/clicker, mob/living/clicked)
    if(!isliving(clicker))
        return
    if(!istype(clicked))
        return FALSE
    // Don't cancel admin quick spawn
    if(isobserver(clicked) && check_rights(R_SPAWN, FALSE, clicker))
        return FALSE
    open_panel(clicker, clicked)
    return COMSIG_MOB_CANCEL_CLICKON

/datum/component/interaction_menu_granter/proc/open_panel(mob/living/user, mob/living/panel_target)
    if(QDELETED(panel_target))
        return
    for(var/datum/interaction_menu_panel/panel as anything in panels)
        if(panel.panel_target == panel_target)
            panel.ui_interact(user, SStgui.get_open_ui(user, panel))
            return
    var/datum/interaction_menu_panel/panel = new(src, user, panel_target)
    panels += panel
    RegisterSignal(panel_target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
    panel.ui_interact(user)

/datum/component/interaction_menu_granter/proc/on_target_deleted(datum/source, ...)
    for(var/i = length(panels) to 1 step -1)
        var/datum/interaction_menu_panel/panel = panels[i]
        if(panel.panel_target == source)
            panels.Cut(i, i + 1)
            qdel(panel)

/datum/component/interaction_menu_granter/proc/panel_ui_close(datum/interaction_menu_panel/panel, mob/living/user)
    UnregisterSignal(panel.panel_target, COMSIG_PARENT_QDELETING)
    panels -= panel
    qdel(panel)

/datum/component/interaction_menu_granter/ui_state(mob/living/user)
    // Funny admin, don't you dare be the extra funny now.
    // [ERP PORT] У Пары деадмин = holder удалён, отдельного флага нет.
    if(user.client.holder)
        return GLOB.always_state
    if(user == parent)
        return GLOB.conscious_state
    return GLOB.erp_never_state

/datum/component/interaction_menu_granter/ui_interact(mob/living/user, datum/tgui/ui)
    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "MobInteraction", "Interactions")
        ui.open()

/datum/component/interaction_menu_granter/proc/panel_ui_data(datum/interaction_menu_panel/panel, mob/living/user)
    . = list()
    var/mob/living/target = panel?.panel_target
    var/mob/living/self = parent
    if(!self)
        return
    .["isTargetSelf"] = target == self
    .["user"] = self
    .["target"] = target
    .["selfAttributes"] = self.list_interaction_attributes(self)
    // [ERP] Владелец меню как ЦЕЛЬ — важно только для актов "на себя" (USER_IS_TARGET),
    // в волне 1 все они innocent. В волне 3 булевы заменятся на per-акт флаги.
    .["user_is_blacklisted"] = SSinteractions.is_blacklisted(self, INTERACTION_CLASS_INNOCENT)
    if(target == self)
        .["theirAttributes"] = null
        .["target_has_active_player"] = null
        .["max_distance"] = 0
        .["target_is_blacklisted"] = .["user_is_blacklisted"]
    else if(target)
        .["theirAttributes"] = target.list_interaction_attributes(self)
        .["target_has_active_player"] = target.ckey ? (target.client ? 2 : TRUE) : FALSE
        .["max_distance"] = get_dist(self, target)
        // [ERP] Явный INNOCENT, а не "максимальный": если передать LEWD, у лисы
        // посереют ВСЕ кнопки, включая глажку. Lewd-акты в волне 3 будут резаться
        // уже в evaluate_target, а здесь появится per-акт флаг.
        .["target_is_blacklisted"] = SSinteractions.is_blacklisted(target, INTERACTION_CLASS_INNOCENT)
    .["auto_interaction_pace"] = auto_interaction_pace
    .["is_auto_target_self"] = auto_interaction_target == self
    .["auto_interaction_target"] = auto_interaction_target
    .["currently_active_interaction"] = currently_active_interaction?.custom_interaction_key || currently_active_interaction?.type
    var/list/hidden_keys = list()
    for(var/key in hidden_interactions)
        if(hidden_interactions[key])
            hidden_keys += key
    .["hidden_interactions_keys"] = hidden_keys

/datum/component/interaction_menu_granter/ui_data(mob/living/user)
    return panel_ui_data(null, user)

/datum/component/interaction_menu_granter/ui_static_data(mob/living/user)
    . = list()
    var/list/sent_interactions = list()
    for(var/interaction_key in SSinteractions.interactions)
        var/datum/interaction/I = SSinteractions.interactions[interaction_key]
        if(!I.description || (I.interaction_flags & INTERACTION_FLAG_HIDE_IN_PANEL))
            continue
        var/list/interaction = list()
        interaction["key"] = I.type
        interaction["desc"] = I.description
        interaction["type"] = INTERACTION_NORMAL
        interaction["maxDistance"] = I.max_distance
        interaction["interactionFlags"] = I.interaction_flags
        interaction["required_from_user"] = I.required_from_user
        interaction["required_from_target"] = I.required_from_target
        sent_interactions += list(interaction)
    .["interactions"] = sent_interactions
    .["interaction_speeds"] = GLOB.interaction_speeds

/datum/component/interaction_menu_granter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
    . = ..()
    if(.)
        return
    return panel_ui_act(null, action, params)

/datum/component/interaction_menu_granter/proc/panel_ui_act(datum/interaction_menu_panel/panel, action, params)
    var/mob/living/target = panel?.panel_target
    var/mob/living/parent_mob = parent
    switch(action)
        if("toggle_hidden_interaction")
            var/interaction_key = params["interaction"]
            if(!length(interaction_key))
                return
            hidden_interactions[interaction_key] = !hidden_interactions[interaction_key]
            refresh_interaction_panels()
            return TRUE
        if("interact")
            var/interaction_key = params["interaction"]
            var/is_hidden = hidden_interactions && (interaction_key in hidden_interactions) ? !!hidden_interactions[interaction_key] : FALSE
            var/datum/interaction/o = SSinteractions.interactions[interaction_key]
            if(!o)
                return FALSE
            if(o == currently_active_interaction)
                to_chat(parent_mob, SPAN_NOTICE("Включена автоматическая интеракция."))
                return TRUE
            o.do_action(parent_mob, target, TRUE, is_hidden)
            play_pixel_shift_animation(parent_mob)
            return TRUE
        if("interaction_pace")
            var/speed = params["speed"]
            if(!(speed in GLOB.interaction_speeds))
                return FALSE
            auto_interaction_pace = speed
            return TRUE
        if("toggle_auto_interaction")
            var/interaction_key = params["interaction"]
            var/datum/interaction/o = SSinteractions.interactions[interaction_key]
            if(!o || (currently_active_interaction == o && auto_interaction_target == target))
                auto_interaction_target = null
                currently_active_interaction = null
                STOP_PROCESSING(SSinteractions, src)
            else
                auto_interaction_target = target
                currently_active_interaction = o
                START_PROCESSING(SSinteractions, src)
            return TRUE
        if("pixel_shift")
            if(params["type"] == "set")
                pixel_shift_x = clamp(round(text2num(params["dx"])), -ERP_PIXEL_SHIFT_MAX, ERP_PIXEL_SHIFT_MAX)
                pixel_shift_y = clamp(round(text2num(params["dy"])), -ERP_PIXEL_SHIFT_MAX, ERP_PIXEL_SHIFT_MAX)
                pixel_shift_speed = clamp(round(text2num(params["speed"])), 1, 60)
                if(params["play_animation"])
                    play_pixel_shift_animation(parent_mob)
                return TRUE
            if(params["type"] == "reset")
                pixel_shift_x = 0
                pixel_shift_y = 0
                return TRUE
            return FALSE

/datum/component/interaction_menu_granter/proc/refresh_interaction_panels()
    for(var/datum/interaction_menu_panel/panel as anything in panels)
        SStgui.update_uis(panel)
    SStgui.update_uis(src)

/datum/component/interaction_menu_granter/proc/panel_ui_interact(datum/interaction_menu_panel/panel, mob/living/user, datum/tgui/ui)
    ui = SStgui.try_update_ui(user, panel, ui)
    if(!ui)
        ui = new(user, panel, "MobInteraction", "Interactions")
        ui.open()

/datum/component/interaction_menu_granter/proc/play_pixel_shift_animation(mob/living/mob)
    if(!mob || pixel_shift_animating || (!pixel_shift_x && !pixel_shift_y))
        return
    pixel_shift_animating = TRUE
    var/matrix/original = matrix(mob.transform)
    var/matrix/target = matrix(original)
    target.Translate(clamp(pixel_shift_x, -ERP_PIXEL_SHIFT_MAX, ERP_PIXEL_SHIFT_MAX), clamp(pixel_shift_y, -ERP_PIXEL_SHIFT_MAX, ERP_PIXEL_SHIFT_MAX))
    var/distance = abs(pixel_shift_x) + abs(pixel_shift_y)
    var/duration = max(round(distance * 10 / pixel_shift_speed), 2)
    animate(mob, transform = target, time = duration, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
    animate(mob, transform = original, time = duration, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)
    addtimer(CALLBACK(src, PROC_REF(pixel_shift_animation_finished)), duration * 2)

/datum/component/interaction_menu_granter/proc/pixel_shift_animation_finished()
    pixel_shift_animating = FALSE

/// [ERP PORT] Прокси-панель на конкретную цель (мультипанели), как в источнике.
/datum/interaction_menu_panel
    var/datum/component/interaction_menu_granter/granter
    var/mob/living/panel_user
    var/mob/living/panel_target

/datum/interaction_menu_panel/New(datum/component/interaction_menu_granter/new_granter, mob/living/user, mob/living/target)
    granter = new_granter
    panel_user = user
    panel_target = target
    return ..()

/datum/interaction_menu_panel/Destroy(force, ...)
    granter = null
    panel_user = null
    panel_target = null
    return ..()

/datum/interaction_menu_panel/ui_state(mob/living/user)
    if(QDELETED(granter))
        return GLOB.erp_never_state
    return granter.ui_state(user)

/datum/interaction_menu_panel/ui_interact(mob/living/user, datum/tgui/ui)
    if(QDELETED(granter))
        return
    granter.panel_ui_interact(src, user, ui)

/datum/interaction_menu_panel/ui_data(mob/living/user)
    if(QDELETED(granter))
        return list()
    return granter.panel_ui_data(src, user)

/datum/interaction_menu_panel/ui_static_data(mob/living/user)
    if(QDELETED(granter))
        return list()
    return granter.ui_static_data(user)

/datum/interaction_menu_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
    . = ..()
    if(.)
        return
    if(QDELETED(granter))
        return FALSE
    return granter.panel_ui_act(src, action, params)

/datum/interaction_menu_panel/ui_close(mob/living/user)
    if(QDELETED(granter))
        return
    granter.panel_ui_close(src, user)

// [ERP PORT] База интеракций. Источник: modular_sand .../_interaction.dm
// Вырезано: p13, belly/portal-логика, COMSIG_INTERACTION_ADJACENT, special_check (волна 3),
// консент-фильтры звука (волна 5). span_* -> SPAN_*.

/mob/proc/list_interaction_attributes()
    return list()

/mob/living/list_interaction_attributes()
    . = ..()
    if(has_hands())
        . += "...обладает руками."
    if(has_mouth())
        . += "...обладает [mouth_is_free() ? "неприкрытым" : "прикрытым"] ртом."

/datum/interaction

    // [ERP] Класс акта: innocent (гладить, обнимать) или lewd. Влияет на блэклисты SSinteractions.
    var/interaction_class = INTERACTION_CLASS_INNOCENT
    var/description
    var/simple_message
    var/simple_style = "notice"
    var/write_log_user
    var/write_log_target
    var/interaction_sound
    var/interaction_sound_volume = 50
    var/max_distance = 1
    var/interaction_flags = INTERACTION_FLAG_ADJACENT
    var/required_from_user = NONE
    var/required_from_user_exposed = NONE
    var/required_from_user_unexposed = NONE
    var/required_from_target = NONE
    var/required_from_target_exposed = NONE
    var/required_from_target_unexposed = NONE
    var/big_user_target_text = FALSE
    var/message_by_user = TRUE
    var/list/additional_details
    var/hearts_effect = FALSE
    var/custom_interaction_key

	/// [ERP PORT] Префиксы скрытых действий. Источник: modular_bluemoon .../bluemoon_interaction.dm
    var/list/hidden_additional = list(
        "Незаметно, ",
        "Аккуратно, ",
        "Осторожно, ",
        "Неприметно, ",
    )

/datum/interaction/proc/evaluate_user(mob/living/user, silent = TRUE, apply_cooldown = TRUE)
    if(SSinteractions.is_blacklisted(user, interaction_class)) // [ERP] класс акта → lewd-блэклист учитывается
        return FALSE
    if(required_from_user & INTERACTION_REQUIRE_MOUTH)
        if(!user.has_mouth())
            if(!silent)
                to_chat(user, SPAN_WARNING("У вас нет рта."))
            return FALSE
        if(!user.mouth_is_free())
            if(!silent)
                to_chat(user, SPAN_WARNING("Ваш рот прикрыт."))
            return FALSE
    if(required_from_user & INTERACTION_REQUIRE_HANDS)
        if(!user.has_hands())
            if(!silent)
                to_chat(user, SPAN_WARNING("У вас нет рук."))
            return FALSE
    if(COOLDOWN_FINISHED(user, last_interaction_time))
        return TRUE
    if(apply_cooldown)
        return FALSE
    return TRUE

/datum/interaction/proc/evaluate_target(mob/living/user, mob/living/target, silent = TRUE)
    if(SSinteractions.is_blacklisted(target, interaction_class)) // [ERP] класс акта → lewd-блэклист учитывается
        return FALSE
    if(!(interaction_flags & INTERACTION_FLAG_USER_IS_TARGET))
        if(user == target)
            if(!silent)
                to_chat(user, SPAN_WARNING("Ты не можешь так поступить с собой."))
            return FALSE
    if(required_from_target & INTERACTION_REQUIRE_MOUTH)
        if(!target.has_mouth())
            if(!silent)
                to_chat(user, SPAN_WARNING("Цель не имеет рта."))
            return FALSE
        if(!target.mouth_is_free())
            if(!silent)
                to_chat(user, SPAN_WARNING("Рот цели прикрыт."))
            return FALSE
    if(required_from_target & INTERACTION_REQUIRE_HANDS)
        if(!target.has_hands())
            if(!silent)
                to_chat(user, SPAN_WARNING("Цель не имеет рук."))
            return FALSE
    return TRUE

/datum/interaction/proc/do_action(mob/living/user, mob/living/target, apply_cooldown = TRUE, is_hidden = FALSE)
    if(QDELETED(user) || QDELETED(target))
        return FALSE
    if(!(interaction_flags & INTERACTION_FLAG_USER_IS_TARGET) && user == target)
        to_chat(user, SPAN_WARNING("Ты не можешь так поступить с собой."))
        return FALSE
    if(get_dist(user, target) > max_distance)
        to_chat(user, SPAN_WARNING("Слишком далеко."))
        return FALSE
    if((interaction_flags & INTERACTION_FLAG_ADJACENT) && !(user.Adjacent(target) && target.Adjacent(user)))
        to_chat(user, SPAN_WARNING("Ты не достаёшь."))
        return FALSE
    if(!evaluate_user(user, silent = FALSE, apply_cooldown = apply_cooldown))
        return FALSE
    if(!evaluate_target(user, target, silent = FALSE))
        return FALSE
    if(QDELETED(user) || QDELETED(target))
        return FALSE
    if(write_log_user)
        user.create_log(ATTACK_LOG, "[write_log_user] [target]")
    if(write_log_target)
        target.create_log(ATTACK_LOG, "[write_log_target] [user]")
    display_interaction(user, target, is_hidden)
    post_interaction(user, target, apply_cooldown, is_hidden)
    return TRUE

/datum/interaction/proc/display_interaction(mob/living/user, mob/living/target, is_hidden = FALSE)
    if(QDELETED(user) || QDELETED(target))
        return
    if(!simple_message)
        return
    var/use_message = replacetext(simple_message, "USER", big_user_target_text ? "<b>\the [user]</b>" : "\the [user]")
    use_message = replacetext(use_message, "TARGET", big_user_target_text ? "<b>\the [target]</b>" : "\the [target]")
    var/full_message = "<span class='[simple_style]'>[is_hidden ? pick(hidden_additional) : null][capitalize(use_message)]</span>"
    var/mob/source = message_by_user ? user : target
    var/mob/other = message_by_user ? target : user
    if(is_hidden)
        // [ERP PORT] Скрытые действия: видят только участники.
        // В BM это было vision_distance=1 в visible_message; сигнатура парашного
        // visible_message параметр дистанции не гарантирует — фильтруем вручную.
        to_chat(source, full_message)
        if(user != target)
            to_chat(other, full_message)
    else
        source.visible_message(full_message)

/datum/interaction/proc/post_interaction(mob/living/user, mob/living/target, apply_cooldown = TRUE, is_hidden = FALSE)
    if(QDELETED(user) || QDELETED(target))
        return
    if(apply_cooldown)
        COOLDOWN_START(user, last_interaction_time, 0.5 SECONDS)
    if(interaction_sound)
        var/soundfile_to_play = islist(interaction_sound) ? pickweight(interaction_sound) : interaction_sound
        play_interaction_sound(message_by_user ? user : target, soundfile_to_play, is_hidden)
    if(hearts_effect)
        spawn_interaction_heart(user, is_hidden)
        if(user != target)
            spawn_interaction_heart(target, is_hidden)

/datum/interaction/proc/spawn_interaction_heart(mob/living/who, is_hidden)
    if(is_hidden)
        return
    // [ERP PORT] Упрощение до волны 5 (их prefs-механика выбора эффекта).
    // Если temp_visual/heart у Пары нет — заменить на свой temp_visual с иконкой из BM.
    new /obj/effect/temp_visual/heart(get_turf(who))

/datum/interaction/proc/play_interaction_sound(mob/living/sound_source, soundin, is_hidden, volume)
    var/turf/sound_turf = get_turf(sound_source)
    if(!sound_turf)
        return
    if(!isnum(volume))
        volume = interaction_sound_volume
    // [ERP PORT] Без консент-фильтра до волны 5.
    playsound(sound_turf, soundin, volume, 1, is_hidden ? -3 : -1)

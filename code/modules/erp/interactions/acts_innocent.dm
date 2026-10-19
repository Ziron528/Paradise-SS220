// [ERP PORT] Невинные акты (волна 1). Вырезано: p13, кей-пасхалки, BM-квирки headpat.
// cheekkiss звук — через наш GLOB.lewd_kiss_sounds, без консент-фильтра до волны 5.

/datum/interaction/handshake
    description = "Пожать руку."
    simple_message = "USER пожимает руку TARGET."
    required_from_user = INTERACTION_REQUIRE_HANDS
    required_from_target = INTERACTION_REQUIRE_HANDS
    interaction_sound = 'sound/weapons/thudswoosh.ogg'

/datum/interaction/pat
    description = "Похлопать по плечу."
    simple_message = "USER хлопает TARGET по плечу."
    required_from_user = INTERACTION_REQUIRE_HANDS
    interaction_sound = 'sound/weapons/thudswoosh.ogg'

/datum/interaction/cheer
    description = "Подбодрить посвистыванием!"
    required_from_user = INTERACTION_REQUIRE_MOUTH
    simple_message = "USER подбадривает TARGET радостным посвистыванием!"
    interaction_sound = 'code/modules/erp/sound/svist.ogg'
    max_distance = 25
    interaction_flags = NONE

/datum/interaction/highfive
    description = "Дать пять!"
    simple_message = "USER даёт пять TARGET!"
    interaction_sound = 'sound/effects/snap.ogg'
    required_from_user = INTERACTION_REQUIRE_HANDS
    required_from_target = INTERACTION_REQUIRE_HANDS

/datum/interaction/headpat
    description = "Погладить по голове."
    simple_message = "USER гладит TARGET по голове."
    required_from_user = INTERACTION_REQUIRE_HANDS
    interaction_sound = 'sound/weapons/thudswoosh.ogg'

/datum/interaction/fistbump
    description = "Удариться кулачками!"
    simple_message = "USER бьётся кулачком о кулачок TARGET! О да!"
    required_from_user = INTERACTION_REQUIRE_HANDS
    required_from_target = INTERACTION_REQUIRE_HANDS

/datum/interaction/pinkypromise
    description = "Пообещать что-то на мизинчиках."
    simple_message = "USER хватается своим мизинчиком за мизинчик TARGET! Клятва Мизинчиками! Давно пора!"
    required_from_user = INTERACTION_REQUIRE_HANDS
    required_from_target = INTERACTION_REQUIRE_HANDS

/datum/interaction/holdhand
    description = "Взяться за руку."
    simple_message = "USER хватается за руку TARGET."
    required_from_user = INTERACTION_REQUIRE_HANDS
    required_from_target = INTERACTION_REQUIRE_HANDS
    interaction_sound = 'sound/weapons/thudswoosh.ogg'

/datum/interaction/salute
    description = "Исполнить Воинское Приветствие!"
    simple_message = "USER исполняет воинское приветствие при виде TARGET!"
    required_from_user = INTERACTION_REQUIRE_HANDS
    interaction_sound = 'sound/weapons/thudswoosh.ogg'
    max_distance = 25
    interaction_flags = NONE

/datum/interaction/handwave
    description = "Помахать рукой."
    simple_message = "USER приветливо машет TARGET."
    required_from_user = INTERACTION_REQUIRE_HANDS
    max_distance = 25
    interaction_flags = NONE

/datum/interaction/bird
    description = "Показать Средний Палец"
    simple_message = "USER демонстрирует TARGET средний палец!"
    required_from_user = INTERACTION_REQUIRE_HANDS
    interaction_sound = 'code/modules/erp/sound/vineboom.ogg'
    max_distance = 25
    interaction_flags = NONE

/datum/interaction/cheekkiss
    description = "Поцеловать в щёчку."
    required_from_user = INTERACTION_REQUIRE_MOUTH
    simple_message = "USER целует TARGET в щёчку."
    simple_style = "lewd"
    write_log_user = "kissed"
    write_log_target = "was kissed by"
    hearts_effect = TRUE

/datum/interaction/cheekkiss/display_interaction(mob/living/user, mob/living/target, is_hidden)
    var/static/list/possible_messages = list(
        "<b>USER</b> вытянув губы бантиком, целует <b>TARGET</b> в щеку.",
        "<b>USER</b> делает легкое, почти невесомое прикосновение губ к щеке <b>TARGET</b>.",
        "<b>USER</b> губы касаются щеки <b>TARGET</b> и тут же отстраняются.",
        "<b>USER</b> громко с причмокиванием целует <b>TARGET</b> в щеку.",
        "<b>USER</b> тычет губами в щеку <b>TARGET</b> одаривая легким поцелуем.",
    )
    var/use_message = replacetext(pick(possible_messages), "USER", "\the [user]")
    use_message = replacetext(use_message, "TARGET", "\the [target]")
    user.visible_message("<span class='[simple_style]'>[is_hidden ? pick(hidden_additional) : null][capitalize(use_message)]</span>")
    // [ERP PORT] playsound вместо playlewdinteractionsound до волны 5 (консент).
    playsound(get_turf(target), pick(GLOB.lewd_kiss_sounds), 70, TRUE, -1)

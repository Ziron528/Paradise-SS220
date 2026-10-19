// [ERP PORT] Подсистема интеракций. Источник: modular_sand controllers/subsystem/interactions.dm
// Блэклист выверен под мобов Пары; BM-шные pickle/babyKiwi выкинуты.
// Если компилятор не знает SS_BACKGROUND/SS_POST_FIRE_TIMING — убрать строку flags.

PROCESSING_SUBSYSTEM_DEF(interactions)
    name = "Interactions"
    wait = 0.5 SECONDS
    stat_tag = "ACT"
    init_order = INIT_ORDER_INTERACTIONS
    flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
    // [ERP PORT] Блэклист выверен под мобов Пары:
    // - их животные живут в /mob/living/basic (butterfly/mouse/crab/cockroach/snake/lizard/bunny/penguin/possum и пр.)
    // - обезьяна — human-подтип
    // - BM-шные pickle/babyKiwi не существуют, выкинуты
    VAR_PROTECTED/list/blacklisted_mobs = list(
        /mob/dead,
        /mob/camera,
        /mob/living/basic,
        /mob/living/carbon/human/monkey,
        /mob/living/simple_animal/pet,
    )
    VAR_PROTECTED/initialized_blacklist
    var/list/interactions = list()

/datum/controller/subsystem/processing/interactions/Initialize(timeofday)
    prepare_interactions()
    prepare_blacklisted_mobs()
    . = ..()
    to_chat(world, "<b>[LAZYLEN(interactions)] interactions loaded!</b>")
    log_world("ERP interactions loaded: [LAZYLEN(interactions)]")

/datum/controller/subsystem/processing/interactions/stat_entry(msg)
    msg += "|🖐:[LAZYLEN(interactions)]|"
    return ..()

/datum/controller/subsystem/processing/interactions/proc/prepare_interactions()
    QDEL_LIST_ASSOC_VAL(interactions)
    interactions = list()
    for(var/datum/interaction/interaction as anything in subtypesof(/datum/interaction))
        if(!initial(interaction.description))
            continue
        interaction = new interaction()
        interactions["[interaction.type]"] = interaction

/datum/controller/subsystem/processing/interactions/proc/prepare_blacklisted_mobs()
    blacklisted_mobs = typecacheof(blacklisted_mobs)
    initialized_blacklist = TRUE

/datum/controller/subsystem/processing/interactions/proc/is_blacklisted(mob/living/creature)
    if(isliving(creature) && creature.client)
        return FALSE
    if(!creature || !initialized_blacklist)
        return TRUE
    return is_type_in_typecache(creature, blacklisted_mobs)

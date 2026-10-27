// [ERP PORT] Волна 1: мобовые вары льюд-слоя.
// Источник: modular_sand .../lewd_definitions.dm. Процы has_*/is_topless/lust-математика — волны 2-3.

/mob/living
    var/has_penis = FALSE
    var/has_balls = FALSE
    var/has_vagina = FALSE
    var/has_anus = TRUE
    var/has_butt = FALSE
    var/anus_always_accessible = FALSE
    var/has_breasts = FALSE
    var/anus_exposed = FALSE
    var/last_partner
    var/last_orifice
    var/obj/item/organ/last_genital
    var/lastmoan
    var/sexual_potency = 15
    var/lust_tolerance = 100
    var/lastlusttime = 0
    var/lust = 0
    var/multiorgasms = 1
    COOLDOWN_DECLARE(refractory_period)
    COOLDOWN_DECLARE(last_interaction_time)
    // [ERP PORT] В волне 3 сменить тип на /datum/interaction/lewd (нужен доступ к её vars).
    var/datum/interaction/last_lewd_datum
    var/cleartimer

/mob/living/proc/clear_lewd_datum()
    last_partner = null
    last_orifice = null
    last_genital = null
    last_lewd_datum = null

// [ERP PORT] Рандом льюд-статов — один раз на моба, при создании.
// Грант меню здесь НЕ делаем: компонент требует parent.client в момент добавления
// (контракт сэндовского компонента), а клиента на Initialize у моба ещё нет.
// Грант переехал в erp_overrides.dm → /mob/Login.
/mob/living/Initialize(mapload)
    . = ..()
    sexual_potency = rand(10, 25)
    lust_tolerance = rand(25, 200)

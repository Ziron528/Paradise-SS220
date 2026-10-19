// [ERP PORT] Never_Forget ERP — дефайны. Инклюдить ПЕРВЫМ из erp-блока.

/// Порядок инициализации SS. Подбери значение между соседними INIT_ORDER_* из code/__DEFINES/subsystems.dm
#define INIT_ORDER_INTERACTIONS 24

/// [ERP PORT] Максимум пиксель-шифта для авто-анимации интеракций (аналог их MAXIMUM_PIXEL_SHIFT).
#define ERP_PIXEL_SHIFT_MAX 12

// [ERP PORT] У Пары нет GLOB.never_state (в code/modules/tgui/states/ нет never.dm).
// Своё «недостижимое» состояние для чужих панелей.
/datum/ui_state/erp_never

/datum/ui_state/erp_never/can_use_topic(src_object, mob/user)
    return UI_CLOSE

GLOBAL_DATUM_INIT(erp_never_state, /datum/ui_state/erp_never, new)

/// Сигнал меню интеракций. Без опционального ядрового патча не отправляется — работает верб.
#define COMSIG_MOB_CTRLSHIFTCLICKON "mob_ctrlshiftclicked"


#define INTERACTION_NORMAL 0
#define INTERACTION_LEWD 1
#define INTERACTION_EXTREME 2
#define INTERACTION_UNHOLY_HARD 4

#define INTERACTION_EFFECT_HEART "heart"

/// Экспозиция гениталий (тройное значение: FALSE / 2 / 3)
#define HAS_EXPOSED_GENITAL 2
#define HAS_UNEXPOSED_GENITAL 3

/// Требования к участникам
#define INTERACTION_REQUIRE_BOTTOMLESS (1<<0)
#define INTERACTION_REQUIRE_HANDS (1<<1)
#define INTERACTION_REQUIRE_MOUTH (1<<2)
#define INTERACTION_REQUIRE_TOPLESS (1<<3)
#define INTERACTION_REQUIRE_ANUS (1<<4)
#define INTERACTION_REQUIRE_BALLS (1<<5)
#define INTERACTION_REQUIRE_BREASTS (1<<6)
#define INTERACTION_REQUIRE_BELLY (1<<7)
#define INTERACTION_REQUIRE_EARS (1<<8)
#define INTERACTION_REQUIRE_EARSOCKETS (1<<9)
#define INTERACTION_REQUIRE_EYES (1<<10)
#define INTERACTION_REQUIRE_EYESOCKETS (1<<11)
#define INTERACTION_REQUIRE_FEET (1<<12)
#define INTERACTION_REQUIRE_PENIS (1<<13)
#define INTERACTION_REQUIRE_VAGINA (1<<14)
// [ERP PORT] дальше — BM-добавки, пригодятся волне 2-3
#define INTERACTION_REQUIRE_TAIL (1<<15)
#define INTERACTION_REQUIRE_KNOT (1<<16)
#define INTERACTION_REQUIRE_DOUBLE_PENIS (1<<17)
#define INTERACTION_REQUIRE_TK (1<<18)

/// Флаги интеракций
#define INTERACTION_FLAG_ADJACENT (1<<0)
#define INTERACTION_FLAG_EXTREME_CONTENT (1<<1)
#define INTERACTION_FLAG_OOC_CONSENT (1<<2)
#define INTERACTION_FLAG_TARGET_NOT_TIRED (1<<3)
#define INTERACTION_FLAG_USER_IS_TARGET (1<<4)
#define INTERACTION_FLAG_USER_NOT_TIRED (1<<5)
#define INTERACTION_FLAG_UNHOLY_CONTENT (1<<6)
#define INTERACTION_FLAG_REQUIRE_BONDAGE (1<<7)
#define INTERACTION_FLAG_RANGED_CONSENT (1<<8)
#define INTERACTION_FLAG_HIDE_IN_PANEL (1<<9)
#define INTERACTION_FLAG_UNHOLY_HARD (1<<10)

GLOBAL_LIST_INIT(interaction_speeds, list(
    4 SECONDS,
    2 SECONDS,
    1 SECONDS,
    0.8 SECONDS,
    0.5 SECONDS,
))

/// [ERP PORT] Пути переписаны на модуль. Файлы скопировать (список в конце).
GLOBAL_LIST_INIT(lewd_kiss_sounds, list(
    'code/modules/erp/sound/interactions/kiss1.ogg',
    'code/modules/erp/sound/interactions/kiss2.ogg',
    'code/modules/erp/sound/interactions/kiss3.ogg',
    'code/modules/erp/sound/interactions/kiss4.ogg',
    'code/modules/erp/sound/interactions/kiss5.ogg',
))


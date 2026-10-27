// [ERP PORT] Never_Forget ERP — дефайны. Инклюдить ПЕРВЫМ из erp-блока.

/// [ERP PORT] Реестр интеракций. 27..1 заняты ядром (см. subsystems.dm), ставим выше GARBAGE(27).
#define INIT_ORDER_INTERACTIONS 28

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
#define INTERACTION_UNHOLY 3 // [ERP PORT][FIX] промежуточный класс из оригинала: без него пороги >= UNHOLY ловили меньше, чем в источнике
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

// [ERP] Класс интеракции: определяет, какие блэклисты её режут.
// Числа с запасом на будущие классы (is_blacklisted проверяет >= LEWD).
#define INTERACTION_CLASS_INNOCENT 1
#define INTERACTION_CLASS_LEWD 2

///////////////////////////////////////////////////////////////////////////////////////////////////
// ERP-МОДУЛЬ — ДЕФАЙНЫ (волна 2)
// Порт Citadel → Sandstorm → SPLURT → BlueMoon → Paradise SS220
// Оригиналы: citadel_defines.dm, code/__SPLURTCODE/DEFINES/lewd.dm
///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////
// БИТФЛАГ-ХЕЛПЕРЫ
// [ERP PORT][FIX] Проверка rg#4: CHECK_BITFIELD на SS220 не определён,
// а наш genital_base.dm его юзает. Добавляем оригинальные макросы.
///////////////////////
#define CHECK_BITFIELD(variable, flag) (variable & flag)
#define CHECK_MULTIPLE_BITFIELDS(flag) (flag && (flag & (flag - 1)))

///////////////////////
// РЕНДЕР-СЛОИ ГЕНИТАЛИЙ
// Константы GENITALS_BEHIND_LAYER / GENITALS_FRONT_LAYER / GENITALS_EXPOSED_LAYER
// уже вставлены в блок Human Overlays (см. блок лэйеров).
///////////////////////

// Порядок рендера внутри генитального стека (меньший индекс рисуется первым)
#define BUTT_LAYER_INDEX          1
#define ANUS_LAYER_INDEX          2
#define VAGINA_LAYER_INDEX        3
#define TESTICLES_LAYER_INDEX     4
#define GENITAL_LAYER_INDEX       5
#define PENIS_LAYER_INDEX         6
#define BELLY_LAYER_INDEX         7
#define BREASTS_LAYER_INDEX       8
#define GENITAL_LAYER_INDEX_LENGTH 8

///////////////////////
// ФЛАГИ ГЕНИТАЛИЙ
///////////////////////
#define GENITAL_BLACKLISTED     (1<<0)  // не добавлять в GLOB.genitals_list
#define GENITAL_INTERNAL        (1<<1)  // внутренний орган, не рендерится на теле
#define GENITAL_HIDDEN          (1<<2)  // GEN_VISIBLE_NEVER
#define GENITAL_THROUGH_CLOTHES (1<<3)  // GEN_VISIBLE_ALWAYS
#define GENITAL_FUID_PRODUCTION (1<<4)  // сам производит флюид (опечатка "FUID" из оригинала сохранена)
#define CAN_MASTURBATE_WITH     (1<<5)
#define MASTURBATE_LINKED_ORGAN (1<<6)  // передаёт задачу парному органу
#define CAN_CLIMAX_WITH         (1<<7)
#define GENITAL_CAN_AROUSE      (1<<8)
#define GENITAL_UNDIES_HIDDEN   (1<<9)  // GEN_VISIBLE_NO_UNDIES
#define UPDATE_OWNER_APPEARANCE (1<<10)
#define CAN_CUM_INTO            (1<<12)
#define HAS_EQUIPMENT           (1<<13)
#define GENITAL_CHASTENED       (1<<15)
#define GENITAL_IMPOTENT        (1<<16)
#define GENITAL_EDGINGONLY      (1<<17)
#define GENITAL_DISAPPOINTING   (1<<18)
#define GENITAL_OVERSTIM        (1<<19)
#define GENITAL_HYPERSENS       (1<<20)
// GENITAL_CAN_TAUR и GENITAL_CAN_STUFF вырезаны: тауров и беременности на сервере нет

#define isgenital(A) (istype(A, /obj/item/organ/genital))

// [ERP PORT][FIX] Проверка rg#7: на SS220 BODY_ZONE_GROIN не определён.
// Строка "groin" — стандартная зона bodypart (chest/groin/head/...), дефайним у себя.
#define BODY_ZONE_GROIN "groin"

///////////////////////
// РАЗМЕРЫ И ФОРМЫ
///////////////////////
#define DEF_VAGINA_SHAPE        "Human"
#define COCK_SIZE_DEF           6
#define COCK_DIAMETER_RATIO_MAX 0.42
#define COCK_DIAMETER_RATIO_DEF 0.25
#define COCK_DIAMETER_RATIO_MIN 0.15
#define DEF_COCK_SHAPE          "human"
#define BALLS_VOLUME_BASE       25
#define BALLS_VOLUME_MULT       1
#define DEF_BALLS_SHAPE         "Single"
#define BALLS_SIZE_MIN          1
#define BALLS_SIZE_DEF          2
#define BALLS_SIZE_2            3
#define BALLS_SIZE_3            4
#define BALLS_SIZE_MAX          5
#define BREASTS_VOLUME_BASE     50  // 50u на A-купа, 850u на HH
#define BREASTS_VOLUME_MULT     1
#define BREASTS_SIZE_DEF        "c" // lowercase: у спрайтов состояния в нижнем регистре
#define DEF_BREASTS_SHAPE       "Pair"
#define BUTT_SIZE_DEF           0
#define BUTT_SIZE_MAX           8
#define BELLY_SIZE_MIN          0
#define BELLY_SIZE_DEF          1
#define BELLY_SIZE_MAX          10
#define DEF_ANUS_SHAPE          "donut"

///////////////////////
// ФЛЮИДЫ
///////////////////////
#define CUM_RATE            2   // юнитов за 10 секунд
#define CUM_RATE_MULT       1
#define CUM_EFFICIENCY      1
#define MILK_RATE           3
#define MILK_RATE_MULT      1
#define MILK_EFFICIENCY     1
#define GENITAL_INFLATION_THRESHOLD 0.5

///////////////////////
// ВИДИМОСТЬ (строки — UI-контракт GenitalTab/GenitalConfig, ключи ModeToIcon)
///////////////////////
#define GEN_VISIBLE_ALWAYS     "Always visible"
#define GEN_VISIBLE_NO_CLOTHES "Hidden by clothes"
#define GEN_VISIBLE_NO_UNDIES  "Hidden by underwear"
#define GEN_VISIBLE_NEVER      "Always hidden"

/// [ERP PORT] Валидные режимы видимости — проверка при смене режима
GLOBAL_LIST_INIT(genitals_visibility_toggles, list(
    GEN_VISIBLE_ALWAYS,
    GEN_VISIBLE_NO_CLOTHES,
    GEN_VISIBLE_NO_UNDIES,
    GEN_VISIBLE_NEVER,
))

// [ERP PORT][FIX] Проверка rg#6: на SS220 нет w_underwear/w_shirt — бельё хранится строками
// (GLOB.underwear_list / GLOB.undershirt_list, паттерн как у h_style).
// «Пустые» ключи сверить контрольной командой ниже; если другие — править только здесь.
#define ERP_UNDERWEAR_COVERS(H)  ((H.underwear)  && (H.underwear  != "Nude"))
#define ERP_UNDERSHIRT_COVERS(H) ((H.undershirt) && (H.undershirt != "None"))

///////////////////////
// КЛИМАКС / КУМ-ОВЕРЛЕИ
///////////////////////
#define REQUIRE_NONE        0
#define REQUIRE_EXPOSED     1
#define REQUIRE_UNEXPOSED   2
#define REQUIRE_ANY         3

#define CUM_TARGET_NIPPLE   "nipple"
#define CUM_TARGET_URETHRA  "urethra"
#define CUM_TARGET_THIGHS   "thighs"
#define CUM_TARGET_BELLY    "belly"
#define CUM_TARGET_ARMPIT   "armpit"

#define CUM_DMI 'icons/effects/cumoverlay.dmi'
#define CUM_STATES list( \
    "cum_normal", \
    "cum_normal_1", \
    "cum_normal_2", \
    "cum_normal_3", \
    "cum_normal_4", \
    "cum_large" \
)
#define CUM_STATES_NEUTRAL list( \
    "cum_normal_1", \
    "cum_normal_2", \
    "cum_normal_3" \
)

///////////////////////
// ERP-ТРЕЙТЫ (Paradise trait-система строковая)
///////////////////////
#define TRAIT_PERMABONER "erp_permaboner"  // орган не может опуститься
#define TRAIT_NEVERBONER "erp_neverboner"  // орган не может встать
// TRAIT_HUSK НЕ заводим: на SS220 его нет (rg#8) и нечем выставлять — проверки хаска заменяем на stat == DEAD
// TRAIT_MESSY и прочие lewd-трейты — на шаге climax (волна 2, часть 5)

///////////////////////
// CIT-ТОГГЛЫ ИГРОКА (биты prefs)
///////////////////////
#define MEDIHOUND_SLEEPER   (1<<0)
#define EATING_NOISES       (1<<1)
#define DIGESTION_NOISES    (1<<2)
#define BREAST_ENLARGEMENT  (1<<3)
#define PENIS_ENLARGEMENT   (1<<4)
#define FORCED_FEM          (1<<5)
#define FORCED_MASC         (1<<6)
#define HYPNO               (1<<7)
#define NEVER_HYPNO         (1<<8)
#define NO_APHRO            (1<<9)
#define NO_ASS_SLAP         (1<<10)
#define BIMBOFICATION       (1<<11)
#define NO_AUTO_WAG         (1<<12)
#define GENITAL_EXAMINE     (1<<13)
#define VORE_EXAMINE        (1<<14)
#define TRASH_FORCEFEED     (1<<15)
#define BUTT_ENLARGEMENT    (1<<16)
#define BELLY_INFLATION     (1<<17)
#define CHASTITY            (1<<18)
#define STIMULATION         (1<<19)
#define EDGING              (1<<20)
#define NO_DISCO_DANCE      (1<<21)
#define CUM_ONTO            (1<<22)
#define SEX_JITTER          (1<<23) // потолок битфлага
#define TOGGLES_CITADEL 0

///////////////////////
// СИГНАЛЫ
///////////////////////
#define COMSIG_MOB_UPDATE_GENITALS "erp_update_genitals" // отправляется после H.update_genitals()

// [ERP PORT][FIX] у Пары species_traits — список строк (как NO_HAIR/NOT_SELECTABLE), не битфилд
#define NOGENITALS		"no_genitals"

/// Синонимы для IC-сообщений; юзают toggle_arousal_state и интеракции волны 1
GLOBAL_LIST_INIT(dick_nouns, list("cock", "dick", "shaft", "member", "pecker"))

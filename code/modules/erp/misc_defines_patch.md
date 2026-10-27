///////////////////////////////////////////////////////////////////////////////////////////////////
// ERP PORT Wave 2, ШАГ 1Б — патч слоёв Пары.
// Файл: code/__defines/misc_defines.dm (блок #define *_LAYER, строки ~191-244)
//
// НИКАКИЕ ДРУГИЕ ФАЙЛЫ НЕ ПРАВЯТСЯ: потребители (organ_internal.dm, augments_arms.dm,
// human_update_icons.dm) используют имена констант, а не числа — греп от 22.10 закрыл
// полный список потребителей.
//
// ПРАВИЛО РЕНУМЕРАЦИИ:
//   1) ВСЕ константы слоя со значением 39..53 получают +3 (становятся 42..56).
//      Значения 38 и ниже (ID_LAYER 38, HANDS_LAYER 37, ... HAND_INTORGAN_LAYER 33, ... 1) НЕ ТРОГАЮТСЯ.
//   2) Вставить три новые константы в указанных местах.
//   3) TOTAL_LAYERS 53 -> 56.
//
// РЕЗУЛЬТАТ (верх блока; после правки):
//   #define EYES_OVERLAY_LAYER          56   // было 53
//   ...
//   #define MARKINGS_LAYER              47   // было 44
//   #define INTORGAN_LAYER              46   // было 43
//   #define GENITALS_BEHIND_LAYER       45   // НОВЫЙ: гениталии за бельём (видны голым, под бельём)
//   #define UNDERWEAR_LAYER             44   // было 42
//   #define GENITALS_FRONT_LAYER        43   // НОВЫЙ: гениталии перед бельём, под формой
//   #define MUTATIONS_LAYER             42   // было 41
//   #define H_DAMAGE_LAYER              41   // было 40
//   #define UNIFORM_LAYER               40   // было 39
//   #define GENITALS_EXPOSED_LAYER      39   // НОВЫЙ: гениталии поверх одежды (always visible / exposed)
//   #define ID_LAYER                    38   // БЕЗ ИЗМЕНЕНИЙ
//   ... всё, что ниже 38, остаётся как было ...
//   #define TOTAL_LAYERS                56   // было 53
//
// ПОЧЕМУ ТАК: направление маппинга подтверждено внутренними парами (uniform 39 идёт ПЕРЕД
// underwear 42, fire 2 / frozen 1 спереди) — МЕНЬШАЯ константа = БЛИЖЕ К ЗРИТЕЛЮ, оверлеи
// применяются с layer = -КОНСТАНТА.
//
// ГРАДАЦИЯ ВИДИМОСТИ (как у БМа):
//   GEN_VISIBLE_NEVER      -> флаг GENITAL_HIDDEN          -> не рисуется вовсе
//   GEN_VISIBLE_NO_UNDIES  -> флаг GENITAL_UNDIES_HIDDEN   -> GENITALS_BEHIND_LAYER (45, за бельём)
//   обычная видимость      -> GENITALS_FRONT_LAYER (43, перед бельём, под формой)
//   GEN_VISIBLE_ALWAYS     -> флаг GENITAL_THROUGH_CLOTHES -> поверх одежды
//   голое тело + no uniform-> промоция в GENITALS_EXPOSED_LAYER (39, поверх всего ниже ID)
///////////////////////////////////////////////////////////////////////////////////////////////////

/// ПРОВЕРКА ПОСЛЕ ПАТЧА (PowerShell, в репо Пары):
/// rg -n "GENITALS_BEHIND_LAYER|GENITALS_FRONT_LAYER|GENITALS_EXPOSED_LAYER|TOTAL_LAYERS" code/__defines/misc_defines.dm
/// Ожидаем: 45 / 43 / 39 / 56 и отсутствие дублей значений в блоке.

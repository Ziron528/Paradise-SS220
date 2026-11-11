///////////////////////////////////////////////////////////////////////////////////////////////////
// ERP PORT Wave 2, ШАГ 2 — рендер-датумы форм гениталий.
// Кладётся: code/modules/erp/genitals_sprite_accessories.dm
// ВАЖНО: файл кладётся ОДИН раз. Дубли датумов мержатся тихо, а дубли var/proc валят
//        компиляцию (ru_name / build_genital_shapes_list).
// ИНИТ списков форм: code/modules/erp/erp_global_lists.dm → init_erp_sprite_accessories(),
//        вызывается 1 строкой из makeDatumRefLists() (code/__HELPERS/global_lists.dm).
//
// Источник: BlueMoon code/modules/arousal/genitals_sprite_accessories.dm (Citadel-база + BM/сплюртовские
// добаки) + modular_bluemoon/code/modules/arousal/centipede_genitals.dm. Порт на базовый датум Пары.
//
// КЛЮЧИ GLOB-листов форм — lowertext(D.name): "human", "pair", "donut", ...
//  - совпадает с дефолтами init_genital_features() в genital_base.dm;
//  - ключом по icon_state нельзя: у *_new-вариантов icon_state совпадает с базовыми (разные dmi).
//
// Верифицировано по парашной базе (code/modules/mob/new_player/sprite_accessories/sprite_accessories.dm):
//  - alt_aroused / center / dimension_x,y / color_src / feat_taur / taur_* УЖЕ есть
//    в /datum/sprite_accessory → блок дублей из genital_base.dm УДАЛЁН (иначе duplicate var);
//  - НО mutant_part_string в базе Пары НЕТ (подтверждено компилятором) → объявлен здесь
//    на /datum/sprite_accessory (ключ принудительной видимости hardlight — волна 3);
//  - ru_name у Пары нет → объявлен своим варом на каждом родителе ветки;
//  - color_src у Пары дефолтится в MUTCOLORS (число) — наш рендер-свитч по строкам его игнорирует,
//    все ветки задают color_src строкой явно.
//
// ДОБАВКИ ПОРТА (в источнике отсутствовали):
//  - /none-варианты для всех 7 веток (нужны будущим префам: "выключить" орган; рендер их скипает
//    по icon_state == "none");
//  - ru_name для непенисных веток (в BM они были только у penis).
// ВЫРЕЗАНО: taur_icon/taur_dimension_x (иконка taur_penis_onmob.dmi не копируется — тауров нет).
//
// ФАЙЛЫ ИКОНОК — скопировать руками (пути источника → модуль):
//  'icons/obj/genitals/penis_onmob.dmi'                    → 'code/modules/erp/icons/genitals/penis_onmob.dmi'
//  'modular_bluemoon/icons/obj/genitals/penis_onmob.dmi'   → 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'  (ПЕРЕИМЕНОВАТЬ!)
//  'modular_splurt/icons/obj/genitals/teshari_penis.dmi'   → 'code/modules/erp/icons/genitals/teshari_penis.dmi'
//  'icons/obj/genitals/testicles_onmob.dmi'                → 'code/modules/erp/icons/genitals/testicles_onmob.dmi'
//  'modular_bluemoon/icons/obj/genitals/testicles_onmob.dmi' → 'code/modules/erp/icons/genitals/testicles_onmob_new.dmi' (ПЕРЕИМЕНОВАТЬ!)
//  'icons/obj/genitals/vagina_onmob.dmi'                   → 'code/modules/erp/icons/genitals/vagina_onmob.dmi'
//  'icons/obj/genitals/breasts_onmob.dmi'                  → 'code/modules/erp/icons/genitals/breasts_onmob.dmi'
//  'modular_splurt/icons/obj/genitals/butt_onmob.dmi'      → 'code/modules/erp/icons/genitals/butt_onmob.dmi'
//  'modular_splurt/icons/obj/genitals/belly_onmob.dmi'     → 'code/modules/erp/icons/genitals/belly_onmob.dmi'
//  'modular_splurt/icons/obj/genitals/anus_onmob.dmi'      → 'code/modules/erp/icons/genitals/anus_onmob.dmi'
//  'modular_bluemoon/icons/obj/genitals/centipede_genitals.dmi' → 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
//
// Формат стейтов: "[slot]_[форма]_[размер]_[эрекция]_[слой]", напр. penis_human_4_1_FRONT;
// "_s"-варианты — под дефолтные скины, используются только при S.center (наши датумы не юзают).
///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// ERP PORT: у парашной базы /datum/sprite_accessory НЕТ mutant_part_string (в BM-базе есть).
// Наши ветки задают его (ключ принудительной видимости hardlight — волна 3) → объявляем сами.
///////////////////////////////////////////////////////////////////////////////////////////////////
/datum/sprite_accessory
        var/mutant_part_string = ""

///////////////////////////////////////////////////////////////////////////////////////////////////
// ЧЛЕНЫ
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/penis
	icon = 'code/modules/erp/icons/genitals/penis_onmob.dmi'
	name = "penis"                  // превью-имя ветки; без icon_state → в списки форм не попадает
	color_src = "cock_color"
	alt_aroused = TRUE
	var/ru_name = "человеческий"
	mutant_part_string = "penis"

/datum/sprite_accessory/penis/none
	icon_state = "none"
	name = "None"
	ru_name = "нет"

/datum/sprite_accessory/penis/human
	icon_state = "human"
	name = "Human"
	ru_name = "человеческий"

/datum/sprite_accessory/penis/human_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "human"
	name = "Human (New Tg)"
	ru_name = "человеческий"

/datum/sprite_accessory/penis/knotted
	icon_state = "knotted"
	name = "Knotted"
	ru_name = "узловатый"

/datum/sprite_accessory/penis/knotted_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "knotted"
	name = "Knotted (New Tg)"
	ru_name = "узловатый"

/datum/sprite_accessory/penis/flared
	icon_state = "flared"
	name = "Flared"
	ru_name = "конический"

/datum/sprite_accessory/penis/flared_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "flared"
	name = "Flared (New Tg)"
	ru_name = "конический"

/datum/sprite_accessory/penis/barbknot
	icon_state = "barbknot"
	name = "Barbed, Knotted"
	ru_name = "узловатый и немного колючий"

/datum/sprite_accessory/penis/barbknot_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "barbknot"
	name = "Barbed, Knotted (New Tg)"
	ru_name = "узловатый и немного колючий"

/datum/sprite_accessory/penis/tapered
	icon_state = "tapered"
	name = "Tapered"
	ru_name = "утончённый к концу"

/datum/sprite_accessory/penis/tapered_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "tapered"
	name = "Tapered (New Tg)"
	ru_name = "утончённый к концу"

/datum/sprite_accessory/penis/taperedbarbed
	icon_state = "barbtapered"
	name = "Tapered Barbed"
	ru_name = "утончённый к концу и покрыт шипами"

/datum/sprite_accessory/penis/tentacle
	icon_state = "tentacle"
	name = "Tentacled"
	ru_name = "тентяклевидный"

/datum/sprite_accessory/penis/tentacle_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "tentacle"
	name = "Tentacled (New Tg)"
	ru_name = "тентяклевидный"

/datum/sprite_accessory/penis/hemi
	icon_state = "hemi"
	name = "Hemi"
	ru_name = "двойной"

/datum/sprite_accessory/penis/hemi_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "hemi"
	name = "Hemi (New Tg)"
	ru_name = "двойной"

/datum/sprite_accessory/penis/hemiknot
	icon_state = "hemiknot"
	name = "Knotted Hemi"
	ru_name = "двойной узловатый"

/datum/sprite_accessory/penis/hemiknot_new
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "hemiknot"
	name = "Knotted Hemi (New Tg)"
	ru_name = "двойной узловатый"

/datum/sprite_accessory/penis/barbedhemiknot
	icon_state = "bhemiknot"
	name = "Barbed, Knotted Hemi"
	ru_name = "двойной, узловатый и немного колючий"

/datum/sprite_accessory/penis/thick
	icon_state = "thick"
	name = "Thick"
	ru_name = "обрезанный" // BM-квирк источника ("Thick" → «обрезанный»), сохранён для 1:1

/datum/sprite_accessory/penis/nondescript
	icon = 'code/modules/erp/icons/genitals/penis_onmob_new.dmi'
	icon_state = "nondescript"
	name = "Thick (New Tg)"
	ru_name = "обрезанный"

/datum/sprite_accessory/penis/teshari
	icon = 'code/modules/erp/icons/genitals/teshari_penis.dmi'
	icon_state = "taperedteshari"
	name = "Teshari (For Teshari Only)"
	ru_name = "тешарьский"

///////////////////////////////////////////////////////////////////////////////////////////////////
// ЯЙЦА
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/testicles
	icon = 'code/modules/erp/icons/genitals/testicles_onmob.dmi'
	icon_state = "testicle"
	name = "testicle"
	color_src = "balls_color"
	var/ru_name = "обычные"
	mutant_part_string = "testicles"

/datum/sprite_accessory/testicles/none
	icon_state = "none"
	name = "None"
	ru_name = "нет"

/datum/sprite_accessory/testicles/single
	icon_state = "single"
	name = "Single" //Single as "single pair", for clarity.
	ru_name = "одиночные"

/datum/sprite_accessory/testicles/single_new
	icon = 'code/modules/erp/icons/genitals/testicles_onmob_new.dmi'
	icon_state = "single"
	name = "Single (New Tg)"
	ru_name = "одиночные"

/datum/sprite_accessory/testicles/hidden
	icon_state = "hidden"
	name = "Hidden"
	ru_name = "скрытые"

/datum/sprite_accessory/testicles/sheath
	icon_state = "sheath"
	name = "Sheath"
	ru_name = "в ножнах"

/datum/sprite_accessory/testicles/sheath_new
	icon = 'code/modules/erp/icons/genitals/testicles_onmob_new.dmi'
	icon_state = "sheath"
	name = "Sheath (New Tg)"
	ru_name = "в ножнах"

///////////////////////////////////////////////////////////////////////////////////////////////////
// ВАГИНЫ
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/vagina
	icon = 'code/modules/erp/icons/genitals/vagina_onmob.dmi'
	name = "vagina"
	color_src = "vag_color"
	alt_aroused = TRUE
	var/ru_name = "человеческая"
	mutant_part_string = "vagina"

/datum/sprite_accessory/vagina/none
	icon_state = "none"
	name = "None"
	ru_name = "нет"

/datum/sprite_accessory/vagina/human
	icon_state = "human"
	name = "Human"
	ru_name = "человеческая"

/datum/sprite_accessory/vagina/tentacles
	icon_state = "tentacle"
	name = "Tentacle"
	ru_name = "тентаклевидная"

/datum/sprite_accessory/vagina/dentata
	icon_state = "dentata"
	name = "Dentata"
	ru_name = "зубастая"

/datum/sprite_accessory/vagina/hairy //BlueMoon Edit
	icon_state = "hairy"
	name = "Hairy"
	ru_name = "волосистая"

/datum/sprite_accessory/vagina/spade //BlueMoon Edit
	icon_state = "spade"
	name = "Spade"
	ru_name = "лопаткообразная"

/datum/sprite_accessory/vagina/furred //BlueMoon Edit
	icon_state = "furred"
	name = "Furred"
	ru_name = "пушистая"

/datum/sprite_accessory/vagina/gaping
	icon_state = "gaping"
	name = "Gaping"
	ru_name = "раскрытая"

/datum/sprite_accessory/vagina/cloaca
	name = "cloaca"
	icon_state = "cloaca"
	ru_name = "клоака"

/datum/sprite_accessory/vagina/feline //BlueMoon Edit
	icon_state = "furred"
	name = "Feline"
	ru_name = "кошачья"

/datum/sprite_accessory/vagina/equine
	icon_state = "gaping"
	name = "Equine"
	ru_name = "конская"

/datum/sprite_accessory/vagina/cervine
	icon_state = "gaping"
	name = "Cervine"
	ru_name = "оленья"

/datum/sprite_accessory/vagina/sergal
	icon_state = "sergal"
	name = "Sergal"
	ru_name = "сергальская"

/datum/sprite_accessory/vagina/hemi
	icon_state = "human"
	name = "Hemi"
	ru_name = "двойная"

/datum/sprite_accessory/vagina/puffy
	icon_state = "hairy"
	name = "Puffy"
	ru_name = "пухленькая"

/datum/sprite_accessory/vagina/teshari //BlueMoon Edit
	name = "Cloaca (For Teshari Only)"
	icon_state = "cloaca_teshari"
	ru_name = "клоака (только для тешари)"

///////////////////////////////////////////////////////////////////////////////////////////////////
// ГРУДЬ
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/breasts
	icon = 'code/modules/erp/icons/genitals/breasts_onmob.dmi'
	name = "breasts"
	color_src = "breasts_color"
	var/ru_name = "пара"
	mutant_part_string = "breasts"

/datum/sprite_accessory/breasts/none
	icon_state = "none"
	name = "None"
	ru_name = "нет"

/datum/sprite_accessory/breasts/pair
	icon_state = "pair"
	name = "Pair"
	ru_name = "пара"

/datum/sprite_accessory/breasts/quad
	icon_state = "quad"
	name = "Quad"
	ru_name = "четыре"

/datum/sprite_accessory/breasts/sextuple
	icon_state = "sextuple"
	name = "Sextuple"
	ru_name = "шесть"

///////////////////////////////////////////////////////////////////////////////////////////////////
// ЗАД
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/butt
	icon = 'code/modules/erp/icons/genitals/butt_onmob.dmi'
	icon_state = "butt"
	name = "butt"
	color_src = "butt_color"
	var/ru_name = "обычная"
	mutant_part_string = "butt"

/datum/sprite_accessory/butt/none
	icon_state = "none"
	name = "None"
	ru_name = "нет"

/datum/sprite_accessory/butt/pair
	icon_state = "pair"
	name = "Pair"
	ru_name = "пара"

///////////////////////////////////////////////////////////////////////////////////////////////////
// ЖИВОТ
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/belly
	icon = 'code/modules/erp/icons/genitals/belly_onmob.dmi'
	icon_state = "belly"
	name = "belly"
	color_src = "belly_color"
	var/ru_name = "обычный"
	mutant_part_string = "belly"

/datum/sprite_accessory/belly/none
	icon_state = "none"
	name = "None"
	ru_name = "нет"

//there literally shouldn't be any other belly types besides one because that'd be weird,
//this is just here to keep things consistent for the genital system. (комментарий источника)
/datum/sprite_accessory/belly/pair
	icon_state = "pair"
	name = "Pair"
	ru_name = "пара"

///////////////////////////////////////////////////////////////////////////////////////////////////
// АНУС
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/anus
	icon = 'code/modules/erp/icons/genitals/anus_onmob.dmi'
	icon_state = "anus"
	name = "anus"
	color_src = "anus_color"
	var/ru_name = "обычный"

/datum/sprite_accessory/anus/none
	icon_state = "none"
	name = "None"
	ru_name = "нет"

/datum/sprite_accessory/anus/donut
	icon_state = DEF_ANUS_SHAPE
	name = DEF_ANUS_SHAPE
	ru_name = "бублик"

/datum/sprite_accessory/anus/squished
	icon_state = "squished"
	name = "squished"
	ru_name = "сжатый"

///////////////////////////////////////////////////////////////////////////////////////////////////
// ЦЕНТИПЕДЬИ (источник: modular_bluemoon/.../centipede_genitals.dm)
///////////////////////////////////////////////////////////////////////////////////////////////////

/datum/sprite_accessory/penis/pede_segmented
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_segmented"
	name = "Segmented (Chitin)"
	ru_name = "сегментированный"

/datum/sprite_accessory/penis/pede_hemi
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_hemi"
	name = "Hemi Segmented (Chitin)"
	ru_name = "двойной сегментированный"

/datum/sprite_accessory/penis/pede_knotted
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_knotted"
	name = "Knotted Segmented (Chitin)"
	ru_name = "узловатый сегментированный"

/datum/sprite_accessory/penis/pede_barbed
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_barbed"
	name = "Barbed Segmented (Chitin)"
	ru_name = "сегментированный с шипами"

/datum/sprite_accessory/penis/pede_ovipositor
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_ovipositor"
	name = "Ovipositor (Chitin)"
	ru_name = "яйцеклад"

/datum/sprite_accessory/penis/pede_hose
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_hose"
	name = "Corrugated Tube (Chitin)"
	ru_name = "гофрированная трубка"

/datum/sprite_accessory/testicles/pede_plated
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_plated"
	name = "Plated Sheath (Chitin)"
	ru_name = "хитиновые в ножнах"

/datum/sprite_accessory/testicles/pede_plated_pair
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_plated_pair"
	name = "Plated Pair (Chitin)"
	ru_name = "хитиновая пара"

/datum/sprite_accessory/testicles/pede_slit
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_slit"
	name = "Genital Slit (Chitin)"
	ru_name = "хитиновая щель"

/datum/sprite_accessory/vagina/pede_chitin
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_chitin"
	name = "Chitin"
	ru_name = "хитиновая"

/datum/sprite_accessory/vagina/pede_chitin_slit
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_chitin_slit"
	name = "Chitin Slit"
	ru_name = "хитиновая щель"

/datum/sprite_accessory/vagina/pede_mandibled
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_mandibled"
	name = "Mandibled (Chitin)"
	ru_name = "с мандибулами"

/datum/sprite_accessory/vagina/pede_ovipore
	icon = 'code/modules/erp/icons/genitals/centipede_genitals.dmi'
	icon_state = "pede_ovipore"
	name = "Ovipore (Chitin)"
	ru_name = "яйцепровод"

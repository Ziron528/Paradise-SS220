// [ERP PORT] Проверки конечностей. bodyparts_by_name — парашный доступ.
// foot_is_free/is_barefoot — волна 3.

/mob/living/proc/has_hands()
    return TRUE

/mob/living/proc/has_mouth()
    return TRUE

/mob/living/proc/mouth_is_free()
    return TRUE

/mob/living/silicon/robot/mouth_is_free()
    return TRUE

/mob/living/carbon/human/has_mouth()
    return bodyparts_by_name[BODY_ZONE_HEAD]

/mob/living/carbon/human/has_hands()
    return bodyparts_by_name[BODY_ZONE_L_ARM] || bodyparts_by_name[BODY_ZONE_R_ARM]

/mob/living/carbon/human/mouth_is_free()
    return !is_muzzled()

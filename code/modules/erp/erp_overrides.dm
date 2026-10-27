// [ERP PORT] Лёгкие оверрайды ядра.
// Дисциплина: оверрайд существующего proc пишется БЕЗ ключевого слова proc/
// (с proc/ компилятор считает это новым объявлением → duplicate definition).
// Внутри — ..() для сохранения цепочки, маркер [ERP].

/mob/CtrlShiftClickOn(atom/A, modifiers)
    var/signal_result = SEND_SIGNAL(src, COMSIG_MOB_CTRLSHIFTCLICKON, A)
    if(signal_result & COMSIG_MOB_CANCEL_CLICKON)
        return signal_result
    return ..()

// [ERP PORT] Грант меню интеракций — на логин, когда клиент уже на мобе.
// iscarbon = воронка волн (сейчас карбоны; силиконы/фауна — волна 3, расширится условие).
// Гард src.client — от гонки "клиент отвалился посреди логина" (в BM login.dm это
// прямо комментировано: клиент может быть удалён посреди выполнения логина).
// Гард GetComponent — от повторного гранта при релогине/перепосадке клиента.
/mob/Login()
    . = ..()
    if(iscarbon(src) && src.client && !GetComponent(/datum/component/interaction_menu_granter)) // [ERP PORT]
        AddComponent(/datum/component/interaction_menu_granter)

// [ERP PORT] Снятие грантера на логауте — 1:1 с оригиналом (modular_sand mob.dm).
// Не косметика: process() не проверяет клиента, и SSD-моб с активным авто-режимом
// продолжал бы тикать do_action по цели. qdel(null) безопасен — у мобов без
// компонента GetComponent вернёт null.
/mob/Logout()
    qdel(GetComponent(/datum/component/interaction_menu_granter)) // [ERP PORT]
    . = ..()

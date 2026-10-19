// [ERP PORT] Лёгкие оверрайды ядра.
// Дисциплина: оверрайд существующего proc пишется БЕЗ ключевого слова proc/
// (с proc/ компилятор считает это новым объявлением → duplicate definition).
// Внутри — ..() для сохранения цепочки, маркер [ERP].

/mob/CtrlShiftClickOn(atom/A, modifiers)
    var/signal_result = SEND_SIGNAL(src, COMSIG_MOB_CTRLSHIFTCLICKON, A)
    if(signal_result & COMSIG_MOB_CANCEL_CLICKON)
        return signal_result
    return ..()

/*
/client/verb/debug_pixel_state(mob/M in view(10))
    set name = "Pixel Debug"
    set category = "Debug"
    if(!istype(M)) return
    var/matrix/Mx = M.transform
    if(!Mx) Mx = matrix()
    to_chat(src, "[M] @ ([M.x],[M.y],[M.z])")
    to_chat(src, "pixel_x=[M.pixel_x] | pixel_y=[M.pixel_y] | glide_size=[M.glide_size]")
    to_chat(src, "transform: a=[Mx.a] b=[Mx.b] c=[Mx.c] d=[Mx.d] e=[Mx.e] f=[Mx.f]")
    to_chat(src, "appearance_flags=[M.appearance_flags]")

/client/verb/reset_pixel_state(mob/M in view(10))
    set name = "Pixel Reset"
    set category = "Debug"
    if(!istype(M)) return
    M.pixel_x = 0
    M.pixel_y = 0
    M.transform = null
    M.appearance_flags |= KEEP_TOGETHER
    to_chat(src, "[M] reset — смотри на спрайт.")

/client/verb/scan_subpixel_mobs()
    set name = "Scan Subpixel"
    set category = "Debug"
    for(var/mob/M in view(12, mob))
        var/flags = ""
        if(M.pixel_x != round(M.pixel_x)) flags += " px=[M.pixel_x]"
        if(M.pixel_y != round(M.pixel_y)) flags += " py=[M.pixel_y]"
        var/matrix/Mx = M.transform
        if(!Mx) Mx = matrix()
        if(Mx.a != 1 || Mx.d != 1 || Mx.b != 0 || Mx.c != 0) flags += " TR(a=[Mx.a],d=[Mx.d],b=[Mx.b],c=[Mx.c])"
        if(Mx.e != round(Mx.e) || Mx.f != round(Mx.f)) flags += " TRfrac(e=[Mx.e],f=[Mx.f])"
        if(flags) to_chat(src, "[M] ([M.x],[M.y],[M.z]):[flags]")
    to_chat(src, "scan done")
*/

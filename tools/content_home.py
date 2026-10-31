# -*- coding: utf-8 -*-
"""Başkanın evi (halk kızınca cam kırılır) ve baca filtresi görünürlüğü metinleri. apply_content.py içe aktarır."""
from content_texts import add

add("LM_BASKAN_EVI", "Başkanın Evi", "Mayor's House")
add("HOME_PLATE", "BAŞKAN", "MAYOR")
add("HOME_GRAFFITI", "İSTİFA!", "RESIGN!")
add("FIELD_HINT_HOME", "[Boşluk] Evine bak", "[Space] Check your house")
add("FIELD_FILTER_COUNT", "Filtreli fabrika: %d / %d", "Filtered factories: %d / %d")
add("BIGMAP_FACTORIES", "Filtreli fabrika: %d / %d", "Filtered factories: %d / %d")

add("HOME_MOB_ARRIVED", "Halk evinin önünde toplandı! Pankartlar havada.", "A crowd gathered outside your house! Banners up.")
add("HOME_WINDOW_BROKE", "ŞANGIR! Evinin camı kırıldı!", "CRASH! Your window is broken!")
add("HOME_COLD", "Kırık camlardan rüzgâr giriyor: sabah üşüdün (-%d enerji).", "Wind howls through the broken windows: you woke up cold (-%d energy).")
add("HOME_NEIGHBORS_FIXED", "Komşular gece camlarını bedavaya taktı. Halk seni seviyor.", "Neighbors fixed your windows for free overnight. The people like you.")
add("HOME_FIXED", "Camlar yerine takıldı.", "Windows fixed.")
add("HOME_FIX", "Camcıyı çağır", "Call the glazier")
add("HOME_LEAVE", "Kalsın", "Leave it")
add("HOME_BROKEN", "Başkanım, %d cam kırık! Camcı Necati her cam için 4 Kasa istiyor, toplam %d. Rüzgâr da içeri giriyor, sabahları üşüyoruz.",
    "Mayor, %d windows are broken! Glazier Necati wants 4 coins per window, %d in total. Wind blows in too, we wake up cold.")
add("HOME_BROKEN_MOB", "Başkanım, %d cam kırık! Camcı, dışarıdaki kalabalığa rağmen gelmeye razı, ama tehlike zammı yok: toplam %d Kasa.",
    "Mayor, %d windows are broken! The glazier will come despite the crowd outside, no danger pay: %d coins in total.")
add("HOME_FINE", "Evimiz sağlam, camlar yerinde. Halk bizi sevdiği sürece böyle kalır, değil mi?", "The house is fine, windows intact. They stay that way as long as people like us, right?")
add("HOME_FINE_ANGRY", "Camlar sağlam ama dışarıda pankartlar var. Ben arka kapıdan çıkmayı öneririm.", "Windows are fine but there are banners outside. I suggest the back door.")
add("HOME_FINE_HAPPY", "Komşular kapıya çiçek bırakmış! Halk seni sevince ev bile gülümsüyor.", "Neighbors left flowers at the door! When the people love you, even the house smiles.")
add("HOME_GIFT", "Komşular kapıya bir sepet bırakmış: içinde kek, bir çam tohumu ve 'Sağ ol Başkan' yazan bir not. (+1 tohum, +3 Kasa)",
    "Neighbors left a basket at the door: cake, a pine seed and a note saying 'Thanks, Mayor'. (+1 seed, +3 coins)")

PROTEST = [
    ("İSTİFA!", "RESIGN!"), ("Ekmek yok!", "No bread!"), ("Ağaç yemeyiz!", "Can't eat trees!"), ("Karnımız aç!", "We're hungry!"),
    ("Camı da kırarız!", "We'll break more!"), ("Halk burada!", "The people are here!"), ("Parayı ver!", "Pay up!"),
    ("Biz de seçmenmişiz!", "We vote too!"), ("Kedi yerine bize bak!", "Look at us, not cats!"), ("Başkan dışarı!", "Mayor, come out!"),
]
for i, (tr_, en) in enumerate(PROTEST, 1):
    add("PROTEST_%d" % i, tr_, en)

add("NEWS_WINDOWS", "Başkanın evinin %d camı kırıldı", "%d windows of the Mayor's house were broken")
HEAD = [
    ("Başkanın Camı Şangır: Halk Sesini Duyurdu", "Mayor's Window Goes Crash: The People Have Spoken"),
    ("Camcı Necati Zengin Oldu, Başkan Üşüdü", "Glazier Necati Gets Rich, Mayor Gets Cold"),
    ("Taş Atan Çok, Cam Tamir Eden Yok", "Many Throw Stones, Few Fix Windows"),
    ("Başkanın Evi Hedef Tahtası Oldu: İsabet Oranı Yüksek", "Mayor's House Becomes Dartboard: Accuracy Is High"),
    ("Halk: 'Cam Kırmak İstemezdik, Elimiz Kaydı'", "People: 'We Didn't Mean To, Our Hands Slipped'"),
]
for i, (tr_, en) in enumerate(HEAD, 1):
    add("NEWS_E_WINDOW_%d" % i, tr_, en)

# Duraklatma menüsü
add("PAUSE_TITLE", "Duraklatıldı", "Paused")
add("PAUSE_RESUME", "Devam Et", "Resume")
add("PAUSE_MENU", "Ana Menü", "Main Menu")
add("PAUSE_CONFIRM", "Emin misin? İlerleme kaybolur", "Sure? Progress will be lost")
add("PAUSE_HINT", "Esc: devam", "Esc: resume")

add("SETTINGS_FULLSCREEN", "Tam ekran (F11)", "Fullscreen (F11)")

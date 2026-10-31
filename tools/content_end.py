# -*- coding: utf-8 -*-
"""Outro (kazanma), kaybetme ekranı ve yeni intro metinleri. tools/apply_content.py işler."""

from content_texts import add

# ====================================================================== Ortak etiketler
add("END_PAPER_CARD", "Karne", "Report Card")
add("END_PAPER_ISSUE", "Özel Baskı", "Special Edition")
add("END_PAPER_ISSUE_WIN", "Son Baskı", "Final Edition")
add("END_RETRY", "Tekrar Dene", "Try Again")
add("END_REPLAY", "Yeniden Oyna", "Play Again")
add("END_STAMP_LOSS", "ÖZEL SAYI", "SPECIAL ISSUE")
add("END_STAMP_WIN", "SON SAYI", "FINAL ISSUE")
add("END_NOTE_DAYS", "Görev süresi: %d gün", "Time in office: %d days")
add("END_NOTE_TREES", "Dikilen ağaç: %d", "Trees planted: %d")
add("END_NOTE_TRASH", "Toplanan çöp: %d", "Trash collected: %d")
add("END_NOTE_FAVORS", "Yardım edilen komşu: %d", "Neighbors helped: %d")
add("END_NOTE_GROVES", "Oluşan koru: %d", "Groves formed: %d")
add("END_CAP_LOSS", "Karatepe, son görüntü.", "Karatepe, final photograph.")
add("END_CAP_WIN", "Karatepe, tepeden, bu sabah.", "Karatepe from above, this morning.")

# ====================================================================== Kaybetme: manşetler (3 varyant), alt başlık, neden, Yiğithan'ın sözü
_LOSS = {
    "BANKRUPT": {
        "hl": [("Kasa Boş, Başkan Cebinde Yırtık Bilet Buldu", "Coffers Empty, Mayor Finds a Torn Ticket in the Pocket"),
               ("Belediye Kasası Yankı Yapıyor: 'Merhaba' Dedi, 'Merhaba' Cevap Verdi", "City Treasury Echoes: Said 'Hello', Echo Said 'Hello'"),
               ("İflas: Hulusi Teklif Verdi, Teklif de Reddedildi", "Bankruptcy: Hulusi Made an Offer, Even That Was Refused")],
        "sub": ("Para bitti, ağaçlar kaldı. Ama ağaçlar maaş almıyor, bu iyi haber.", "Money ran out, trees remain. But trees don't take wages, which is good news."),
        "why": ("Neden: Kasa sıfıra indi. Her kararın bir bedeli var, bazen de borcu.", "Cause: The treasury hit zero. Every decision has a price, sometimes a debt."),
        "q": ("Kasa boşalabilir Başkanım, tohum cebinde kaldıkça. Bir daha deneyelim, bu sefer parayı ağaçlara harcayalım.", "The treasury may empty, Mayor, as long as the seed stays in your pocket. Let's try again, and spend the money on trees this time."),
    },
    "REVOLT": {
        "hl": [("Halk Meydanda: Başkana 'Tamam, Sağ Ol' Dendi", "People in the Square: Mayor Told 'Okay, Thanks'"),
               ("Karatepe Ayağa Kalktı, Çay Ocağı Sonuna Kadar Açık", "Karatepe Rises Up, Tea House Open to the Very End"),
               ("İsyan! Rıza Bile 'Ben Karışmıyorum' Dedi", "Revolt! Even Rıza Said 'I'm Staying Out of This'")],
        "sub": ("Halk memnuniyeti sıfırlandı. Güvercin bile oy kullanmadı.", "People's approval hit zero. Even the pigeon abstained."),
        "why": ("Neden: Halk senden vazgeçti. İnsanlar nefes alır ama dinlenmeyince bağırır.", "Cause: The people gave up on you. People breathe, but when unheard they shout."),
        "q": ("Halk bazen bağırır, çünkü duyulmak ister. Bu sefer daha çok dinleyelim, ben de yardım ederim.", "People shout sometimes because they want to be heard. Let's listen more this time, I'll help."),
    },
    "POLLUTION": {
        "hl": [("Karatepe Havasızlıktan Boşaldı: Güvercinler İlk Gitti", "Karatepe Emptied by Smog: Pigeons Left First"),
               ("Hava Bitti, Haber Bitti, Gazete Bile Öksürdü", "Air Ran Out, News Ran Out, Even the Paper Coughed"),
               ("Son Nefes: Duman Şehri Teslim Aldı", "Last Breath: Smoke Takes Over the City")],
        "sub": ("Çevre sıfırlandı. Kuşlar bu haberi geç öğrendi, çünkü uçup gitmişlerdi.", "Nature hit zero. The birds heard late; they had already flown away."),
        "why": ("Neden: Çevre sıfıra indi. Kirlilik her sabah biraz daha ağır bastı.", "Cause: Nature hit zero. The pollution grew heavier every morning."),
        "q": ("Hava bitti diye ağaçlar bitmedi. Bir tohum daha, bir fidan daha. Bu sefer ben de yanında olacağım.", "The air ran out but the trees didn't. One more seed, one more sapling. I'll be right beside you this time."),
    },
    "DEADLINE": {
        "hl": [("30 Gün Doldu: Karatepe Kurtarılamadı, Çay Soğudu", "30 Days Are Up: Karatepe Not Saved, Tea Gone Cold"),
               ("Süre Doldu, Çevre Eksik: Kıl Payı Bir Hikâye", "Time's Up, Nature Short: A Story of a Whisker"),
               ("Otuzuncu Gün Geldi, Ağaçlar Biraz Daha İstiyor", "Day Thirty Arrived, Trees Want a Little More")],
        "sub": ("Neredeyse oldu. Neredeyse en cesur kelimedir.", "Almost happened. 'Almost' is the bravest word."),
        "why": ("Neden: 30. günde Çevre yeterli değildi. Dönüşü olmayan nokta geçildi.", "Cause: Nature wasn't enough on day 30. The point of no return was passed."),
        "q": ("Otuz gün az geldi. Ama biraz daha çalışırsak yeter. Hani demiştim: 'Biraz Daha'.", "Thirty days weren't enough. But a little more work will do. Remember: 'A Little More'."),
    },
    "DISMISSED": {
        "hl": [("Meclis Başkanı Görevden Aldı: Gerekçe 'Ağaç Yetmedi'", "Council Dismisses Mayor: Reason 'Not Enough Trees'"),
               ("Görevden Alma: Başkan Koltuğu Bırakırken Saksıyı da Aldı", "Dismissal: Mayor Left the Chair But Took the Plant"),
               ("Meclis Toplandı, Karar Çıktı: 'Biraz Daha Çaba'", "Council Convened, Verdict: 'A Little More Effort'")],
        "sub": ("Bölüm hedefi tutmadı. Meclis çok öfkeli, çok. Hatta dilekçe bile yazdılar.", "The chapter goal was missed. The council is very angry. They even wrote a petition."),
        "why": ("Neden: Bölüm sonunda Çevre hedefin yeterince yakınına bile gelmedi.", "Cause: At the chapter's end Nature wasn't even close enough to the goal."),
        "q": ("Meclis seni görevden aldı ama ormanın kapısı hâlâ açık. Gel, çay var. Sonra yeniden başlarız.", "The council dismissed you but the forest's door is still open. Come, there's tea. Then we start again."),
    },
}
for _k, _d in _LOSS.items():
    for _i, (_tr, _en) in enumerate(_d["hl"]):
        add("END_HL_%s_%d" % (_k, _i + 1), _tr, _en)
    add("END_SUB_%s" % _k, _d["sub"][0], _d["sub"][1])
    add("END_WHY_%s" % _k, _d["why"][0], _d["why"][1])
    add("END_Q_%s" % _k, _d["q"][0], _d["q"][1])

# ====================================================================== Kazanma: son sayı manşetleri (hikâye sonuna göre), alt başlık (yıldıza göre), Yiğithan'ın sözü
_WIN_HL = {
    "END_WIN": ("30 Gün, 1 Orman, 0 Bahane: Karatepe Kurtuldu", "30 Days, 1 Forest, 0 Excuses: Karatepe Is Saved"),
    "END_WIN_HERO": ("Başkan Hiçbir Şeyi Satmadı: Şaşkınlık Yaygın, Sevinç Daha Yaygın", "Mayor Sold Nothing: Shock Widespread, Joy Even More So"),
    "END_WIN_SOLD": ("Karatepe Nefes Alıyor (Hulusi'nin Bacaları da Alıyor)", "Karatepe Breathes (So Do Hulusi's Chimneys)"),
    "END_WIN_REDEEMED": ("Hulusi Fidan Dikti: Etiket Söküldü, Gözyaşı Gerçek", "Hulusi Plants a Sapling: Label Removed, Tears Real"),
    "END_WIN_JUSTICE": ("Tohum Bankası Kasabanın: Hulusi'nin Avukatı Bu Sefer Ayakta Kaldı", "Seed Bank Belongs to the Town: Hulusi's Lawyer Stayed Conscious This Time"),
}
for _k, (_tr, _en) in _WIN_HL.items():
    add("END_HL_" + _k, _tr, _en)
add("END_SUB_WIN_1", "Hava hâlâ biraz ağır ama artık nefes alınıyor. Güvercin öksürmeyi bıraktı, sadece nazlanıyor.", "The air is still a bit heavy but you can breathe now. The pigeon stopped coughing, it's just being dramatic.")
add("END_SUB_WIN_2", "Gökyüzünde ilk mavi yarık göründü. Rıza fotoğrafını çekti, dedikodu başladı.", "The first blue crack appeared in the sky. Rıza photographed it, gossip began.")
add("END_SUB_WIN_3", "Karatepe'de çocuklar gökyüzünü ilk kez gördü. Bir kısmı korktu. Sonra güldüler.", "In Karatepe the children saw the sky for the first time. Some got scared. Then they laughed.")
add("END_Q_WIN_1", "Biraz Daha dedik, oldu. Daha çok işimiz var ama artık nefes alarak yapacağız.", "We said 'A Little More', and it happened. We still have work, but we'll do it breathing.")
add("END_Q_WIN_2", "Ağaçlar bir günde büyümez Başkan. Ama sen bir ormanı uyandırdın. Gece de sana teşekkür ediyor: Huu.", "Trees don't grow in a day, Mayor. But you woke a forest. Gece thanks you too: Hoo.")
add("END_Q_WIN_3", "Bak yukarı Başkanım. Orada bir şey var, mavi. Buna gökyüzü derler. Sen yaptın bunu. Hepimiz yaptık.", "Look up, Mayor. There's something blue up there. It's called a sky. You did that. We all did.")

# ====================================================================== Outro: sinematik anlatım ve karakter epilogları
add("OUTRO_HINT", "Geçmek için Boşluk  ·  Atlamak için Esc", "Space to continue  ·  Esc to skip")
add("OUTRO_N1", "Otuz gün geçti.", "Thirty days passed.")
add("OUTRO_N2", "Kül düştü. Tohum uyandı.", "The Ash fell. The Seed awoke.")
add("OUTRO_N3", "Karatepe nefes alıyor.", "Karatepe is breathing.")
add("OUTRO_TIER_1", "Hava hâlâ biraz ağır. Ama artık nefes alınıyor.", "The air is still a bit heavy. But you can breathe now.")
add("OUTRO_TIER_2", "Gökyüzünde ilk mavi yarık açıldı.", "The first blue crack opened in the sky.")
add("OUTRO_TIER_3", "Çocuklar ilk kez gökyüzünü gördü. Bir kısmı korktu.", "The children saw the sky for the first time. Some got scared.")
add("OUTRO_END", "Teşekkürler, Başkan.", "Thank you, Mayor.")
add("OUTRO_PINAR_1", "Pınar ağacının altında ders çalışıyor. Öğretmene hâlâ söylemiyoruz.", "Pınar studies under her tree. We still haven't told the teacher.")
add("OUTRO_PINAR_2", "Pınar'ın ağacı boy attı. Pınar daha da büyümesini istiyor, bu sefer ağaçtan.", "Pınar's tree has grown tall. Pınar wants it taller still.")
add("OUTRO_VELI_1", "Veli Dede iskeleden olta attı. İlk balık: bir çizme. İkinci balık: bir balık! Ağladı.", "Grandpa Veli cast a line from the pier. First catch: a boot. Second catch: a fish! He wept.")
add("OUTRO_CANAN_1", "Canan Tohum Bankası'nın ilk kaydını yazdı: 'Tohum no 1: Başkan'ın çamı.' Gözlüğü buğulandı.", "Canan wrote the Seed Bank's first entry: 'Seed no. 1: the Mayor's pine.' Her glasses fogged.")
add("OUTRO_RIZA_1", "Rıza çay ocağında ilk kez 'Bugün haber yok, bu iyi haber' dedi. Herkes bayıldı.", "Rıza said at the tea house, for the first time: 'No news today, that's good news.' Everyone fainted.")
add("OUTRO_KEMAL_1", "Bacalar söndü, vardiyalar kısa. Kemal'in oğlu artık öksürmüyor, bazen sadece laf sokuyor.", "The chimneys are out, shifts are short. Kemal's son no longer coughs, he just makes remarks.")
add("OUTRO_KEMAL_2", "Fabrika hâlâ çalışıyor ama bacalarında maske var. Kemal 'İdare eder' dedi. Bu onun övgüsü.", "The factory still runs but its chimneys wear masks. Kemal said 'It'll do.' That's his praise.")
add("OUTRO_HULUSI_SOLD", "Hulusi yeni AVM'sine 'Ova Mall 2' adını verdi. Çatıda yine ova resmi, bu sefer daha mutlu.", "Hulusi named his new mall 'Plain Mall 2'. The roof has a plain painting again, a happier one this time.")
add("OUTRO_HULUSI_REDEEMED", "Hulusi Pınar'ın ağacının yanına kendi fidanını dikti. Etiketini söktü. Gözleri doldu, gizledi.", "Hulusi planted his own sapling next to Pınar's tree. He removed the label. His eyes welled up; he hid it.")
add("OUTRO_HULUSI_JUSTICE", "Hulusi hesap verdi, sonra Yeşil Sanayi Fonu'nu kurdu. Zarfları bağışladı. Zarflar şeffaf çıktı.", "Hulusi answered for his deeds, then founded the Green Industry Fund. He donated the envelopes. They turned out transparent.")
add("OUTRO_HULUSI_DEFAULT", "Hulusi kasabadan ayrılmadı. Bavulu artık bomboş, ama yüzü ilk kez hafif.", "Hulusi never left town. His suitcase is empty now, but his face is light for the first time.")
add("OUTRO_TOMURCUK_1", "Tomurcuk pilini ilk kez şarja taktı. 'Ben de ağlıyorum,' dedi, 'ama bu pas.'", "Sprout plugged in his battery for the first time. 'I'm crying too,' he said, 'but it's rust.'")
add("OUTRO_YIGITHAN_1", "Son Ağaç 'Biraz Daha' dikildi. Gece havalandı. Yiğithan ağlamadı, terledi. 'Ağaçlar bir günde büyümez Başkan, ama sen bir ormanı uyandırdın.'", "The Last Tree 'A Little More' was planted. Gece took flight. Yiğithan didn't cry, he sweated. 'Trees don't grow in a day, Mayor, but you woke a forest.'")
add("OUTRO_YIGITHAN_2", "Yiğithan ve Gece ormanda nöbette. 'Ağaçlar bir günde büyümez Başkan,' dedi. 'Ama sen birini başlattın.'", "Yiğithan and Gece stand watch in the forest. 'Trees don't grow in a day, Mayor,' he said. 'But you started one.'")


# ====================================================================== Yeni intro (oyunun gerçek haritası üzerinde, daha komik)
add("INTRO_2", "Karatepe. Nüfus: 4.812 insan, 3 kedi ve öksüren bir güvercin.", "Karatepe. Population: 4,812 people, 3 cats and one coughing pigeon.")
add("INTRO_3", "Fabrikalar hiç durmuyor. Çamaşırlar gri kuruyor. Güneş çoktan istifa etti.", "The factories never stop. Laundry dries gray. The sun resigned long ago.")
add("INTRO_4", "Ve sen, yeni Başkansın. Seçildin, çünkü kimse o koltuğa oturmak istemedi.", "And you are the new Mayor. You were elected because nobody else wanted that chair.")
add("INTRO_5", "Rapor masanda: otuz gün sonra bu havada nefes alınmayacak. Gerisi detay.", "The report is on your desk: in thirty days this air will no longer be breathable. The rest is detail.")
add("INTRO_6", "Elinde iki şey var: bir avuç tohum ve garanti kapsamı dışında bir robot.\n\n[color=#9fe3d6]— Merhaba Başkanım! Ben Tomurcuk. Pilim %4, moralim tam. Başlayalım mı?[/color]",
    "You have two things: a handful of seeds and a robot out of warranty.\n\n[color=#9fe3d6]— Hello, Mayor! I'm Sprout. Battery 4%, morale full. Shall we begin?[/color]")

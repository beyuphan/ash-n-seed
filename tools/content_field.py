# -*- coding: utf-8 -*-
"""Saha komikliği: konuşma balonları, boş replikler, geliştirme adları, yeni komşu yardımları.
tools/apply_content.py bunu content_texts ile birlikte işler."""

from content_texts import add

# ====================================================================== Saha: ağaç dikerken, çöp toplarken, çay içerken esprili balonlar
_QUIP_PLANT = [
    ("Büyü küçük ağaç, büyü. Lütfen.", "Grow, little tree, grow. Please."),
    ("Ağaç dikildi. Ağaç henüz bunu bilmiyor.", "Tree planted. The tree doesn't know yet."),
    ("Bir tohum, bir umut, bir sürü sinek.", "One seed, one hope, lots of flies."),
    ("Toprak: 'Hı? Ne? Biri mi geldi?'", "Soil: 'Huh? What? Is someone here?'"),
    ("Büyüyünce bana teşekkür edecek. Belki.", "It'll thank me when it grows. Maybe."),
    ("Dik dik dik... bel ağrısı da cabası.", "Plant, plant, plant... back pain included."),
    ("Ağaca fısıldadım: 'Hulusi'ye gölge etme.'", "I whispered to the tree: 'Don't shade Hulusi.'"),
    ("Yeni ağaç! Adı: Ağaç Junior.", "New tree! Name: Tree Junior."),
    ("Bu kasabada tohumlar bile yalnız hissediyor.", "In this town even seeds feel lonely."),
    ("Bir ağaç daha. Çevre: 'Eh, idare eder.'", "One more tree. Nature: 'Meh, it'll do.'"),
    ("Kuşlar henüz gelmedi. Biletleri yok herhalde.", "Birds haven't arrived. No tickets, probably."),
    ("Bunu sulamayı unutursam Pınar küser.", "If I forget to water this, Pınar will sulk."),
    ("Fidan: 'Beni neden buraya diktin, burası otopark!'", "Sapling: 'Why here? This is a parking lot!'"),
    ("Ağaçlar kasabanın en sessiz çalışanları.", "Trees are the town's quietest employees."),
]
for _i, (_tr, _en) in enumerate(_QUIP_PLANT):
    add("FIELD_QUIP_PLANT_%d" % (_i + 1), _tr, _en)

_QUIP_TRASH = [
    ("Bir poşet daha. Bu şehir poşetle yaşıyor.", "One more bag. This city lives on bags."),
    ("Vicdanım hafifledi, torbam ağırlaştı.", "My conscience got lighter, my bag heavier."),
    ("Kim attı bunu? Pınar'a sorsam 'Ben değil' der.", "Who dropped this? Pınar would say 'Not me'."),
    ("Teneke kutu... koleksiyon mu yapsam?", "A tin can... should I start a collection?"),
    ("Bu şişe yirmi yıllık. Eski dost.", "This bottle is twenty years old. An old friend."),
    ("Çöp kutusu üç metre ötede. Üç metre!", "The bin is three meters away. Three meters!"),
    ("Çöp toplamak: ucuz spor, pahalı bel.", "Collecting trash: cheap sport, expensive back."),
    ("Üstünde 'Karatepe Çelik' yazıyor. Şaşırmadım.", "It says 'Karatepe Steel'. Not surprised."),
    ("Çöpe merhaba dedim. Cevap vermedi.", "I said hello to the trash. No answer."),
    ("Geri dönüşüm: çöpe ikinci şans.", "Recycling: a second chance for trash."),
]
for _i, (_tr, _en) in enumerate(_QUIP_TRASH):
    add("FIELD_QUIP_TRASH_%d" % (_i + 1), _tr, _en)

_QUIP_TEA = [
    ("Çay! Dünyanın en iyi ikinci icadı.", "Tea! The world's second best invention."),
    ("Şekersiz içtim. Pişmanım.", "Drank it without sugar. I regret it."),
    ("Çayım bitti, moralim bitmedi.", "My tea is gone, my morale is not."),
    ("Rıza'nın çayı kadar iyi değil ama olsun.", "Not as good as Rıza's, but fine."),
    ("Bir yudum çay, bin yudum umut.", "One sip of tea, a thousand sips of hope."),
]
for _i, (_tr, _en) in enumerate(_QUIP_TEA):
    add("FIELD_QUIP_TEA_%d" % (_i + 1), _tr, _en)

# ====================================================================== Saha: mevcut mesajlar biraz daha komik
add("FIELD_FIRST_TREE", "İlk ağacın! Kasaba iyileşmeye başlıyor. Ağaç henüz haberi yok.", "Your first tree! The town starts healing. The tree doesn't know yet.")
add("FIELD_TEA_LIMIT", "Bugünlük çay bitti. Rıza seni uyarmıştı.", "No more tea today. Rıza warned you.")
add("FIELD_CANNOT_PLANT", "Yeşil yere ağaç mı? Çorak bir yer bul.", "A tree on green ground? Find some barren land.")
add("FIELD_NO_SEEDS", "Tohum yok! Pazar seni bekliyor (ve cüzdanını).", "No seeds! The market awaits you (and your wallet).")
add("FIELD_NO_MONEY", "Kasa yetmiyor! Hulusi'den bir zarf mı istesek?", "Not enough coins! Shall we ask Hulusi for an envelope?")
add("FIELD_DAY_OVER", "Gün bitti. Ayaklar da bitti.", "Day over. So are your feet.")
add("FIELD_WISH_NONE", "Bozuk para battı. Çeşme teşekkür etmedi.", "The coin sank. The fountain didn't say thanks.")
add("FIELD_FISH_JUNK", "Sadece eski bir şişe çıktı. Muhtemelen Hulusi'nin.", "Just an old bottle. Probably Hulusi's.")
add("DIS_FLOOD_SAVED", "Kurtarıldı! +4 Kasa. (Şemsiyesini de istiyor.)", "Saved! +4 coins. (He wants his umbrella back too.)")
add("DIS_HEAT_SAVED", "Ağaç kurtuldu! +4 Kasa. Yaprakları teşekkür hışırdadı.", "Tree saved! +4 coins. Its leaves rustled thanks.")
add("DIS_LEAK_SAVED", "Sızıntı kapandı! +4 Kasa. Variller utandı.", "Leak sealed! +4 coins. The barrels are ashamed.")
add("DIS_STORM_PERFECT", "Kusursuz kaçış! +12 Kasa, +3 Halk. Şimşek bile alkışladı.", "Perfect dodge! +12 coins, +3 People. Even the lightning applauded.")

# ====================================================================== Saha: karakterlerin boş replikleri (5 yeni, toplam 8)
_IDLE = {
    "RIZA": [
        ("Çay demledim, haber demlemedim. Bekle biraz.", "I brewed tea, not news. Wait a bit."),
        ("Bugün kimse şikâyet etmedi. Şüpheli.", "Nobody complained today. Suspicious."),
        ("Mahalle sakin, bu da başka bir sorun.", "The neighborhood is quiet, which is another problem."),
        ("Simit aldım. Ama sana değil.", "I bought a bagel. Not for you."),
        ("Başkanım, normalde gevezeyim ama bugün susuyorum. Kırmızı alarm.", "Mayor, I'm usually chatty but today I'm silent. Red alert."),
    ],
    "CANAN": [
        ("Bu toprağın pH'ı beni üzdü. Neyse, çaya geçtim.", "This soil's pH upset me. Anyway, I switched to tea."),
        ("Not defterim bitti, kalemim de. Çok kritik.", "My notebook ran out, and my pen. Very critical."),
        ("Tohum sayıyorum. 412, 413... pardon dalgınım.", "Counting seeds. 412, 413... sorry, I'm distracted."),
        ("Bilim, sabır ve bol su. Özellikle su.", "Science, patience and lots of water. Especially water."),
        ("Ağaçlarla konuşmak bilimsel mi? Hayır. Ama işe yarıyor.", "Is talking to trees scientific? No. But it works."),
    ],
    "HULUSI": [
        ("Bugün sadece bakıyorum. Kimse bakmıyor ama ben bakıyorum.", "Today I'm just watching. Nobody watches, but I do."),
        ("Şu bavul mu? Yemek kutusu. Sadece öğle yemeği.", "This suitcase? A lunchbox. Just lunch."),
        ("Beni kötü adam sanıyorsun. Ben sadece... esnek bir iş insanıyım.", "You think I'm the bad guy. I'm just... a flexible businessman."),
        ("Mühahaha! ...öhöm. Boğazım kaçtı.", "Muahaha! ...ahem. My throat slipped."),
        ("Hayat kısa, zarf uzun.", "Life is short, envelopes are long."),
    ],
    "PINAR": [
        ("Bir sincap gördüm! Gerçi sincap değil de çöp torbasıydı.", "I saw a squirrel! Well, it was a trash bag."),
        ("Annem bu kasaba bir gün yeşil olacak diyor. Ben yarın diyorum.", "Mom says this town will be green someday. I say tomorrow."),
        ("Ağacım bana göz kırptı. Galiba. Belki rüzgâr.", "My tree winked at me. I think. Maybe wind."),
        ("Okulda kuş resmi çizdik. Kuşlar kızmıştır.", "We drew birds at school. The birds must be mad."),
        ("Büyüyünce Başkan olacağım. Ya da çöpçü. İkisi de önemli.", "When I grow up I'll be Mayor. Or a trash collector. Both matter."),
    ],
    "VELI": [
        ("Gençliğimde nehirde balıklar konuşurdu. Şimdi öksürüyorlar.", "In my youth the fish talked in this river. Now they cough."),
        ("Otur evladım. Bu bank 80 yıllık, ben 90.", "Sit, child. This bench is 80 years old, I'm 90."),
        ("Her ağaç bir söz, her kök bir sır. Bu laf benimdi, yazmadım.", "Every tree a promise, every root a secret. That line is mine, I never wrote it down."),
        ("Rüzgâr sana selam söyledi. Duymadın mı? Kulağın mı tıkalı?", "The wind said hello to you. Didn't you hear? Are your ears blocked?"),
        ("Zaman akar, nehir durur. Ya da tersi. Yaşlıyım, karıştırıyorum.", "Time flows, the river stands still. Or the opposite. I'm old, I mix things up."),
    ],
    "KEMAL": [
        ("Anahtarım nerede? Elimde. Hep elimde.", "Where's my wrench? In my hand. Always in my hand."),
        ("Bacalar sustu, kulaklarım çınlıyor. Sessizlik de ağır.", "The chimneys fell silent, my ears are ringing. Silence is heavy too."),
        ("Çay ocağı kapalı, fabrika açık. Hayat adaletsiz.", "The tea house is closed, the factory open. Life is unfair."),
        ("Oğlum bana 'Baba, ağaç ister misin?' dedi. İstedim.", "My son asked 'Dad, want a tree?' I did."),
        ("İşçiler yorgun. Ben de. Ama kimse çaya gitmiyor.", "The workers are tired. Me too. But nobody goes for tea."),
    ],
}
for _who, _lines in _IDLE.items():
    for _i, (_tr, _en) in enumerate(_lines):
        add("NPC_%s_IDLE_%d" % (_who, _i + 4), _tr, _en)

# ====================================================================== Pazar tezgâhı: geliştirme adları
add("UP_MASK", "Gaz Maskesi", "Gas Mask")
add("UP_MASK_DESC", "kirli zeminde enerji %30 az gider. Nefes alan herkes seni kıskanır", "dirty ground drains 30% less energy. Everyone who breathes envies you")
add("UP_BOOTS", "Roket Çizme", "Rocket Boots")
add("UP_BOOTS_DESC", "%15 daha hızlı yürürsün. Roket yok ama ruh var", "walk 15% faster. No rockets, but plenty of spirit")
add("UP_BUCKET", "Efsane Kova", "Legendary Bucket")
add("UP_BUCKET_DESC", "yangın söndürmek çok daha az enerji harcar. Kovanın adı Kemal", "putting out fires costs far less energy. The bucket's name is Kemal")
add("UP_NURSERY", "Fidanlık Aboneliği", "Nursery Subscription")
add("UP_NURSERY_DESC", "her sabah +1 bedava çam tohumu. İptal etmek zor", "+1 free pine seed every morning. Hard to cancel")


# ====================================================================== Yeni komşu yardımları (mevcut dört mini oyunun yeni hikâyeleri)
def _favor(kind, name, title, ask, yes, no, win, loss):
    key = "FAVOR_%s_" % kind.upper()
    for suffix, pair in (("NAME", name), ("TITLE", title), ("ASK", ask), ("YES", yes), ("NO", no), ("WIN", win), ("LOSS", loss)):
        add(key + suffix, pair[0], pair[1])


_favor("grill", ("Mangal Başındaki Komşu", "Neighbor at the Grill"), ("Mangalı Körükle", "Fan the Grill"),
       ("Başkanım, mangalın közü sönüyor! Sosisler bekliyor, misafirler aç. Hızlı hızlı körükler misin?", "Mayor, the grill's embers are dying! The sausages wait, the guests are hungry. Can you fan it fast?"),
       ("Körükleyeyim.", "Let me fan it."), ("Ben vejetaryenim.", "I'm a vegetarian."),
       ("Mangal alev aldı! Sosisler çıtır çıtır. Al bir tane, senin hakkın.", "The grill roared! Crispy sausages. Take one, you earned it."),
       ("Kül uçuştu, sosisler çiğ kaldı. Neyse, salata yeriz.", "Ash flew, the sausages stayed raw. Never mind, we'll eat salad."))
_favor("crow", ("Kargalı Komşu", "Neighbor With Crows"), ("Merdiveni Tut", "Hold the Ladder"),
       ("Başkanım, çatıya kargalar yuva yapmış! Merdiveni tutar mısın, ben çıkıp çatıyı kurtaracağım.", "Mayor, crows nested on my roof! Hold the ladder while I climb up and save it."),
       ("Tutarım.", "I'll hold it."), ("Karga benim işim değil.", "Crows aren't my business."),
       ("Karga uçtu, çatı kurtuldu! Karga: 'Kraa!' (muhtemelen teşekkür).", "The crow flew off, the roof is saved! Crow: 'Caw!' (probably thanks)."),
       ("Merdiven sallandı, karga güldü. Sorun değil, bir gün alacağım.", "The ladder wobbled, the crow laughed. Fine, I'll get it someday."))
_favor("safe", ("Şifreyi Unutan Müteahhit", "Contractor Who Forgot the Code"), ("Kasayı Aç", "Open the Safe"),
       ("Başkan! Kasanın şifresini unuttum! İçinde sadece belgeler var, evet, sadece belgeler. Bir bakar mısın?", "Mayor! I forgot the safe's code! Only documents inside, yes, only documents. Could you have a look?"),
       ("Bakalım içinde ne var.", "Let's see what's inside."), ("Belge mi? Hayır.", "Documents? No."),
       ("Kasa açıldı! İçinde bir sürü zarf ve kedi maması vardı. Hulusi: 'Gördüğünüz her şey şeffaf!'", "The safe opened! Inside: lots of envelopes and cat food. Hulusi: 'Everything you see is transparent!'"),
       ("Açılmadı. Hulusi kasaya kafa attı, kasa daha sağlam çıktı.", "It didn't open. Hulusi headbutted the safe; the safe won."))
_favor("karaoke", ("Karaoke Gecesi", "Karaoke Night"), ("Şarkıya Eşlik Et", "Sing Along"),
       ("Başkanım, çay ocağında karaoke var ama şarkı sırası bende ve sesimi kaybettim. Sen söyler misin?", "Mayor, there's karaoke at the tea house, it's my turn but I lost my voice. Would you sing?"),
       ("Mikrofonu ver.", "Hand me the mic."), ("Ben sadece duşta söylerim.", "I only sing in the shower."),
       ("Herkes ayağa kalktı! Teyzeler alkışladı, Rıza ağladı. Sen bir yıldızsın.", "Everyone stood! The aunties applauded, Rıza cried. You're a star."),
       ("Ses çatladı, bardak çatladı ama herkes 'Bis!' dedi (alay ederek).", "Your voice cracked, a glass cracked, but everyone yelled 'Encore!' (mockingly)."))


# ====================================================================== Yeni mini oyunlar: yakala, ayır, vur, hatırla, yığ
_favor("orange", ("Devrilen Tezgâhın Sahibi", "Owner of the Fallen Stall"), ("Portakalları Yakala", "Catch the Oranges"),
       ("Başkanım, tezgâh devrildi, portakallar yağıyor! Sepeti tut da yere düşmesin. Çürükleri de karıştırma, onları müşteriye satıyorum.", "Mayor, my stall tipped over and oranges are raining! Hold the basket so they don't hit the ground. And skip the rotten ones, those I sell to customers."),
       ("Sepeti ver.", "Give me the basket."), ("Ben C vitamini almam.", "I don't take vitamin C."),
       ("Tek portakal yere düşmedi! Pazarcı gözyaşlarını sildi, sana bir torba verdi. 'Çürükleri de kattım,' dedi, 'dürüstlük.'", "Not one orange hit the ground! The vendor wiped his tears and gave you a bag. 'Threw in the rotten ones,' he said, 'honesty.'"),
       ("Portakallar yola yuvarlandı. Bir çocuk top sandı, şimdi mahallede portakal ligi başladı.", "The oranges rolled onto the road. A kid thought they were balls; the neighborhood orange league has begun."))
_favor("melon", ("Rekorcu Manav", "Record-Chasing Grocer"), ("Kasaları Yığ", "Stack the Crates"),
       ("Başkanım, Guinness'e başvuruyorum: dünyanın en yüksek karpuz kulesi! Kasaları üst üste düzgün koyar mısın? Dengeye dikkat.", "Mayor, I'm applying for Guinness: the world's tallest melon tower! Could you stack the crates neatly? Mind the balance."),
       ("Kasaları getir.", "Bring the crates."), ("Karpuzdan korkarım.", "I'm afraid of melons."),
       ("Kule göğe uzandı! Guinness aradı, 'karpuz mu?' deyip kapattı. Yine de gurur duyduk.", "The tower reached the sky! Guinness called, said 'melons?' and hung up. We're proud anyway."),
       ("Kule devrildi. Karpuz suyundan göl oldu, ördekler geldi, manav 'rekor bu' dedi.", "The tower fell. Melon juice formed a lake, ducks arrived, the grocer said 'that's a record too.'"))
_favor("recycle", ("Geri Dönüşüm Teyzesi", "Recycling Auntie"), ("Çöpü Ayır", "Sort the Trash"),
       ("Başkanım, mahallede geri dönüşüm yarışması var ve kutuları karıştırdım! Şunları doğru kutuya atar mısın? Fatma Teyze'ye yenilemem.", "Mayor, there's a neighborhood recycling contest and I mixed up the bins! Could you drop these in the right ones? I can't lose to Auntie Fatma."),
       ("Bana bırak.", "Leave it to me."), ("Ben hep karışık atarım.", "I always throw it mixed."),
       ("Hepsi yerli yerinde! Teyze birinci oldu, kupayı seninle paylaştı. Kupa kağıttan ama olsun.", "Everything in place! Auntie won first and shared the trophy with you. It's made of paper, but still."),
       ("Cam kutusuna muz kabuğu girdi. Teyze: 'Neyse, ben de karışık atmayı seviyorum.'", "A banana peel went into the glass bin. Auntie: 'Whatever, I like it mixed too.'"))
_favor("mole", ("Bahçıvan Salih", "Gardener Salih"), ("Köstebekleri Kov", "Chase the Moles"),
       ("Başkanım, bahçeyi köstebekler bastı! Ama aralarında bir kirpi var, ona dokunma, o benim komşum.", "Mayor, moles invaded my garden! But there's a hedgehog among them, don't touch it, it's my neighbor."),
       ("Tokmağı ver.", "Hand me the mallet."), ("Köstebeklerin de hakkı var.", "Moles have rights too."),
       ("Bahçe temiz! Kirpi bile başını eğip teşekkür etti. (Yuvarlandı, ama teşekkür gibiydi.)", "The garden is clean! Even the hedgehog nodded thanks. (Rolled over, but it felt like thanks.)"),
       ("Köstebekler kazandı. Bahçeye yeni bir metro hattı açıldı, ilk durak lahana.", "The moles won. A new metro line opened in the garden; first stop: cabbage."))
_favor("wedding", ("Düğünün Orkestrası", "Wedding Band"), ("Sırayı Hatırla", "Remember the Order"),
       ("Başkanım, düğünde notaları unuttuk! Biz çalıyoruz, sen sırayı hatırla, yanlış çalarsak söyle. Yok yok, sen çal.", "Mayor, we forgot the sheet music at the wedding! We play, you remember the order and tell us if we go wrong. No no, you play."),
       ("Notaları göster.", "Show me the notes."), ("Ben kulaktan çalamam.", "I can't play by ear."),
       ("Düğün kurtuldu! Gelin ağladı, damat ağladı, davulcu da ağladı (çünkü hep yanlış çalıyordu).", "The wedding is saved! The bride cried, the groom cried, and the drummer cried (because he'd been wrong all along)."),
       ("Zurna davula, davul saza girdi. Gelin 'bu yeni bir tür' dedi, alkışladılar.", "The zurna cut into the drum, the drum into the saz. The bride said 'it's a new genre', and they applauded."))

add("MG_HINT_CATCH", "A / D ile sepeti kaydır. Çürük olanlardan kaç!", "Slide the basket with A / D. Dodge the rotten ones!")
add("MG_HINT_SORT", "Eşyayı doğru kutuya at: ← kağıt, ↓ cam, → plastik", "Drop the item in the right bin: ← paper, ↓ glass, → plastic")
add("MG_HINT_WHACK", "Köstebeğe tıkla (ya da Q W E / A S D / Z X C). Kirpiye dokunma!", "Click the mole (or Q W E / A S D / Z X C). Don't touch the hedgehog!")
add("MG_HINT_MEMORY", "Sırayı izle, aynısını çal: 1 2 3 4 (ya da A S D F, fare)", "Watch the order, then repeat it: 1 2 3 4 (or A S D F, mouse)")
add("MG_HINT_STACK", "Boşluğa basıp kasayı bırak, kule dik dursun", "Press Space to drop the crate and keep the tower straight")
add("MG_CAUGHT", "Yakalanan: %d / %d", "Caught: %d / %d")
add("MG_HITS", "Vuruş: %d / %d", "Hits: %d / %d")
add("MG_ROUND", "Tur: %d / %d", "Round: %d / %d")
add("MG_STACKED", "Kule: %d / %d", "Tower: %d / %d")
add("MG_PERFECT", "Tam isabet!", "Perfect!")
add("MG_WATCH", "İzle...", "Watch...")
add("MG_YOURS", "Sıra sende!", "Your turn!")
add("MG_BIN_PAPER", "Kağıt", "Paper")
add("MG_BIN_GLASS", "Cam", "Glass")
add("MG_BIN_PLASTIC", "Plastik", "Plastic")

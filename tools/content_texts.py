# -*- coding: utf-8 -*-
"""Komik paket: metin değişiklikleri. Her giriş: anahtar -> (Türkçe, İngilizce). Var olan anahtarın üstüne yazar, yoksa ekler.
tools/apply_content.py çalıştırır. Yeni bir şaka eklemek için buraya satır ekle ve betiği yeniden çalıştır."""

TEXTS = {}


def add(key, tr, en):
    TEXTS[key] = (tr, en)


# ====================================================================== Yeni karakter adları
add("CHAR_ASSISTANT_NAME", "Tomurcuk", "Sprout")
add("CHAR_ASSISTANT_ROLE", "Pili %4, morali tam.", "Battery 4%, morale full.")
add("CHAR_ASSIST_ROLE", "Pili %4, morali tam.", "Battery 4%, morale full.")
add("CHAR_NEZAKET_NAME", "Nezaket Teyze", "Auntie Nezaket")
add("CHAR_NEZAKET_ROLE", "Börek getirir, dert de getirir.", "Brings pastry. Brings trouble.")
add("CHAR_MIRMIR_NAME", "Mırmır", "Mırmır")
add("CHAR_MIRMIR_ROLE", "Belediye Kedisi. Resmî sıfatı: Başkan Yardımcısı.", "Municipal Cat. Official title: Deputy Mayor.")
add("CHAR_DEFNE_NAME", "Gazeteci Defne", "Reporter Defne")
add("CHAR_DEFNE_ROLE", "Soru sorar. Cevap değil, manşet bekler.", "Asks questions. Wants headlines, not answers.")
add("CHAR_BRUCE_NAME", "Bay Bruce", "Mister Bruce")
add("CHAR_BRUCE_ROLE", "Yabancı yatırımcı. Her şeye 'fantastic' der.", "Foreign investor. Calls everything 'fantastic'.")
add("CHAR_HULUSI_ROLE", "Sıcak para. Soğuk sonuçlar. Zarf içinde zarf.", "Hot money. Cold consequences. Envelope in envelope.")

# ====================================================================== Hulusi: mevcut kartlar komik kötü olarak yeniden yazıldı
add("CARD_F1_BETON_LOBISI_TEXT",
    "Başkanım! Ben Hulusi, Karatepe Çelik'in sahibi, geleceğin ve cebimin dostu. Ormanın kıyısındaki şu küçük arazi var ya... imara açarsan ilk sıcak parayı ben indiririm. Zarf içinde zarf içinde zarf, tamamen şeffaf.",
    "Mayor! I'm Hulusi, owner of Karatepe Steel, friend of the future and of my pocket. That little plot by the forest... open it for construction and I'll drop the first warm money. Envelope in envelope in envelope: totally transparent.")
add("CARD_F1_BETON_LOBISI_A", "Zarfı Al, İmara Aç", "Take the Envelope, Rezone It")
add("CARD_F1_BETON_LOBISI_B", "'Zarf mı? Hayır.' De", "Say 'Envelope? No.'")
add("CARD_F1_BETON_LOBISI_RA", "Hulusi: 'Mühahaha! ...öhöm. Yani, ne güzel bir iş birliği.'", "Hulusi: 'Muahaha! ...ahem. I mean, what a lovely collaboration.'")
add("CARD_F1_BETON_LOBISI_RB", "Hulusi bir an donup kaldı. 'Hım. Çok katı biriymişsin. Hoşuma gitti. Tehlikeli.'", "Hulusi froze for a moment. 'Hm. You're very strict. I like it. Dangerous.'")
add("NEWS_C_F1_BETON_LOBISI_A", "Orman Kıyısı İmara Açıldı: Hulusi'nin Gülümsemesi Gözlerine Ulaşmadı", "Forest Edge Opened to Construction: Hulusi's Smile Didn't Reach His Eyes")
add("NEWS_C_F1_BETON_LOBISI_B", "Başkan 'Hayır' Dedi: Hulusi Bavulunu Sıkı Tuttu", "Mayor Said 'No': Hulusi Held His Suitcase Tight")

add("CARD_F1_GECE_MESAISI_TEXT",
    "Hulusi: 'Başkanım, fabrikam gece de çalışsın. Halk 'Çok gürültü' diyor ama onlar uykuya fazla değer veriyor. Uyku bence abartılmış bir lüks. Ben on yıldır uyumuyorum, bakın, hâlâ... öhöm... ayaktayım.'",
    "Hulusi: 'Mayor, my factory should run at night too. People say 'too noisy' but they overvalue sleep. Sleep is an overrated luxury. I haven't slept in ten years and look, I'm still... ahem... standing.'")
add("CARD_F1_GECE_MESAISI_A", "İzin Ver (Uykuya Veda)", "Allow It (Goodbye, Sleep)")
add("CARD_F1_GECE_MESAISI_B", "Yasakla (Hulusi Esniyor)", "Ban It (Hulusi Yawns)")
add("CARD_F1_GECE_MESAISI_RA", "Hulusi: 'Harika! Gece vardiyasına gece yarısı çay ikram edeceğim. Kendi ürettiğim çay. Duman tadında.'", "Hulusi: 'Great! I'll serve the night shift midnight tea. My own brand. Smoke flavored.'")
add("CARD_F1_GECE_MESAISI_RB", "Hulusi: 'Haklısınız.' Esnedi. 'Aslında ben de uyumak istiyordum. Kimseye söylemeyin.'", "Hulusi: 'You're right.' He yawned. 'Actually I wanted to sleep too. Don't tell anyone.'")
add("NEWS_C_F1_GECE_MESAISI_A", "Fabrika Gece de Çalışacak: Karatepe'nin Horultusu Bacadan Duyuluyor", "Factory Goes Night Shift: Karatepe's Snoring Now Heard From the Chimney")
add("NEWS_C_F1_GECE_MESAISI_B", "Gece Mesaisi Yasaklandı: Hulusi Yarım Saat Uyudu, Çok Mutlu", "Night Shift Banned: Hulusi Slept Half an Hour, Very Happy")

add("CARD_F1_NEHIR_RESTORAN_TEXT",
    "Hulusi nehir kenarına 'Hulusi'nin Sahil Lokantası' açmak istiyor. Atıklar nehre gidecek ama 'nehir buna alışık, bak, hiç şikâyet etmiyor.' Nehir şu an cevap veremiyor çünkü köpük içinde.",
    "Hulusi wants to open 'Hulusi's Seaside Restaurant' by the river. The waste will go into the river, but 'the river is used to it, look, it never complains.' The river can't answer right now: it's covered in foam.")
add("CARD_F1_NEHIR_RESTORAN_A", "İzin Ver", "Allow It")
add("CARD_F1_NEHIR_RESTORAN_B", "Mühürle", "Seal It")
add("CARD_F1_NEHIR_RESTORAN_RA", "Lokanta açıldı. Menüde 'Nehir Çorbası' var. Sipariş veren olmadı, çorba kendiliğinden kaynıyor.", "The restaurant opened. The menu has 'River Soup'. Nobody ordered, the soup boils by itself.")
RB = "Hulusi mührü gördü: 'Bu ne? Bu... bu yasal mı? Avukatım bayıldı.' Gerçekten bayılmıştı."
add("CARD_F1_NEHIR_RESTORAN_RB", RB, "Hulusi saw the seal: 'What is this? Is this... legal? My lawyer fainted.' He really had.")
add("NEWS_C_F1_NEHIR_RESTORAN_A", "Nehir Kıyısına Lokanta: 'Nehir Çorbası' Tezgâhta, Müşteri Yok", "Restaurant on the Riverbank: 'River Soup' on the Menu, No Customers")
add("NEWS_C_F1_NEHIR_RESTORAN_B", "Lokanta Mühürlendi: Hulusi'nin Avukatı Bayıldı", "Restaurant Sealed: Hulusi's Lawyer Faints")

add("CARD_F2_BETON_IHANETI_TEXT",
    "Hulusi: 'Başkanım, sanayiyi yeşil alana doğru büyütelim! Adı 'Yeşil Sanayi Parkı', çünkü bacalara yeşil boya sürdüm. Kasana da dev bir fon aktaracağım. Yeşil boya dahil!'",
    "Hulusi: 'Mayor, let's expand the industry into the green zone! It'll be called 'Green Industrial Park', because I painted the chimneys green. I'll also pump a huge fund into your treasury. Green paint included!'")
add("CARD_F2_BETON_IHANETI_A", "İmara Aç (Yeşil Boya Dahil)", "Rezone It (Green Paint Included)")
add("CARD_F2_BETON_IHANETI_B", "Reddet", "Refuse")
add("CARD_F2_BETON_IHANETI_RA", "Hulusi parmaklarını birbirine kenetledi. 'Mühahaha... yani, teşekkür ederim.' Bir boya kovası daha getirtti.", "Hulusi laced his fingers. 'Muahaha... I mean, thank you.' He ordered another bucket of paint.")
add("CARD_F2_BETON_IHANETI_RB", "Hulusi şaşkın: 'Reddettin mi? Yeşil boyayı da mı?' Boya kovasını kucaklayıp çıktı.", "Hulusi, stunned: 'You refused? Even the green paint?' He left hugging the paint bucket.")
add("NEWS_C_F2_BETON_IHANETI_A", "Sanayi Bölgesi Büyüyor: Bacalar Yeşile Boyandı, Hava Yine Gri", "Industrial Zone Expands: Chimneys Painted Green, Air Still Gray")
add("NEWS_C_F2_BETON_IHANETI_B", "İmar Reddedildi: Hulusi Yeşil Boyayı Kendi Evinde Kullanacak", "Rezoning Rejected: Hulusi Will Use the Green Paint at Home")

add("CARD_F2_GECEKONDU_TEXT",
    "Hulusi lüks site yapmak için gecekonduları yıkmak istiyor. Adı: 'Gecekondu Vista Residence'. Reklamında kuş sesi var, kuş yok ama ses var.",
    "Hulusi wants to demolish the shanties for a luxury complex. Name: 'Shanty Vista Residence'. The ad has bird sounds, there are no birds but there is sound.")
add("CARD_F2_GECEKONDU_A", "İzin Ver", "Allow It")
add("CARD_F2_GECEKONDU_B", "Yıkımı Durdur", "Stop the Demolition")
add("CARD_F2_GECEKONDU_RA", "Yıkım başladı. Hulusi dozerin üstüne çıkıp elini salladı: 'Gelecek geliyor! Biraz toz ama geliyor!'", "Demolition began. Hulusi climbed on the bulldozer and waved: 'The future is coming! A bit dusty, but coming!'")
add("CARD_F2_GECEKONDU_RB", "Hulusi: 'Durdurdun mu? Peki... Reklamdaki kuş sesi ne olacak?' Boynunu büktü.", "Hulusi: 'You stopped it? Well... what about the bird sounds in the ad?' He hung his head.")
add("NEWS_C_F2_GECEKONDU_A", "Gecekondular Yıkılıyor: 'Vista' Reklamında Kuş Sesi, Gerçekte Sessizlik", "Shanties Torn Down: 'Vista' Ad Has Bird Sounds, Reality Has Silence")
add("NEWS_C_F2_GECEKONDU_B", "Yıkım Durduruldu: Hulusi'nin Kuş Sesi Kasetleri Elde Kaldı", "Demolition Halted: Hulusi Left With Bird-Sound Tapes")

add("CARD_F3_BETON_TARLALAR_TEXT",
    "Hulusi: 'Şehrin son verimli ovasına AVM yapalım! Adı 'Ova Mall'. Ovayı hatırlamak isteyenler için çatıya ova resmi koyacağım, tam boyut, nostaljik.'",
    "Hulusi: 'Let's build a mall on the town's last fertile plain! Called 'Plain Mall'. For those who want to remember the plain, I'll put a plain painting on the roof, full size, nostalgic.'")
add("CARD_F3_BETON_TARLALAR_A", "Arazileri Sat", "Sell the Fields")
add("CARD_F3_BETON_TARLALAR_B", "Çiftçiyi Koru", "Protect the Farmers")
add("CARD_F3_BETON_TARLALAR_RA", "Hulusi gözyaşlarını sildi: 'Çok duygusal. Ova gidiyor, AVM geliyor. Hayat bu.'", "Hulusi wiped his tears: 'So emotional. The plain goes, the mall comes. That's life.'")
add("CARD_F3_BETON_TARLALAR_RB", "Çiftçiler Hulusi'ye bir sepet domates uzattı. Hulusi: 'Bu bir tehdit mi?' Hayır, domatesti.", "The farmers offered Hulusi a basket of tomatoes. Hulusi: 'Is this a threat?' No, tomatoes.")
add("NEWS_C_F3_BETON_TARLALAR_A", "Ovaya AVM Geliyor: Çatıya Ova Resmi, Zemine Beton", "Mall Coming to the Plain: Plain Painting on the Roof, Concrete on the Ground")
add("NEWS_C_F3_BETON_TARLALAR_B", "Ova Kurtuldu: Hulusi 'Çok Güzel, Yine Gelirim' Dedi", "Plain Saved: Hulusi Says 'Very Nice, I'll Be Back'")

add("CARD_F3_RUSVET_SKANDALI_TEXT",
    "Bir denetçi Hulusi'nin usulsüzlüğünü bulmuş. Hulusi sana fısıldıyor (bağırarak): 'Kimse bilmesin! SESSİZ OL!' Elinde 'RÜŞVET' yazan bir zarf var. Üstüne etiket bile yapıştırmış, ne kadar şeffaf.",
    "An auditor found Hulusi's irregularity. Hulusi whispers to you (shouting): 'Nobody must know! BE QUIET!' He holds an envelope labelled 'BRIBE'. He even stuck a label on it, so transparent.")
add("CARD_F3_RUSVET_SKANDALI_A", "Zarfı Al", "Take the Envelope")
add("CARD_F3_RUSVET_SKANDALI_B", "Denetçiyi Destekle", "Back the Auditor")
add("CARD_F3_RUSVET_SKANDALI_RA", "Hulusi: 'Mühahaha! ...öhöm. Yani, teşekkürler.' Zarfı üç kere el değiştirdi, kimse kime ne verdi bilmiyor.", "Hulusi: 'Muahaha! ...ahem. I mean, thanks.' The envelope changed hands three times, nobody knows who gave what.")
add("CARD_F3_RUSVET_SKANDALI_RB", "Denetçi sana teşekkür etti. Hulusi zarfı kendi cebine geri koydu: 'Bu sefer ben ısmarlayayım.'", "The auditor thanked you. Hulusi put the envelope back in his own pocket: 'This one's on me.'")
add("NEWS_C_F3_RUSVET_SKANDALI_A", "Rüşvet Skandalı: Zarf Üç Kere El Değiştirdi, Kimse Hatırlamıyor", "Bribery Scandal: Envelope Changed Hands Three Times, Nobody Remembers")
add("NEWS_C_F3_RUSVET_SKANDALI_B", "Denetçi Destek Gördü: Hulusi 'Ben de Destekliyorum' Dedi (Kendimi)", "Auditor Gets Support: Hulusi Says 'I Support Too' (Myself)")

add("CARD_F4_KIMYASAL_NEHIR_TEXT",
    "Hulusi'nin fabrikasının nehre kimyasal döktüğü ifşa oldu. Hulusi bavulla geldi: 'Aramızda çözelim. Bavulun üstünde 'Aramızda' yazıyor, bak. Yanında bir de çikolata.'",
    "It's revealed that Hulusi's factory dumps chemicals into the river. Hulusi arrived with a suitcase: 'Let's settle it between us. The suitcase says 'Between us', look. There's chocolate too.'")
add("CARD_F4_KIMYASAL_NEHIR_A", "Fabrikayı Mühürle", "Seal the Factory")
add("CARD_F4_KIMYASAL_NEHIR_B", "Rüşveti Al ve Sus", "Take the Bribe, Stay Quiet")
add("CARD_F4_KIMYASAL_NEHIR_RA", "Hulusi mühre baktı: 'Ben bunu hiç beklemiyordum.' Bavulunu kapattı, çikolatayı yedi.", "Hulusi looked at the seal: 'I did not expect this.' He shut the suitcase and ate the chocolate.")
add("CARD_F4_KIMYASAL_NEHIR_RB", "Hulusi bavulu açtı. İçinde 200 Kasa, 3 çikolata ve bir not: 'Teşekkür ederim. -H.' Not da şeffaf.", "Hulusi opened the suitcase. Inside: 200 coins, 3 chocolates and a note: 'Thank you. -H.' The note was transparent too.")
add("NEWS_C_F4_KIMYASAL_NEHIR_A", "Fabrika Mühürlendi: Hulusi 'Bu Bir Yanlış Anlaşılma, Bir de Çikolata' Dedi", "Factory Sealed: Hulusi Says 'It's a Misunderstanding, Also Chocolate'")
add("NEWS_C_F4_KIMYASAL_NEHIR_B", "Nehir Zehirli, Bavul Dolu: Ömürlük Sessizlik Anlaşması", "River Toxic, Suitcase Full: Lifetime Silence Deal")

add("CARD_F4_NEHIR_YATAGI_TEXT",
    "Hulusi kurumuş nehir yatağına rezidans yapmak istiyor: 'Nehir yok, sorun yok! Manzara bile satarım: 'Nehir Manzaralı Daireler.' Nehir yok ama manzara var, kimse nehri göremeyecek ama manzarası olacak.'",
    "Hulusi wants to build residences on the dried riverbed: 'No river, no problem! I even sell views: 'River View Apartments.' No river, but a view. Nobody will see the river but there will be a view.'")
add("CARD_F4_NEHIR_YATAGI_A", "Sat Gitsin", "Sell It")
add("CARD_F4_NEHIR_YATAGI_B", "Reddet", "Refuse")
add("CARD_F4_NEHIR_YATAGI_RA", "Satış başladı. Hulusi broşür dağıttı: 'Hayalinizdeki nehir, hemen yanınızda yok!'", "Sales began. Hulusi handed out brochures: 'Your dream river, not right next to you!'")
add("CARD_F4_NEHIR_YATAGI_RB", "Hulusi iç çekti. Nehir yatağına kendi büstünü dikmek istedi. Onu da reddettin.", "Hulusi sighed. He wanted to put his own bust in the riverbed. You refused that too.")
add("NEWS_C_F4_NEHIR_YATAGI_A", "'Nehir Manzaralı' Dairelerde Nehir Yok: Hulusi 'Manzara Var' Diyor", "'River View' Apartments Have No River: Hulusi Says 'There's a View'")
add("NEWS_C_F4_NEHIR_YATAGI_B", "Nehir Yatağı Kurtuldu: Hulusi Büstünü Kendi Bahçesine Dikti", "Riverbed Saved: Hulusi Erected His Bust in His Own Garden")

add("CARD_F5_AVM_ACILISI_TEXT",
    "AVM'nin açılışı! Hulusi: 'Başkan, kurdeleyi sen kes!' Kurdele, ovadan sökülen çimlerden örülmüş. Çok duygusal, çok ironik. Hulusi bile biraz utanıyor.",
    "The mall opening! Hulusi: 'Mayor, cut the ribbon!' The ribbon is woven from grass torn from the plain. So emotional, so ironic. Even Hulusi is a bit ashamed.")
add("CARD_F5_AVM_ACILISI_A", "Açılışı Yap", "Cut the Ribbon")
add("CARD_F5_AVM_ACILISI_B", "Boykot Et", "Boycott It")
add("CARD_F5_AVM_ACILISI_RA", "Kurdele kesildi. AVM'nin ilk müşterisi bir güvercin oldu, kapıdan çıktı, dönmedi.", "Ribbon cut. The mall's first customer was a pigeon: it walked out and never came back.")
add("CARD_F5_AVM_ACILISI_RB", "Hulusi açılışı tek başına yaptı. Kurdeleyi kendi kesti, kendi alkışladı, kendi gitti.", "Hulusi held the opening alone. He cut the ribbon himself, applauded himself, left by himself.")
add("NEWS_C_F5_AVM_ACILISI_A", "AVM Açıldı: İlk Müşteri Güvercin, İlk Alışveriş 'Çim'", "Mall Opens: First Customer a Pigeon, First Purchase 'Grass'")
add("NEWS_C_F5_AVM_ACILISI_B", "AVM Açılışına Kimse Gelmedi: Hulusi Kendini Alkışladı", "Nobody Came to the Mall Opening: Hulusi Applauded Himself")

add("CARD_F5_COP_ITHALATI_TEXT",
    "Hulusi: 'Yurtdışından çöp ithal edip yakalım! Buna 'Karbon Eğlencesi' diyelim. Çok büyük para, çok büyük duman. Duman bile yurtdışı kalitesinde!'",
    "Hulusi: 'Let's import garbage from abroad and burn it! We'll call it 'Carbon Fun'. Huge money, huge smoke. The smoke is even imported quality!'")
add("CARD_F5_COP_ITHALATI_A", "Kabul Et", "Accept")
add("CARD_F5_COP_ITHALATI_B", "Reddet", "Refuse")
add("CARD_F5_COP_ITHALATI_RA", "Hulusi dev bir çek yazdı. Çekte 'Karbon Eğlencesi' yazıyor. Banka şaşırdı ama kabul etti.", "Hulusi wrote a giant check. It says 'Carbon Fun'. The bank was baffled but accepted it.")
add("CARD_F5_COP_ITHALATI_RB", "Hulusi: 'Çöp ithal etmezsek ne ithal edeceğiz? Kurabiye mi?' Ciddi ciddi düşündü.", "Hulusi: 'If we don't import garbage what do we import? Cookies?' He pondered it seriously.")
add("NEWS_C_F5_COP_ITHALATI_A", "Karatepe Çöp İthal Ediyor: 'Karbon Eğlencesi' Başladı, Eğlenen Yok", "Karatepe Imports Garbage: 'Carbon Fun' Begins, Nobody Having Fun")
add("NEWS_C_F5_COP_ITHALATI_B", "Çöp İthalatı Reddedildi: Hulusi Kurabiye İthal Etmeyi Düşünüyor", "Garbage Import Rejected: Hulusi Considers Importing Cookies")

add("CARD_F6_SON_ORMAN_TEXT",
    "Hulusi son kez geldi, elinde dev bir çek: 'Şehrin son ormanını bana sat. Karşılığında sana bir ağaç heykeli yaptıracağım. Ağaç heykeli, plastik, yeşil, yaprakları bile var!'",
    "Hulusi came one last time with a giant check: 'Sell me the town's last forest. In return I'll build you a tree statue. A tree statue, plastic, green, it even has leaves!'")
add("CARD_F6_SON_ORMAN_A", "Sat", "Sell")
add("CARD_F6_SON_ORMAN_B", "Reddet", "Refuse")
add("CARD_F6_SON_ORMAN_RA", "Orman satıldı. Hulusi heykelin ilk yaprağını kendi elleriyle yapıştırdı. Düştü. Bir daha yapıştırdı. Düştü.", "The forest was sold. Hulusi glued the statue's first leaf himself. It fell. He glued it again. It fell.")
add("CARD_F6_SON_ORMAN_RB", "Hulusi bir an sustu. Sonra yavaşça bavulunu kapattı: 'Çok yoruldum Başkan. Biraz ağaçlara bakayım mı?'", "Hulusi went quiet. Then slowly he closed his suitcase: 'I'm very tired, Mayor. May I look at the trees for a bit?'")
add("NEWS_C_F6_SON_ORMAN_A", "Son Orman Satıldı: Plastik Ağaç Heykeli Dikildi, Yaprakları Dökülüyor", "Last Forest Sold: Plastic Tree Statue Erected, Leaves Falling Off")
add("NEWS_C_F6_SON_ORMAN_B", "Son Orman Satılmadı: Hulusi Ağaçlara Bakıyor (Bir Süredir)", "Last Forest Not Sold: Hulusi Is Looking at Trees (For a While)")

add("CARD_F6_HURDA_SAHASI_TEXT",
    "Hulusi hurda sahasını rezidansa çevirmek istiyor: 'Pas Vadisi Evleri.' Pas tonu sevimli olacakmış, duvarlar zaten pas rengi, tasarım masrafı yok!",
    "Hulusi wants to turn the scrapyard into residences: 'Rust Valley Homes.' The rust tone will be cute, the walls are already rust colored, no design costs!")
add("CARD_F6_HURDA_SAHASI_A", "İzin Ver", "Allow It")
add("CARD_F6_HURDA_SAHASI_B", "Reddet", "Refuse")
add("CARD_F6_HURDA_SAHASI_RA", "Satışlar başladı. İlk alıcı: tetanos aşısı yaptıran bir müşteri.", "Sales began. First buyer: a customer who got a tetanus shot first.")
add("CARD_F6_HURDA_SAHASI_RB", "Hulusi: 'Pas Vadisi ismi hâlâ boşta. Başka bir yer arıyorum.' Gitti. Sonra geri geldi: 'Çatı katı var mı?'", "Hulusi: 'The name Rust Valley is still free. I'll find another place.' He left. Then he came back: 'Any attic available?'")
add("NEWS_C_F6_HURDA_SAHASI_A", "Pas Vadisi Evleri Satışta: İlk Müşteri Önce Tetanos Aşısı Oldu", "Rust Valley Homes on Sale: First Customer Got a Tetanus Shot First")
add("NEWS_C_F6_HURDA_SAHASI_B", "Pas Vadisi Reddedildi: Hulusi Çatı Katı Arıyor", "Rust Valley Rejected: Hulusi Looking for an Attic")

# ====================================================================== Hulusi: hikâye ve saha repliklerinin komikleştirilmesi
add("STORY_HULUSI_1_L1",
    "Sayın Başkan! Ben Hulusi, Karatepe Çelik'in sahibi ve bu kasabanın en sevgili kötü... yani en sevgili müteahhidi. Şu çeşmeyi hep sevmişimdir, susuz kalması yüreğimi burkuyor. Cüzdanımı da.",
    "Dear Mayor! I'm Hulusi, owner of Karatepe Steel and this town's most beloved villain... I mean contractor. I've always loved this fountain, it breaks my heart that it has no water. And my wallet.")
add("STORY_HULUSI_1_L2",
    "Onarımı ben yaptırırım. Adı da 'Hulusi Çeşmesi' olur, tabii ki. Karşılığında yeni bacamıza ufak bir izin. Hem kasaba kazanır hem ben. Daha çok ben, ama kasaba da.",
    "I'll have it repaired. It'll be called 'Hulusi Fountain', of course. In return, a tiny permit for our new chimney. The town wins and I win. Me more, but the town too.")
add("STORY_HULUSI_1_R1",
    "Harika! Zarf masanızda. Zarfın içinde bir zarf daha var, onun içinde yine zarf. Sadece cüzdanım şeffaf. Çeşme de yakında akar!",
    "Wonderful! The envelope is on your desk. Inside is another envelope, and inside that, yet another. Only my wallet is transparent. The fountain will flow soon!")
add("STORY_HULUSI_1_R2",
    "Ne yazık... Pişman olabilirsiniz dostum. Ben pişman olmam, hiç denemedim.",
    "Too bad... You might regret it, my friend. I never regret anything, I've never tried.")
add("STORY_HULUSI_2_L1_Y",
    "Anlaşmamız iyi işliyor Başkanım! Bakın, çeşme akıyor, bacalar tütüyor. Bir baca daha istiyorum, aynı şartlarla. Bu sefer bacanın adı 'Hulusi 2'.",
    "Our deal is working well, Mayor! Look, the fountain flows, the chimneys puff. I want one more chimney, same terms. This one will be called 'Hulusi 2'.")
add("STORY_HULUSI_2_L1_N",
    "Vazgeçtiğimi sanmayın! Bu sefer farklı bir yöntem: diktiğiniz her fidan başına ödeme öneriyorum, sessizce. Sessizce, yani fısıltıyla bağırarak.",
    "Don't think I gave up! This time a new method: I offer payment for every sapling you plant, quietly. Quietly, meaning shouting in a whisper.")
add("STORY_HULUSI_2_L2",
    "Her şeyin bir fiyatı var Başkanım. Sizinki ne? Hadi, ucuz tutarım. Yok, pahalı da tutarım. İkisini de ayarlarım.",
    "Everything has a price, Mayor. What's yours? Come on, I'll keep it cheap. No, I'll keep it expensive. I can arrange both.")
add("STORY_HULUSI_2_L3",
    "Kimseye zararım yok. Sadece geçmişi eşelemeyin. Geçmiş... gizli. Hatta çok gizli. Neyse, ben bir şey demedim.",
    "I harm nobody. Just don't dig into the past. The past is... secret. Very secret. Anyway, I didn't say anything.")
add("STORY_HULUSI_2_R1", "Zevkle çalışmış olalım! (Mühahaha... öhöm.)", "Pleasure doing business! (Muahaha... ahem.)")
add("STORY_HULUSI_2_R2",
    "Bilmek ayrı, kanıtlamak ayrı Başkanım. Ayrıca bilmekle kanıtlamak arasındaki mesafe benim en sevdiğim yer. Görürüz.",
    "Knowing is one thing, proving another, Mayor. Also, the distance between knowing and proving is my favorite place. We'll see.")
add("STORY_HULUSI_3_L1",
    "Demek buldunuz. Babamın bıraktığı pislik... ama kamyonları ben de durdurmadım Başkanım. İtiraf ediyorum. Bu sefer zarf yok, ellerim boş. Bakın: boş. Bu bile garip geliyor.",
    "So you found it. The filth my father left behind... but I didn't stop the trucks either, Mayor. I confess. No envelope this time, my hands are empty. Look: empty. Even that feels strange.")
add("STORY_HULUSI_3_L2",
    "Şimdi bir teklifiniz var, değil mi? Ya da benim size. Ya da... ikimizin de teklifi var ve ikimiz de beceriksiziz.",
    "Now you have an offer, right? Or I have one for you. Or... we both have offers and we're both clumsy.")
add("STORY_HULUSI_3_R1",
    "...Anlıyorum. Avukatım bile bunu önermezdi. Hatta avukatım şu an bayıldı. Anahtarlar sende, kayıtlar da.",
    "...I see. Even my lawyer wouldn't have suggested this. In fact my lawyer just fainted. The keys are yours, and the records.")
add("STORY_HULUSI_3_R2",
    "Bu... adil. Hatta teselli. Yarın sabah ilk iş, kendime söz veriyorum: sabah altıda, kahvaltısız.",
    "This is... fair. Even comforting. First thing tomorrow, I promise myself: six in the morning, no breakfast.")
add("STORY_HULUSI_3_R3",
    "Güzel. Çocuklar nefes alacak mı, onu bilmem. Ama ben rahat uyurum. Zaten hep rahat uyurum, bu da bir sorun.",
    "Good. Whether the children will breathe, I don't know. But I'll sleep well. I always sleep well, which is a problem.")
add("NPC_HULUSI_ASK",
    "Başkanım, fabrikalarımın yanına ağaç dikmeyi bir unut. 20 Kasa nakit, soru yok. Hatta cevap da yok.",
    "Mayor, forget about planting trees near my factories. 20 coins cash, no questions. No answers either.")
add("NPC_HULUSI_TAKEN",
    "Seninle iş yapmak güzel. Havanın benimle ne ilgisi var? Hava, değil mi? Hava havadır.",
    "Nice doing business. What does air have to do with me? Air is air.")
add("NPC_HULUSI_REFUSED",
    "Hım. Herkesin bir fiyatı vardır Başkan... şimdilik. Not aldım, deftere yazdım, ikinci deftere de yazdım.",
    "Hm. Everybody has a price, Mayor... for now. Noted it, wrote it in my notebook, and in the second notebook too.")
add("NPC_HULUSI_DONE", "Teklifimi bugün zaten yaptım. Günde bir teklif, doktor tavsiyesi.", "I already made my offer today. One offer a day, doctor's orders.")
add("NPC_HULUSI_SPONSOR_ASK",
    "Başkanım, imajım bozuldu. Dün bir kuş bana bakıp öksürdü. Sanayi bölgesine iki ağaç dikersen sponsor olurum: otuz Kasa.",
    "Mayor, my image took a hit. Yesterday a bird looked at me and coughed. Plant two trees in the industrial zone and I'll sponsor you: thirty coins.")
add("NPC_HULUSI_SPONSOR_OK",
    "Anlaştık! Ağaçları dik, paranı al. Kamerayı hazır tutacağım, 'Hulusi Doğa Dostu' diye reklam yapacağım.",
    "Deal! Plant the trees, get your money. I'll keep the camera ready: 'Hulusi, Friend of Nature' ad coming.")
add("NPC_HULUSI_SMOKE_ASK",
    "Bacalarımı bugünlük kısabilirim. Bana on beşe mal olur. Senin de işin kolaylaşır. Bacalar için fısıltı moduna geçeceğiz.",
    "I can turn my chimneys down for today. It costs me fifteen. It makes your job easier too. We'll switch the chimneys to whisper mode.")
add("NPC_HULUSI_SMOKE_OK",
    "Bacalar bugün sakin. Bu bir iyilik değil, yatırım. Ayrıca bacalar yorgun, bırak bir gün dinlensinler.",
    "The chimneys are calm today. This is no favor, it's an investment. Also the chimneys are tired, let them rest a day.")
add("NPC_HULUSI_IDLE_1", "Yoğun bir gündeyim Başkanım. Sonra. Çok yoğun. Yoğunluktan yoğruldum.", "Busy day, Mayor. Later. Very busy. I'm kneaded with busyness.")
add("NPC_HULUSI_IDLE_2", "Sonra görüşürüz. Bu sefer gerçekten.", "See you later. For real this time.")
add("NPC_HULUSI_IDLE_3", "Hava güzel, dumana rağmen. Sağ ol duman, bugün de güzelsin.", "Nice weather, despite the smoke. Thanks smoke, you look lovely today.")
add("GUIDE_F_HULUSI",
    "Müteahhit Hulusi kasabada. Teklifleri tatlı, bedeli ağır. Kahkahasına güvenme: üç kere 'mühahaha' deyip hemen 'öhöm' diyor. İşaretledim.",
    "Contractor Hulusi is in town. Sweet offers, heavy price. Don't trust his laugh: he does a villain 'muahaha' then immediately says 'ahem'. I marked him.")

# ====================================================================== Tomurcuk: komik yardımcı
add("GUIDE_WELCOME",
    "Merhaba Başkanım! Ben Tomurcuk: robot, rehber, ara sıra tost makinesi. Karatepe'yi kurtarmak için 30 günümüz var. Bugün kolay: yürü, ağaç dik. Gerisini tek tek göstereceğim, panik yok. (Panik modülüm zaten bozuk.)",
    "Hello, Mayor! I'm Sprout: robot, guide, occasional toaster. We have 30 days to save Karatepe. Today is easy: walk and plant. I'll show the rest one at a time, no panic. (My panic module is broken anyway.)")
add("GUIDE_CONTROLS",
    "WASD ile yürürsün, Shift ile koşarsın. Boşluk ağaç diker. Ağaç toprağı temizler, Çevre yükselir. Kirli toprakta enerjin hızla erir, çünkü kirli hava ciğere kötü. Bu bilimsel bir gerçek, ben uydurmadım.",
    "WASD to walk, Shift to run. Space plants a tree. Trees clean the soil and raise Nature. On dirty ground your energy melts, because dirty air is bad for lungs. That's science, I didn't make it up.")
add("GUIDE_TRASH",
    "Çöpün üstünden geçersen toplanır. Peş peşe toplarsan zincir bonusu gelir: çöp toplamak bu kasabanın en ucuz sporu. Şimdi ilk ağacını dik, heyecandan titriyorum (devrelerim).",
    "Walk over trash to collect it. Grab several fast for a combo bonus: trash collecting is this town's cheapest sport. Now plant your first tree. I'm trembling with excitement (my circuits are).")
add("GUIDE_FIRST_PLANT",
    "Aferin, ilk ağaç! Bir not: durursan kirlilik geri yayılır, ayrıca kasaba her gece biraz Çevre kaybeder. Yani koş, dik, yine koş. Dinlenmek lüks, bu şehir dinlenemez.",
    "First tree, well done! A note: if you stand still pollution creeps back, and the town loses some Nature each night. So run, plant, run again. Rest is a luxury this town can't afford.")
add("GUIDE_NO_SEEDS",
    "Tohumun bitti. Pazardan Kasa ile yenisini al: oku takip et, orada Boşluk'a bas. Evet, tohum satın alıyoruz. Doğa bile faturayla çalışıyor.",
    "Out of seeds. Buy more at the market with coins: follow the arrow and press Space there. Yes, we pay for seeds. Even nature runs on invoices.")
add("GUIDE_LOW_ENERGY",
    "Enerjin azalıyor! Sıfırlanınca gün biter ve seni sırtımda taşıyamam (kollarım ince). Pazarda E ile çay içersen dolar. İstersen günü de bitirebilirsin.",
    "Your energy is low! At zero the day ends and I can't carry you (my arms are thin). A tea at the market (E) refills some. Or just end the day.")
add("GUIDE_SPREAD",
    "Durursan kirlilik temiz topraklara sızar. Kirlilik sabırsız bir komşudur: boş yer görünce hemen taşınır. Hareket et!",
    "Standing still lets pollution seep into clean land. Pollution is an impatient neighbor: it moves into any empty spot. Keep moving!")
add("GUIDE_REGION_2",
    "Yeni yerler açıldı: orman ve nehir! Nehir Kıyısı'nı haritaya işaretledim. Mayonu evde bırak: nehir şu an yüzmeye değil, ağlamaya uygun.",
    "New areas opened: forest and river! I marked the Riverbank. Leave your swimsuit at home: the river is currently suited for crying, not swimming.")
add("GUIDE_REGION_3",
    "Sanayi bölgesi açıldı. Bacalar her gece havayı zehirliyor, işaretledim. Orada ağaç dikmek bonus Çevre verir ama dumanlı hava seni çabuk yorar. Cesaret ister, ya da inat.",
    "The industrial district is open. The chimneys poison the air every night, I marked it. Planting there gives bonus Nature, but the smoggy air wears you out. It takes courage, or stubbornness.")
add("GUIDE_REGION_4",
    "Tarım ovası açıldı. Meyve ağaçları burada iyi yetişir: elma, armut... Hulusi'nin bu araziye sinsi sinsi baktığını da fark ettim. İşaretledim.",
    "The farmland is open. Fruit trees thrive here: apples, pears... I also noticed Hulusi eyeing this land slyly. I marked it.")
add("GUIDE_REGION_5",
    "Çöplük açıldı. Bol enerjiyle git, kokuyu görmezden gel. Ben koku alamıyorum, bu durumda tek avantajım. İşaretledim.",
    "The landfill is open. Bring lots of energy and ignore the smell. I can't smell anything, my only advantage here. I marked it.")
add("GUIDE_REGION_6",
    "Artık bütün harita açık. Son etap! 30. güne kadar dayan Başkanım. Ben de pilimi şarja takmadım, birlikte bitiriyoruz.",
    "The whole map is open. Final stretch! Hold on until day 30, Mayor. I skipped charging my battery too, so we finish this together.")
add("GUIDE_F_MINIMAP",
    "Sağ üstte mini harita! Beyaz nokta sensin, sarı artı pazar. Artık kaybolmak imkânsız. (Ben yine de kaybolurum, sorma.)",
    "A minimap in the top right! The white dot is you, the yellow cross is the market. Getting lost is no longer possible. (I'd still manage it, don't ask.)")
add("GUIDE_F_WELLS",
    "Kuyular açıldı. Birinin yanında Boşluk'a basarsan su içip enerji kazanırsın. En yakınını işaretledim. Su bedava, tek bedeli kuyudan gelen yankıya cevap vermemek.",
    "Wells are open. Press Space next to one to drink and restore energy. I marked the nearest. Water is free; the only price is not answering the echo from inside.")
add("GUIDE_F_CANAN",
    "Canan sokaklarda. Konuşursan hediye, ipucu ya da meydan okuma çıkar. Çok zeki biri, konuşurken ben de not alıyorum. İşaretledim.",
    "Canan is out in the streets. Talk to her for gifts, tips or challenges. She's very clever, I take notes while she talks. I marked her.")
add("GUIDE_F_RIZA",
    "Muhtar Rıza sokaklarda. Çayı çok sever, karşılığında işe yarar haberler verir. Ona çay ısmarlamak yatırımdır bence. (Bu yatırım tavsiyesi değildir.)",
    "Headman Rıza is out and about. He loves tea and pays you back with useful news. Buying him tea is an investment, I think. (This is not financial advice.)")
add("GUIDE_F_CHESTS",
    "Kasabaya gizli sandıklar saklanmış! Gezerek tohum ve Kasa bulabilirsin. Kim saklamış bilmiyorum, muhtemelen çok dağınık bir hazine avcısı.",
    "Hidden crates are scattered around town! Explore to find seeds and coins. I don't know who hid them, probably a very messy treasure hunter.")
add("GUIDE_F_OAK",
    "Meşe tohumu açıldı! Pahalı ve yorucu ama 3'e 3'lük alan temizler, en çok Çevre'yi verir. Tab ile tür değiştirirsin. Çam ucuz sandviç, meşe tam menü.",
    "Oak seeds unlocked! Pricey and tiring, but they clean a 3 by 3 area and give the most Nature. Tab switches type. Pine is a cheap sandwich; oak is the full menu.")
add("GUIDE_F_SHOP",
    "Pazardaki tezgâh açıldı. Pazarda U'ya basıp kalıcı geliştirmeler alabilirsin. Pazarı işaretledim. Alışveriş terapisi, yeşil versiyon.",
    "The market stall is open. Press U at the market for permanent upgrades. I marked the market. Retail therapy, green edition.")
add("GUIDE_F_GROVE",
    "İki karo arayla kümelenen ağaçlar koru oluşturur: bonus Çevre ve bedava tohum! Ağaçlar sosyaldir; yalnız bırakırsan küserler.",
    "Trees planted two tiles apart in a cluster form a grove: bonus Nature and a free seed! Trees are social. Leave them alone and they sulk.")
add("GUIDE_F_DUMP",
    "Bazen geceleri kaçak çöp dökülür. Sabah bulduğun yığınları temizle. Kim yapıyor? Soruşturdum: belli değil, ama kamyonun plakası 'HULUSİ' ile başlıyor... şaka. Çoğunlukla.",
    "Sometimes trash is dumped illegally at night. Clean the piles you find in the morning. Who does it? I investigated: unclear, but the plate starts with 'HULUSI'... just kidding. Mostly.")
add("GUIDE_F_FRUIT",
    "Meyve ağaçları açıldı. Az Çevre verir ama her akşam Kasa kazandırır. Hem akciğer hem maaş: kasabanın en iyi çalışanı.",
    "Fruit trees are open. A little Nature, but they pay coins every evening. Both lung and salary: the town's best employee.")
add("GUIDE_F_FIRE",
    "Artık orman yangınları çıkabilir. Yanan ağaca koş, Boşluk ile söndür; yoksa yayılır. Ağaç yanarken kuş bile 'ben bu işin içinde değilim' diyor.",
    "Wildfires can start now. Run to a burning tree and press Space to put it out before it spreads. When a tree burns, even the birds say 'not my problem'.")
add("GUIDE_F_FILTER",
    "Fabrika bacalarına filtre takabilirsin. Filtresiz her baca geceleri Çevre götürür. Bir fabrikayı işaretledim. Filtre bacanın maskesidir: bacalar maske takarsa herkes mutlu.",
    "You can fit filters on factory chimneys. Each unfiltered chimney costs Nature every night. I marked a factory. A filter is a chimney's face mask: if chimneys wear masks everyone's happy.")
add("GUIDE_F_SMOG",
    "Dumanlı günlerde enerji çok daha hızlı tükenir. Rıza bir gün önceden haber verebilir. Ben duman günlerinde pas tutuyorum, o yüzden senin için ekstra endişeleniyorum.",
    "Smog days drain energy much faster. Rıza can warn you a day ahead. I rust on smog days, so I worry about you extra.")
add("GUIDE_F_LOGGER",
    "Kaçak oduncular ağaçlarımızı kesiyor! Birinin yanına gidip Boşluk ile kov. Kavga etme, sadece 'Hişt!' de. Şaşırtıcı derecede işe yarıyor.",
    "Illegal loggers are cutting our trees! Walk up to one and press Space to chase him off. No fighting, just yell 'Hey!' It works surprisingly well.")
add("GUIDE_F_RABBIT",
    "Bazen altın bir tavşan çıkar! Shift ile koş, yanında Boşluk'a bas, yakala. Neden altın? Bilmiyorum. Belki Hulusi boyadı.",
    "A golden rabbit sometimes shows up! Sprint with Shift, press Space next to it to catch it. Why golden? No idea. Maybe Hulusi painted it.")
add("GUIDE_F_AIRDROP",
    "Bazı günler gökten tohum kutuları düşer! Oku takip et, süre dolmadan topla. Gökyüzünün yıllardır ilk iyi niyetli işi.",
    "Some days crates of seeds fall from the sky! Follow the arrow and grab them before time runs out. The sky's first act of goodwill in years.")
add("GUIDE_F_RACE", "Yarış! Hızlı dik, süre ekranın üstünde. Rekabet ruhu! (Ben tribünde bayrak sallarım.)", "A race! Plant fast, the timer is at the top. Competitive spirit! (I'll wave a flag from the stands.)")
add("GUIDE_F_FLOOD",
    "Seller nehir kıyısında insanları mahsur bırakabilir. Yanlarında Boşluk'a bas, süre dolmadan pazara götür. Seni yavru ördekler gibi takip edecekler.",
    "Floods can strand people on the riverbank. Press Space next to them, then lead them to the market before time runs out. They'll follow you like ducklings.")
add("GUIDE_F_HEAT",
    "Kuraklık ağaçları kurutur. Kuyuda Boşluk ile kovayı doldur, sonra kuruyan ağaçları sula. Süre var! Ağaçlar kibarca şikâyetçi: sadece yapraklarını döküyorlar.",
    "Heatwaves wither trees. Fill a bucket at a well with Space, then water the wilting trees. There's a timer! The trees complain politely: they only drop their leaves.")
add("GUIDE_F_LEAK",
    "Fabrikalarda zehirli variller akıtıyor. Her birinin yanında Boşluk'a art arda basarak kapat. Pompalamak gibi düşün, ritim önemli. Bunun için bir şarkı yazdım, dinlemek ister misin? Hayır mı. Peki.",
    "Toxic barrels leak at the factories. Stand next to each and mash Space to seal it. Think of it as pumping, rhythm matters. I wrote a song for it. Want to hear? No? Okay.")
add("GUIDE_F_STORM",
    "Yıldırımlı fırtına! Kırmızı daire yıldırımın düşeceği yeri gösterir. Hareket et, dairelerden uzak dur. Sen çarpılırsan ben de çarpılırım. Lütfen çarpılma.",
    "Lightning storm! A red circle shows where lightning will strike. Keep moving and stay out of the circles. If you get hit, I get hit too. Please don't.")
add("GUIDE_F_RECYCLE",
    "Topladığın çöpler torbana girer. Pazarda R'ye bas: her 4 çöp bir tohum ve Kasa olur. Çöpten para! Simyacı olduk.",
    "Trash you pick up goes into your bag. Take it to the market and press R: every 4 pieces turn into a seed and coins. Money from garbage! We've become alchemists.")
add("GUIDE_F_FAVORS",
    "Başkanım, komşular artık yardım isteyecek! Yanlarına git, evet de: her biri küçük bir meydan okuma (çilingirlik, kedi kurtarma, davul çalma, lastik şişirme: Başkanlık ilanında yazmıyordu). Komşuluk Defteri seni ödüllendirir.",
    "Mayor, neighbors will now ask for help! Walk up and say yes: each one is a little challenge (lockpicking, cat rescue, drumming, tire pumping: none of it was in the mayor's job listing). The Neighbor Book rewards you.")
add("GUIDE_STORY_HINT_CANAN", "Canan seninle konuşmak istiyor. Heyecanlı görünüyordu, ağzında kalem vardı. Haritaya işaretledim.", "Canan wants to talk to you. She seemed excited, a pencil in her mouth. I marked her on your map.")
add("GUIDE_STORY_HINT_RIZA", "Muhtar Rıza'nın önemli bir sözü var. Çayı soğumadan git. İşaretledim.", "Headman Rıza has something important to say. Go before his tea gets cold. I marked him.")
add("GUIDE_STORY_HINT_HULUSI", "Hulusi seni arıyor. Elinde bavul gördüm. İyi bir işaret değil. Haritaya işaretledim.", "Hulusi is asking for you. I saw a suitcase in his hand. Not a good sign. I marked him on the map.")
add("GUIDE_STORY_HINT_PINAR", "Küçük Pınar sana bir şey soracak. Çocuk sorusu: cevabı zor, kaçmak imkânsız. Haritada işaretli.", "Little Pınar wants to ask you something. A kid's question: hard to answer, impossible to dodge. Marked on the map.")
add("GUIDE_STORY_HINT_VELI", "Değirmendeki Veli Dede'nin sana anlatacağı bir hikâye var. Sandalyeni hazır tut, uzun sürebilir. İşaretledim.", "Grandpa Veli at the mill has a story for you. Keep your chair ready, it may take a while. I marked him.")
add("GUIDE_STORY_HINT_KEMAL", "Ustabaşı Kemal seninle konuşmak istiyor. Kaşları çatık ama kalbi yumuşak, bence. Haritaya işaretledim.", "Foreman Kemal wants a word. Frowning brows but a soft heart, I think. I marked him on your map.")
add("GUIDE_FINALE",
    "Başkanım, bugün son gün. Bütün tohumlarımız, bütün dostlarımız hazır. Son nefese kadar dikelim. (Şu an biraz akıyorum ama bu pas, merak etme.)",
    "Mayor, it's the last day. All our seeds, all our friends are ready. Let's plant until the last breath. (I'm leaking a little but it's just rust, don't worry.)")

# ====================================================================== Bölüm girişleri
add("CH1_INTRO",
    "Kasaba seni bekliyor: tozlu, öksüren ve şaşırtıcı derecede iyimser. Tohum ek, çöp topla, insanlarla tanış. Küçük bir kızın senden bir isteği var. (Ağaç istiyor. Büyük bir tane.)",
    "The town awaits you: dusty, coughing and surprisingly optimistic. Plant seeds, collect trash, meet people. A little girl has a request. (She wants a tree. A big one.)")
add("CH2_INTRO",
    "Karasu'nun kıyısında eski bir değirmen ve ondan da eski bir efsane var. Yeni yüzler, yeni tehlikeler, yeni bahaneler. Müteahhit Hulusi'nin bir 'ufak teklifi' var, kulakların çınlasın.",
    "By the Karasu stands an old mill and an even older legend. New faces, new dangers, new excuses. Contractor Hulusi has a 'tiny proposal'. Your ears should be ringing.")
add("CH3_INTRO",
    "Karatepe Çelik'in kapıları açıldı. Duman, işçiler ve her şeyi değiştirebilecek eski bir şema. Bir de filtre meselesi: bacalar için maske zamanı.",
    "The gates of Karatepe Steel are open. Smoke, workers and an old blueprint that could change everything. Also the filter question: mask time for the chimneys.")
add("CH4_INTRO",
    "Tarlalarda toprak nefes alıyor. Kayıp bir günlük, bir sır ve kime güveneceğin üzerine bir karar. Bir de yabancı bir yatırımcı geliyor: şapkası büyük, vaatleri daha büyük.",
    "The soil breathes in the fields. A lost diary, a secret and a choice about whom to trust. Also a foreign investor arrives: big hat, bigger promises.")
add("CH5_INTRO",
    "Çöp tepelerinin ardında kasabanın en eski sırrı yatıyor. Kül onu yeniden gömmeden çıkar. Burnunu tutmak serbest, korkaklık sayılmaz.",
    "Behind the garbage hills lies the town's oldest secret. Dig it up before the ash buries it again. Holding your nose is allowed and not counted as cowardice.")
add("CH6_INTRO",
    "Herkes ya yanında ya karşında. Beş gün kaldı. Son nefese kadar dik. Ve lütfen bu kez Hulusi'ye 'evet' deme.",
    "Everyone is either with you or against you. Five days left. Plant until the last breath. And please don't say 'yes' to Hulusi this time.")

# ====================================================================== Tepkiler (karar sonrası). REACT_<KARAKTER>_<GREEN|DIRTY|MEH>_<1|2>
_R = {
    "RIZA": {
        "GREEN": [("Rıza çayını yudumladı: 'Eh... bu iş yürür gibi.'", "Rıza sipped his tea: 'Well... this just might work.'"),
                  ("Rıza: 'Helal olsun Başkanım. Mahalle bunu çay ocağında bir hafta konuşur.'", "Rıza: 'Well done, Mayor. The neighborhood will talk about this at the tea house for a week.'")],
        "DIRTY": [("Rıza kaşlarını kaldırdı: 'Başkanım, ciğerlerimiz kararlarınıza bağlı. Hatırlatayım dedim.'", "Rıza raised his brows: 'Mayor, our lungs depend on your decisions. Just a reminder.'"),
                  ("Rıza çayını bıraktı. 'Bu karara çay yetmez, bir de simit lazım.'", "Rıza put down his tea. 'This decision needs more than tea, it needs a bagel.'")],
        "MEH": [("Rıza omuz silkti: 'Ne iyi ne kötü. Tam bir muhtarlık kararı.'", "Rıza shrugged: 'Neither good nor bad. A true headman's decision.'"),
                ("Rıza: 'Peki Başkanım, mahalleye öyle söylerim.' Ne söyleyeceğini bilmiyor.", "Rıza: 'Alright Mayor, I'll tell the neighborhood.' He has no idea what he'll say.")],
    },
    "CANAN": {
        "GREEN": [("Canan gözlüğünü düzeltip gülümsedi: 'Verilere göre... bu güzel.'", "Canan adjusted her glasses and smiled: 'According to the data... this is nice.'"),
                  ("Canan not defterine yıldız çizdi. Üç tane.", "Canan drew a star in her notebook. Three of them.")],
        "DIRTY": [("Canan'ın gözlüğü buğulandı: 'Bu kararın grafiğini göstermek istemezdim.'", "Canan's glasses fogged up: 'I'd rather not show you the graph of this decision.'"),
                  ("Canan fidan saksısını sıkıca tuttu: 'Tamam. Tamam. Nefes alıyorum.'", "Canan gripped her sapling pot: 'Okay. Okay. I'm breathing.'")],
        "MEH": [("Canan: 'Bilimsel olarak ne diyeceğimi bilemedim, o yüzden... mm.'", "Canan: 'Scientifically I don't know what to say, so... mm.'"),
                ("Canan: 'Ölçeceğim, sonra söylerim. Kızarsam belli olur.'", "Canan: 'I'll measure it and tell you later. If I blush, you'll know.'")],
    },
    "HULUSI": {
        "GREEN": [("Hulusi dişlerini sıktı: 'Çok güzel... çok... güzel. Mühahaha... yani, tebrikler.'", "Hulusi gritted his teeth: 'Very nice... very... nice. Muahaha... I mean, congratulations.'"),
                  ("Hulusi bavuluna sarıldı: 'Doğa dostu olmak da bir yatırım. Ben de bir gün deneyeceğim.'", "Hulusi hugged his suitcase: 'Being eco-friendly is an investment too. I'll try it one day.'")],
        "DIRTY": [("Hulusi: 'Mühahaha! ...öhöm. Yani, ne güzel bir iş birliği.'", "Hulusi: 'Muahaha! ...ahem. I mean, what a lovely collaboration.'"),
                  ("Hulusi elini kalbine koydu: 'Karatepe'nin geleceği parlak. Hatta dumandan görünmüyor bile.'", "Hulusi put his hand on his heart: 'Karatepe's future is bright. You can't even see it through the smoke.'")],
        "MEH": [("Hulusi: 'Yani ne evet ne hayır? Siz ciddi bir diplomatsınız. Korkutucu.'", "Hulusi: 'So neither yes nor no? You're a serious diplomat. Frightening.'"),
                ("Hulusi saatine baktı: 'Bu karar da geçer. Her şey geçer. Zarflar hariç.'", "Hulusi checked his watch: 'This decision will pass too. Everything passes. Except envelopes.'")],
    },
    "EVENT": {
        "GREEN": [("Siren sustu. Odada tarif edilemez bir huzur var. Biri öksürdü ama mutlu bir öksürük.", "The siren fell silent. The room is wonderfully calm. Someone coughed, but a happy cough."),
                  ("Alarm lambası yeşile döndü. Aslında sarı. Ama niyet güzeldi.", "The alarm light turned green. Actually yellow. But the intention was nice.")],
        "DIRTY": [("Siren bir kez daha öttü, sanki 'Bunu yapmasaydın' dercesine.", "The siren wailed once more, as if saying 'You shouldn't have.'"),
                  ("Pencereden bir baca odaya selam gönderdi.", "From the window, a chimney sent greetings to the room.")],
        "MEH": [("Siren mırıldandı, sonra bir şey olmamış gibi durdu.", "The siren hummed, then stopped as if nothing had happened."),
                ("Ne olduğunu kimse anlamadı ama bir şey oldu.", "Nobody understood what happened, but something did.")],
    },
    "ASSISTANT": {
        "GREEN": [("Tomurcuk: 'Bunu not aldım. Üç kere. Birini yedek aldım.'", "Sprout: 'I noted this. Three times. One as a backup.'"),
                  ("Tomurcuk sevinçten gözlerini yeşil yaptı. Normalde mavi ama bugün yeşil.", "Sprout turned his eyes green with joy. Normally blue, but today green.")],
        "DIRTY": [("Tomurcuk: 'Başkanım, gözlerim bu karar için tasarlanmadı.'", "Sprout: 'Mayor, my eyes were not designed for this decision.'"),
                  ("Tomurcuk'un pili aniden %3 düştü. Üzüntü pil yer.", "Sprout's battery suddenly dropped 3%. Sadness eats battery.")],
        "MEH": [("Tomurcuk: 'Mmm. Hesaplıyorum... hesaplıyorum... Tamam, hesaplayamadım.'", "Sprout: 'Mmm. Calculating... calculating... Okay, couldn't calculate.'"),
                ("Tomurcuk: 'Kararsızlık da bir karardır. Bunu çıkartma yaparız.'", "Sprout: 'Indecision is also a decision. We'll make it a sticker.'")],
    },
    "NEZAKET": {
        "GREEN": [("Nezaket Teyze: 'Aferin evladım! Bak sana bir börek daha.' Börek masaya düştü.", "Auntie Nezaket: 'Well done, dear! Here's another pastry for you.' The pastry landed on the desk."),
                  ("Nezaket Teyze gözlerini sildi: 'Annen görse gurur duyardı. Ben de duyuyorum, annen olmasam da.'", "Auntie Nezaket wiped her eyes: 'Your mother would be proud. I am too, even though I'm not your mother.'")],
        "DIRTY": [("Nezaket Teyze: 'Ah evladım ah. Bu karar da yağlı börek gibi: içine girince çıkamıyorsun.'", "Auntie Nezaket: 'Oh dear, oh dear. This decision is like a greasy pastry: once you're in, you can't get out.'"),
                  ("Nezaket Teyze başını salladı: 'Tövbe tövbe. Mahalleye söylemeyeceğim. Söylemek zorundayım.'", "Auntie Nezaket shook her head: 'Heavens. I won't tell the neighborhood. I have to tell the neighborhood.'")],
        "MEH": [("Nezaket Teyze: 'Olur, olur. Ben çay koyuyorum, böreği de ısıtırım.'", "Auntie Nezaket: 'Fine, fine. I'll make tea and warm up the pastry.'"),
                ("Nezaket Teyze: 'Peki, peki. Giderken kapıyı çarpacağım ama sessizce.'", "Auntie Nezaket: 'Alright, alright. I'll slam the door on my way out, but quietly.'")],
    },
    "MIRMIR": {
        "GREEN": [("Mırmır gözlerini kıstı ve tek bir 'mırr' çıkardı. Bu onun 'Alkış'ı.", "Mırmır narrowed her eyes and let out a single 'purr'. That's her applause."),
                  ("Mırmır kuyruğunu dikip masadan zıpladı. Başkan Yardımcısı onaylıyor.", "Mırmır raised her tail and jumped off the desk. The Deputy Mayor approves.")],
        "DIRTY": [("Mırmır sana soğuk soğuk baktı, sonra tüy bıraktı. Bu şiddetli bir eleştiri.", "Mırmır gave you a cold stare, then left some fur. A harsh critique."),
                  ("Mırmır masadan bir kalem düşürdü. Yavaşça. Gözünü kırpmadan.", "Mırmır knocked a pen off the desk. Slowly. Without blinking.")],
        "MEH": [("Mırmır esnedi. Kararına verdiği cevap bu.", "Mırmır yawned. That's her answer to your decision."),
                ("Mırmır kendini yalamaya başladı. Fikri yok.", "Mırmır started licking herself. No opinion.")],
    },
    "DEFNE": {
        "GREEN": [("Defne not defterini çevirdi: 'Bu manşet olur.' Gülümsedi: iyi anlamda.", "Defne turned her notebook: 'This is a headline.' She smiled: in a good way."),
                  ("Defne kalemini ısırdı: 'Dürüst olayım, ben de şaşırdım.'", "Defne bit her pen: 'To be honest, I'm surprised too.'")],
        "DIRTY": [("Defne tek kaşını kaldırdı: 'Bunu yazmayacağım. Hayır, yazacağım. Üç sütun.'", "Defne raised one brow: 'I won't write this. No, I will. Three columns.'"),
                  ("Defne: 'Yarın okuyucular bunu çok sevecek. Siz değil, ben.'", "Defne: 'Readers will love this tomorrow. Not you, me.'")],
        "MEH": [("Defne: 'Hmm. Bu bir manşet değil. Ama ben onu manşet yaparım.'", "Defne: 'Hmm. This isn't a headline. But I'll make it one.'"),
                ("Defne: 'Kararsızlık da haber. Hatta köşe yazısı.'", "Defne: 'Indecision is news too. Even a column.'")],
    },
    "BRUCE": {
        "GREEN": [("Bay Bruce: 'Fantastic! Very green, very sustainable, very... cheap?'", "Mister Bruce: 'Fantastic! Very green, very sustainable, very... cheap?'"),
                  ("Bay Bruce başını salladı: 'Ben de ağaç severim. Resimlerde.'", "Mister Bruce nodded: 'I like trees too. In pictures.'")],
        "DIRTY": [("Bay Bruce: 'Fantastic! Dirty is the new clean, nobody knows yet!'", "Mister Bruce: 'Fantastic! Dirty is the new clean, nobody knows yet!'"),
                  ("Bay Bruce şapkasını çıkarıp selam verdi: 'You are a person of business! Or mayor!'", "Mister Bruce tipped his hat: 'You are a person of business! Or mayor!'")],
        "MEH": [("Bay Bruce: 'Hmm. Maybe, maybe not. I am very diplomatic. Like a... sandwich.'", "Mister Bruce: 'Hmm. Maybe, maybe not. I am very diplomatic. Like a... sandwich.'"),
                ("Bay Bruce: 'I will think about it. Meanwhile, I will leave. Bye bye.'", "Mister Bruce: 'I will think about it. Meanwhile, I will leave. Bye bye.'")],
    },
}
for _char, _moods in _R.items():
    for _mood, _lines in _moods.items():
        for _i, (_tr, _en) in enumerate(_lines):
            add("REACT_%s_%s_%d" % (_char, _mood, _i + 1), _tr, _en)

# ====================================================================== Akşam gazetesi: manşet havuzları
_N = {
    "HIGH": [
        ("Karatepe Nefes Alıyor! Bir Vatandaş Alışkın Değil, Bayıldı", "Karatepe Breathes! One Citizen Unused to It Fainted"),
        ("Gökyüzünde İlk Mavi Yarık: Güvercinler Fotoğraf İstedi", "First Blue Crack in the Sky: Pigeons Ask for Photos"),
        ("Karatepe Yeşile Dönüyor, Halk Meydanda Selfie Çekiyor", "Karatepe Turns Green, Crowd Takes Selfies in the Square"),
        ("Ağaçlar Fırladı: 'Böyle Bir Gün Görmedik' Diyor Kuşlar", "Trees Shoot Up: 'Never Seen a Day Like This,' Say Birds"),
        ("Rekor Yeşillik! Hulusi'nin Bacası Utancından Kızardı", "Record Greenery! Hulusi's Chimney Blushes With Shame"),
    ],
    "UP": [
        ("Yeşil Umut Büyüyor, Bütçe Hâlâ Büyümüyor", "Green Hope Grows, Budget Still Doesn't"),
        ("Başkan Sahada: Toprak 'Teşekkürler' Dedi (Fısıltıyla)", "Mayor in the Field: Soil Said 'Thanks' (In a Whisper)"),
        ("Küçük Adımlar, Büyük Fark, Çok Küçük Çizmeler", "Small Steps, Big Difference, Very Small Boots"),
        ("Fidanlar Sevinçli, Çöpler Kaçıyor", "Saplings Cheer, Trash on the Run"),
        ("Bir Ağaç Daha, Bir Dert Daha Az", "One More Tree, One Less Worry"),
    ],
    "FLAT": [
        ("Karatepe'de Sıradan Bir Gün: Kimse Bir Şey Yapmadı (Resmen)", "An Ordinary Day in Karatepe: Nobody Did Anything (Officially)"),
        ("Hava Değişmedi, Dert de. Çay Fiyatları Arttı", "Air Unchanged, Worries Too. Tea Prices Up"),
        ("Şehir Nefesini Tutuyor, Cevap Bekliyor", "City Holds Its Breath, Awaiting an Answer"),
        ("Sakin Gün: Muhtarın Bıyığı Bile Kıpırdamadı", "Calm Day: Even the Headman's Mustache Didn't Move"),
        ("Bugün Hiçbir Şey Olmadı. Haber Yapmak Zor Oldu.", "Nothing Happened Today. Making News Was Hard."),
    ],
    "DOWN": [
        ("Hava Her Gün Biraz Daha Ağır: Sandalyeler Bile Öksürüyor", "Air Gets Heavier Every Day: Even the Chairs Are Coughing"),
        ("Gri Bulutlar Geri Döndü, Üstelik Bavullarıyla", "Gray Clouds Are Back, And With Luggage"),
        ("Karatepe Yine Öksürüyor: Doktor 'Yine Mi?' Dedi", "Karatepe Coughs Again: Doctor Says 'Again?'"),
        ("Kirlilik Artıyor, Çamaşırlar Gri Kurudu", "Pollution Rises, Laundry Dries Gray"),
        ("Nefes Alanlara Tavsiye: Biraz Daha Az Nefes Almak", "Advice to Those Who Breathe: Breathe a Bit Less"),
    ],
    "LOW": [
        ("Başkan Zehir Solutuyor: Maske Satışları Zirvede", "Mayor Inhales Poison: Mask Sales Peak"),
        ("Karatepe'de Zehirli Gün: Güvercinler Yürüyerek Kaçtı", "Toxic Day in Karatepe: Pigeons Fled on Foot"),
        ("Kül Yağmuru Şehri Kapladı: Çamaşırcılar İsyanda", "Ash Rain Covers the City: Laundromats in Revolt"),
        ("Hava Kalitesi: 'Hayır'. Başkanın Yorumu: 'Hmm'", "Air Quality: 'No'. Mayor's Comment: 'Hmm'"),
        ("Duman Bulutu Yeni Belediye Binası Sanıldı", "Smoke Cloud Mistaken for New City Hall"),
    ],
}
for _band, _lines in _N.items():
    for _i, (_tr, _en) in enumerate(_lines):
        add("NEWS_NAT_%s_%d" % (_band, _i + 1), _tr, _en)

_D = {
    "GREEDY": [
        ("Kasa doldu ama bedelini hava ödedi.", "The coffers are full but the air paid the price."),
        ("Sıcak para geldi, temiz hava gitti.", "Warm money arrived, clean air left."),
        ("Hulusi cebine baktı, Başkan çevreye: ikisi de mutsuz.", "Hulusi looked at his pocket, the Mayor at nature: both unhappy."),
        ("Para kokuyor, hava da öyle.", "Money stinks, and so does the air."),
    ],
    "POPULIST": [
        ("Halk memnun, ciğerleri değil.", "The people are pleased, their lungs aren't."),
        ("Bugünü kurtaran karar yarını kirletti.", "The decision that saved today polluted tomorrow."),
        ("Alkışlar yükseldi, dumanlar da.", "Applause rose, and so did the smoke."),
        ("Herkes mutlu, bir tek ağaçlar öfkeli.", "Everyone is happy except the trees."),
    ],
    "GREEN": [
        ("Sabah kararı doğaya yaradı.", "The morning decision did nature good."),
        ("Pahalı ama temiz bir karar.", "An expensive but clean decision."),
        ("Ağaçlar Başkan'a teşekkür notu bıraktı (yaprakla yazılmış).", "Trees left the Mayor a thank-you note (written on a leaf)."),
        ("Kuşlar şüpheli ama memnun.", "Birds are suspicious but pleased."),
    ],
    "AUSTERITY": [
        ("Kemerler sıkıldı, kimse memnun değil.", "Belts tightened, nobody pleased."),
        ("Masada zor bir sabah, dışarıda daha zor bir akşam.", "A hard morning at the desk, an even harder evening outside."),
        ("Kemer o kadar sıkıldı ki bazılarının iki kemeri koptu.", "Belts were tightened so much that some people broke two."),
        ("Tasarruf: kısık sesle, kısık ışıkla.", "Austerity: low voice, low light."),
    ],
    "NEUTRAL": [
        ("Başkan bugün kararsız kaldı.", "The Mayor stayed undecided today."),
        ("Başkan masasında ağır ağır düşündü.", "The Mayor thought slowly at the desk."),
        ("Başkan karar verdi: bir daha düşünmeye.", "The Mayor decided: to think again."),
        ("Karar çıktı, ne olduğunu kimse anlamadı.", "A decision was made, nobody understood what it was."),
    ],
}
for _cat, _lines in _D.items():
    for _i, (_tr, _en) in enumerate(_lines):
        add("NEWS_DEC_%s_%d" % (_cat, _i + 1), _tr, _en)

_E = {
    "FLOOD": [("Sel Kasabayı Bastı: Başkan Kurtardı, Ördekler Alkışladı", "Flood Hits Town: Mayor Rescues, Ducks Applaud"),
              ("Nehir Taştı! Mahsur Kalanlar 'Şemsiyemiz Yoktu' Dedi", "River Overflows! Stranded Say 'We Had No Umbrellas'")],
    "STORM": [("Yıldırım Çarptı! Başkan Ayakları Yerden Kesilerek Kaçtı", "Lightning Strikes! Mayor Flees, Feet Barely Touching Ground"),
              ("Fırtına Karatepe'yi Salladı: Saçlar Dik, Kuşlar Yüzünde Panik", "Storm Shakes Karatepe: Hair Stands Up, Birds Panic")],
    "HEAT": [("Kavurucu Sıcak! Ağaçlar Terledi, Kuyular İç Çekti", "Scorching Heat! Trees Sweat, Wells Sigh"),
             ("Kuraklık Vurdu: Kuyu Başında Uzun Kuyruk", "Drought Strikes: Long Queue at the Well")],
    "LEAK": [("Fabrikada Zehirli Sızıntı: Variller 'Biz Yapmadık' Dedi", "Toxic Leak at the Factory: Barrels Say 'Wasn't Us'"),
             ("Sızıntı Kapatıldı! Kahramanın Parmağı Hâlâ Boşluğa Basıyor", "Leak Sealed! Hero's Finger Still Pressing Space")],
    "AIRDROP": [("Gökten Tohum Yağdı: Meteorologlar Şaşkın, Çiftçiler Mutlu", "Seeds Rain From the Sky: Meteorologists Baffled, Farmers Delighted"),
                ("Havadan Kutu Yağdı! Güvercin 'Benim Değil' Dedi", "Crates Fall From the Sky! Pigeon Says 'Not Mine'")],
    "DUMP": [("Gece Yarısı Çöp Skandalı: Kamyonun Plakası 'Gizli'", "Midnight Garbage Scandal: Truck's Plate Reads 'Secret'"),
             ("Kaçak Çöp Dağı: Çöpçüler 'Biz Yeni Başlamıştık' Dedi", "Illegal Garbage Mountain: Cleaners Say 'We Had Just Started'")],
    "RAIN": [("Yağmur Yağdı, Karatepe Duş Aldı", "Rain Falls, Karatepe Takes a Shower"),
             ("Gökyüzü Ağladı, Çatılar Rahatladı", "Sky Weeps, Rooftops Relieved")],
    "SMOG": [("Duman Şehri Yuttu: Trafik Işıkları Birbirini Göremiyor", "Smog Swallows City: Traffic Lights Can't See Each Other"),
             ("Sis Değil Duman! Bakışlar Gri, Moraller de", "Not Fog, Smog! Looks Are Gray, So Is Morale")],
    "PEDDLER": [("Gezici Tohumcu Şehirde: Fiyatlar 'Sürpriz Ucuz'", "Traveling Seed Seller in Town: Prices 'Surprisingly Cheap'"),
                ("Tohum Tezgâhına Hücum: Kuyruk Köşeyi Döndü", "Rush on the Seed Stall: Queue Turned the Corner")],
    "FIRE": [("Orman Yangını Söndürüldü! Başkan Dumandan Siyah Çıktı", "Forest Fire Put Out! Mayor Emerges Black With Soot"),
             ("Alevler Yenildi: Kova Takımı Kahraman İlan Edildi", "Flames Defeated: Bucket Brigade Declared Heroes")],
    "BURNED": [("Yangın Ağaçları Yaktı: Kuşlar Kayıp İlanı Verdi", "Fire Burns Trees: Birds Post Missing Notices"),
               ("Yanan Ağaçlar İçin Yas: Kül Tohuma Dönecek mi?", "Mourning for Burned Trees: Will the Ash Turn to Seed?")],
    "LOGGER": [("Kaçak Oduncu Kovalandı: Baltası Ağaca Çarpıp Utandı", "Illegal Logger Chased: Axe Bumps Into Tree, Embarrassed"),
               ("Oduncu Yakalandı: 'Sadece Yürüyordum' Dedi", "Logger Caught: 'I Was Just Walking' He Says")],
    "FELLED": [("Kaçak Kesim: Ağaçlar Soruşturma İstiyor", "Illegal Felling: Trees Demand Investigation"),
               ("Baltalar Konuştu, Ormanlar Sustu", "Axes Spoke, Forests Fell Silent")],
    "RABBIT": [("Altın Tavşan Yakalandı! Hulusi 'O Benim' Diye Bağırdı", "Golden Rabbit Caught! Hulusi Shouts 'That's Mine'"),
               ("Tavşan Avı Bitti: Havuç Sponsorluğu Rekor Kırdı", "Rabbit Hunt Over: Carrot Sponsorship Breaks Record")],
    "FAVORS": [("Başkan Komşulara Yardım Etti: Kedi, Kapı, Davul, Lastik", "Mayor Helps Neighbors: Cat, Door, Drum, Tire"),
               ("Komşuluk Defteri Doldu, Başkanın Eli Yoruldu", "Neighbor Book Fills Up, Mayor's Hand Tired")],
    "PLANTED": [("Başkan Ormancı Mı Oldu? Bugün Rekor Fidan!", "Has the Mayor Become a Forester? Record Saplings Today!"),
                ("Tohum Yağmuru: Toprak Hâlâ Cevap Vermeye Çalışıyor", "Seed Shower: Soil Still Trying to Respond")],
    "IDLE": [("Başkan Bugün Hiç Ağaç Dikmedi: 'İlham Perisi İzinde'", "Mayor Planted No Trees Today: 'Muse Is on Leave'"),
             ("Tembellik Günü: Ağaçlar Bile Şaşırdı", "Laziness Day: Even the Trees Were Surprised")],
    "TRASH": [("Çöpler Cezalandırıldı: Başkan Sokakları Süpürdü", "Trash Punished: Mayor Swept the Streets"),
              ("Çöp Kutuları İlk Kez İş Buldu", "Trash Cans Finally Found Work")],
    "TEA": [("Çay Fiyatları Fırladı: Başkan Sebep Mi?", "Tea Prices Soar: Is the Mayor to Blame?"),
            ("Çay Ocağı Başkan'a Teşekkür Etti: Bardaklar Alkışladı", "Tea House Thanks Mayor: Glasses Applaud")],
}
for _ev, _lines in _E.items():
    for _i, (_tr, _en) in enumerate(_lines):
        add("NEWS_E_%s_%d" % (_ev, _i + 1), _tr, _en)

_T = [
    ("Hava durumu: yarın da pus bekleniyor.", "Weather: more haze expected tomorrow."),
    ("Pazar yerinde öksüren bir güvercin görüldü.", "A coughing pigeon was spotted at the marketplace."),
    ("Vatandaşlar soruyor: yıldızlar nereye gitti?", "Citizens ask: where did the stars go?"),
    ("Tohum fiyatları sabit, umut fiyatları yükselişte.", "Seed prices stable, hope prices rising."),
    ("Emekli muhtar: 'Bizim de bir nehrimiz vardı.'", "Retired headman: 'We used to have a river too.'"),
    ("Karatepe Postası hatırlatır: ağaçlar kendi kendine dikilmez.", "Karatepe Post reminds: trees don't plant themselves."),
    ("Belediye Kedisi Mırmır tekrar Başkan Yardımcısı seçildi. Oy: 1 (kendisi).", "Municipal Cat Mırmır re-elected Deputy Mayor. Votes: 1 (herself)."),
    ("Çay ocağında yeni skandal: şeker kesme mi, toz mu?", "New scandal at the tea house: cube sugar or granulated?"),
    ("Hava durumu: yarın yağmur, ertesi gün yağmur arayışı.", "Weather: rain tomorrow, a search for rain the day after."),
    ("Vatandaşlar sordu: hani ağaç dikilecekti? Başkan: dikiliyor, dikiliyor.", "Citizens asked: weren't trees being planted? Mayor: they are, they are."),
    ("Fabrika bacası 'Ben sigara içmiyorum' dedi. Kimse inanmadı.", "Factory chimney says 'I don't smoke'. Nobody believed it."),
    ("Muhtar Rıza: 'Bizim zamanımızda hava mavi, çay sıcak, belediye başkanı kayıptı.'", "Headman Rıza: 'In our day the air was blue, tea hot, and the mayor missing.'"),
    ("Pazarda domatesin fiyatı çıldırdı, soğan ağladı.", "Tomato prices went wild at the market, the onion wept."),
    ("Karatepe Spor yine kaybetti. Hakem kaybetmesin diye ağaç dikmiş.", "Karatepe FC lost again. The referee planted a tree so he wouldn't lose."),
    ("Tomurcuk robotu hâlâ tost makinesinden yetki bekliyor.", "Sprout the robot still awaits authorization from the toaster."),
    ("Nezaket Teyze'nin böreği yarışmada ikinci oldu. Birinci: Nezaket Teyze'nin başka böreği.", "Auntie Nezaket's pastry took second place. First place: another pastry by Auntie Nezaket."),
    ("Son dakika: köpekler barış anlaşmasını onayladı. Kediler 'Düşünüyoruz' dedi.", "Breaking: dogs ratify peace deal. Cats say 'We're thinking about it'."),
    ("Okul önünde ağaç, ağacın önünde Pınar. Pınar'ın önünde herkes ürküyor.", "A tree in front of the school, Pınar in front of the tree. Everyone is wary of Pınar."),
    ("Uyarı: Hulusi 'yeşil' kelimesini reklamlarda kullanmaktan men edildi.", "Warning: Hulusi has been banned from using the word 'green' in ads."),
    ("Mahalle muhtarı: 'Yarın yağmur yağacak. Yağmazsa ben de ağlarım.'", "Neighborhood headman: 'It will rain tomorrow. If not, I'll cry instead.'"),
]
for _i, (_tr, _en) in enumerate(_T):
    add("TICKER_%d" % (_i + 1), _tr, _en)

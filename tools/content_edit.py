# -*- coding: utf-8 -*-
"""Metin incelemesi sonrası düzeltmeler (metin_incelemesi.md). apply_content.py bunu EN SON içe aktarır, bu yüzden
aynı anahtarın eski sürümlerinin (content_*.py, story_*.py) üstüne yazar. Yeni düzenleme için buraya ekle.
Atlananlar: 18 (END_SUB_DEADLINE aynı kaldı), 24 ve 25 (Yiğithan replikleri aynı kaldı)."""
from content_texts import add

# --- A. Ana menü ve intro
add("GAME_SUBTITLE", "Bir kasaba, bir avuç tohum, otuz gün", "One town, a handful of seeds, thirty days")
add("INTRO_1", "Karatepe'de yağmur bile artık kül kokuyor.", "In Karatepe even the rain smells of ash now.")
add("INTRO_3", "Fabrikalar hiç durmuyor. Çamaşırlar soldu. Güneşi en son ne zaman gördüğünü kimse hatırlamıyor.",
    "The factories never stop. The laundry has faded. Nobody remembers when they last saw the sun.")
add("INTRO_5", "Rapor masanda. Özeti: otuz gün sonra burada kimse nefes alamayacak.",
    "The report is on your desk. The short version: in thirty days nobody here will be able to breathe.")
add("CREDITS_BODY",
    "Yapım: Eyüphan Binici\nMüzik ve çoğu ses efekti: bu oyun için kodla üretildi.\nÇizimler: Kenney.nl Tiny Town (CC0) ve kodla çizilen karakterler.\nYazı tipleri: SIL Open Font License. Motor: Godot 4.\nTüm kaynaklar: CREDITS.md.",
    "Created by Eyüphan Binici\nMusic and most sound effects: generated in code for this game.\nArt: Kenney.nl Tiny Town (CC0) and characters drawn in code.\nFonts: SIL Open Font License. Engine: Godot 4.\nAll sources: CREDITS.md.")

# --- B. Tomurcuk'un rehberi
add("GUIDE_WELCOME",
    "Merhaba Başkanım! Ben Tomurcuk: robot, rehber, ara sıra tost makinesi. Karatepe'yi kurtarmak için 30 günümüz var. Bugün kolay: yürü, ağaç dik. Gerisini sırayla anlatırım.",
    "Hello, Mayor! I'm Sprout: robot, guide, occasional toaster. We have 30 days to save Karatepe. Today is easy: walk and plant. I'll explain the rest as we go.")
add("GUIDE_CONTROLS",
    "WASD ile yürürsün, Shift ile koşarsın. Boşluk ağaç diker. Ağaç toprağı temizler, Çevre yükselir. Kirli toprakta enerjin daha çabuk biter.",
    "WASD to walk, Shift to run. Space plants a tree. Trees clean the soil and raise Nature. On dirty ground your energy drains faster.")
add("GUIDE_TRASH",
    "Çöpün üstünden geçersen toplanır. Peş peşe toplarsan zincir bonusu gelir. Şimdi ilk ağacını dik.",
    "Walk over trash to collect it. Grab several in a row for a combo bonus. Now plant your first tree.")
add("GUIDE_FIRST_PLANT",
    "İlk ağaç dikildi! Not: durursan kirlilik geri yayılır, üstüne kasaba her gece biraz Çevre kaybeder. Yani durma.",
    "First tree planted! A note: if you stand still the pollution creeps back, and the town loses some Nature every night. So keep moving.")
add("GUIDE_NO_SEEDS",
    "Tohumun bitti. Pazardan Kasa ile yenisini alabilirsin: oku takip et, orada Boşluk'a bas.",
    "Out of seeds. You can buy more at the market with coins: follow the arrow and press Space there.")
add("GUIDE_F_MINIMAP",
    "Sağ üstte mini harita! Beyaz nokta sensin, sarı artı pazar. Artık kaybolmak imkânsız.",
    "A minimap in the top right! The white dot is you, the yellow cross is the market. Getting lost is no longer possible.")
add("GUIDE_F_RIZA",
    "Muhtar Rıza sokaklarda. Çayı çok sever, karşılığında işe yarar haberler verir.",
    "Headman Rıza is out and about. He loves tea and pays you back with useful news.")
add("GUIDE_F_SHOP",
    "Pazardaki tezgâh açıldı. Pazarda U'ya basıp kalıcı geliştirmeler alabilirsin. Pazarı işaretledim.",
    "The market stall is open. Press U at the market for permanent upgrades. I marked the market.")
add("GUIDE_F_FRUIT",
    "Meyve ağaçları açıldı. Çevreye az katkı verir ama her akşam Kasa getirir.",
    "Fruit trees are open. They add little Nature but bring in coins every evening.")
add("GUIDE_F_LEAK",
    "Fabrikalarda zehirli variller akıtıyor. Her birinin yanında Boşluk'a art arda basarak kapat. Pompalamak gibi düşün, ritim önemli.",
    "Toxic barrels leak at the factories. Stand next to each and mash Space to seal it. Think of it as pumping, rhythm matters.")
add("GUIDE_FINALE",
    "Başkanım, bugün son gün. Bütün tohumlarımız, bütün dostlarımız hazır. Son nefese kadar dikelim.",
    "Mayor, it's the last day. All our seeds, all our friends are ready. Let's plant until the last breath.")
add("GUIDE_F_FAVORS",
    "Başkanım, komşular artık yardım isteyecek! Yanlarına git, evet de: her biri küçük bir oyun (kedi kurtarmak, portakal yakalamak, düğünde çalmak, köstebek kovmak...). Başkanlık ilanında yazmıyordu. Komşuluk Defteri seni ödüllendirir.",
    "Mayor, neighbors will now ask for help! Walk up and say yes: each one is a little game (rescuing a cat, catching oranges, playing at a wedding, chasing moles...). It wasn't in the mayor's job listing. The Neighbor Book rewards you.")
add("GUIDE_F_SMOG",
    "Dumanlı günlerde enerji çok daha hızlı tükenir. Rıza bir gün önceden haber verebilir.",
    "Smog days drain energy much faster. Rıza can warn you a day ahead.")

# --- C. Aforizma ve bilge cümleler
add("END_WIN_REDEEMED", "Karatepe nefes alıyor. Hulusi bile Pınar'ın ağacının yanına bir fidan dikiyor.",
    "Karatepe breathes again. Even Hulusi plants a tree beside Pınar's.")
add("NPC_VELI_IDLE_3", "Otur evladım, bir nefes al. Ağaçlar kaçmaz.", "Sit, child, take a breath. The trees aren't going anywhere.")
add("NPC_VELI_IDLE_6", "Bu sözü gençken bir yerde duydum. Nerede, onu unuttum.", "I heard this saying somewhere when I was young. Where, I've forgotten.")
add("FIELD_QUIP_TEA_5", "Bir bardak çay daha, bir ağaç daha.", "One more glass of tea, one more tree.")
add("TICKER_4", "Tohum fiyatları sabit, çay yine zamlı.", "Seed prices stable, tea prices up again.")
add("END_Q_REVOLT", "Bu sefer halk sesini duyurdu. Bir dahaki sefere önce dinleyelim.", "This time the people made themselves heard. Next time, let's listen first.")
add("END_WHY_REVOLT", "Neden: Halk memnuniyeti sıfıra indi.", "Cause: Public approval fell to zero.")
add("END_WHY_BANKRUPT", "Neden: Kasa sıfıra indi.", "Cause: The treasury hit zero.")
add("END_Q_BANKRUPT", "Para bitti ama tohumlar duruyor. Bir daha deneyelim, bu sefer parayı ağaçlara harcayalım.",
    "The money ran out but the seeds are still here. Let's try again and spend the money on trees this time.")
add("END_Q_POLLUTION", "Bu sefer yetişemedik. Daha erken ağaç dikelim, ben de yanındayım.", "We didn't make it in time. Let's plant earlier, I'm right beside you.")
add("END_WHY_POLLUTION", "Neden: Çevre sıfıra indi.", "Cause: Nature hit zero.")

# --- D. Bölüm girişleri
add("CH1_INTRO",
    "Kasaba seni bekliyor: tozlu, öksüren ama hâlâ umutlu. Tohum ek, çöp topla, insanlarla tanış. Küçük bir kızın senden bir isteği var. (Ağaç istiyor. Büyük bir tane.)",
    "The town awaits you: dusty, coughing, but still hopeful. Plant seeds, collect trash, meet people. A little girl has a request. (She wants a tree. A big one.)")
add("CH2_INTRO",
    "Karasu'nun kıyısında eski bir değirmen, ondan da eski bir efsane var. Müteahhit Hulusi'nin de bir 'ufak teklifi' var, kulakların çınlasın.",
    "By the Karasu stands an old mill and an even older legend. Contractor Hulusi also has a 'tiny proposal'. Your ears should be ringing.")
add("CH6_INTRO", "Herkes ya yanında ya karşında. Beş gün kaldı. Bu kez Hulusi'ye 'evet' deme, lütfen.",
    "Everyone is either with you or against you. Five days left. Please don't say 'yes' to Hulusi this time.")

# --- E. Tekrar eden şakalar: "mühahaha" (REACT_HULUSI_DIRTY_1, NPC_HULUSI_IDLE_7 ve rehber açıklaması kalır)
add("CARD_F1_BETON_LOBISI_RA", "Hulusi: 'Ne güzel bir iş birliği.' Sırıtmamak için dudaklarını ısırdı.",
    "Hulusi: 'What a lovely collaboration.' He bit his lip to keep from grinning.")
add("CARD_F2_BETON_IHANETI_RA", "Hulusi parmaklarını birbirine kenetledi. 'Teşekkür ederim, çok teşekkür ederim.' Bir boya kovası daha getirtti.",
    "Hulusi laced his fingers. 'Thank you, thank you so much.' He ordered another bucket of paint.")
add("CARD_F3_RUSVET_SKANDALI_RA", "Hulusi: 'Teşekkürler, çok naziksiniz.' Zarf bir cepten ötekine geçti, kimse kimin cebinden çıktığını bilmiyor.",
    "Hulusi: 'Thanks, you're too kind.' The envelope slid from one pocket to another and nobody knows whose it was.")
add("NEWS_C_F3_RUSVET_SKANDALI_A", "Rüşvet Skandalı: Zarf Cepten Cebe Geçti, Kimse Görmedi",
    "Bribery Scandal: Envelope Moved From Pocket to Pocket, Nobody Saw")
add("REACT_HULUSI_GREEN_1", "Hulusi dişlerini sıktı: 'Çok güzel... çok... güzel. Tebrikler.'",
    "Hulusi gritted his teeth: 'Very nice... very... nice. Congratulations.'")
add("STORY_HULUSI_2_R1", "Zevkle çalışmış olalım!", "Pleasure doing business!")
add("CARD_D_HULUSI_REKLAM_RB", "Hulusi telefonda bir şey mırıldandı, sonra 'öhöm' diyerek ahizeyi kapattı.",
    "Hulusi mumbled something into the phone, then said 'ahem' and hung up.")
add("CARD_H_REKLAM_RB", "Pano söküldü. Hulusi güldü ama sonra gözleri doldu.", "The billboard came down. Hulusi laughed but then his eyes teared up.")
add("NEWS_C_H_REKLAM_B", "Dev Pano Söküldü: Hulusi Önce Güldü, Sonra Sustu", "Giant Billboard Removed: Hulusi Laughed First, Then Fell Silent")

# --- "zarf içinde zarf" (CHAR_HULUSI_ROLE, kart F1_BETON_LOBISI, STORY_HULUSI_1_R1, OUTRO_HULUSI_JUSTICE kalır)
add("CARD_M_GERI_DONUS_RA", "Hulusi kravatı kucakladı: 'Altın, ama duygusal!' Sana bir kutu çikolata uzattı. İçi boştu.",
    "Hulusi hugged the tie: 'Gold, but sentimental!' He handed you a box of chocolates. It was empty.")
add("NEWS_C_M_GERI_DONUS_A", "Altın Kravat Hulusi'ye Döndü: Mırmır Pati İzi Bıraktı", "Golden Tie Back With Hulusi: Mırmır Left Paw Prints")
add("NEWS_C_D_HULUSI_REKLAM_B", "Haber Sızmadı: Hulusi'den Minnet Çikolatası", "Story Never Leaked: Thank-You Chocolates From Hulusi")
add("CARD_B_VEDA_RB", "Valizin içinde 14 poster, 3 kravat ve Hulusi'nin kayıp çikolatası çıktı. Bruce: 'Ben sadece taşıyordum.'",
    "The suitcase held 14 posters, 3 ties and Hulusi's missing chocolates. Bruce: 'I was only carrying it.'")
add("NEWS_C_B_VEDA_B", "Bruce'un Valizi Arandı: Poster, Kravat, Çikolata Çıktı", "Bruce's Suitcase Searched: Posters, Ties, Chocolates Found")
add("NPC_HULUSI_IDLE_8", "Hayat kısa, bavul ağır.", "Life is short, suitcases are heavy.")
add("FAVOR_SAFE_WIN", "Kasa açıldı! İçinde bir sürü evrak ve kedi maması vardı. Hulusi: 'Gördüğünüz her şey şeffaf!'",
    "The safe opened! Inside: lots of paperwork and cat food. Hulusi: 'Everything you see is transparent!'")
add("FIELD_NO_MONEY", "Kasa yetmiyor! Hulusi'den borç mu istesek?", "Not enough coins! Shall we ask Hulusi for a loan?")

# --- Yiğithan'ın tekrarları
add("STORY_YIGITHAN_5_R1", "Tamam. O gün gözüm dolarsa duman yüzündendir, bilesin. Baykuşa da söylerim.",
    "Okay. If my eyes well up that day it's the smoke, mark my words. I'll tell the owl too.")
add("NPC_YIGITHAN_IDLE_6", "Dün bir meşeye sarıldım. Gören olmadı, Gece hariç.", "Yesterday I hugged an oak. Nobody saw, except Gece.")
add("OUTRO_YIGITHAN_1", "Son Ağaç 'Biraz Daha' dikildi. Gece havalandı. Yiğithan bir süre ağaca baktı, kürek sapına yaslandı.",
    "The Last Tree 'A Little More' was planted. Gece took flight. Yiğithan looked at the tree for a while and leaned on his shovel.")
add("OUTRO_YIGITHAN_2", "Yiğithan ve Gece ormanda nöbette. Yeni fidanları tek tek sayıyorlar.",
    "Yiğithan and Gece stand watch in the forest. They count the new saplings one by one.")
add("END_Q_WIN_2", "Ormanın sesi duyuluyor Başkan. Gece de sana teşekkür ediyor: Huu.", "The forest can be heard, Mayor. Gece thanks you too: Hoo.")
add("END_SUB_WIN_3", "Karatepe'de çocuklar gökyüzünü ilk kez gördü. Ne olduğunu anlamadı ama yüzündeki gülümseme her şeye değerdi.",
    "In Karatepe the children saw the sky for the first time. They didn't understand what it was, but the smile on their faces was worth everything.")

# --- Dil hataları ve küçük düzeltmeler
add("FIELD_FIRST_TREE", "İlk ağacın! Kasaba iyileşmeye başlıyor. Ağacın henüz haberi yok.", "Your first tree! The town starts healing. The tree doesn't know yet.")
add("FIELD_TEA_LIMIT", "Bugünlük çay bitti.", "No more tea today.")

# --- F. Şakayı açıklayan kartlar
add("CARD_F5_AVM_ACILISI_TEXT",
    "AVM'nin açılışı! Hulusi: 'Başkan, kurdeleyi sen kes!' Kurdele, ovadan sökülen çimlerden örülmüş. Hulusi bile biraz utanıyor.",
    "The mall opening! Hulusi: 'Mayor, cut the ribbon!' The ribbon is woven from grass torn from the plain. Even Hulusi is a bit ashamed.")
add("CARD_F2_GECEKONDU_TEXT",
    "Hulusi lüks site yapmak için gecekonduları yıkmak istiyor. Adı: 'Gecekondu Vista Residence'. Reklamında kuş sesi var, kuş yok.",
    "Hulusi wants to demolish the shanties for a luxury complex. Name: 'Shanty Vista Residence'. The ad has bird sounds, there are no birds.")
add("CARD_F4_NEHIR_YATAGI_TEXT",
    "Hulusi kurumuş nehir yatağına rezidans yapmak istiyor: 'Nehir yok, sorun yok! Manzara bile satarım: Nehir Manzaralı Daireler.'",
    "Hulusi wants to build residences on the dried riverbed: 'No river, no problem! I even sell views: River View Apartments.'")
add("CARD_F1_NEHIR_RESTORAN_TEXT",
    "Hulusi nehir kenarına 'Hulusi'nin Sahil Lokantası' açmak istiyor. Atıklar nehre gidecek ama 'nehir buna alışık, bak, hiç şikâyet etmiyor.' Nehir itiraz etmedi, köpükten konuşamıyordu.",
    "Hulusi wants to open 'Hulusi's Seaside Restaurant' by the river. The waste will go into the river, but 'the river is used to it, look, it never complains.' The river didn't object, it couldn't speak for the foam.")

# --- Kuru kartlara tek cümlelik ses (46)
DRY = {
    "F1_SU_BORUSU": ("Eski altyapı çöktü, mahalleleri su bastı. Çocuklar sokakta kâğıttan kayık yarıştırıyor.",
                     "The old infrastructure collapsed and water flooded the neighborhoods. Kids are racing paper boats down the street."),
    "F1_ELEKTRIK_KESINTISI": ("Eski trafolar yanıyor. Kimse söndürmeye cesaret edemiyor, çünkü ellerinde kova yok.",
                              "The old transformers are burning. Nobody dares put them out, because nobody has a bucket."),
    "F1_ORMAN_KESIMI": ("Oduncular kış için ağaç kesme izni ister. Baltalar çoktan bilenmiş, cevaptan emin görünüyorlar.",
                        "Lumberjacks ask for a permit to cut trees for the winter. Their axes are already sharpened; they seem sure of the answer."),
    "F1_COP_GREVI": ("Çöp toplayıcıları maaş zammı istiyor. Pankartları çöp torbasından yapılmış.",
                     "The garbage collectors demand a raise. Their banners are made of garbage bags."),
    "F1_ILAC_EKSIGI": ("Kış hastalıkları başladı, sağlık ocağında ilaç yok. Doktor reçeteye 'bol çay' yazıyor.",
                       "Winter illnesses have begun, and the clinic has no medicine. The doctor is writing 'plenty of tea' on prescriptions."),
    "F1_OKUL_CATISI": ("Fırtınada lisenin çatısı uçtu. Bütçe yok. Öğrenciler derslerin açık havada olmasına sevindi.",
                       "A storm blew the high school roof off. There is no budget. The students are happy that class is outdoors now."),
    "F1_SOKAK_KOPEKLERI": ("Şehir merkezinde köpek çeteleri oluştu. Simitçi artık simidi yüksekten satıyor.",
                           "Gangs of stray dogs have formed in the city center. The simit seller now sells from a high shelf."),
    "F2_BILET_ZAMMI": ("Belediye bütçesi açık veriyor. Biletlere zam yapılmalı mı? Tomurcuk hesap yaptı, sonucu söylemeye çekiniyor.",
                       "The municipal budget is running a deficit. Should ticket prices go up? Sprout did the math and is hesitant to share the result."),
    "F2_ISIKLANDIRMA": ("Tasarruf için sokak lambaları gece kapatılsın mı? Güvercinler memnun, yarasalar daha da memnun.",
                        "Should the street lamps be switched off at night to save money? Pigeons are happy about it, bats even more."),
    "F2_POSET_YASAGI": ("Canan şehirde plastik poşeti yasaklamak istiyor. Pazarcılar poşet stoklarına sarılmış durumda.",
                        "Canan wants to ban plastic bags in the city. The vendors are clinging to their bag stocks."),
    "F2_SPOR_KULUBU": ("Şehrin amatör futbol takımı Karatepe Spor batmak üzere. Son maçı 9-0 kaybettiler, hakem bile üzüldü.",
                       "The city's amateur football team, Karatepe Spor, is about to go under. They lost their last match 9-0; even the referee felt bad."),
    "F2_ARITMA_BOZULDU": ("Eski arıtma tesisi çöktü. Tamiri çok pahalı. Müdür 'Zaten pek arıtmıyordu' diyor.",
                          "The old treatment plant has broken down. Repairing it is very expensive. The manager says, 'It wasn't treating much anyway.'"),
    "F2_FESTIVAL": ("Halk moral bulmak için bahar festivali istiyor. Programda çay içme yarışması ve çuval koşusu var.",
                    "People want a spring festival to lift their spirits. The program includes a tea-drinking contest and a sack race."),
    "F3_HAVA_UYARISI": ("Bugün hava çok kirli, okulları tatil edelim. Öğrenciler çoktan çantalarını toplamış.",
                        "The air is very polluted today. Let's close the schools. The students have already packed their bags."),
    "F3_SU_KESINTISI": ("Baraj seviyesi düştü. Suları günde 12 saat kesmek gerekiyor. Mahalle çeşmelerinde kuyruk şimdiden başladı.",
                        "The dam level has dropped. Water must be cut for 12 hours a day. Queues at the neighborhood fountains have already started."),
    "F3_BALIK_OLUMLERI": ("Nehirde balıklar ölmeye başladı. Veli Dede iskelede sessizce oturuyor.",
                          "Fish have started dying in the river. Old Veli sits quietly on the pier."),
    "F3_ESKI_BASKAN_BORCU": ("Eski başkandan kalan kredi borcunun taksidi geldi. Bildirimin köşesinde eski başkanın el yazısıyla 'Kolay gelsin' yazıyor.",
                             "The installment of the loan debt left by the former mayor has come due. In the corner of the notice, in the former mayor's handwriting: 'Good luck.'"),
    "F4_MASKE": ("Hava kirliliğinden maske takmak zorunlu olsun mu? Rıza maskeyle çay içemeyeceğini söylüyor.",
                 "Should wearing masks be mandatory because of the air pollution? Rıza says he can't drink tea in a mask."),
    "F4_HAVA_FILTRESI": ("Okullara hava temizleyici filtre alınmalı. Pınar şimdiden filtreye bir isim koymuş.",
                         "Air purifier filters should be bought for the schools. Pınar has already given the filter a name."),
    "F5_GUNES_TARLASI": ("Canan boş araziye güneş tarlası kurmak istiyor. Kuşlar panellerin üstünde dinlenmeye şimdiden sıraya girdi.",
                         "Canan wants to build a solar field on the empty land. The birds are already lined up to rest on the panels."),
    "F5_SU_KACAKLARI": ("Mahallelerde borular delik deşik, su kaçıyor. Mırmır sızıntının yanında uyuyor, onu hiçbir şey rahatsız etmiyor.",
                        "The pipes in the neighborhoods are full of holes and water is leaking. Mırmır naps next to a leak; nothing bothers her."),
    "F6_KURAK_YAZ": ("Kuraklık barajı kuruttu. Barajın dibinden iki eski bisiklet ve bir buzdolabı çıktı.",
                     "The drought has dried up the dam. Two old bicycles and a refrigerator surfaced from the bottom."),
    "F6_COP_AYIRMA": ("Halk çöp ayırma kampanyası istiyor. Nezaket Teyze renkli kovaları şimdiden sipariş etmiş.",
                      "People want a waste-sorting campaign. Auntie Nezaket has already ordered the colored bins."),
}
for card_id, (tr_text, en_text) in DRY.items():
    add("CARD_%s_TEXT" % card_id, tr_text, en_text)

# --- G. Karakter boş konuşma satırları
add("NPC_RIZA_IDLE_1", "Bugün haber yok Başkanım, çay demli.", "No news today, Mayor. The tea is steeped.")
add("NPC_RIZA_IDLE_2", "Sen işine bak, ben bir şey duyarsam söylerim.", "You go on with your work, I'll tell you if I hear anything.")
add("NPC_RIZA_IDLE_3", "Çay bitti, yenisi demleniyor. Birazdan gel.", "The tea ran out, a fresh pot is brewing. Come back in a bit.")
add("NPC_KEMAL_IDLE_1", "Vardiyadayım Başkan, sonra konuşuruz.", "I'm on shift, Mayor. We'll talk later.")
add("NPC_CANAN_IDLE_3", "İşim çok, sonra konuşuruz. Ağaçları unutma.", "I'm swamped, we'll talk later. Don't forget the trees.")

# --- H. Ev
add("HOME_FINE_HAPPY", "Komşular kapıya çiçek bırakmış!", "Neighbors left flowers at the door!")
add("HOME_NEIGHBORS_FIXED", "Komşular gece camlarını bedavaya taktı.", "Neighbors fixed your windows for free overnight.")
add("HOME_FINE", "Evimiz sağlam, camlar yerinde. Halk kızmadığı sürece böyle kalır.",
    "The house is fine, windows intact. It stays that way as long as the people aren't angry.")

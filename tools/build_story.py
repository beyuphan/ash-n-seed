"""Hikâye verisini üretir: scripts/field/story_data.gd (sahneler, etkiler) ve translations/strings.csv (metinler).
Tek kaynak bu dosya. Yeni sahne için beat(...) ekle, bu betiği çalıştır."""
import csv
import json
import os

os.chdir('D:/Projects/cop31')
BEATS = {}
TEXTS = {}  # anahtar -> (en, tr)


def beat(bid, npc, day, at, lines, choices, window=3, req=None, not_=None, variant=None):
    """lines: [(tr, en)]. choices: [{"label": (tr, en), "result": (tr, en), "fx": {...}}].
    variant: (flag, (trY, enY), (trN, enN)): ilk konuşma bayrağa göre değişir."""
    key = "STORY_" + bid.upper()
    data = {"npc": npc, "day": day, "window": window, "at": at, "req": req or [], "not": not_ or [],
            "variant": variant[0] if variant else "", "lines": len(lines), "choices": []}
    for i, (tr, en) in enumerate(lines):
        if i == 0 and variant:
            TEXTS[key + "_L1_Y"] = (variant[1][1], variant[1][0])
            TEXTS[key + "_L1_N"] = (variant[2][1], variant[2][0])
        else:
            TEXTS["%s_L%d" % (key, i + 1)] = (en, tr)
    for i, c in enumerate(choices):
        TEXTS["%s_C%d" % (key, i + 1)] = (c["label"][1], c["label"][0])
        TEXTS["%s_R%d" % (key, i + 1)] = (c["result"][1], c["result"][0])
        data["choices"].append(c["fx"])
    BEATS[bid] = data


# =============================================================== PERDE 1: UYANIŞ (1-10)

beat("pinar_1", "pinar", 2, "okul_avlu", [
    ("Başkan! Başkan! Sen ağaç dikiyorsun, değil mi? Annem ağaç diye bir şey olduğunu söylüyor ama ben hiç görmedim.",
     "Mayor! Mayor! You plant trees, right? Mom says trees exist, but I have never seen one."),
    ("Bana bir tane diker misin? Göletin yanına. Büyüyünce altında oturacağım!",
     "Will you plant one for me? Next to the pond. When it grows, I will sit under it!"),
], [
    {"label": ("Tabii, hemen şimdi!", "Of course, right now!"),
     "result": ("Yaşasın! Gölet kenarına bir fidan diktik. Her gün bakacağım, sakın ona bir şey olmasın!",
                "Hooray! We planted a sapling by the pond. I will check on it every day, do not let anything happen to it!"),
     "fx": {"people": 3, "pinar_tree": True, "flags": ["pinar_tree"], "promise": "pinar_tree"}},
    {"label": ("Büyüyünce konuşuruz.", "We will talk when you are older."),
     "result": ("Hıh. O zaman ben kendi başıma dikerim. Küçük bir tane, kimse görmesin.",
                "Hmph. Then I will plant it myself. A small one, so nobody sees."),
     "fx": {"people": -1, "pinar_tree": True, "flags": ["pinar_alone"]}},
], window=4)

beat("canan_1", "canan", 3, "fidanlik_on", [
    ("Hoş geldiniz Başkanım! Ben Canan. Bu fidanlık benim, şu cam yığını da laboratuvarım. Bir saniye... o robot.",
     "Welcome, Mayor! I am Canan. This nursery is mine, and that glass heap is my lab. One second... that robot."),
    ("Tomurcuk?! Hocam Selim'in Tomurcuk'u! Hocamı iki yıl önce kaybettik ama toprakta bir iz bıraktı: kasabanın Tohum Bankası çöplüğün altında gömülü.",
     "Sprout?! Professor Selim's Sprout! We lost him two years ago, but he left a trace in the soil: the town's Seed Bank is buried under the landfill."),
    ("Ona ulaşmak için önce kasabayı temizlemeliyiz. Bana güveniyor musunuz?",
     "To reach it we must clean the town first. Do you trust me?"),
], [
    {"label": ("Güveniyorum, anlat.", "I trust you. Go on."),
     "result": ("Teşekkür ederim! Bu deneme tohumlarını alın. Çöplüğe yaklaştıkça konuşuruz.",
                "Thank you! Take these test seeds. We will talk as we get closer to the landfill."),
     "fx": {"seeds": {"pine": 3}, "people": 2, "flags": ["canan_trust"], "promise": "canan_lab"}},
    {"label": ("Önce kanıt göster.", "Show me proof first."),
     "result": ("Haklısınız. Kanıt getireceğim, o zamana dek bunlar sizde kalsın.",
                "Fair enough. I will bring proof. Keep this for now."),
     "fx": {"money": 6, "flags": ["canan_skeptic"]}},
], window=4)

beat("riza_1", "riza", 4, "cay_ocagi_on", [
    ("Başkanım, buyurun bir çay. Hayır hayır, bu sefer ısmarlıyorum. Bir şey söyleyeceğim, ayakta zor söylenir.",
     "Mayor, have some tea. No no, my treat this time. I have something to say that is hard to say standing."),
    ("Fabrikalar kapanırsa yüz aile işsiz kalır. Ama bu duman çocukları hasta ediyor. Halk sizden bir söz bekliyor.",
     "If the factories close, a hundred families lose their jobs. But this smoke makes the children sick. The people want a promise from you."),
], [
    {"label": ("Hem iş hem temiz hava: ikisine de söz.", "Jobs and clean air: I promise both."),
     "result": ("Halk rahatladı. Ama sözünüzü tutmalısınız Başkanım, yoksa çay bile soğur.",
                "The people are relieved. But you must keep your word, Mayor, or even the tea goes cold."),
     "fx": {"people": 6, "flags": ["promise"], "promise": "riza_word"}},
    {"label": ("Önce hava. Gerisi sonra.", "Air first. The rest comes after."),
     "result": ("Sert ama dürüst. Bazıları kızacak, ben de onlara çay ikram ederim.",
                "Harsh but honest. Some will be angry, and I will serve them tea."),
     "fx": {"nature": 2, "people": -3, "flags": ["air_first"]}},
])

beat("veli_1", "veli", 6, "degirmen_on", [
    ("Çarkı döndüren su artık kokuyor evladım. Eskiden bu değirmen buğday öğütmezdi, tohum saklardı.",
     "The water that turns the wheel smells now, child. This mill never ground wheat. It kept seeds."),
    ("Karatepe'yi tohum bekçileri kurmuş. Her evin bir tohum küpü varmış. 'Kül düşünce Tohum uyanır' derlermiş.",
     "Karatepe was founded by seed keepers. Every house had a seed jar. They said: when the Ash falls, the Seed wakes."),
    ("Efsane işte. Sen yaşlı bir adamı dinler misin?", "Just a legend. Will you listen to an old man?"),
], [
    {"label": ("Sonuna kadar dinlerim.", "I will listen to the end."),
     "result": ("Aferin. Al şunu, dedemin küpünden kalma. Toprağa karışınca anlarsın.",
                "Good. Take this, from my grandfather's jar. You will understand when it meets the soil."),
     "fx": {"seeds": {"oak": 2}, "flags": ["veli_legend"], "promise": "veli_fish"}},
    {"label": ("Efsaneye vaktim yok.", "I have no time for legends."),
     "result": ("Vakit nehir gibidir evladım, akar gider. Neyse, kolay gelsin.",
                "Time is like a river, child. It flows away. Anyway, good luck."),
     "fx": {"people": -1}},
], window=4)

beat("hulusi_1", "hulusi", 8, "pazar_on", [
    ("Sayın Başkan! Hulusi, Karatepe Çelik. Şu çeşmeyi hep sevmişimdir, susuz kalması yüreğimi burkuyor.",
     "Mayor! Hulusi, Karatepe Steel. I have always loved that fountain. Seeing it dry breaks my heart."),
    ("Onarımı ben yaptırırım. Karşılığında yeni bacamıza ufak bir izin. Hem kasaba kazanır, hem ben.",
     "I will pay for the repair. In return, a small permit for our new chimney. The town wins, and so do I."),
], [
    {"label": ("Anlaştık, çeşme çalışsın.", "Deal. Fix the fountain."),
     "result": ("Harika! Zarf masanızda. Çeşme de yakında akar.", "Splendid! The envelope is on your desk. The fountain will run soon."),
     "fx": {"money": 25, "pollution": 0.3, "flags": ["deal"]}},
    {"label": ("Kasaba satılık değil.", "This town is not for sale."),
     "result": ("Ne yazık... Pişman olabilirsiniz dostum.", "A pity... You may regret this, my friend."),
     "fx": {"people": 3, "flags": ["refused"]}},
])

beat("canan_2", "canan", 9, "orman_kulubesi_on", [
    ("Nehrin suyunu analiz ettim Başkanım. Ağır metal, hem de bol. Çocuklar bu suyu içiyor.",
     "I analyzed the river water, Mayor. Heavy metals, plenty. Children drink this water."),
    ("Daha kapsamlı bir test için 15 Kasa lazım. Sonuçlar elimizde koz olur.",
     "A fuller test needs 15 coins. The results would be our trump card."),
], [
    {"label": ("Al, 15 Kasa.", "Here, 15 coins."),
     "result": ("Tamam, sonuçlar yazılı. Fabrikayı sıkıştırırken kullanacağız.", "Done, the results are on paper. We will use them to press the factory."),
     "fx": {"cost": 15, "people": 1, "flags": ["lab_report"]}},
    {"label": ("Şimdilik yok.", "Not for now."),
     "result": ("Anlıyorum, elimdekilerle idare ederim.", "I understand. I will manage with what I have."),
     "fx": {}},
])

# =============================================================== PERDE 2: DUMAN VE TOPRAK (11-20)

beat("kemal_1", "kemal", 11, "lojman_on", [
    ("Sen kimsin, Başkan mı? Fabrika benim ekmeğim, çoluk çocuğun ekmeği. Bacaları söndürmeye geldiysen yürü git.",
     "Who are you, the Mayor? The factory is my bread, my family's bread. If you came to put out the chimneys, move along."),
    ("Ama biliyor musun, benim oğlum da öksürüyor. Her gece. Söyle bana: hem iş hem hava mümkün mü?",
     "But you know, my son coughs too. Every night. Tell me: are jobs and air both possible?"),
], [
    {"label": ("Mümkün. Birlikte yapacağız.", "It is possible. We will do it together."),
     "result": ("Hı. Büyük laf. Ama dinlerim. İşçileri ben toplarım, filtre işinde yanındayım.",
                "Hm. Big words. But I will listen. I will gather the workers and stand by you on the filters."),
     "fx": {"people": 3, "flags": ["workers_ally"], "promise": "kemal_filter"}},
    {"label": ("Kirletenle uzlaşma olmaz.", "No compromise with polluters."),
     "result": ("O zaman biz de seninle uzlaşmayız Başkan. Bakalım kim kazanacak.",
                "Then we will not compromise with you either, Mayor. Let us see who wins."),
     "fx": {"nature": 2, "people": -3, "flags": ["workers_angry"]}},
], window=4)

beat("canan_3", "canan", 12, "fabrika_kapisi_on", [
    ("Fabrika kapısının yanında eski filtre şemalarını buldum. Hocam Selim yıllar önce çizmiş.",
     "Near the factory gate I found old filter blueprints. Professor Selim drew them years ago."),
    ("Atölyede ucuza yaptırabilirim ama malzemeye 15 Kasa lazım.", "I can have them made cheaply, but materials need 15 coins."),
], [
    {"label": ("Al, 15 Kasa.", "Here, 15 coins."),
     "result": ("Tamam! Artık filtreler 7 Kasa daha ucuz.", "Done! Filters now cost 7 coins less."),
     "fx": {"cost": 15, "people": 1, "flags": ["filter_cheap"]}},
    {"label": ("Şimdilik bütçem yok.", "My budget is empty for now."),
     "result": ("Anlıyorum. Elimden geleni yaparım.", "I understand. I will do what I can."),
     "fx": {}},
])

beat("pinar_2", "pinar", 13, "okul_avlu", [
    ("Başkan, ağacım büyüdü mü? Bak, yaprağı çıkmış! ...öhö öhö.",
     "Mayor, did my tree grow? Look, it has a leaf! ...cough cough."),
    ("Bugün hava yine ağır. Öğretmen pencereleri kapattırdı. Ağaçlar da nefes alamıyor mu, onlar da öksürüyor mu?",
     "The air is heavy again. The teacher had the windows shut. Do trees struggle to breathe too? Do they cough?"),
], [
    {"label": ("Al, bu maskeyi tak.", "Here, wear this mask."),
     "result": ("Çok teşekkürler! Sen ağaçla sözleştin, ben de sana söz: büyüyeceğiz!", "Thank you so much! You made a deal with my tree, and I promise you: we will grow!"),
     "fx": {"cost": 5, "people": 4, "flags": ["pinar_cared"]}},
    {"label": ("Eve git, dinlen.", "Go home and rest."),
     "result": ("Tamam... Ama yarın ağaca bakmaya geleceğim.", "Okay... But I will come check on the tree tomorrow."),
     "fx": {"people": 1}},
])

beat("riza_2", "riza", 14, "belediye_on", [
    ("Başkanım, işçiler meydanda toplandı. Kızgınlar ve işlerinden korkuyorlar.",
     "Mayor, the workers gathered in the square. They are angry and afraid for their jobs."),
    ("Onları ağaç dikmeye verirsek yatışırlar. Maliyeti 20 Kasa.", "If we put them to work planting trees, they would calm down. It costs 20 coins."),
], [
    {"label": ("Çalıştırın. İşte 20 Kasa.", "Put them to work. Here are 20 coins."),
     "result": ("Alkışlıyorlar! Kemal de meşe fidanı getirdi.", "They are cheering! Kemal even brought oak saplings."),
     "fx": {"cost": 20, "people": 8, "seeds": {"oak": 2}, "flags": ["workers_planting"]}},
    {"label": ("Şimdi olmaz. Yatışırlar.", "Not now. They will calm down."),
     "result": ("Yatışmıyorlar Başkanım. Güven eriyor.", "They are not calming down, Mayor. Trust is draining."),
     "fx": {"people": -4, "extra_if": {"flag": "promise", "people": -4}}},
])

beat("veli_2", "veli", 15, "degirmen_on", [
    ("Çatı katında bir sandık buldum evladım. Selim'in günlüğü. Hani şu kayıp profesörün.",
     "I found a chest in the attic, child. Selim's journal. The lost professor."),
    ("Yazıyor ki: Tohum Bankası çöplüğün en dibinde. Çöp oraya kazara dökülmedi. Karatepe Çelik'in kamyonları gecelerce üstünü örttü.",
     "It says: the Seed Bank lies at the bottom of the landfill. The trash was not dumped by accident. Karatepe Steel's trucks covered it night after night."),
    ("Ne yapacaksın bu bilgiyle?", "What will you do with this knowledge?"),
], [
    {"label": ("Hulusi'yle yüzleşeceğim.", "I will confront Hulusi."),
     "result": ("Cesursun. Ama dikkat et, o adam gülümserken ısırır.", "You are brave. But careful, that man bites while smiling."),
     "fx": {"people": 2, "flags": ["journal", "confront_plan"]}},
    {"label": ("Önce Canan'a danışalım.", "Let us consult Canan first."),
     "result": ("Akıllıca. Taş, acele edenin ayağına düşer.", "Wise. The stone falls on the foot of the hasty."),
     "fx": {"seeds": {"oak": 1}, "flags": ["journal", "careful"]}},
], window=4)

beat("hulusi_2", "hulusi", 17, "genel_mudurluk_on", [
    ("-", "-"),
    ("Her şeyin bir fiyatı var Başkanım. Sizinki ne?", "Everything has a price, Mayor. What is yours?"),
    ("Kimseye zararım yok. Sadece geçmişi eşelemeyin.", "I mean no harm. Just do not dig through the past."),
], [
    {"label": ("Parayı kabul et.", "Take the money."),
     "result": ("Zevkle çalışmış olalım!", "A pleasure doing business!"),
     "fx": {"money": 25, "pollution": 0.3, "flags": ["deal2"]}},
    {"label": ("Hayır. Geçmişini biliyorum.", "No. I know your past."),
     "result": ("Bilmek ayrı, kanıtlamak ayrı Başkanım. Görürüz.", "Knowing is one thing, proving another, Mayor. We shall see."),
     "fx": {"people": 3, "money": -8, "flags": ["enemy"]}},
], variant=("deal",
            ("Anlaşmamız iyi işliyor Başkanım. Bir baca daha istiyorum, aynı şartlarla.", "Our arrangement works well, Mayor. I want one more chimney, same terms."),
            ("Vazgeçtiğimi sanmayın. Bu sefer diktiğiniz fidan başına ödeme öneriyorum, sessizce.", "Do not think I gave up. This time I offer payment per sapling you plant, quietly.")))

beat("kemal_2", "kemal", 18, "sendika_on", [
    ("-", "-"),
    ("Çöplüğe kamyonlar gidiyor Başkan, gece vardiyasında gördüm. Yüzlerce. Fabrika atığını dibe gömüyorlar.",
     "Trucks go to the landfill, Mayor. I saw them on the night shift. Hundreds. They bury the factory waste at the bottom."),
    ("Yıllardır biliyoruz ama susmak zorundaydık. İstersen kapıyı sana ben açarım.", "We have known for years but had to stay silent. If you want, I will open the gate for you."),
], [
    {"label": ("Kapıyı aç, birlikte yürüyeceğiz.", "Open the gate. We walk together."),
     "result": ("Nöbet değişimi gece ikide. Kapı açık olacak.", "Shift change is at two at night. The gate will be open."),
     "fx": {"people": 3, "flags": ["kemal_gate"]}},
    {"label": ("Kendi yolumu bulurum.", "I will find my own way."),
     "result": ("Peki. Kapıyı kapatmam ama açmam da.", "Fine. I will not shut the gate, but I will not open it either."),
     "fx": {}},
], variant=("workers_ally",
            ("Dostum. Sana güvenerek söylüyorum, kimse duymasın.", "My friend. I tell you this trusting you, let nobody hear."),
            ("Senden hoşlanmıyorum Başkan ama çocuklar için sustuğumu bırakıyorum.", "I do not like you, Mayor, but for the children I stop being silent.")))

beat("canan_4", "canan", 20, "ciftlik_on", [
    ("Selim'in günlüğünü Tomurcuk'la çözdük Başkanım. Tohum Bankası'nın kapısı yalnızca 'Kül' altında uyanıyormuş.",
     "Sprout and I decoded Selim's journal, Mayor. The Seed Bank's door only wakes under the Ash."),
    ("Çöplükteki çöpü temizleyip kapının önünü açmamız gerek. Hazır mısınız?", "We must clear the trash and open the front of the door. Are you ready?"),
], [
    {"label": ("Hazırım. Çöplüğe gidiyoruz.", "I am ready. We go to the landfill."),
     "result": ("Yarın çöplük kapısında buluşalım. Bol enerjiyle gelin!", "Meet me at the landfill gate tomorrow. Bring plenty of energy!"),
     "fx": {"people": 2, "flags": ["vault_plan"]}},
])

# =============================================================== PERDE 3: ÇÖPLÜK VE SON NEFES (21-30)

beat("canan_5", "canan", 21, "copluk_kapisi_on", [
    ("Çöp tepelerinin ardında bir kapı var Başkanım! Taş kapı, paslı kilitler... Hocamın dediği yer!",
     "Behind the trash mounds there is a door, Mayor! A stone door, rusty locks... The place my professor spoke of!"),
    ("Kapıyı açabilirim. İçeridekileri ne yapacağız: hepsini hemen ekelim mi, yoksa bir kısmını geleceğe saklayalım mı?",
     "I can open it. What do we do with what is inside: plant everything now, or save some for the future?"),
], [
    {"label": ("Hepsini şimdi ekelim.", "Let us plant them all now."),
     "result": ("Toprak hepsini içine çekecek!", "The soil will drink them all in!"),
     "fx": {"nature": 3, "seeds": {"oak": 4}, "flags": ["seeds_all", "vault_open"], "vault_open": True}},
    {"label": ("Yarısını saklayalım.", "Let us save half."),
     "result": ("Akıllıca. Her sabah bir tohum fazlamız olacak.", "Wise. Every morning we will have one extra seed."),
     "fx": {"people": 3, "seeds": {"oak": 2, "pine": 4}, "flags": ["seeds_saved", "vault_open"], "vault_open": True}},
], window=4)

beat("veli_3", "veli", 23, "iskele_ucu", [
    ("Kapı açıldı demek. Kül düştü, Tohum uyanıyor... Eski sözü yerine getirelim evladım.",
     "So the door opened. The Ash has fallen, the Seed wakes... Let us keep the old promise, child."),
    ("Tohumları halka biçiminde dikersen toprak onları kardeş sayar. Bir ağaç diğerini besler. Merasimi birlikte yapalım mı?",
     "Plant the seeds in a ring and the soil counts them as siblings. One tree feeds the other. Shall we do the ceremony together?"),
], [
    {"label": ("Merasimi yapalım.", "Let us do the ceremony."),
     "result": ("Gözlerin ışıldıyor. Çevre bunu hisseder.", "Your eyes shine. The land can feel it."),
     "fx": {"nature": 2, "people": 2, "flags": ["grove_ritual"]}},
    {"label": ("Zamanımız dar.", "We are short on time."),
     "result": ("Zaman dardır evladım ama toprağın sabrı geniştir.", "Time is short, child, but the patience of the soil is wide."),
     "fx": {"seeds": {"pine": 2}}},
])

beat("hulusi_3", "hulusi", 25, "tohum_bankasi_on", [
    ("Demek buldunuz. Babamın bıraktığı pislik... ama kamyonları ben de durdurmadım Başkanım. İtiraf ediyorum.",
     "So you found it. The filth my father left... but I did not stop the trucks either, Mayor. I admit it."),
    ("Şimdi bir teklifiniz var, değil mi? Ya da benim size.", "Now you have an offer, don't you? Or I have one for you."),
    ("Ne yapacağız dostum?", "What shall we do, my friend?"),
], [
    {"label": ("Hesap vereceksin. Her şey gazetede.", "You will answer for this. Everything goes public."),
     "result": ("...Anlıyorum. Avukatım bile bunu önermezdi. Anahtarlar sende, kayıtlar da.", "...I see. Not even my lawyer would suggest this. The keys are yours, and the records."),
     "fx": {"people": 4, "money": -10, "pollution": -0.3, "filter": 3, "flags": ["hulusi_justice"]}},
    {"label": ("Bir fon kur. Temizlik senin yükün.", "Set up a fund. Cleaning up is your burden."),
     "result": ("Bu... adil. Hatta teselli. Yarın sabah ilk iş.", "That is... fair. Even a comfort. First thing tomorrow morning."),
     "fx": {"money": 25, "people": 2, "pollution": -0.4, "filter": 2, "flags": ["hulusi_redeemed"]}},
    {"label": ("Sessiz kal, bağışını al.", "Stay quiet and take your donation."),
     "result": ("Güzel. Çocuklar nefes alacak mı, onu bilmem.", "Good. Whether the children will breathe, I do not know."),
     "fx": {"money": 40, "nature": -8, "flags": ["sold"]}},
])

beat("riza_3", "riza", 26, "belediye_on", [
    ("Başkanım, bütün kasaba meydanda. Sizi dinlemek istiyorlar. Ben çaylarını doldurdum, sıra sizde.",
     "Mayor, the whole town is in the square. They want to hear you. I filled their teas, now it is your turn."),
    ("Nasıl bir ton tutturalım?", "What tone shall we take?"),
], [
    {"label": ("Umuttan söz et.", "Speak of hope."),
     "result": ("Ağlıyorlar ve alkışlıyorlar. Umut yayılıyor.", "They are crying and cheering. Hope is spreading."),
     "fx": {"people": 6, "flags": ["speech_hope"]}},
    {"label": ("Zor gerçeği söyle.", "Tell the hard truth."),
     "result": ("Ağır bir sessizlik, sonra alkış. Dürüstlüğe saygı duyuyorlar.", "A heavy silence, then applause. They respect honesty."),
     "fx": {"people": 2, "nature": 3, "flags": ["speech_truth"]}},
])

beat("kemal_3", "kemal", 27, "sendika_on", [
    ("-", "-"),
    ("Fabrikada oylama yaptık: bacaları söndürüp tek vardiyaya geçiyoruz. Sen ne dersin Başkan?", "We voted at the factory: we shut the chimneys and move to one shift. What do you say, Mayor?"),
], [
    {"label": ("Sonuna kadar destekliyorum.", "I support it to the end."),
     "result": ("Yarın ilk vardiyada bacalar sönecek!", "Tomorrow, on the first shift, the chimneys go dark!"),
     "fx": {"people": 3, "pollution": -0.5, "filter": 2, "flags": ["stacks_off"]}},
    {"label": ("Karar sizin.", "It is your decision."),
     "result": ("Yine yaparız. Ama senin imzan olsaydı...", "We will do it anyway. But with your signature..."),
     "fx": {"people": 1, "pollution": -0.2}},
], variant=("workers_ally",
            ("Hepsi senin için elini kaldırdı Başkan.", "Everyone raised their hand for you, Mayor."),
            ("Seni sevmeyenler çok ama çocuklarımız nefes alsın istiyorlar.", "Many dislike you, but they want our children to breathe.")))

beat("pinar_3", "pinar", 28, "pinar_agaci", [
    ("-", "-"),
    ("Başkan, ağacıma bak! Boyum kadar oldu!", "Mayor, look at my tree! It is as tall as me!"),
], [
    {"label": ("Birlikte sulayalım.", "Let us water it together."),
     "result": ("En iyi arkadaşım sensin. Büyüyünce altında oturacağız, söz!", "You are my best friend. When it grows, we will sit beneath it, promise!"),
     "fx": {"people": 5, "flags": ["pinar_hope"]}},
], variant=("pinar_cared",
            ("Artık öksürmüyorum! Ağaç da sen de... benim kahramanımsınız.", "I do not cough anymore! The tree and you... you are my heroes."),
            ("Hâlâ biraz öksürüyorum ama Veli Dede ağaç büyüdükçe geçecek diyor.", "I still cough a little, but Grandpa Veli says it will pass as the tree grows.")))

beat("canan_6", "canan", 29, "fidanlik_on", [
    ("Başkanım, Tomurcuk'un içinde hocamın bir kaydı varmış. Bu sabah kendiliğinden çalıştı.",
     "Mayor, there was a recording from my professor inside Sprout. It played by itself this morning."),
    ("'Kül her şeyi yutsa da Tohum bekler. Bunu duyan, sadece dikmeyi bilsin.' Yarın son gün.",
     "'Even if the Ash swallows everything, the Seed waits. Whoever hears this, just know how to plant.' Tomorrow is the last day."),
], [
    {"label": ("Hazırız.", "We are ready."),
     "result": ("Alın, elimdeki bütün tohumlar sizin. Hadi son kez!", "Take them, all the seeds I have are yours. One last time!"),
     "fx": {"seeds": {"oak": 3, "pine": 5}, "people": 3, "flags": ["ready"]}},
])

# =============================================================== Yiğithan (tools/story_yigithan.py)
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import story_yigithan  # noqa: E402
story_yigithan.add(beat)

# =============================================================== Yer kataloğu ve karakter yerleşimi

HOMES = {
    "pinar": ["okul_avlu", "okul_avlu", "okul_avlu", "okul_avlu", "okul_avlu", "pinar_agaci"],
    "canan": ["fidanlik_on", "orman_kulubesi_on", "fabrika_kapisi_on", "ciftlik_on", "copluk_kapisi_on", "fidanlik_on"],
    "riza": ["cay_ocagi_on", "cay_ocagi_on", "belediye_on", "belediye_on", "belediye_on", "belediye_on"],
    "veli": ["degirmen_on", "degirmen_on", "degirmen_on", "degirmen_on", "iskele_ucu", "degirmen_on"],
    "hulusi": ["pazar_on", "pazar_on", "genel_mudurluk_on", "genel_mudurluk_on", "tohum_bankasi_on", "genel_mudurluk_on"],
    "kemal": ["lojman_on", "lojman_on", "lojman_on", "sendika_on", "sendika_on", "sendika_on"],
    "yigithan": ["orman_kulubesi_on", "orman_kulubesi_on", "orman_kulubesi_on", "ciftlik_on", "copluk_kapisi_on", "fidanlik_on"],
}

# Tomurcuk'un sahne ipuçları ve bitiş metinleri
EXTRA = {
    "GUIDE_STORY_HINT_PINAR": ("Little Pınar wants to ask you something. I marked her on your map.", "Küçük Pınar size bir şey soracak. Haritaya işaretledim."),
    "GUIDE_STORY_HINT_VELI": ("Grandpa Veli at the mill has a story for you. I marked him.", "Değirmendeki Veli Dede'nin size anlatacağı bir şey var. İşaretledim."),
    "GUIDE_STORY_HINT_KEMAL": ("Foreman Kemal wants a word. I marked him on your map.", "Ustabaşı Kemal sizinle konuşmak istiyor. Haritaya işaretledim."),
    "CHAR_PINAR_NAME": ("Pınar", "Pınar"),
    "CHAR_VELI_NAME": ("Grandpa Veli", "Dede Veli"),
    "CHAR_KEMAL_NAME": ("Foreman Kemal", "Usta Kemal"),
    "UNLOCK_PINAR": ("New: little Pınar at the school yard.", "Yeni: okul bahçesinde küçük Pınar."),
    "UNLOCK_VELI": ("New: old Veli at the mill.", "Yeni: değirmende yaşlı Veli."),
    "UNLOCK_KEMAL": ("New: Foreman Kemal at the workers' lodgings.", "Yeni: lojmanlarda Usta Kemal."),
    "LM_BELEDIYE": ("Town Hall", "Belediye"),
    "LM_FIDANLIK": ("Nursery", "Fidanlık"),
    "LM_OKUL": ("School", "Okul"),
    "LM_CAY_OCAGI": ("Tea House", "Çay Ocağı"),
    "LM_ORMAN_KULUBESI": ("Ranger Cabin", "Bekçi Kulübesi"),
    "LM_DEGIRMEN": ("Old Mill", "Eski Değirmen"),
    "LM_ISKELE": ("Pier", "İskele"),
    "LM_FABRIKA_KAPISI": ("Factory Gate", "Fabrika Kapısı"),
    "LM_GENEL_MUDURLUK": ("Headquarters", "Genel Müdürlük"),
    "LM_LOJMAN": ("Lodgings", "Lojmanlar"),
    "LM_SENDIKA": ("Union Shack", "Sendika Barakası"),
    "LM_CIFTLIK": ("Farmhouse", "Çiftlik"),
    "LM_COPLUK_KAPISI": ("Landfill Gate", "Çöplük Kapısı"),
    "LM_TOHUM_BANKASI": ("Seed Bank", "Tohum Bankası"),
    "LM_YASLI_MESE": ("Old Oak", "Yaşlı Meşe"),
    "LM_PINAR_AGACI": ("Pınar's Tree", "Pınar'ın Ağacı"),
    "END_WIN": ("Karatepe breathes again! The air is clean enough to live in.", "Karatepe nefes alıyor! Hava artık yaşanacak kadar temiz."),
    "END_WIN_HERO": ("Karatepe breathes again, and you never sold it out. Children will play under these trees.", "Karatepe nefes alıyor ve sen onu hiç satmadın. Çocuklar bu ağaçların altında oynayacak."),
    "END_WIN_SOLD": ("Karatepe breathes, but not freely: Hulusi's chimneys are still there, and so is his price.", "Karatepe nefes alıyor ama özgürce değil: Hulusi'nin bacaları hâlâ orada, bedeli de."),
    "END_WIN_REDEEMED": ("Karatepe breathes again. Even Hulusi plants a tree beside Pınar's. Some ashes turn into seeds.", "Karatepe nefes alıyor. Hulusi bile Pınar'ın ağacının yanına bir fidan dikiyor. Bazı küller tohuma dönüşür."),
    "END_WIN_JUSTICE": ("Karatepe breathes again, and the guilty answered for it. The Seed Bank belongs to the town now.", "Karatepe nefes alıyor, suçlular hesap verdi. Tohum Bankası artık kasabanın."),
    "GUIDE_FINALE": ("Mayor, this is the last day. All our seeds, all our friends. Plant until the last breath.", "Başkanım, bugün son gün. Bütün tohumlarımız, bütün dostlarımız hazır. Son nefese kadar dikelim."),
}
for k, (en, tr) in EXTRA.items():
    TEXTS[k] = (en, tr)
for k, (tr, en) in story_yigithan.EXTRA.items():
    TEXTS[k] = (en, tr)

NEWS = {'pinar_1': ('Göletin kenarına küçük bir fidan dikildi, mahallenin çocukları bayram etti.', 'A small sapling was planted by the pond, and the neighborhood kids celebrated.'), 'canan_1': ('Fidanlıktaki genç ekolog, çöplüğün altında bir sır olduğunu söylüyor.', 'The young ecologist at the nursery says a secret lies under the landfill.'), 'riza_1': ('Çay ocağında iş mi, hava mı tartışması kızıştı.', 'At the tea house, the jobs-or-air debate heated up.'), 'veli_1': ("Değirmendeki yaşlı Veli 'Kül düşünce Tohum uyanır' sözünü yeniden andı.", 'Old Veli at the mill recalled the saying: when the Ash falls, the Seed wakes.'), 'hulusi_1': ('Karatepe Çelik, çeşme onarımı için kasabaya yaklaştı.', 'Karatepe Steel approached the town about repairing the fountain.'), 'canan_2': ('Nehirden alınan numunelerde ağır metal çıktı.', 'Samples from the river showed heavy metals.'), 'kemal_1': ("Lojmanlarda ustabaşı Kemal ile Başkan'ın görüşmesi dillerde.", "The talk between foreman Kemal and the Mayor is on everyone's lips."), 'canan_3': ('Fabrika kapısında eski filtre şemaları bulundu.', 'Old filter blueprints were found by the factory gate.'), 'pinar_2': ('Okul bahçesinde çocuklar yine öksürdü, veliler endişeli.', 'Children coughed again in the schoolyard, parents are worried.'), 'riza_2': ('İşçiler belediye meydanında toplandı.', 'Workers gathered in the town square.'), 'veli_2': ("Kayıp profesör Selim'in günlüğü bulundu.", "The lost professor Selim's journal was found."), 'hulusi_2': ("Genel Müdürlük'te kapalı kapılar ardında pazarlık yapıldı.", 'Bargaining took place behind closed doors at Headquarters.'), 'kemal_2': ('Gece vardiyasında çöplüğe giden kamyonlar konuşuluyor.', 'Trucks heading to the landfill on the night shift are the talk of the town.'), 'canan_4': ("Tohum Bankası'nın kapısını açmak için hazırlık başladı.", "Preparations began to open the Seed Bank's door."), 'canan_5': ('Çöplükte taş bir kapı bulundu: Tohum Bankası gün ışığına çıkıyor!', 'A stone door was found in the landfill: the Seed Bank sees daylight!'), 'veli_3': ('İskelede eski tohum merasimi için kasabalı toplandı.', 'The townsfolk gathered at the pier for the old seed ceremony.'), 'hulusi_3': ('Hulusi ile Başkan arasında Tohum Bankası önünde son görüşme.', 'A final meeting between Hulusi and the Mayor at the Seed Bank.'), 'riza_3': ('Meydandaki konuşma uzun süre alkışlandı.', 'The speech in the square was applauded for a long time.'), 'kemal_3': ('Fabrika işçileri baca söndürme oylamasına gitti.', 'Factory workers went to a vote on shutting the chimneys.'), 'pinar_3': ("Pınar'ın ağacı boy attı, gölün kenarı şenlendi.", "Pınar's tree grew tall, the pond side came alive."), 'canan_6': ("Fidanlıkta eski bir ses kaydı çalındı: 'Tohum bekler.'", "An old recording played at the nursery: 'The Seed waits.'")}
for bid, (tr, en) in NEWS.items():
    TEXTS["STORY_%s_NEWS" % bid.upper()] = (en, tr)
for bid, (tr, en) in story_yigithan.NEWS.items():
    TEXTS["STORY_%s_NEWS" % bid.upper()] = (en, tr)

# Boş yer tutucu satırlar ("-"): kullanılmaz, oyundan çıkarılır
for k in list(TEXTS):
    if TEXTS[k] == ("-", "-"):
        del TEXTS[k]

# Boş (kullanılmayan) ilk satırlar için satır sayısını düzelt
for bid, b in BEATS.items():
    pass

# ---------------------------------------------------------------- yaz
gd = "class_name StoryData\nextends RefCounted\n## OTOMATİK ÜRETİLDİ: tools/build_story.py. Elle değiştirme, o betiği değiştir.\n\n"
gd += "const BEATS := " + json.dumps(BEATS, ensure_ascii=False, indent=1) + "\n\n"
gd += "const HOMES := " + json.dumps(HOMES, ensure_ascii=False, indent=1) + "\n"
open('scripts/field/story_data.gd', 'w', encoding='utf-8').write(gd)

rows = list(csv.reader(open('translations/strings.csv', encoding='utf-8', newline='')))
rows = [r for r in rows if not r[0].startswith('STORY_') or r[0] in ('STORY_NEXT', 'STORY_OK', 'STORY_NO_MONEY')]
have = {r[0]: r for r in rows}
for k, (en, tr) in TEXTS.items():
    if k in have:
        have[k][1], have[k][2] = en, tr
    else:
        r = [k, en, tr]
        rows.append(r)
        have[k] = r
csv.writer(open('translations/strings.csv', 'w', encoding='utf-8', newline='')).writerows(rows)
print(len(BEATS), 'sahne', len(TEXTS), 'metin')

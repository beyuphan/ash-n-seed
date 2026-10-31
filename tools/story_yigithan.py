# -*- coding: utf-8 -*-
"""Yiğithan: Karatepe'nin orman bekçisi, ağaçların abisi, omzunda baykuş Gece. Oyunun en önemli iyi karakteri.
tools/build_story.py bu dosyayı içe aktarır: beat(...) çağrılarıyla 6 sahne ekler.

Etkiler (bayraklar oyunu gerçekten değiştirir):
  yigithan_roots: her sabah +1 bedava meşe tohumu (Kök Sözü)
  yigithan_guard: günlük Çevre kaybı -1 (gece nöbeti)
  last_tree_*:    final (outro) ve 30. gün sahnesi
"""


def add(beat):
    # 1) Gece: baykuş yavrusu (gün 7)
    beat("yigithan_1", "yigithan", 7, "orman_kulubesi_on", [
        ("Başkanım! Dur dur, bastığın yere dikkat: yerde bir baykuş yavrusu var. Adı Gece. Dumanı yutmuş, kanatlarına kül yapışmış.",
         "Mayor! Wait, watch your step: there's a baby owl on the ground. Her name is Gece. She swallowed smoke, ash is stuck to her wings."),
        ("Ben Yiğithan, bu ormanın bekçisi. Resmî unvanım 'Orman Bekçisi', gayriresmî unvanım 'Ağaçların Abisi'. Yazın üç yüz fidan suladım, duman hepsini kuruttu. Ağladım. Ağaçlar da bana sarıldı, dallarıyla, bilirsin.",
         "I'm Yiğithan, keeper of this forest. Official title: 'Forest Ranger', unofficial: 'Big Brother of Trees'. This summer I watered three hundred saplings and the smoke dried them all. I cried. The trees hugged me back, with their branches, you know."),
        ("Ağaç diktiğini duydum. Gece'ye yeni bir yuva yapalım mı birlikte? Yalnız uyarayım: baykuşlar çok titizdir, çatısı düzgün dikilmiş olmalı.",
         "I heard you plant trees. Shall we build Gece a new nest together? Fair warning: owls are picky, the roof must be planted properly."),
    ], [
        {"label": ("Tabii, yuvayı birlikte yapalım.", "Of course, let's build the nest together."),
         "result": ("Yaşasın! Gece 'Huu' dedi. Çevirisi: 'Sağ ol, tombul.' Kusura bakma, o böyle konuşur. Al sana kulübeden iki meşe fidanı.",
                    "Hooray! Gece said 'Hoo'. Translation: 'Thanks, chubby.' Sorry, that's how she talks. Here, two oak saplings from the cabin."),
         "fx": {"seeds": {"oak": 2}, "people": 2, "flags": ["yigithan_friend"]}},
        {"label": ("Önce ağaç dikmeliyim, sonra bakarız.", "Planting first, we'll see about it later."),
         "result": ("Tamam kardeşim, anlıyorum. Gece beklerse bekler, baykuşlar sabırlıdır. Kapım hep açık, hatta fazla açık: menteşe koptu.",
                    "Okay brother, I understand. If Gece waits, she waits, owls are patient. My door is always open, even too open: the hinge broke."),
         "fx": {"people": -1, "flags": ["yigithan_wait"]}},
    ], window=4)

    # 2) Kök Sözü (gün 11)
    beat("yigithan_2", "yigithan", 11, "orman_kulubesi_on", [
        ("Başkanım! Gece yuvaya taşındı, her sabah kapımı gagalıyor. Sanırım teşekkür ediyor. Ya da kahvaltı istiyor.",
         "Mayor! Gece moved into the nest and pecks my door every morning. I think she's thanking me. Or asking for breakfast."),
        ("Sana bir şey öğretmek istiyorum: Kök Sözü. Eski bekçilerden kalma. Bir ağacı dikerken köküne söz verirsin: 'Ben burada olduğum sürece sen de burada olacaksın.' Sonra tutarsın. Hepsi bu.",
         "I want to teach you something: the Root Oath. It's from the old keepers. When you plant a tree you give its root a promise: 'As long as I'm here, you'll be here too.' Then you keep it. That's all."),
    ], [
        {"label": ("Söz veriyorum.", "I promise."),
         "result": ("Kök Sözü verildi! Her sabah kulübemden sana bir meşe fidanı bırakacağım. Ağaçlara da fısıldayacağım: 'Başkan bizi unutmaz.' Biraz baskı oldu, biliyorum.",
                    "The Root Oath is given! Every morning I'll leave you an oak sapling from my cabin. I'll also whisper to the trees: 'The Mayor won't forget us.' A bit of pressure, I know."),
         "fx": {"people": 1, "flags": ["yigithan_roots"]}},
        {"label": ("Söz çok, vaktim az.", "Many promises, little time."),
         "result": ("Olur. Ama kök söz bekler. Tohumları bir sepete koyuyorum, istediğinde al.",
                    "Fine. But a root waits for a promise. I'll put seeds in a basket, take them whenever you want."),
         "fx": {"seeds": {"oak": 1}, "flags": ["yigithan_roots_half"]}},
    ], window=4,
        variant=("yigithan_friend",
                 ("Başkanım! Gece yuvaya taşındı, her sabah kapımı gagalıyor. Sanırım teşekkür ediyor. Ya da kahvaltı istiyor.",
                  "Mayor! Gece moved into the nest and pecks my door every morning. I think she's thanking me. Or asking for breakfast."),
                 ("Başkanım, geldin! Gece yuvayı kendi yaptı, çok gururlu. Ben de çatıyı kurmaya çalıştım, düştüm. Bak, hâlâ morarık.",
                  "Mayor, you came! Gece built the nest herself, very proud. I tried to build the roof and fell. Look, still bruised.")))

    # 3) Gece nöbeti (gün 16)
    beat("yigithan_3", "yigithan", 16, "ciftlik_on", [
        ("Başkanım. Dün gece fabrikanın kamyonları atıkla çiftliğe doğru geliyordu. Önlerine yattım. Evet, yattım. Üç saat. Şoför sonunda ağladı, çünkü o da burada doğmuş.",
         "Mayor. Last night the factory trucks came toward the farm loaded with waste. I lay down in front of them. Yes, lay down. Three hours. The driver finally cried, because he was born here too."),
        ("Şimdi herkes bana deli diyor. Ben 'ormancı' diyorum ama kimse dinlemiyor. Bir nöbet kuralım: fener, minder, sıcak çay. Çay Rıza'nın, minderler Nezaket Teyze'nin.",
         "Now everyone calls me crazy. I say 'forester' but nobody listens. Let's set up a vigil: lanterns, cushions, hot tea. Tea from Rıza, cushions from Auntie Nezaket."),
        ("Ben tek başıma yatarım ama iki kişi daha iyi: biri uyur, diğeri horlar. Ne dersin?",
         "I can lie down alone but two is better: one sleeps, the other snores. What do you say?"),
    ], [
        {"label": ("Nöbete ben de katılırım. (-20 Kasa)", "I'll join the vigil. (-20 coins)"),
         "result": ("Başkan benimle yatıyor! Bu haber yarın gazetede çıkar. Nöbet kuruldu: sızan her kamyon artık utanarak dönecek.",
                    "The Mayor is lying down with me! This will be in the paper tomorrow. The vigil is on: every truck that leaks will turn back in shame."),
         "fx": {"cost": 20, "people": 2, "flags": ["yigithan_guard"]}},
        {"label": ("Sen devam et, ben ayakta destek olurum.", "You carry on, I'll support from standing."),
         "result": ("Ayakta destek de destektir. Ama ayakta uyumak zor, söylemedi deme.",
                    "Standing support is support too. But sleeping standing is hard, don't say I didn't warn you."),
         "fx": {"people": 1}},
    ], window=4)

    # 4) Kül Bekçisi / Bekçi Anahtarı (gün 22)
    beat("yigithan_4", "yigithan", 22, "copluk_kapisi_on", [
        ("Başkanım, kapının önünde dur. Hissediyor musun? Toprak titriyor. Kül düşmek üzere.",
         "Mayor, stop in front of the gate. Do you feel it? The ground trembles. The Ash is about to fall."),
        ("Sana bir sır vereceğim: Ben Tohum Bekçileri'nin sonuncusuyum. Dedem, onun dedesi... hepsi bu çöplüğün altını beklemiş. Bankanın kapısı iki anahtar ister: biri hocan Selim'de, biri bende.",
         "I'll tell you a secret: I'm the last of the Seed Keepers. My grandfather, his grandfather... all of them guarded what lies under this landfill. The bank's door needs two keys: one with your professor Selim, one with me."),
        ("Anahtarı bana emanet ettiler ama ben ağaç bekçisiyim, kapı bekçisi değil. Sen alır mısın, yoksa Canan'la birlikte mi saklayalım?",
         "They entrusted the key to me but I'm a tree keeper, not a gate keeper. Will you take it, or shall we keep it with Canan together?"),
    ], [
        {"label": ("Anahtarı ben alırım.", "I'll take the key."),
         "result": ("Al. Ağır, ama kalbine benziyor. Dikkat et, kapının önünde bir akrep var. Şaka, akrep yok. Çöp var.",
                    "Take it. Heavy, but it feels like a heart. Careful, there's a scorpion at the gate. Kidding, no scorpion. Trash."),
         "fx": {"seeds": {"oak": 3}, "flags": ["yigithan_key"]}},
        {"label": ("Canan'la birlikte saklayalım.", "Let's keep it with Canan."),
         "result": ("Akıllıca. Bir anahtar iki kişide iki kat güvende. Üç kişide de olabilir ama Hulusi'ye verme.",
                    "Wise. A key held by two is twice as safe. Three is fine too, but don't give it to Hulusi."),
         "fx": {"seeds": {"pine": 4}, "people": 3, "flags": ["yigithan_key_shared"]}},
    ], window=3)

    # 5) Son Ağaç sözü (gün 27)
    beat("yigithan_5", "yigithan", 27, "fidanlik_on", [
        ("Başkanım, üç gün kaldı. Biliyorum, tarihin en kısa üç günü. Ben bir şey seçtim: Son Ağaç için bir meşe fidanı. Adı 'Biraz Daha'.",
         "Mayor, three days left. I know, the shortest three days in history. I picked something: an oak sapling for the Last Tree. Its name is 'A Little More'."),
        ("Ağaca isim koymak saçma gelebilir ama kökleri duyuyor. Adı 'Umut' olsaydı çok baskı olurdu. 'Biraz Daha' diyince sadece nefes alıyor.",
         "Naming a tree may sound silly but its roots can hear. If it were named 'Hope' it'd be under pressure. Called 'A Little More' it just breathes."),
        ("30. gün Son Ağaç'ı birlikte dikelim mi? Herkes gelsin, ama ilk kürek senin olsun.",
         "Shall we plant the Last Tree together on day 30? Let everyone come, but the first shovel is yours."),
    ], [
        {"label": ("Birlikte dikelim, ilk kürek benim.", "Let's plant it together, first shovel mine."),
         "result": ("Tamam. O gün ben ağlarsam bu ter, bilesin. Baykuşa da söylerim.",
                    "Okay. If I cry that day it's sweat, mark my words. I'll tell the owl too."),
         "fx": {"people": 2, "flags": ["last_tree_us"]}},
        {"label": ("Son Ağaç'ı herkes birlikte diksin.", "Let everyone plant the Last Tree together."),
         "result": ("Bu daha da güzel! Kürekleri ben getiririm. Pınar'ın eli de kürek tutsun, o da dikmek istiyor.",
                    "Even better! I'll bring the shovels. Let Pınar hold one too, she wants to plant."),
         "fx": {"people": 3, "flags": ["last_tree_all"]}},
    ], window=2)

    # 6) Son Ağaç (gün 30)
    beat("yigithan_6", "yigithan", 30, "fidanlik_on", [
        ("Son gün Başkanım. Fidan hazır, kürek hazır, ben hazır değilim ama kimse hiç hazır değildir zaten.",
         "Last day, Mayor. The sapling is ready, the shovel is ready, I'm not ready but nobody ever is."),
        ("Bir şey söyleyeyim: ağaçlar bir günde büyümez. Ama biri onları dikmezse hiç büyümez. Sen diktin. Yalnız dikmedin, hepimize diktirdin. Bu çok önemli.",
         "Let me say something: trees don't grow in a day. But if nobody plants them they never grow. You planted. And not just alone, you made all of us plant. That matters a lot."),
    ], [
        {"label": ("Hadi, Son Ağaç'ı dikelim.", "Come on, let's plant the Last Tree."),
         "result": ("Gece havalandı bile! Bak, uçtu. 'Biraz Daha' toprağa değdi. Karatepe sana bakıyor Başkanım. Nefes al.",
                    "Gece even took off! Look, she's flying. 'A Little More' touched the soil. Karatepe is looking at you, Mayor. Breathe."),
         "fx": {"nature": 2, "people": 3, "flags": ["last_tree_done"]}},
    ], window=0)


NEWS = {
    "yigithan_1": ("Orman bekçisi Yiğithan, duman yutmuş bir baykuş yavrusunu kurtardı.", "Forest keeper Yiğithan rescued a baby owl that swallowed smoke."),
    "yigithan_2": ("Ormanda 'Kök Sözü' geleneği yeniden canlandı.", "The 'Root Oath' tradition was revived in the forest."),
    "yigithan_3": ("Çiftlik yolunda gece nöbeti: kamyonlar utanarak geri döndü.", "Night vigil on the farm road: trucks turned back in shame."),
    "yigithan_4": ("Çöplük kapısında son Tohum Bekçisi konuştu.", "The last Seed Keeper spoke at the landfill gate."),
    "yigithan_5": ("Son Ağaç'ın adı belli oldu: 'Biraz Daha'.", "The Last Tree has a name: 'A Little More'."),
    "yigithan_6": ("Son Ağaç dikildi. Baykuş uçtu, Yiğithan ağlamadı (terledi).", "The Last Tree was planted. The owl flew, Yiğithan didn't cry (he sweated)."),
}

EXTRA = {
    "CHAR_YIGITHAN_NAME": ("Yiğithan", "Yiğithan"),
    "CHAR_YIGITHAN_ROLE": ("Ağaçların abisi. Omzunda baykuş: Gece.", "Big brother of trees. An owl on his shoulder: Gece."),
    "GUIDE_STORY_HINT_YIGITHAN": ("Bekçi Yiğithan seni arıyor. Omzundaki baykuş seni çoktan gördü. Haritaya işaretledim.",
                                  "Keeper Yiğithan is looking for you. The owl on his shoulder has already spotted you. I marked him on your map."),
    "NPC_YIGITHAN_DONE": ("Bugünlük bu kadar kardeşim. Ağaçlara selam söyle.", "That's it for today, brother. Say hi to the trees."),
    "NPC_YIGITHAN_IDLE_1": ("Fısıldayarak konuşuyorum, ağaçlar ürkmesin. Sen de fısılda: 'Merhaba ağaç.'", "I'm whispering so the trees don't get startled. You whisper too: 'Hello tree.'"),
    "NPC_YIGITHAN_IDLE_2": ("Gece bugün üç fare yakaladı. Sonra bıraktı. Utandı.", "Gece caught three mice today. Then let them go. She was embarrassed."),
    "NPC_YIGITHAN_IDLE_3": ("Bir ağaç dikmek, bir sözü toprağa gömmek gibi. Ama canlı.", "Planting a tree is like burying a promise in the soil. But a living one."),
    "NPC_YIGITHAN_IDLE_4": ("Bu mantarı yiyebilir miyim? Hayır, yiyemem. Neyse, Gece yer.", "Can I eat this mushroom? No, I can't. Anyway, Gece will."),
    "NPC_YIGITHAN_IDLE_5": ("Ormanda kaybolmadım, sadece alternatif bir yoldayım.", "I'm not lost in the forest, I'm just on an alternative path."),
    "NPC_YIGITHAN_IDLE_6": ("Dün bir meşeye sarıldım. Ağlamadım, yağmur yağıyordu. İçeride.", "Yesterday I hugged an oak. I wasn't crying, it was raining. Inside."),
    "NPC_YIGITHAN_IDLE_7": ("Her sabah kendime bir şey öğretiyorum. Bugün: ağaçlar da üşür.", "Every morning I teach myself something. Today: trees get cold too."),
    "NPC_YIGITHAN_IDLE_8": ("Sen ağaç dikerken ben nefes alıyorum. Aynı iş.", "While you plant trees I breathe. Same job."),
    "JOURNAL_CLUE_YIGITHAN_FRIEND": ("Yiğithan ve baykuş Gece artık dostun.", "Yiğithan and the owl Gece are your friends now."),
}

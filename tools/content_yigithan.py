# -*- coding: utf-8 -*-
"""Yiğithan'ın masa kartları ve genel tepkileri. tools/apply_content.py bu dosyayı da işler."""

from content_cards import CARDS
from content_texts import add

CARDS += [
    {
        "id": "y_baykus", "char": "yigithan", "min": 7, "max": 14, "weight": 1,
        "extra": {"must_by_day": 12},
        "A": {"effects": {"money": -8, "nature": 8}},
        "B": {"effects": {"people": 3}},
        "tr": {
            "text": "Yiğithan masaya Gece'yi bıraktı: 'Başkanım, Gece belediyeye başvuru yapmış: Gece Nöbetçiliği. Maaşı: fare. Çalışma saatleri: tüm gece. Özgeçmişi: baykuş.'",
            "a": "Gece'yi Nöbetçi Yap (Maaşı Fare)", "b": "Başvuruyu 'İnceleniyor' Yap",
            "ra": "Gece rozetini taktı ve ilk iş olarak masadaki kalemi gözetledi. Kalem hiçbir şey yapmadı. Gece memnun.",
            "rb": "Yiğithan: 'İnceleniyor mu? Peki.' Gece sana bir bakış attı: 'Huu.' Tercümesi: 'Hatırlayacağım.'",
            "ha": "Belediyenin İlk Baykuşu Göreve Başladı: Fareler Dilekçe Verdi",
            "hb": "Baykuş Başvurusu 'İnceleniyor': Gece Sabırlı, Ama Gözü Üzerinizde",
        },
        "en": {
            "text": "Yiğithan put Gece on the desk: 'Mayor, Gece applied to the municipality: Night Watch. Salary: mice. Hours: all night. Résumé: owl.'",
            "a": "Hire Gece as Night Watch (Paid in Mice)", "b": "Mark the Application 'Under Review'",
            "ra": "Gece pinned on her badge and promptly began watching the pen on the desk. The pen did nothing. Gece is satisfied.",
            "rb": "Yiğithan: 'Under review? Okay.' Gece gave you a look: 'Hoo.' Translation: 'I'll remember this.'",
            "ha": "City's First Owl Starts Work: Mice File a Petition",
            "hb": "Owl Application 'Under Review': Gece Is Patient, But Watching You",
        },
    },
    {
        "id": "y_yangin", "char": "yigithan", "min": 14, "max": 24, "weight": 1,
        "extra": {},
        "A": {"effects": {"money": -8, "nature": 8}},
        "B": {"effects": {"money": 5, "nature": -8}},
        "tr": {
            "text": "Yiğithan: 'Ormanın bir köşesi çok kuru. İtfaiyeyi beklemeden kum torbası dolduralım mı? Ben kürek getirdim, kürek de kendi başına çalışmaz.'",
            "a": "Kum Torbalarını Doldur", "b": "Beklemek: Hava Durumu 'İyi' Diyor",
            "ra": "Yiğithan ve gönüllüler üç yüz torba doldurdu. Biri Hulusi'nin cebini doldurmaya çalıştı, kimse kabul etmedi.",
            "rb": "Yiğithan sessizce başını salladı ve kürekle ormana yürüdü. Yalnız gitti. Bu, gürültüden daha ağır.",
            "ha": "Orman Koruma Seferberliği: 300 Kum Torbası, 1 Baykuş Gözetmeni",
            "hb": "Hava 'İyi' Dedi, Orman 'Emin Değilim' Dedi",
        },
        "en": {
            "text": "Yiğithan: 'One corner of the forest is very dry. Shall we fill sandbags without waiting for the fire brigade? I brought a shovel, and a shovel doesn't work alone.'",
            "a": "Fill the Sandbags", "b": "Wait: The Forecast Says 'Fine'",
            "ra": "Yiğithan and volunteers filled three hundred bags. Someone tried to fill Hulusi's pocket too; nobody agreed.",
            "rb": "Yiğithan quietly nodded and walked into the forest with his shovel. He went alone. That's heavier than noise.",
            "ha": "Forest Protection Drive: 300 Sandbags, 1 Owl Supervisor",
            "hb": "Forecast Said 'Fine', Forest Said 'Not Sure'",
        },
    },
    {
        "id": "y_fidan_yuruyusu", "char": "yigithan", "min": 13, "max": 22, "weight": 1,
        "extra": {},
        "A": {"effects": {"money": -15, "nature": 8, "people": 3}},
        "B": {"effects": {"money": -5, "nature": 3}},
        "tr": {
            "text": "Yiğithan çocuklarla Fidan Yürüyüşü planlıyor: 40 çocuk, 40 kürek, 1 yorgun öğretmen. 'Çocuklar kürekle ağaç dikmeyi çok sever, sadece biraz da kürekle birbirlerini dikmeyi.'",
            "a": "Yürüyüşü Destekle", "b": "Yarım Gün Yapsınlar",
            "ra": "Kırk çocuk kırk fidan dikti. İki çocuk birbirini dikmeye çalıştı, öğretmen kurtardı. Yiğithan gözyaşlarını 'toz' diye açıkladı.",
            "rb": "Yarım gün sürdü ama çocuklar bütün gün konuştu. Öğretmen akşam bir çay istedi, çay ocağı kapalıydı. Mutsuzluk.",
            "ha": "Fidan Yürüyüşü: 40 Çocuk, 40 Ağaç, 0 Kayıp (Neredeyse)",
            "hb": "Yarım Günlük Yürüyüş: Çocuklar Devam Etmek İstiyor, Öğretmen İstemiyor",
        },
        "en": {
            "text": "Yiğithan plans a Sapling March with the kids: 40 kids, 40 shovels, 1 tired teacher. 'Kids love planting with shovels, just a bit too much planting each other.'",
            "a": "Support the March", "b": "Make It Half a Day",
            "ra": "Forty kids planted forty saplings. Two kids tried to plant each other; the teacher rescued them. Yiğithan blamed his tears on 'dust'.",
            "rb": "It lasted half a day but the kids talked all day long. The teacher wanted a tea in the evening; the tea house was closed. Sadness.",
            "ha": "Sapling March: 40 Kids, 40 Trees, 0 Missing (Almost)",
            "hb": "Half-Day March: Kids Want More, Teacher Doesn't",
        },
    },
    {
        "id": "y_nehir", "char": "yigithan", "min": 17, "max": 25, "weight": 1,
        "extra": {},
        "A": {"effects": {"money": -15, "nature": 15}},
        "B": {"effects": {"nature": 8, "people": -8}},
        "tr": {
            "text": "Yiğithan nehir kıyısını temizlemek için gönüllü topladı: 60 kişi, 60 çöp torbası, 12 çift bot. 'Botlar yetmiyor. Yetmeyince biz paçaları sıvıyoruz. Nezaket Teyze 'çıplak ayakla olmaz' diyor.'",
            "a": "Botları Satın Al", "b": "Gönüllüler Çıplak Ayakla",
            "ra": "Botlar geldi. Nehir kıyısı pırıl pırıl, Yiğithan'ın botu 'çift sol' çıktı ama o yine de yürüdü. Yürüyüş biraz yamuk.",
            "rb": "Çıplak ayakla temizlik çok hızlı bitti, çünkü herkes üşüdü. Nezaket Teyze iki saat sonra çorba getirdi, herkes affetti.",
            "ha": "Nehir Kıyısı Temizlendi: Yiğithan'ın Botları 'Çift Sol' Çıktı",
            "hb": "Çıplak Ayakla Nehir Temizliği: Rekor Hız, Rekor Üşüme",
        },
        "en": {
            "text": "Yiğithan gathered volunteers to clean the riverbank: 60 people, 60 trash bags, 12 pairs of boots. 'Not enough boots. When there aren't enough, we roll up our trousers. Auntie Nezaket says 'not barefoot'.'",
            "a": "Buy the Boots", "b": "Volunteers Go Barefoot",
            "ra": "The boots arrived. The riverbank sparkles, Yiğithan's boots turned out to be 'two left' but he walked anyway. A slightly crooked walk.",
            "rb": "Barefoot cleanup finished very fast because everyone was cold. Auntie Nezaket brought soup two hours later, everyone forgave.",
            "ha": "Riverbank Cleaned: Yiğithan's Boots Were 'Two Left'",
            "hb": "Barefoot River Cleanup: Record Speed, Record Shivering",
        },
    },
    {
        "id": "y_orman_okulu", "char": "yigithan", "min": 20, "max": 28, "weight": 1,
        "extra": {"must_by_day": 24},
        "A": {"effects": {"money": -8, "nature": 8}},
        "B": {"effects": {"money": -3, "people": 5}},
        "tr": {
            "text": "Yiğithan Orman Okulu açmak istiyor. Ders programı: 'Ağaca Nasıl Davranılır', 'Fidan Nasıl Dikilir', 'Hulusi'yle Nasıl Başa Çıkılır'. Son ders seçmeli.",
            "a": "Başkan da Derse Katılsın", "b": "Sadece Çocuklar Katılsın",
            "ra": "Sen de katıldın. Not: 'Başkan çok iyi dinliyor ama sürekli saati kontrol ediyor.' Yiğithan sana 'Altın Fidan' rozeti verdi.",
            "rb": "Çocuklar öğrendi, sen çay içtin. Yiğithan sana bir not bıraktı: 'Gelmek isteseydin kapıyı çalardın.' Kapı açıktı.",
            "ha": "Orman Okulu Açıldı: İlk Ders 'Ağaçla Konuşma Etiği'",
            "hb": "Orman Okulu Çocuklara Açık, Başkana Kapalı: Başkan 'Zaten Yoğundum' Dedi",
        },
        "en": {
            "text": "Yiğithan wants to open a Forest School. Curriculum: 'How to Treat a Tree', 'How to Plant a Sapling', 'How to Deal With Hulusi'. The last course is elective.",
            "a": "Mayor Attends Too", "b": "Kids Only",
            "ra": "You joined too. Note: 'Mayor listens very well but keeps checking the clock.' Yiğithan gave you a 'Golden Sapling' badge.",
            "rb": "The kids learned, you drank tea. Yiğithan left a note: 'If you wanted to come you'd have knocked.' The door was open.",
            "ha": "Forest School Opens: First Lesson 'Ethics of Talking to Trees'",
            "hb": "Forest School Open to Kids, Closed to Mayor: Mayor Says 'I Was Busy Anyway'",
        },
    },
    {
        "id": "y_son", "char": "yigithan", "min": 26, "max": 30, "weight": 1,
        "extra": {"must_by_day": 28},
        "A": {"effects": {"nature": 8}},
        "B": {"effects": {"people": 8, "nature": -3}},
        "tr": {
            "text": "Yiğithan: 'Son Ağaç için fidanı seçtim ama adında anlaşamıyoruz. Pınar 'Pamuk' diyor, Veli Dede 'Kök Dede', ben 'Biraz Daha'. Sen seç, Başkan. Ağaç alınganmış.'",
            "a": "'Biraz Daha'", "b": "'Pamuk'",
            "ra": "Yiğithan sustu. Sonra gözlerini sildi: 'Tabii ki seçtin.' Gece havalandı, bir tur attı, kondu. Onay.",
            "rb": "Pınar sevinçten zıpladı: 'Pamuuuk!' Veli Dede sessizce 'Kök Dede de güzeldi' dedi. Yiğithan ağaca fısıldadı: 'Özür dilerim.'",
            "ha": "Son Ağaç'ın Adı 'Biraz Daha': Yiğithan Ağladı (Toz Kaçtı)",
            "hb": "Son Ağaç'ın Adı 'Pamuk' Oldu: Veli Dede Kırgın, Pınar Havalarda",
        },
        "en": {
            "text": "Yiğithan: 'I chose the sapling for the Last Tree but we can't agree on its name. Pınar says 'Cotton', Grandpa Veli says 'Root Elder', I say 'A Little More'. You choose, Mayor. The tree is sensitive.'",
            "a": "'A Little More'", "b": "'Cotton'",
            "ra": "Yiğithan fell silent. Then he wiped his eyes: 'Of course you chose that.' Gece took off, circled once, landed. Approval.",
            "rb": "Pınar jumped with joy: 'Cottoooon!' Grandpa Veli quietly said 'Root Elder was nice too.' Yiğithan whispered to the tree: 'I'm sorry.'",
            "ha": "Last Tree Named 'A Little More': Yiğithan Cried (Dust in Eye)",
            "hb": "Last Tree Named 'Cotton': Grandpa Veli Hurt, Pınar on Cloud Nine",
        },
    },
]

# Genel tepkiler (özel tepkisi olmayan kartlar için; Yiğithan kartlarının hepsinin özel tepkisi var ama yine de)
for _mood, _lines in {
    "GREEN": [("Yiğithan başını salladı: 'Ağaçlar bunu duydu. Ben de.' Gece omzunda onayladı.", "Yiğithan nodded: 'The trees heard that. So did I.' Gece approved from his shoulder."),
              ("Yiğithan seni sıkıca omzundan tuttu: 'Kardeşim, sağ ol.' Hafif acıdı ama güzeldi.", "Yiğithan gripped your shoulder: 'Thanks, brother.' It hurt a little but felt nice.")],
    "DIRTY": [("Yiğithan bir şey demedi. Sadece Gece'ye baktı. Gece sana baktı.", "Yiğithan said nothing. He just looked at Gece. Gece looked at you."),
              ("Yiğithan nazikçe: 'Anlıyorum.' Sonra ormana doğru yürüdü, sessizce.", "Yiğithan, gently: 'I understand.' Then walked into the forest, quietly.")],
    "MEH": [("Yiğithan omuz silkti: 'Olur. Ağaçlar sabırlıdır.'", "Yiğithan shrugged: 'Okay. Trees are patient.'"),
            ("Yiğithan gülümsedi: 'Bir sonrakinde hep birlikte.'", "Yiğithan smiled: 'Next time, all together.'")],
}.items():
    for _i, (_tr, _en) in enumerate(_lines):
        add("REACT_YIGITHAN_%s_%d" % (_mood, _i + 1), _tr, _en)

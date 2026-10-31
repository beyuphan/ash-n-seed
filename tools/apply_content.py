# -*- coding: utf-8 -*-
"""Komik paketi oyuna işler: tools/content_texts.py ve tools/content_cards.py -> translations/strings.csv, data/crisis_pool.json.
Tekrar çalıştırılabilir (idempotent): var olan anahtar ve kartların üstüne yazar.
Sonra Godot ile çeviriyi yeniden içe aktar:
    Godot_console.exe --headless --path D:\\Projects\\cop31 --import
"""
import csv
import io
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from content_cards import CARDS  # noqa: E402
from content_texts import TEXTS  # noqa: E402
import content_field  # noqa: E402,F401  (TEXTS'e ekleme yapar)
import content_yigithan  # noqa: E402,F401  (CARDS ve TEXTS'e ekleme yapar)
import content_end  # noqa: E402,F401  (outro, son ekranlar, intro)
import content_home  # noqa: E402,F401  (başkanın evi, baca filtresi)
import content_edit  # noqa: E402,F401  (metin incelemesi düzeltmeleri, EN SON kalmalı)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(ROOT, "translations", "strings.csv")
JSON_PATH = os.path.join(ROOT, "data", "crisis_pool.json")


def card_texts(card):
    key = card["id"].upper()
    out = {}
    for field, suffix in (("text", "TEXT"), ("a", "A"), ("b", "B"), ("ra", "RA"), ("rb", "RB")):
        out["CARD_%s_%s" % (key, suffix)] = (card["tr"][field], card["en"][field])
    out["NEWS_C_%s_A" % key] = (card["tr"]["ha"], card["en"]["ha"])
    out["NEWS_C_%s_B" % key] = (card["tr"]["hb"], card["en"]["hb"])
    return out


def card_json(card):
    entry = {
        "id": card["id"],
        "character": card["char"],
        "weight": card.get("weight", 1),
    }
    extra = card.get("extra", {})
    if not extra.get("scheduled_only"):
        entry["once"] = True
        entry["requires"] = {"min_day": card["min"], "max_day": card["max"]}
    for k, v in extra.items():
        if k == "recyclable" and not v:
            continue
        entry[k] = v
    choices = []
    for side in ("A", "B"):
        c = {"effects": card[side]["effects"]}
        for k in ("set_flags", "unlock_cards", "schedule", "pollution_rate"):
            if k in card[side]:
                c[k] = card[side][k]
        choices.append(c)
    entry["choices"] = choices
    return entry


def balance_pass(cards):
    """İkilem geçişi (idempotent, choice["bp"] işaretiyle). Kasa ve Halk kıt olduğunda 'hep yeşili seç' çözümü işlemesin:
    - yeşil seçenek (Çevre'si belirgin yüksek olan) halka bir kısmında -5 mal olur,
    - kirli seçenek hiçbir artı getirmiyorsa +5 Kasa ya da +5 Halk getirir (kirlenmenin bir çekiciliği olsun).
    Karar kartın kimliğinden deterministik, yani her oyunda aynı kartlar aynı şekilde dengelenir."""
    changed = 0
    for card in cards:
        ch = card["choices"]
        if len(ch) != 2 or card["id"].startswith(("k_", "e_", "t_")):
            continue
        n0 = float(ch[0].get("effects", {}).get("nature", 0.0))
        n1 = float(ch[1].get("effects", {}).get("nature", 0.0))
        if abs(n0 - n1) < 8.0:
            continue
        g, d = (0, 1) if n0 > n1 else (1, 0)
        h = sum(ord(c) for c in card["id"])
        eg, ed = ch[g].setdefault("effects", {}), ch[d].setdefault("effects", {})
        if not ch[g].get("bp") and float(eg.get("people", 0.0)) <= 0.0 and h % 2 == 0:
            eg["people"] = float(eg.get("people", 0.0)) - 5.0
            ch[g]["bp"] = 1
            changed += 1
        if not ch[d].get("bp") and float(ed.get("money", 0.0)) <= 0.0 and float(ed.get("people", 0.0)) <= 0.0:
            if h % 3 == 0:
                ed["people"] = 5.0
            else:
                ed["money"] = 5.0
            ch[d]["bp"] = 1
            changed += 1
    return changed


def main():
    # --- CSV
    raw = open(CSV_PATH, "rb").read().decode("utf-8")
    rows = list(csv.reader(io.StringIO(raw, newline="")))
    header, body = rows[0], rows[1:]
    index = {r[0]: i for i, r in enumerate(body)}

    all_texts = dict(TEXTS)
    for card in CARDS:
        all_texts.update(card_texts(card))

    added = replaced = 0
    for key, (tr, en) in all_texts.items():
        row = [key, en, tr]
        if key in index:
            body[index[key]] = row
            replaced += 1
        else:
            index[key] = len(body)
            body.append(row)
            added += 1
    out = io.StringIO(newline="")
    csv.writer(out, lineterminator="\r\n").writerows([header] + body)
    with open(CSV_PATH, "wb") as f:
        f.write(out.getvalue().encode("utf-8"))
    print("CSV: %d eklendi, %d değiştirildi" % (added, replaced))

    # --- JSON
    data = json.load(open(JSON_PATH, encoding="utf-8"))
    cards = data["cards"]
    pos = {c["id"]: i for i, c in enumerate(cards)}
    for card in CARDS:
        entry = card_json(card)
        if entry["id"] in pos:
            cards[pos[entry["id"]]] = entry
        else:
            pos[entry["id"]] = len(cards)
            cards.append(entry)
    print("Denge geçişi: %d seçenek değişti" % balance_pass(cards))
    doc = data.get("_doc", {})
    doc["alanlar"] = ("id, character (hulusi/riza/canan/event/assistant/nezaket/mirmir/defne/bruce/yigithan), weight, once, recyclable, "
                      "must_by_day, priority, cooldown_days, scheduled_only, locked, requires, choices. Metinler strings.csv içinde "
                      "CARD_<ID>_TEXT/_A/_B, karar sonrası tepki CARD_<ID>_RA/_RB, gazete manşeti NEWS_C_<ID>_A/_B.")
    data["_doc"] = doc
    with open(JSON_PATH, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print("JSON: toplam %d kart" % len(cards))

    # --- Doğrulama: her kartın tüm anahtarları var mı
    keys = {r[0] for r in body}
    missing = []
    for c in cards:
        k = c["id"].upper()
        for suffix in ("TEXT", "A", "B"):
            if "CARD_%s_%s" % (k, suffix) not in keys and not (suffix == "B" and len(c["choices"]) < 2):
                missing.append("CARD_%s_%s" % (k, suffix))
    print("Eksik kart anahtarı:", missing)


if __name__ == "__main__":
    main()

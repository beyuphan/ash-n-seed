class_name EndReports
extends RefCounted
## Oyun sonu gazetesinin (EndPaper) içeriğini kurar: kaybetme "ÖZEL SAYI", kazanma "SON SAYI".
## stats: {money, people, nature} (oyun bittiği andaki değerler), GameState.totals sayaçları.

const GOOD := Color(0.13, 0.48, 0.15)
const BAD := Color(0.72, 0.17, 0.11)


## ending_key: END_BANKRUPT, END_REVOLT, END_POLLUTION, END_DEADLINE, END_DISMISSED
static func loss(ending_key: String, stats: Dictionary) -> Dictionary:
	var short := ending_key.trim_prefix("END_")
	var bad_stat := ""
	match short:
		"BANKRUPT": bad_stat = "money"
		"REVOLT": bad_stat = "people"
		"POLLUTION", "DEADLINE", "DISMISSED": bad_stat = "nature"
	var notes := _notes(true)
	notes.push_front(tr_key("END_WHY_%s" % short))
	return {
		"stamp": "END_STAMP_LOSS",
		"win": false,
		"day": GameState.day,
		"headline": "END_HL_%s_%d" % [short, randi() % 3 + 1],
		"sub": "END_SUB_%s" % short,
		"nature": minf(float(stats["nature"]), 30.0),
		"trees": int(GameState.totals.get("planted", 0)),
		"caption": "END_CAP_LOSS",
		"rows": _rows(stats, bad_stat),
		"notes": notes,
		"stars": -1,
		"ending_text": "",
		"quote_who": "yigithan",
		"quote": "END_Q_%s" % short,
		"replay_text": "END_RETRY",
	}


static func win(ending_key: String, stats: Dictionary, tier: int) -> Dictionary:
	return {
		"stamp": "END_STAMP_WIN",
		"issue": "END_PAPER_ISSUE_WIN",
		"win": true,
		"day": GameState.MAX_DAYS,
		"headline": "END_HL_%s" % ending_key,
		"sub": "END_SUB_WIN_%d" % tier,
		"nature": 90.0,
		"trees": int(GameState.totals.get("planted", 0)),
		"caption": "END_CAP_WIN",
		"rows": _rows(stats, ""),
		"notes": _notes(false),
		"stars": tier,
		"ending_text": ending_key,
		"quote_who": "yigithan",
		"quote": "END_Q_WIN_%d" % tier,
		"replay_text": "END_REPLAY",
	}


static func _rows(stats: Dictionary, bad_stat: String) -> Array:
	var rows: Array = []
	for entry in [["money", "coin", "STAT_MONEY"], ["people", "heart", "STAT_PEOPLE"], ["nature", "sprout", "STAT_NATURE"]]:
		var value := int(round(float(stats[entry[0]])))
		rows.append({"icon": entry[1], "label": tr_key(entry[2]), "value": "%d" % value,
			"color": BAD if entry[0] == bad_stat else Color(0.14, 0.11, 0.09)})
	return rows


static func _notes(include_days: bool) -> Array:
	var notes: Array = []
	if include_days:
		notes.append(tr_key("END_NOTE_DAYS") % GameState.day)
	notes.append(tr_key("END_NOTE_TREES") % int(GameState.totals.get("planted", 0)))
	notes.append(tr_key("END_NOTE_TRASH") % int(GameState.totals.get("collected", 0)))
	if int(GameState.totals.get("favors", 0)) > 0:
		notes.append(tr_key("END_NOTE_FAVORS") % int(GameState.totals["favors"]))
	if int(GameState.totals.get("groves", 0)) > 0:
		notes.append(tr_key("END_NOTE_GROVES") % int(GameState.totals["groves"]))
	return notes


static func tr_key(key: String) -> String:
	return str(TranslationServer.translate(key))

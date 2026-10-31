class_name StoryData
extends RefCounted
## OTOMATİK ÜRETİLDİ: tools/build_story.py. Elle değiştirme, o betiği değiştir.

const BEATS := {
 "pinar_1": {
  "npc": "pinar",
  "day": 2,
  "window": 4,
  "at": "okul_avlu",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "people": 3,
    "pinar_tree": true,
    "flags": [
     "pinar_tree"
    ],
    "promise": "pinar_tree"
   },
   {
    "people": -1,
    "pinar_tree": true,
    "flags": [
     "pinar_alone"
    ]
   }
  ]
 },
 "canan_1": {
  "npc": "canan",
  "day": 3,
  "window": 4,
  "at": "fidanlik_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "seeds": {
     "pine": 3
    },
    "people": 2,
    "flags": [
     "canan_trust"
    ],
    "promise": "canan_lab"
   },
   {
    "money": 6,
    "flags": [
     "canan_skeptic"
    ]
   }
  ]
 },
 "riza_1": {
  "npc": "riza",
  "day": 4,
  "window": 3,
  "at": "cay_ocagi_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "people": 6,
    "flags": [
     "promise"
    ],
    "promise": "riza_word"
   },
   {
    "nature": 2,
    "people": -3,
    "flags": [
     "air_first"
    ]
   }
  ]
 },
 "veli_1": {
  "npc": "veli",
  "day": 6,
  "window": 4,
  "at": "degirmen_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "seeds": {
     "oak": 2
    },
    "flags": [
     "veli_legend"
    ],
    "promise": "veli_fish"
   },
   {
    "people": -1
   }
  ]
 },
 "hulusi_1": {
  "npc": "hulusi",
  "day": 8,
  "window": 3,
  "at": "pazar_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "money": 25,
    "pollution": 0.3,
    "flags": [
     "deal"
    ]
   },
   {
    "people": 3,
    "flags": [
     "refused"
    ]
   }
  ]
 },
 "canan_2": {
  "npc": "canan",
  "day": 9,
  "window": 3,
  "at": "orman_kulubesi_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "cost": 15,
    "people": 1,
    "flags": [
     "lab_report"
    ]
   },
   {}
  ]
 },
 "kemal_1": {
  "npc": "kemal",
  "day": 11,
  "window": 4,
  "at": "lojman_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "people": 3,
    "flags": [
     "workers_ally"
    ],
    "promise": "kemal_filter"
   },
   {
    "nature": 2,
    "people": -3,
    "flags": [
     "workers_angry"
    ]
   }
  ]
 },
 "canan_3": {
  "npc": "canan",
  "day": 12,
  "window": 3,
  "at": "fabrika_kapisi_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "cost": 15,
    "people": 1,
    "flags": [
     "filter_cheap"
    ]
   },
   {}
  ]
 },
 "pinar_2": {
  "npc": "pinar",
  "day": 13,
  "window": 3,
  "at": "okul_avlu",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "cost": 5,
    "people": 4,
    "flags": [
     "pinar_cared"
    ]
   },
   {
    "people": 1
   }
  ]
 },
 "riza_2": {
  "npc": "riza",
  "day": 14,
  "window": 3,
  "at": "belediye_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "cost": 20,
    "people": 8,
    "seeds": {
     "oak": 2
    },
    "flags": [
     "workers_planting"
    ]
   },
   {
    "people": -4,
    "extra_if": {
     "flag": "promise",
     "people": -4
    }
   }
  ]
 },
 "veli_2": {
  "npc": "veli",
  "day": 15,
  "window": 4,
  "at": "degirmen_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "people": 2,
    "flags": [
     "journal",
     "confront_plan"
    ]
   },
   {
    "seeds": {
     "oak": 1
    },
    "flags": [
     "journal",
     "careful"
    ]
   }
  ]
 },
 "hulusi_2": {
  "npc": "hulusi",
  "day": 17,
  "window": 3,
  "at": "genel_mudurluk_on",
  "req": [],
  "not": [],
  "variant": "deal",
  "lines": 3,
  "choices": [
   {
    "money": 25,
    "pollution": 0.3,
    "flags": [
     "deal2"
    ]
   },
   {
    "people": 3,
    "money": -8,
    "flags": [
     "enemy"
    ]
   }
  ]
 },
 "kemal_2": {
  "npc": "kemal",
  "day": 18,
  "window": 3,
  "at": "sendika_on",
  "req": [],
  "not": [],
  "variant": "workers_ally",
  "lines": 3,
  "choices": [
   {
    "people": 3,
    "flags": [
     "kemal_gate"
    ]
   },
   {}
  ]
 },
 "canan_4": {
  "npc": "canan",
  "day": 20,
  "window": 3,
  "at": "ciftlik_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "people": 2,
    "flags": [
     "vault_plan"
    ]
   }
  ]
 },
 "canan_5": {
  "npc": "canan",
  "day": 21,
  "window": 4,
  "at": "copluk_kapisi_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "nature": 3,
    "seeds": {
     "oak": 4
    },
    "flags": [
     "seeds_all",
     "vault_open"
    ],
    "vault_open": true
   },
   {
    "people": 3,
    "seeds": {
     "oak": 2,
     "pine": 4
    },
    "flags": [
     "seeds_saved",
     "vault_open"
    ],
    "vault_open": true
   }
  ]
 },
 "veli_3": {
  "npc": "veli",
  "day": 23,
  "window": 3,
  "at": "iskele_ucu",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "nature": 2,
    "people": 2,
    "flags": [
     "grove_ritual"
    ]
   },
   {
    "seeds": {
     "pine": 2
    }
   }
  ]
 },
 "hulusi_3": {
  "npc": "hulusi",
  "day": 25,
  "window": 3,
  "at": "tohum_bankasi_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "people": 4,
    "money": -10,
    "pollution": -0.3,
    "filter": 3,
    "flags": [
     "hulusi_justice"
    ]
   },
   {
    "money": 25,
    "people": 2,
    "pollution": -0.4,
    "filter": 2,
    "flags": [
     "hulusi_redeemed"
    ]
   },
   {
    "money": 40,
    "nature": -8,
    "flags": [
     "sold"
    ]
   }
  ]
 },
 "riza_3": {
  "npc": "riza",
  "day": 26,
  "window": 3,
  "at": "belediye_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "people": 6,
    "flags": [
     "speech_hope"
    ]
   },
   {
    "people": 2,
    "nature": 3,
    "flags": [
     "speech_truth"
    ]
   }
  ]
 },
 "kemal_3": {
  "npc": "kemal",
  "day": 27,
  "window": 3,
  "at": "sendika_on",
  "req": [],
  "not": [],
  "variant": "workers_ally",
  "lines": 2,
  "choices": [
   {
    "people": 3,
    "pollution": -0.5,
    "filter": 2,
    "flags": [
     "stacks_off"
    ]
   },
   {
    "people": 1,
    "pollution": -0.2
   }
  ]
 },
 "pinar_3": {
  "npc": "pinar",
  "day": 28,
  "window": 3,
  "at": "pinar_agaci",
  "req": [],
  "not": [],
  "variant": "pinar_cared",
  "lines": 2,
  "choices": [
   {
    "people": 5,
    "flags": [
     "pinar_hope"
    ]
   }
  ]
 },
 "canan_6": {
  "npc": "canan",
  "day": 29,
  "window": 3,
  "at": "fidanlik_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "seeds": {
     "oak": 3,
     "pine": 5
    },
    "people": 3,
    "flags": [
     "ready"
    ]
   }
  ]
 },
 "yigithan_1": {
  "npc": "yigithan",
  "day": 7,
  "window": 4,
  "at": "orman_kulubesi_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "seeds": {
     "oak": 2
    },
    "people": 2,
    "flags": [
     "yigithan_friend"
    ]
   },
   {
    "people": -1,
    "flags": [
     "yigithan_wait"
    ]
   }
  ]
 },
 "yigithan_2": {
  "npc": "yigithan",
  "day": 11,
  "window": 4,
  "at": "orman_kulubesi_on",
  "req": [],
  "not": [],
  "variant": "yigithan_friend",
  "lines": 2,
  "choices": [
   {
    "people": 1,
    "flags": [
     "yigithan_roots"
    ]
   },
   {
    "seeds": {
     "oak": 1
    },
    "flags": [
     "yigithan_roots_half"
    ]
   }
  ]
 },
 "yigithan_3": {
  "npc": "yigithan",
  "day": 16,
  "window": 4,
  "at": "ciftlik_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "cost": 20,
    "people": 2,
    "flags": [
     "yigithan_guard"
    ]
   },
   {
    "people": 1
   }
  ]
 },
 "yigithan_4": {
  "npc": "yigithan",
  "day": 22,
  "window": 3,
  "at": "copluk_kapisi_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "seeds": {
     "oak": 3
    },
    "flags": [
     "yigithan_key"
    ]
   },
   {
    "seeds": {
     "pine": 4
    },
    "people": 3,
    "flags": [
     "yigithan_key_shared"
    ]
   }
  ]
 },
 "yigithan_5": {
  "npc": "yigithan",
  "day": 27,
  "window": 2,
  "at": "fidanlik_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 3,
  "choices": [
   {
    "people": 2,
    "flags": [
     "last_tree_us"
    ]
   },
   {
    "people": 3,
    "flags": [
     "last_tree_all"
    ]
   }
  ]
 },
 "yigithan_6": {
  "npc": "yigithan",
  "day": 30,
  "window": 0,
  "at": "fidanlik_on",
  "req": [],
  "not": [],
  "variant": "",
  "lines": 2,
  "choices": [
   {
    "nature": 2,
    "people": 3,
    "flags": [
     "last_tree_done"
    ]
   }
  ]
 }
}

const HOMES := {
 "pinar": [
  "okul_avlu",
  "okul_avlu",
  "okul_avlu",
  "okul_avlu",
  "okul_avlu",
  "pinar_agaci"
 ],
 "canan": [
  "fidanlik_on",
  "orman_kulubesi_on",
  "fabrika_kapisi_on",
  "ciftlik_on",
  "copluk_kapisi_on",
  "fidanlik_on"
 ],
 "riza": [
  "cay_ocagi_on",
  "cay_ocagi_on",
  "belediye_on",
  "belediye_on",
  "belediye_on",
  "belediye_on"
 ],
 "veli": [
  "degirmen_on",
  "degirmen_on",
  "degirmen_on",
  "degirmen_on",
  "iskele_ucu",
  "degirmen_on"
 ],
 "hulusi": [
  "pazar_on",
  "pazar_on",
  "genel_mudurluk_on",
  "genel_mudurluk_on",
  "tohum_bankasi_on",
  "genel_mudurluk_on"
 ],
 "kemal": [
  "lojman_on",
  "lojman_on",
  "lojman_on",
  "sendika_on",
  "sendika_on",
  "sendika_on"
 ],
 "yigithan": [
  "orman_kulubesi_on",
  "orman_kulubesi_on",
  "orman_kulubesi_on",
  "ciftlik_on",
  "copluk_kapisi_on",
  "fidanlik_on"
 ]
}

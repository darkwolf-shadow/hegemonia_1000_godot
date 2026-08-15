import json, collections
base = r'C:\Users\Administrator\repos\hegemonia_1000_godot'
with open(base + '\\data\\config\\game_config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)
region_factions = {
    'indian': ['Impero Chola'],
    'african': ['Impero del Ghana'],
    'american': ['Toltechi', 'Regni Maya'],
    'asian': ['Dinastia Song', 'Impero Khitan Liao', 'Regno Heian', 'Regno Khmer', 'Regno di Srivijaya'],
    'oriental': ['Impero Bizantino', 'Califfato di Cordova', 'Impero Fatimide', 'Califfato Abbaside', 'Sultanato Ghaznavide'],
    'european': ['Sacro Romano Impero', 'Vichinghi', 'Regno di Francia', 'Regno d\'Ungheria', 'Principato di Kiev', 'Regno di Polonia', 'Terra di Nessuno'],
}
out = collections.defaultdict(list)
for uid, u in cfg['units'].items():
    for f in u.get('factions', []):
        for region, fl in region_factions.items():
            if f in fl:
                if uid not in out[region]:
                    out[region].append(uid)
for r in ['indian','african','american','asian','oriental','european']:
    print(r, len(out[r]), out[r])

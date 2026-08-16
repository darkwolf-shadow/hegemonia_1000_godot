import json
from collections import defaultdict

p = json.load(open('data/world/provinces_1000.json', encoding='utf-8'))

fac = defaultdict(lambda: {'provinces': 0, 'pop': 0, 'cibo': 0, 'denaro': 0, 'legname': 0, 'pietra': 0, 'ferro': 0, 'armi': 0, 'prestigio': 0, 'oro': 0})
for name, v in p.items():
    owner = v.get('owner', 'Terra di Nessuno')
    f = fac[owner]
    f['provinces'] += 1
    f['pop'] += int(v.get('population', 0))
    r = v.get('resources', {})
    for k in ['cibo', 'denaro', 'legname', 'pietra', 'ferro', 'armi', 'prestigio', 'oro']:
        f[k] += int(r.get(k, 0))

for o in sorted(fac, key=lambda x: -fac[x]['provinces']):
    f = fac[o]
    print(f"{o}: prov={f['provinces']} pop={f['pop']} oro={f['oro']} denaro={f['denaro']} cibo={f['cibo']} legname={f['legname']} pietra={f['pietra']} ferro={f['ferro']} armi={f['armi']} prestigio={f['prestigio']}")

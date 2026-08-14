import os

BASE_DIR = os.path.join("assets", "backgrounds", "1000")


def save(name, svg):
    os.makedirs(BASE_DIR, exist_ok=True)
    with open(os.path.join(BASE_DIR, f"{name}.svg"), "w", encoding="utf-8") as f:
        f.write(svg)


def bg(contents, sky="#87CEEB"):
    return (
        f'<svg viewBox="0 0 1920 1080" xmlns="http://www.w3.org/2000/svg">'
        f'<rect width="1920" height="1080" fill="{sky}"/>'
        f'{contents}'
        f'</svg>'
    )


TERRAINS = {
    "plains": bg('<rect y="600" width="1920" height="480" fill="#7a9a4a"/>'
                 '<path d="M0 600 Q480 500 960 600 T1920 600 V1080 H0 Z" fill="#6a8a3a"/>'
                 '<circle cx="1600" cy="180" r="80" fill="#f5e6a3" opacity="0.8"/>'),
    "hills": bg('<path d="M0 1080 L0 650 Q300 400 600 650 T1200 600 T1920 700 V1080 Z" fill="#6a8a3a"/>'
                '<path d="M0 1080 L0 800 Q400 650 800 800 T1600 750 T1920 850 V1080 Z" fill="#5a7a2a"/>'),
    "mountains": bg('<path d="M0 1080 L0 700 L300 300 L600 700 L900 250 L1200 700 L1500 350 L1920 700 V1080 Z" fill="#5a5a5a"/>'
                    '<path d="M300 300 L330 350 L270 350 Z" fill="#e8e8e8"/>'
                    '<path d="M900 250 L930 300 L870 300 Z" fill="#e8e8e8"/>'
                    '<path d="M1500 350 L1530 400 L1470 400 Z" fill="#e8e8e8"/>'),
    "forest": bg('<rect y="500" width="1920" height="580" fill="#3e6b2e"/>'
                 '<circle cx="200" cy="500" r="80" fill="#2d4d1f"/>'
                 '<circle cx="400" cy="520" r="90" fill="#366326"/>'
                 '<circle cx="700" cy="480" r="100" fill="#2d4d1f"/>'
                 '<circle cx="1000" cy="510" r="85" fill="#366326"/>'
                 '<circle cx="1400" cy="490" r="110" fill="#2d4d1f"/>'
                 '<circle cx="1700" cy="520" r="75" fill="#366326"/>'),
    "desert": bg('<rect y="600" width="1920" height="480" fill="#d4a76a"/>'
                 '<path d="M0 650 Q400 550 800 650 T1600 620 T1920 700 V1080 H0 Z" fill="#c49e5a"/>'
                 '<circle cx="1700" cy="180" r="90" fill="#f5e6a3"/>'),
    "coast": bg('<rect y="450" width="1920" height="630" fill="#4a7a9a"/>'
                '<path d="M0 1080 L0 600 Q600 550 1200 600 T1920 650 V1080 Z" fill="#c4b896"/>'
                '<path d="M1200 600 L1300 500 L1400 600 Z" fill="#8b7355"/>'),
    "swamp": bg('<rect y="600" width="1920" height="480" fill="#5a6a4a"/>'
                '<ellipse cx="400" cy="800" rx="100" ry="30" fill="#4a5a3a"/>'
                '<ellipse cx="900" cy="900" rx="140" ry="35" fill="#4a5a3a"/>'
                '<ellipse cx="1500" cy="750" rx="120" ry="25" fill="#4a5a3a"/>'
                '<path d="M350 800 L350 650 M450 800 L450 660" stroke="#3a4a2a" stroke-width="4"/>'
                '<path d="M850 900 L850 720 M950 900 L950 720" stroke="#3a4a2a" stroke-width="4"/>'),
    "river": bg('<rect y="600" width="1920" height="480" fill="#7a9a4a"/>'
                '<path d="M0 1080 L0 800 Q300 700 600 800 T1200 850 T1920 750 V1080 Z" fill="#4a7a9a"/>'),
    "jungle": bg('<rect y="450" width="1920" height="630" fill="#1e5a2e"/>'
                 '<circle cx="250" cy="450" r="100" fill="#0f3d1f"/>'
                 '<circle cx="600" cy="500" r="120" fill="#164d26"/>'
                 '<circle cx="1000" cy="440" r="110" fill="#0f3d1f"/>'
                 '<circle cx="1500" cy="480" r="130" fill="#164d26"/>'
                 '<circle cx="1800" cy="460" r="90" fill="#0f3d1f"/>'),
    "savannah": bg('<rect y="580" width="1920" height="500" fill="#b8a75a"/>'
                   '<path d="M0 600 Q500 500 1000 600 T1920 550 V1080 H0 Z" fill="#a8984a"/>'
                   '<circle cx="300" cy="550" r="5" fill="#5a4a2a"/>'
                   '<circle cx="700" cy="520" r="4" fill="#5a4a2a"/>'
                   '<circle cx="1200" cy="560" r="6" fill="#5a4a2a"/>'),
    "steppe": bg('<rect y="600" width="1920" height="480" fill="#9aa85a"/>'
                 '<path d="M0 600 Q600 500 1200 600 T1920 580 V1080 H0 Z" fill="#8a964a"/>'),
    "tundra": bg('<rect y="600" width="1920" height="480" fill="#c8d4e0"/>'
                 '<path d="M0 650 Q400 550 800 650 T1600 620 T1920 700 V1080 H0 Z" fill="#a8b8c8"/>'
                 '<path d="M200 650 L220 600 L240 650 Z" fill="#e8e8e8"/>'
                 '<path d="M1400 620 L1430 560 L1460 620 Z" fill="#e8e8e8"/>'),
    "generic": bg('<rect y="600" width="1920" height="480" fill="#7a9a4a"/>'
                  '<circle cx="1600" cy="180" r="80" fill="#f5e6a3" opacity="0.8"/>'),
}


SETTLEMENTS = {
    "civil": bg('<rect y="600" width="1920" height="480" fill="#7a9a4a"/>'
                '<rect x="700" y="450" width="120" height="120" fill="#a89f91"/>'
                '<path d="M680 450 L760 380 L840 450 Z" fill="#7a6f63"/>'
                '<rect x="900" y="420" width="140" height="150" fill="#a89f91"/>'
                '<path d="M880 420 L970 350 L1060 420 Z" fill="#7a6f63"/>'),
    "military": bg('<rect y="600" width="1920" height="480" fill="#6a7a5a"/>'
                   '<rect x="650" y="400" width="220" height="180" fill="#7a7a6a" stroke="#2a2a1a" stroke-width="4"/>'
                   '<rect x="730" y="320" width="60" height="100" fill="#6a6a5a" stroke="#2a2a1a" stroke-width="3"/>'),
    "industrial": bg('<rect y="600" width="1920" height="480" fill="#6a5a4a"/>'
                     '<rect x="700" y="400" width="200" height="180" fill="#5a4a3a" stroke="#1a0a0a" stroke-width="3"/>'
                     '<rect x="750" y="300" width="30" height="80" fill="#4a3a2a"/>'
                     '<rect x="820" y="280" width="30" height="100" fill="#4a3a2a"/>'
                     '<path d="M760 280 Q740 220 780 220" fill="none" stroke="#888" stroke-width="4"/>'
                     '<path d="M830 250 Q810 200 850 200" fill="none" stroke="#888" stroke-width="4"/>'),
    "port": bg('<rect y="600" width="1920" height="480" fill="#7a9a4a"/>'
               '<rect x="600" y="400" width="400" height="50" fill="#5a4a3a"/>'
               '<path d="M900 580 L980 500 L1100 500 L1180 580" fill="#4a7a9a" stroke="#1a2a3a" stroke-width="3"/>'
               '<rect x="700" y="350" width="120" height="80" fill="#a89f91"/>'
               '<path d="M680 350 L760 290 L840 350 Z" fill="#7a6f63"/>'),
}


def main():
    for name, svg in TERRAINS.items():
        save(name, svg)
    for name, svg in SETTLEMENTS.items():
        save(name, svg)
    print("Sfondi generati in", BASE_DIR)


if __name__ == "__main__":
    main()

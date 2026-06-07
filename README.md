# Small Cannon

Mod do Factorio 2.0 dodający małą armatę artyleryjską dostępną wcześniej niż standardowa artyleria — idealna do obrony bazy w środkowej fazie gry.

---

## Spis treści

1. [Opis](#opis)
2. [Nowa wieżyczka: Mała artyleria](#nowa-wieżyczka-mała-artyleria)
3. [Nowa amunicja: Żelazny pocisk artyleryjski](#nowa-amunicja-żelazny-pocisk-artyleryjski)
4. [Technologia](#technologia)
5. [Receptury](#receptury)
6. [Porównanie: Mała vs Standardowa artyleria](#porównanie-mała-vs-standardowa-artyleria)
7. [Instalacja](#instalacja)
8. [Pliki moda](#pliki-moda)
9. [Znane problemy](#znane-problemy)

---

## Opis

**Small Cannon** wprowadza mniejszą, tańszą i wcześniej dostępną wieżyczkę artyleryjską wraz z dedykowaną, tańszą amunicją. Doskonałe uzupełnienie bazy w momencie, gdy standardowa artyleria jest jeszcze poza zasięgiem (wymaga space science).

---

## Nowa wieżyczka: Mała artyleria

| Cecha | Wartość |
|-------|---------|
| Nazwa | `small-artillery-turret` |
| HP | 500 |
| Zasięg | 120 kratek |
| Minimalny zasięg | 8 kratek |
| Szybkostrzelność | co 2.5 sekundy (150 ticków) |
| Czas obrotu | 0.8s (pełny obrót 360°) |
| Kategoria amunicji | `artillery-shell` |
| Odległość tworzenia pocisku | 1.5 |

**Automatyczne celowanie** — wieżyczka sama namierza i ostrzeliwuje wrogów w zasięgu, tak jak standardowa artyleria.

---

## Nowa amunicja: Żelazny pocisk artyleryjski

Żelazny pocisk artyleryjski to tańsza alternatywa dla standardowych pocisków. Dzieli tę samą kategorię amunicji (`artillery-shell`), więc może być używany zarówno w małej, jak i w standardowej artylerii — i odwrotnie.

| Cecha | Wartość |
|-------|---------|
| Nazwa | `iron-cannon-shell` |
| Obrażenia | 150 (eksplozja) |
| Promień wybuchu | 4 kratki |
| Czas przeładowania | 1s (60 ticków) |
| Pojemność magazynka | 1 |
| Stos w ekwipunku | 50 sztuk |

**Skutki trafienia:**
- Eksplozja (wizualna) w miejscu uderzenia
- Obszarowe obrażenia w promieniu 4 kratek
- Niszczenie dekoracji (drzewa, skały) w promieniu 4 kratek

---

## Technologia

**Small Artillery** — technologia odblokowująca małą armatę i żelazne pociski.

| Cecha | Wartość |
|-------|---------|
| Nazwa | `small-artillery` |
| Wymagania wstępne | `military-3`, `production-science-pack`, `engine` |
| Koszt | 200 jednostek nauki |
| Czas badania | 30 sekund |
| Używane pakiety nauki | military (szary), production (fioletowy), chemical (niebieski) |
| Efekty | Odblokowuje recepturę `small-artillery-turret` i `iron-cannon-shell` |

Dostępna po uzyskaniu production science (fioletowe pakiety) — jeszcze przed space science (żółte pakiety).

---

## Receptury

### Mała artyleria

```
Czas wytwarzania: 5s
Składniki:
  - 30x stal (steel-plate)
  - 20x koło zębate (iron-gear-wheel)
  - 10x silnik (engine-unit)
  -  5x silnik elektryczny (electric-engine-unit)
  - 10x układ zaawansowany (advanced-circuit)
Wynik: 1x small-artillery-turret
```

### Żelazny pocisk artyleryjski

```
Czas wytwarzania: 3s
Składniki:
  - 6x żelazo (iron-plate)
  - 3x stal (steel-plate)
  - 2x materiały wybuchowe (explosives)
Wynik: 1x iron-cannon-shell
```

---

## Porównanie: Mała vs Standardowa artyleria

| Cecha | Mała artyleria | Standardowa artyleria |
|-------|---------------|----------------------|
| HP | 500 | 1000 |
| Zasięg | 120 | 224 |
| Szybkostrzelność | co 2.5s (szybciej) | co 3s |
| Obrażenia na pocisk | 150 | 500 |
| Promień wybuchu | 4 | 8 |
| Zajmowana przestrzeń | ~2×2 kratki | ~3×3 kratki |
| Koszt wieżyczki | ok. 65 surowców | ok. 125 surowców |
| Koszt amunicji | 6 żelaza + 3 stali + 2 mat. wyb. | 8 stali + 5 mat. wyb. + 2 plastiku |
| Wymagana technologia | **production science** | **space science** |
| Fazowanie | Średnia gra | Późna gra |

---

## Instalacja

### Ręcznie

1. Skopiuj folder `small-cannon` do katalogu modów Factorio:

   | System | Ścieżka |
   |--------|---------|
   | **Linux** | `~/.factorio/mods/small-cannon/` |
   | **Windows** | `%appdata%/Factorio/mods/small-cannon/` |
   | **macOS** | `~/Library/Application Support/factorio/mods/small-cannon/` |

2. Uruchom Factorio — mod powinien pojawić się na liście modów.
3. Włącz moda i kliknij **Synchronize mods** (lub uruchom grę).

### Poprzez portal modów

*(Mod nie jest obecnie opublikowany w portalu Factorio Mod Portal)*

---

## Pliki moda

```
small-cannon/
├── info.json            # Metadane moda (nazwa, wersja, zależności)
├── data.lua             # Nowe prototypy: amunicja, pocisk, receptury, technologia
├── data-updates.lua     # Kopie bazowej wieżyczki i działa + modyfikacje
└── README.md            # Ten plik
```

### `data.lua`

Definiuje wszystkie nowe prototypy, które nie zależą od danych bazowych:
- `iron-cannon-shell` — amunicja
- `iron-cannon-shell-projectile` — pocisk
- Receptury dla wieżyczki i amunicji
- Technologia `small-artillery`

### `data-updates.lua`

Uruchamiany po załadowaniu danych bazowych. Kopiuje prototyp standardowej wieżyczki artyleryjskiej oraz jej działa (`artillery-wagon-cannon`) i modyfikuje je:
- Skaluje grafikę wieżyczki do 65%
- Zmniejsza statystyki (HP, zasięg, obrażenia)
- Zmniejsza collision_box i selection_box
- Tworzy odpowiednik itemu i corpse
- Tworzy nowy prototyp działa (`small-artillery-cannon`) ze zmodyfikowanymi parametrami ataku (zasięg, szybkostrzelność)
- Wiąże nową wieżyczkę z nowym działem przez pole `gun`

---

## Znane problemy

- Grafika działa na zasadzie **przeskalowania** oryginalnej tekstury artylerii — może nie wyglądać idealnie proporcjonalnie.
- Animacja pocisku wykorzystuje grafikę standardowego pocisku artyleryjskiego (zamiast dedykowanej).
- Mod nie był testowany z innymi modami dodającymi artylerię — mogą wystąpić konflikty kategorii amunicji.
- Wymaga **Factorio 2.0** — nie działa z wersją 1.1.

---

## Licencja

MIT — możesz swobodnie modyfikować i rozpowszechniać.

# 🗺️ Kartan Parannusehdotukset

## 📊 Nykyinen Tila

### ✅ Mitä on jo:
- Google Maps integraatio ✅
- Klusterointi (markkerit ryhmiteltynä) ✅
- Käyttäjän sijainnin näyttäminen ✅
- Draggable bottom sheet (kartta piilossa kun lista ylhäällä) ✅

### ⚠️ Mitä puuttuu:
- Kustomoidut markkerit kategorioille (kaikki vihreitä)
- Kartan tyylit (vain normaali)
- Zoom-napit
- Markkerin klikkaus → avaa ilmoituksen
- Etäisyysviivat käyttäjästä
- Paremmat kluster-ikonit

---

## 🎯 PARANNUSEHDOTUKSET (Prioriteetti)

### 1. **Kustomoidut Markkerit Kategorioille** 🔥 KORKEA

**Ongelma**: Kaikki markkerit ovat vihreitä → vaikea erottaa kategorioita

**Ratkaisu**: Eri värit/ikonit kategorioille
- 🍎 Hedelmiä → Punainen
- 🥖 Leivonnaiset → Keltainen
- 🥬 Vihannekset → Vihreä
- 🥛 Muut → Sininen

**Aika**: 1-2h  
**Vaikeus**: Helppo

---

### 2. **Markkerin Klikkaus → Avaa Ilmoitus** 🔥 KORKEA

**Ongelma**: Markkeria klikkaamalla ei tapahdu mitään

**Ratkaisu**: 
- Klikkaa markkeria → avaa `FoodDetailScreen`
- InfoWindow näyttää otsikon ja hinnan
- "Näytä lisää" -nappi InfoWindow:ssa

**Aika**: 30min  
**Vaikeus**: Helppo

---

### 3. **Kartan Tyylit** ⭐ Keski

**Ongelma**: Vain normaali kartta

**Ratkaisu**: Lisää dropdown/button group:
- Normaali (nykyinen)
- Satelliitti
- Maasto
- Hybridi

**Aika**: 1h  
**Vaikeus**: Helppo

---

### 4. **Zoom-napit** ⭐ Keski

**Ongelma**: Ei zoom-nappeja (zoomControlsEnabled: false)

**Ratkaisu**: Lisää custom zoom-napit:
- ➕ Zoom in
- ➖ Zoom out
- 🎯 Keskitä käyttäjään

**Aika**: 1h  
**Vaikeus**: Helppo

---

### 5. **Paremmat Kluster-ikonit** ⭐ Keski

**Ongelma**: Klusterit ovat oransseja palloja

**Ratkaisu**: 
- Kustomoidut kluster-ikonit numerolla
- Eri koko klustereille (pieni/keski/iso)
- Väri muuttuu määrän mukaan

**Aika**: 2h  
**Vaikeus**: Keski

---

### 6. **Etäisyysviivat** 💡 Matala

**Ongelma**: Ei näy etäisyysviivoja käyttäjästä

**Ratkaisu**: 
- Ympyrät käyttäjän ympärillä (1km, 2km, 5km)
- Näyttää visuaalisesti etäisyydet

**Aika**: 2-3h  
**Vaikeus**: Keski

---

### 7. **Kartan Suodattimet** ⭐ Keski

**Ongelma**: Suodattimet ovat vain listassa

**Ratkaisu**: 
- Näytä suodattimet myös kartan päällä
- Kun suodatetaan → piilota markkerit kartalta
- Näytä vain valitun kategorian markkerit

**Aika**: 1-2h  
**Vaikeus**: Keski

---

### 8. **Kartan Animointi** 💡 Matala

**Ongelma**: Kartta ei animoi sujuvasti

**Ratkaisu**: 
- Sujuvat siirtymät zoomissa
- Animoi kun käyttäjä liikkuu
- Smooth camera movements

**Aika**: 1h  
**Vaikeus**: Helppo

---

## 🎨 VISUAALISET PARANNUKSET

### 9. **InfoWindow Parannukset** ⭐ Keski

**Nykyinen**: Vain otsikko ja kuvaus

**Parannus**:
- Näytä kuva (pieni thumbnail)
- Näytä hinta (ilmainen / €X.XX)
- Näytä etäisyys
- Näytä kategoria-ikoni
- "Näytä lisää" -nappi

**Aika**: 2h  
**Vaikeus**: Keski

---

### 10. **Kartan Tema** 💡 Matala

**Ongelma**: Kartta on perus Google Maps

**Ratkaisu**: 
- Kustomoitu kartan väriteema
- Vihreä/ekologinen teema
- Dark mode tuki

**Aika**: 3-4h  
**Vaikeus**: Vaikea

---

## 🚀 SUOSITUS: Aloita Näistä

### 🔥 **KORKEA PRIORITEETTI** (Tee ensin):
1. **Kustomoidut markkerit kategorioille** (1-2h)
2. **Markkerin klikkaus → avaa ilmoitus** (30min)

### ⭐ **KESKI PRIORITEETTI**:
3. **Kartan tyylit** (1h)
4. **Zoom-napit** (1h)
5. **InfoWindow parannukset** (2h)

### 💡 **MATALA PRIORITEETTI**:
6. **Paremmat kluster-ikonit** (2h)
7. **Etäisyysviivat** (2-3h)
8. **Kartan suodattimet** (1-2h)

---

## 📝 YHTEENVETO

**Nopeimmat parannukset** (2-3h yhteensä):
- Kustomoidut markkerit
- Markkerin klikkaus
- Zoom-napit

**Isoimmat vaikutukset**:
- Kustomoidut markkerit → käyttäjä näkee kategoriat heti
- Markkerin klikkaus → parempi UX
- InfoWindow parannukset → enemmän tietoa ilman klikkausta

---

**Haluatko että toteutan jonkin näistä?** 🚀

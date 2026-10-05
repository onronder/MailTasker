# Segmentasyon ve task çıkarma kuralları

## Segment nedir

> Kişi alanlarında (`config.spaces[].people`) bu bölüm yerine `SKILL.md` 2b'deki kişi kuralı uygulanır:
> segment = maili ilgilendiren kişi (ör. Kuzey, Poyraz), birden çoksa "Ortak", hiçbiri değilse "Genel".
> Görev başlıklarına kişi adını yazmaya gerek yok; segment zaten gösterir.

Kullanıcının hayatındaki **kalıcı bir konu** veya iş akışı: bir müşteri, proje, tedarikçi grubu,
bir süreç (faturalar, işe alım, seyahat), bir topluluk. Tek seferlik bir mail segment değildir.

İyi segment adları: "Alfa projesi", "Müşteri: Beta A.Ş.", "Faturalar ve ödemeler", "İşe alım", "Bülten ve duyurular".
Kötü: "Önemli", "Diğer", "Mailler", "Ayşe'nin maili", "Ekim".

### Atama sırası
1. Mevcut segmentleri (`mergedInto` hedeflerine çözülmüş) ad, açıklama ve `keywords` ile karşılaştır.
   Gönderen alan adı, konu satırındaki proje/müşteri adı ve thread geçmişi en güçlü sinyallerdir.
2. Aynı thread'in önceki maili bir segmentteyse aynı segmenti kullan.
3. Hiçbiri uymuyorsa ve konu belirginse yeni segment aç. Belirsiz tekil mailler → `seg-diger` ("Diğer" / "Other");
   bu segmentte 3+ mail aynı konuda birikirse yeni segmente taşı (`emails` `update`).
4. Hedef: toplamda 5–15 segment. 20'yi geçme; geçecekse en yakın mevcut segmenti kullan.

Yeni segmente her iki dilde ad ver (`name.tr`, `name.en`) ve 3–8 `keywords` ekle (iki dilden de).
Bülten, pazarlama ve otomatik bildirimler için tek bir "Bülten ve bildirimler" segmenti yeterlidir.

## Task nedir
Kullanıcının **kendisinin** yapması gereken somut bir eylem. Şunlardan biri olmalı:
- Açık istek veya soru: "rapor gönderebilir misin", "onayınızı bekliyoruz", "görüşünü yazar mısın"
- Ödeme / fatura / yenileme son tarihi
- Toplantı/randevu planlama veya teyit
- Belge imzalama, form doldurma, inceleme
- Kullanıcının mailde verdiği söz ("yarın dönerim" → takip task'ı, `kind: follow-up`)

Task **değildir**: bilgilendirme, bülten, reklam, kargo/sipariş durum bildirimi (aksiyon gerekmiyorsa),
başkasına atanmış işler, kullanıcının CC'de olduğu ve kendisinden bir şey istenmeyen mailler,
otomatik "şifre sıfırlama"/"giriş kodu" mailleri.

Bir maildeki task sayısı genelde 0–2; 4'ü geçmesin.

**Son kontrol (yazmadan önce, her görev için):** mailin tam metnindeki tarih ve saatleri görevle karşılaştır.
Metinde bu işle ilgili bir tarih varken `due` boşsa, ya da detay başka bir şubenin tarihini içeriyorsa düzelt. Emin değilsen task açma — yanlış pozitif listeyi kirletir.

## Task alanları
- `title`: emir kipinde, ≤ 80 karakter, kim/ne net. "Beta A.Ş. sözleşme taslağına yorum gönder" ✔ — "Sözleşme" ✘
- `detail`: tutar, kişi, belge adı gibi işe yarar 1–2 cümle; gizli veri (IBAN tamamı, kart, şifre, kod) yazma.
- `due`: **Mailde tarih geçen bir olay için görev asla tarihsiz bırakılmaz.**
  - Tarihler sınıfa/şubeye/gruba göre veriliyorsa (ör. "4A 5 Eki, 4B 9 Eki") kişinin `config.spaces[].people[].section`
    bilgisine göre doğru tarihi seç ve detaya yalnızca o tarihi yaz.
  - Şube bilinmiyorsa `due` = listedeki en erken tarih; detaya "(şube bilinmiyor; Ayarlar › Alanlar'dan ekle)" yaz
    ve raporda kullanıcıya şubeyi sor.
  - Hazırlık görevlerinde (kıyafet, malzeme, form, imza) `due` = olay günü; olay 2 gün içindeyse öncelik `high`.
  - Mailde açık tarih varsa onu kullan. Göreli ifadeleri ("cuma", "haftaya", "EOD", "ay sonu")
  **mailin tarihine göre** çöz. Tarih yoksa `null`.
- `priority`:
  - `high`: 3 gün içinde son tarih, ödeme/ceza riski, yöneticiden/müşteriden doğrudan istek, "acil"
  - `med`: tarihli ama acil değil, veya doğrudan istek ama tarih yok
  - `low`: isteğe bağlı, "fırsat olursa", takip hatırlatmaları
- `kind`: `reply | pay | review | approve | schedule | send | follow-up | other`
- `lang`: `config.lang` `auto` ise mailin dili; aksi halde config dili. `title`/`detail` bu dilde.

## Özet
Her mail için 1–2 cümle, mailin dilinde (veya `config.lang`): kim, ne istiyor/ne bildiriyor, varsa tarih.
Selamlaşma ve dolgu yok.

## Örnekler

**TR, task var**
> Kimden: Ayşe (tedarikci.com) — Konu: Ekim faturası — Tarih: 2 Ekim
> "Merhaba, ekim ayı hosting faturanız ektedir. Son ödeme tarihi 10 Ekim'dir."

→ segment `seg-faturalar`; task: `{ title: "Ekim hosting faturasını öde", due: "2026-10-10", priority: "med", kind: "pay" }`

**EN, task var, göreli tarih**
> From: Mark (client) — Subject: Draft contract — Date: Thu 1 Oct
> "Could you send your comments on the draft by Monday? We want to sign next week."

→ segment `seg-musteri-acme`; task: `{ title: "Send comments on Acme draft contract", due: "2026-10-05", priority: "high", kind: "review", lang: "en" }`

**Task yok**
> "Siparişiniz kargoya verildi. Takip no: ..."

→ segment `seg-bulten-bildirim`; task yok.

**Başkasına atanmış**
> To: Ali, CC: kullanıcı — "Ali, sunumu cuma gününe kadar hazırlar mısın?"

→ task yok (kullanıcıdan istenmiyor). Kullanıcı yöneticiyse ve takip etmesi bekleniyorsa `low` bir `follow-up` olabilir.

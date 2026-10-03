# MailTasker

Gmail ve Outlook (Microsoft 365) hesaplarında **seçtiğin klasörlerdeki** mailleri okuyan,
konulara (segmentlere) ayıran ve maillerden **yapılacaklar listesi** çıkaran bir Claude agent'ı.
Sonuçlar claude.ai'de canlı bir dashboard'da durur. Sunucu, veritabanı ya da API anahtarı gerekmez.

```
"mailleri tara"  ─►  mailtasker skill (Claude)
                       ├─ Gmail / Microsoft 365 connector'ları ile klasörleri okur (salt okunur)
                       ├─ segmentler, özetler, görevleri çıkarır
                       └─ sonuçları MailTasker Dashboard'a yazar  ─►  claude.ai artifact
```

## Bileşenler

| Yol | Ne işe yarar |
|---|---|
| `.claude/skills/mailtasker/SKILL.md` | Agent'ın adım adım çalışma talimatı |
| `.claude/skills/mailtasker/references/extraction.md` | Segment ve görev çıkarma kuralları (TR/EN örnekli) |
| `.claude/skills/mailtasker/references/providers.md` | Gmail etiket ve Outlook klasör sorgu tarifleri |
| `.claude/skills/mailtasker/references/schema.md` | Dashboard veri şeması |
| `dashboard/index.html` | Dashboard sayfasının kaynağı |
| `mailtasker.json` | Yayınlanmış dashboard'un adresi |

Dashboard: https://claude.ai/artifact/MeW1dkCwBgnkCJKVKcWvv5 (gizli, yalnızca sen açabilirsin)

## Kurulum

1. **Gmail**: claude.ai › Settings › Connectors › **Gmail** › Connect.
2. **Outlook**: aynı yerden **Microsoft 365** connector'ünü ekle. Bu connector iş/okul hesapları içindir;
   kişisel outlook.com/hotmail hesapları bağlanamayabilir.
3. Dashboard'u aç › **Ayarlar** sekmesi › hesaplarını ve taranacak klasörleri ekle › *Ayarları kaydet*.
   - Gmail'de klasör = etiket adı (`Faturalar`, `Projeler/Alfa`) ya da `INBOX`.
   - Outlook'ta klasör adı (`Inbox`, `Müşteriler`).

## Kullanım

Bu repo açıkken Claude Code'da (veya skill'i yüklediğin bir claude.ai sohbetinde) şunlardan birini yaz:

- `mailleri tara` / `scan my mail` / `/mailtasker`
- `sadece Faturalar klasörünü tara`
- `iş hesabımdaki Müşteriler klasörünü son 7 gün için tara`

Claude yeni mailleri işler, dashboard'u günceller ve sohbete kısa bir özet yazar.
Agent yalnızca sen istediğinde çalışır.

### Dashboard'da

- **Özet**: açık / gecikmiş / bu haftaki görevler, segment kartları ve 30 günlük mail grafiği.
- **Görevler**: tarihe göre gruplu liste. Tamamla, yarına ya da 1 hafta sonraya ertele, yoksay.
- **Segmentler**: yeniden adlandır, renk ver, iki segmenti birleştir. Bir sonraki tarama bu kararlara uyar.
- **Ayarlar**: hesaplar, klasörler, ilk taramada kaç gün geriye gidileceği, görev dili.
- Sağ üstten arayüz dilini TR/EN arasında değiştirebilirsin.

### claude.ai'de (repo olmadan) kullanmak

`.claude/skills/mailtasker` klasörünü zip'leyip claude.ai › Settings › Capabilities › Skills'ten yükle.
İlk çalıştırmada Claude dashboard linkini soracak; yukarıdaki adresi ver.

## Gizlilik

- Agent maillere yalnızca **okuma** amaçlı erişir; mail göndermez, silmez, etiket değiştirmez.
- Dashboard'a mailin tamamı değil, yalnızca konu, gönderen, tarih, 1–2 cümlelik özet ve bağlantı yazılır.
- Dashboard gizlidir. Paylaşırsan, paylaştığın kişiler bu özetleri ve görevleri görebilir.

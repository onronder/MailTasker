# Mail sağlayıcı tarifleri

Connector tool adları ve argümanları zamanla değişebilir. Her çalıştırmada önce tool'u ToolSearch ile yükle,
**input şemasını oku** ve aşağıdaki tarifi o şemaya uyarla. Şemada olmayan bir argüman uydurma.

Tüm sağlayıcılarda hedef aynı normalize kayıt:
```
messageId, threadId, from{name,email}, to[], subject, date(ISO), body(düz metin, ≤4000 kr), link
```

## Gmail (claude.ai "Gmail" connector)

ToolSearch: `gmail`. Genelde bir **arama** tool'u (Gmail arama sözdizimi alır), bir **mesaj/thread okuma** tool'u
ve bir **etiket listeleme** tool'u bulunur. Taslak/gönderme tool'larını kullanma.

Gmail'de "klasör" = **etiket (label)**.

| Config'teki klasör | Gmail sorgusu |
|---|---|
| `INBOX` | `in:inbox` |
| `Faturalar` | `label:faturalar` |
| `Projeler/Alfa` (iç içe) | `label:projeler-alfa` (boşluk ve `/` → `-`) |
| `Sent` | `in:sent` |
| Kategori (ör. Promotions) | `category:promotions` |

Tarih filtresi: `after:YYYY/MM/DD` (gün hassasiyeti) ya da `after:<unix saniye>` (saat hassasiyeti; cursor için bunu kullan).
Örnek: `label:faturalar after:1727942400 -in:chats -in:spam -in:trash`

Adımlar:
1. Etiket adından emin değilsen önce etiketleri listele, config'teki adı en yakın etikete eşle.
2. Arama sonuçlarını sayfalayarak `maxPerRun` sınırına kadar topla (en yeniden eskiye).
3. Her sonuç için mesajı/thread'i oku (sonuç zaten gövde içeriyorsa ayrıca okuma).
4. Link: `https://mail.google.com/mail/u/<address>/#all/<threadId>` (`address` config'ten; yoksa `u/0`).

## Outlook / Microsoft 365 (claude.ai "Microsoft 365" connector)

ToolSearch: `outlook` / `microsoft 365`. Mail için `outlook_email_search` tool'u kullanılır; içerik eksikse
`read_resource` ile tek mesajı oku.

- Bu connector **iş/okul (Entra ID) hesapları** içindir. Kişisel outlook.com/hotmail hesabı bağlanamıyorsa
  kullanıcıya söyle ve o hesabı atla.

Doğrulanmış kullanım (Ekim 2026):
- Klasör listesi: `outlook_email_search` ile `folderName` + `afterDateTime` (ISO tarih), `limit: 25`, `offset: 0`.
  Son öğe `{"moreResults": true, "nextOffset": 25, "totalResultCount": N}` ise `offset`'i ilerleterek sayfala.
- `folderName` ayarlıyken `query` ile `sender`/`afterDateTime` **birlikte kullanılamaz**; klasör taramasında `query` verme.
- `Inbox`, `Sent Items`, `Archive` gibi standart adlar her dilde tanınır (`INBOX` da çalışır); diğer adlar
  (ör. `Muhasebe`) klasör listesinden eşlenir.
- Her sonuç: `id`, `uri` (`mail:///messages/...`), `subject`, `sender` (yalnızca adres), `recipients`,
  `receivedDateTime`, `summary` (gövdenin ilk ~250 karakteri), `hasAttachments`, `importance`, `isRead`, `webLink`.
  Tam gövde gerekirse `read_resource` ile `uri`'yi oku.
- Sonuçlarda `conversationId` yok → `threadId` olarak `RE:/FW:` önekleri atılmış küçük harf konu kullan.
- Doküman id'si için `schema.md` → `emailId` (kısa kuyruk şeması); tam Graph id `messageId` alanına.
- Link: `webLink`'i aynen kullan.
- Gönderilmiş öğeler: `folderName: "Sent Items"` + aynı `afterDateTime`.

## Gövde temizliği (her sağlayıcı)
- HTML ise düz metne çevir; görsel/izleme pikseli/stil bloklarını at.
- Alıntılanmış önceki yanıtları kes (`On ... wrote:`, `... tarihinde ... şunu yazdı:`, `-----Original Message-----`, `>` satırları).
- İmza ve yasal uyarı bloklarını kes.
- Ekleri okuma; yalnızca ek adlarını not et (ör. "ekte: fatura_ekim.pdf").

# Dashboard veri şeması (Artifact `db`)

Tüm okuma/yazma `ArtifactData` tool'u ile, `url` = dashboard URL'si.

## Kurallar
- Doküman id karakterleri: harf, rakam, `_ - . ~ : @ +` (en fazla 200 bayt). Başka karakter (`/`, `=`, boşluk) → `-` yap.
- **Var olan bir dokümana yazarken `if_version` zorunlu** (okuduğun `version`). Sürüm çakışmasında (kullanıcı
  o arada dashboard'da değiştirdiyse) dokümanı yeniden oku ve yazmayı kullanıcının değişikliğini koruyarak tekrarla.
- Yeni doküman oluştururken `if_version` verme.
- `batch` en fazla 50 yazma; aynı doküman bir batch'te bir kez geçer.
- Tarihler ISO 8601 string (`2026-10-03T09:15:00Z`); sadece gün için `2026-10-10`.
- Depo limiti 25.000 doküman → `SKILL.md` bakım adımı.

## `config/main`
Dashboard Ayarlar sekmesi ve skill tarafından yazılır.
```json
{
  "accounts": [
    { "key": "gmail-kisisel", "provider": "gmail", "address": "ben@gmail.com", "folders": ["INBOX", "Faturalar", "Projeler/Alfa"] },
    { "key": "is", "provider": "m365", "address": "ben@sirket.com", "folders": ["Inbox", "Müşteriler"] }
  ],
  "lookbackDays": 30,
  "maxPerRun": 150,
  "lang": "auto"
}
```
- `key`: kısa, id-güvenli hesap anahtarı (doküman id'lerinde kullanılır).
- `lang`: `"auto"` → task/özet mailin dilinde; `"tr"` / `"en"` → hep o dilde.

## `meta/state`
```json
{
  "cursors": { "gmail-kisisel/Faturalar": "2026-10-03T08:00:00Z" },
  "runs": [ { "at": "2026-10-03T08:01:12Z", "folders": 3, "fetched": 42, "newEmails": 40, "newTasks": 11, "newSegments": 2, "notes": "" } ]
}
```
`runs` en yeni başta, en fazla 20 kayıt. Cursor = o klasörde işlenen en yeni mailin tarihi.

## `segments/{segmentId}`
`segmentId`: `seg-` + kısa slug (`seg-faturalar`, `seg-alfa-projesi`). Bir kez verildikten sonra değişmez.
```json
{
  "name": { "tr": "Faturalar ve ödemeler", "en": "Invoices & payments" },
  "description": "Tedarikçi faturaları, abonelik ödemeleri, dekontlar",
  "color": "c3",
  "keywords": ["fatura", "invoice", "ödeme", "dekont"],
  "userLocked": false,
  "mergedInto": null,
  "createdAt": "2026-10-03T08:01:12Z",
  "lastSeenAt": "2026-10-03T08:01:12Z"
}
```
- `color`: `c1`…`c8` (dashboard paleti). Yeni segmente henüz kullanılmamış ilk rengi ver.
- `userLocked`: kullanıcı dashboard'da adı düzenlediyse `true` → skill `name`/`description`'a dokunmaz.
- `mergedInto`: kullanıcı bu segmenti başka birine birleştirdiyse hedef id. Yeni mailleri hedefe ata.

## `emails/{emailId}`
`emailId`: `{accountKey}_{messageId}` (geçersiz karakterler `-`, en fazla 180 karakter; uzunsa messageId'nin son kısmını al).
```json
{
  "account": "gmail-kisisel",
  "provider": "gmail",
  "folder": "Faturalar",
  "messageId": "18f2c9a7b3e4d5f6",
  "threadId": "18f2c9a7b3e4d5f6",
  "from": { "name": "Ayşe Yılmaz", "email": "ayse@tedarikci.com" },
  "subject": "Ekim faturası",
  "date": "2026-10-02T14:20:00Z",
  "summary": "Ekim ayı hosting faturası ekte; son ödeme 10 Ekim.",
  "lang": "tr",
  "segmentId": "seg-faturalar",
  "link": "https://mail.google.com/mail/u/0/#all/18f2c9a7b3e4d5f6",
  "taskIds": ["gmail-kisisel_18f2c9a7b3e4d5f6~1"],
  "processedAt": "2026-10-03T08:01:12Z"
}
```
Dedupe: yazmadan önce `query` ile `where: [["messageId","in",[...en fazla 30 id]]]` kontrol et
ya da `list` ile tüm id'leri bir kez çek (küçük depoda daha ucuz).

## `tasks/{taskId}`
`taskId`: `{emailId}~{n}` (n = o maildeki sıra, 1'den başlar).
```json
{
  "title": "Ekim hosting faturasını öde",
  "detail": "Tutar 1.250 TL, IBAN mailde.",
  "segmentId": "seg-faturalar",
  "emailId": "gmail-kisisel_18f2c9a7b3e4d5f6",
  "threadId": "18f2c9a7b3e4d5f6",
  "account": "gmail-kisisel",
  "due": "2026-10-10",
  "priority": "high",
  "kind": "pay",
  "status": "open",
  "snoozeUntil": null,
  "lang": "tr",
  "createdAt": "2026-10-03T08:01:12Z"
}
```
- `priority`: `high | med | low`
- `kind`: `reply | pay | review | approve | schedule | send | follow-up | other`
- `status`: `open | done | dismissed | snoozed` — **skill yeni task'ı her zaman `open` yazar ve var olan task'ın
  `status`/`snoozeUntil` alanlarına asla dokunmaz.** Bunlar kullanıcıya aittir.
- Aynı `threadId` için zaten `open` bir task aynı işi anlatıyorsa yenisini açma; gerekirse sadece `due`/`detail`'ı `update` et.

## Örnek batch
```json
{
  "action": "batch",
  "url": "<dashboardUrl>",
  "writes": [
    { "op": "set", "collection": "segments", "doc_id": "seg-faturalar", "data": { "...": "..." } },
    { "op": "update", "collection": "segments", "doc_id": "seg-alfa-projesi", "if_version": 7, "data": { "lastSeenAt": "2026-10-03T08:01:12Z" } },
    { "op": "set", "collection": "emails", "doc_id": "gmail-kisisel_18f2c9a7b3e4d5f6", "data": { "...": "..." } },
    { "op": "set", "collection": "tasks", "doc_id": "gmail-kisisel_18f2c9a7b3e4d5f6~1", "data": { "...": "..." } }
  ]
}
```
Büyük batch'lerde gövdeyi elle yazmak yerine JSON dosyası hazırlayıp `file_path` kullanabilirsin.

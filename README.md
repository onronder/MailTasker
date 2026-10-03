# MailTasker

A Claude agent that reads the Gmail or Outlook folders you pick, groups the mail by topic and turns it into a
to-do list on a live dashboard in your own Claude account. No server, database or API key.

Gmail ya da Outlook'ta seçtiğin klasörlerdeki mailleri okuyan, konulara ayıran ve yapılacakları kendi Claude
hesabındaki canlı bir dashboard'a yazan Claude agent'ı. Sunucu, veritabanı ya da API anahtarı gerekmez.

```
"scan my mail" / "mailleri tara"
        │
        ▼
  mailtasker skill ──► Gmail / Microsoft 365 connector (read-only)
        │
        ▼
  MailTasker Dashboard  (a private page in your Claude account: topics, tasks, settings)
```

## Install / Kurulum

### 1. Add the skill / Skill'i ekle

1. Download [`dist/mailtasker-skill.zip`](dist/mailtasker-skill.zip).
2. In Claude: **Settings › Capabilities** → turn on **Code execution and file creation** (skills need it).
3. Same page: **Skills › Upload skill** and pick the zip.
   *(Claude › Ayarlar › Yetenekler → "Kod çalıştırma ve dosya oluşturma"yı aç → Skills › Skill yükle)*

Team/Enterprise owners can make it available to everyone at once:
**Organization settings › Plugins & skills › Add › Upload a skill**, then set it to *Installed by default*.

### 2. Connect your mail / Mailini bağla

**Settings › Connectors** → connect **Gmail** and/or **Microsoft 365**.
Microsoft 365 is for work or school accounts. Some companies require an IT admin to approve it first.

### 3. Run it / Çalıştır

Start a chat and say **"scan my mail"** (or **"mailleri tara"**).

On the first run Claude:
1. creates your private **MailTasker Dashboard** page,
2. asks which accounts and folders to scan,
3. scans the last 30 days and fills the dashboard.

After that, saying "scan my mail" again only processes new mail.

## Using the dashboard / Dashboard

- **Overview**: open, overdue and this-week tasks, one card per topic with a 30-day mail chart.
- **Tasks**: grouped by due date. Mark done, snooze to tomorrow or next week, dismiss.
- **Segments**: rename, recolor or merge topics. Future scans follow your changes.
- **Settings**: accounts, folders, how far back the first scan goes, task language.
- Switch the interface between Turkish and English in the top-right corner.

Example requests:
- `scan only my Invoices folder` / `sadece Faturalar klasörünü tara`
- `what's overdue this week?` / `bu hafta gecikmiş ne var?`

## Privacy / Gizlilik

- Mail access is read-only. MailTasker never sends, deletes, moves or labels mail.
- The dashboard stores subject, sender, date, a 1–2 sentence summary and a link per email. It never stores full
  bodies or attachments.
- The dashboard is private to you. If you share it, the people you share it with can read those summaries.
- Before creating tasks, Claude checks your Sent folder so requests you already answered are skipped.

## Where it works / Nerede çalışır

The live dashboard needs a Claude environment that can publish artifacts with storage. Where that isn't
available, MailTasker falls back to **snapshot mode**: it scans the last few days and lists the tasks in chat,
without remembering earlier scans.

## Claude Code / Cowork plugin

This repo is also a plugin marketplace:

```
/plugin marketplace add onronder/mailtasker
/plugin install mailtasker@mailtasker
```

Once added from Claude Code, the plugin also shows up in the desktop app's Cowork mode at the next session.
The repo must be public, or the user needs GitHub access to it.

## For developers / Geliştiriciler için

| Path | Purpose |
|---|---|
| `skills/mailtasker/SKILL.md` | Agent workflow |
| `skills/mailtasker/references/extraction.md` | Topic and task rules (TR/EN examples) |
| `skills/mailtasker/references/providers.md` | Gmail and Microsoft 365 query recipes |
| `skills/mailtasker/references/schema.md` | Dashboard data model |
| `skills/mailtasker/assets/dashboard.html` | Dashboard page, published on first run |
| `.claude-plugin/` | Plugin and marketplace manifests |
| `scripts/build-skill.sh` | Rebuilds `dist/mailtasker-skill.zip` |

`.claude/skills/mailtasker` is a symlink to `skills/mailtasker`, so opening this repo in Claude Code loads the
skill automatically. Run `scripts/build-skill.sh` after changing the skill. Your personal dashboard link is kept in
`mailtasker.json`, which is git-ignored.

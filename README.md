# Error Code Guide

Hugo static site for long-tail error-code troubleshooting pages.

## Local development

```powershell
hugo server --disableFastRender
```

Open the local URL printed by Hugo.

## Generate articles from a seed CSV

Edit `seeds/keyword_seed.csv`, then run:

```powershell
./scripts/generate-error-articles.ps1 -SeedCsv seeds/keyword_seed.csv -StartDate 2026-04-27 -DailyCount 3
```

The script writes Markdown files under `content/errors/<brand>/<code>.md`.

For real production content, use `docs/article-generation-prompt.md` as the AI prompt contract, then put the reviewed keyword rows into the CSV before generation.

Generated or AI-written articles belong in:

```text
content/errors/<brand-slug>/<code-slug>.md
```

Do not edit `public/` by hand. Hugo regenerates `public/` on every build.

## Drip publishing

Hugo does not publish future-dated content when `buildFuture: false`. Put future dates in each article front matter, push all files to GitHub, then trigger a Vercel rebuild daily with a Vercel Deploy Hook. Each rebuild publishes only pages whose `date` is no longer in the future.

For an article to publish automatically, its front matter must have:

```yaml
draft: false
date: 2026-04-28T09:00:00Z
```

If `draft: true`, it will not publish even after the date arrives.

Use this as a legitimate publishing queue. Avoid cloaking, scraped text, or misleading automation claims; keep pages accurate, source-checkable, and useful.

## Vercel

1. Push this folder to a GitHub repository.
2. Import the repository in Vercel.
3. Set the build command to `hugo --gc --minify` and output directory to `public` if Vercel does not read `vercel.json`.
4. Create a Vercel Deploy Hook and call it from cron-job.org once per day.

## AdSense

Ad placement is already built into the article template. Before approval, leave `data/adsense.yaml` empty and ads will not render.

After AdSense approval, edit only `data/adsense.yaml`:

```yaml
enabled: true
test_mode: false
client: "ca-pub-0000000000000000"
article_slot: "0000000000"
ads_txt: "google.com, pub-0000000000000000, DIRECT, f08c47fec0942fa0"
```

Every article will automatically render the same responsive mid-article ad block. The `ads.txt` file is generated at `/ads.txt` from the same config.

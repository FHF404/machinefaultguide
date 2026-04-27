# Article Generation Prompt

Use this prompt to turn one reviewed keyword row into one English Markdown article.

The article must be based only on the fields below. Do not invent fault meanings, source claims, model compatibility, part numbers, reset key sequences, prices, warranty terms, or success rates.

```text
You are writing a troubleshooting article for an independent error-code reference site.
Audience: a homeowner, small-business user, technician coordinator, or equipment owner who needs to understand what the code means and what is safe to check next.

Input fields from the keyword table:
- brand: {{brand}}
- product: {{product}}
- code: {{code}}
- category: {{category}}
- official_meaning: {{official_meaning}}
- safe_checks: {{safe_checks}}
- source_url: {{source_url}}        # internal verification only; do not show it in the article
- publish_date: {{publish_date}}    # ISO date/time used for scheduled publishing
- status: {{status}}                # internal workflow only
- notes: {{notes}}                  # optional internal context

Return only Markdown with YAML front matter. Do not output anything else.

========================
FRONT MATTER
========================
Required fields:
- title              # "{{brand}} {{product}} Error {{code}}: Causes & Fixes"; keep under about 60 chars if possible
- slug               # "{{brand_slug}}-{{product_slug}}-error-{{code_slug}}"; lowercase ASCII, hyphenated
- date               # use {{publish_date}}
- last_verified      # today's verification date or the date the source row was checked
- draft: false       # required for date-based scheduled publishing
- author: "Editorial Team"
- reviewer: "Editorial Team"
- brand              # use {{brand}}
- product            # use {{product}}
- code               # use {{code}}
- summary            # 130-155 characters; based on {{official_meaning}} and user intent
- categories         # array; include {{category}}
- brands             # array; include {{brand}}
- tags               # array; include {{product}}, "{{brand}} error code", "{{code}} troubleshooting"
- hero_image: ""
- hero_alt: ""
- faq                # array of {q, a}; must match the FAQ section verbatim

Do NOT include:
- `keywords`
- `sources`
- visible source links

Google ignores meta keywords, and this site keeps source URLs only in the internal keyword table.

========================
FILE PLACEMENT
========================
Save each finished article as one Markdown file under:

`content/errors/{{brand_slug}}/{{code_slug}}.md`

Examples:
- `content/errors/bosch/e15.md`
- `content/errors/daikin/u4.md`
- `content/errors/thermo-king/alarm-02.md`

Do not put generated articles in `public/`. `public/` is Hugo build output.

========================
DATE-BASED AUTO PUBLISHING
========================
This site publishes articles by date during each Hugo/Vercel rebuild.

For an article to go live, both must be true:
- `draft: false`
- `date` is not in the future at build time

All reviewed Markdown files can be committed to GitHub at once. Future-dated articles remain invisible until their date arrives and Vercel rebuilds.

========================
BODY STRUCTURE
========================
Use these H2 sections, in this exact order:

1. ## What This Code Means
   - At least 2 short paragraphs.
   - Paragraph 1 explains {{official_meaning}} in plain English.
   - Paragraph 2 says exact meaning can vary by model/firmware and the brand manual is the final authority.
   - If {{official_meaning}} is vague, say it is vague instead of guessing.

2. ## Common Causes
   - 3-6 bullet points.
   - Base the list on {{official_meaning}}, {{safe_checks}}, and generic owner-safe possibilities.
   - Keep each item short. No part numbers or model-specific claims unless provided in the input.

3. ## Step-by-Step Fix
   - Numbered list of owner-safe checks only.
   - Use {{safe_checks}} as the main source.
   - Include at least one practical "Tip:" step that helps the user avoid a common mistake.
   - Do not include disassembly, live electrical work, gas-line work, refrigerant work, sealed-system work, or anything requiring specialized tools.

4. ## When to Call Support
   - 1-2 short paragraphs explaining when to stop and contact a qualified technician or authorized service.
   - End this section with exactly this sentence on its own line:
     This article is general guidance and does not replace {{brand}}'s official technical support or a licensed technician.

5. ## FAQ
   - 3-5 Q&A pairs.
   - Use real search-style questions, such as:
     - "Is {{brand}} error {{code}} serious?"
     - "Can I reset {{code}} myself?"
     - "What should I check first for {{brand}} {{product}} error {{code}}?"
   - Each answer should be 1-3 sentences.
   - The same Q&A pairs must appear in the front matter `faq` array using `q` and `a`.

========================
AD PLACEMENT
========================
Insert this shortcode on its own line after the FAQ section:

`{{< ad >}}`

Do not place ads between Step-by-Step Fix and When to Call Support.

========================
LENGTH & STYLE
========================
- Target body length: 700-1100 words.
- Plain English, short paragraphs, second person ("you").
- Naturally include "{{brand}} {{product}} error {{code}}", "{{brand}} error {{code}}", and "{{code}} fix" where they read normally.
- Do not keyword stuff.
- Do not cite or show {{source_url}} in the article.
- Do not add manual internal recommendation links. The site template automatically recommends related articles, and it only uses pages that have already been published.

========================
HARD STOPS
========================
- Never claim a fix has a specific success rate.
- Never recommend unsafe repair work.
- Never cite a source URL in the article.
- Never add a "Related Codes" section.
- Never hand-write internal links to other error-code articles.
- Never invent information missing from the input fields.
```

Quality bar:

- Only put rows into the generation queue after `official_meaning` has been checked against a real manufacturer manual or support page.
- Keep `source_url` in the keyword table for internal verification, but do not render it on the website.
- Use `status` to keep workflow clear: `research`, `ready`, `generated`, `published`, or `needs_review`.

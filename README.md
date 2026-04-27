# Machine Fault Guide

A compact Hugo reference site for equipment fault-code notes.

## Development

```powershell
hugo server --disableFastRender
```

## Build

```powershell
hugo --gc --minify
```

The site is built from Markdown content, Hugo layouts, and static assets. Generated output belongs in `public/` and is not committed.

## Content

Editorial source files live under `content/`. Supporting data and maintenance scripts are kept in the project folders for internal use.

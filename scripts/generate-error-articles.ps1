param(
  [string]$SeedCsv = "seeds/keyword_seed.csv",
  [datetime]$StartDate = (Get-Date),
  [int]$DailyCount = 3,
  [bool]$Draft = $false,
  [string]$Author = "Editorial Team",
  [string]$Reviewer = "Editorial Team"
)

$ErrorActionPreference = "Stop"

function ConvertTo-Slug {
  param([string]$Text)
  $slug = $Text.ToLowerInvariant() -replace "[^a-z0-9]+", "-"
  $slug = $slug.Trim("-")
  return $slug
}

function Escape-Yaml {
  param([string]$Text)
  return '"' + ($Text -replace '"', '\"') + '"'
}

function Get-Field {
  param(
    [object]$Row,
    [string]$Name,
    [string]$Fallback = ""
  )
  if ($Row.PSObject.Properties.Name -contains $Name) {
    return [string]$Row.$Name
  }
  return $Fallback
}

$rows = Import-Csv -Path $SeedCsv
$index = 0

foreach ($row in $rows) {
  $rowPublishDate = Get-Field $row "publish_date"
  if ([string]::IsNullOrWhiteSpace($rowPublishDate)) {
    $publishDate = $StartDate.AddDays([math]::Floor($index / $DailyCount)).ToString("yyyy-MM-ddT09:00:00Z")
  } else {
    $publishDate = ([datetime]$rowPublishDate).ToString("yyyy-MM-ddT09:00:00Z")
  }
  $officialMeaning = Get-Field $row "official_meaning" (Get-Field $row "summary")
  $safeChecks = Get-Field $row "safe_checks" "Power the unit off, check owner-accessible external conditions, restart only if safe, and stop if the code returns."
  $lastVerified = Get-Field $row "last_verified" $StartDate.ToString("yyyy-MM-dd")
  $brandSlug = ConvertTo-Slug $row.brand
  $productSlug = ConvertTo-Slug $row.product
  $codeSlug = ConvertTo-Slug $row.code
  $slug = "$brandSlug-$productSlug-error-$codeSlug"
  $title = "$($row.brand) $($row.product) Error $($row.code): Causes & Fixes"
  $dir = Join-Path "content/errors" $brandSlug
  $path = Join-Path $dir "$codeSlug.md"

  New-Item -ItemType Directory -Force -Path $dir | Out-Null

  $frontMatter = @(
    "---"
    "title: $(Escape-Yaml $title)"
    "slug: $(Escape-Yaml $slug)"
    "date: $publishDate"
    "last_verified: $lastVerified"
    "draft: $($Draft.ToString().ToLowerInvariant())"
    "author: $(Escape-Yaml $Author)"
    "reviewer: $(Escape-Yaml $Reviewer)"
    "brand: $(Escape-Yaml $row.brand)"
    "product: $(Escape-Yaml $row.product)"
    "code: $(Escape-Yaml $row.code)"
    "summary: $(Escape-Yaml $officialMeaning)"
    "categories:"
    "  - $(Escape-Yaml $row.category)"
    "brands:"
    "  - $(Escape-Yaml $row.brand)"
    "tags:"
    "  - $(Escape-Yaml $row.product)"
    "  - $(Escape-Yaml "$($row.brand) error code")"
    "  - $(Escape-Yaml "$($row.code) troubleshooting")"
    "hero_image: `"`""
    "hero_alt: `"`""
    "faq:"
    "  - q: $(Escape-Yaml "Is $($row.brand) error $($row.code) serious?")"
    "    a: $(Escape-Yaml "It can be serious if the code returns quickly, the unit leaks, smells hot, trips a breaker, or fails to complete a normal cycle.")"
    "  - q: $(Escape-Yaml "Can I reset $($row.code) myself?")"
    "    a: $(Escape-Yaml "You can try a basic power reset and owner-safe checks, but do not open sealed, gas, refrigerant, or live electrical components.")"
    "  - q: $(Escape-Yaml "Does error $($row.code) always mean a part is bad?")"
    "    a: $(Escape-Yaml "No. Many error codes are caused by blocked hoses, dirty filters, poor water supply, installation issues, or temporary sensor readings.")"
    "---"
    ""
  ) -join "`n"

  $body = @"
## What This Code Means

$officialMeaning

The exact meaning can vary by model or firmware, and $($row.brand)'s own manual is the final authority before ordering parts or scheduling repair.

## Common Causes

- The condition described by the manufacturer: $officialMeaning
- An owner-accessible setup, cleaning, airflow, water-flow, or load issue related to the code.
- A condition that returns after basic checks and needs qualified service.

## Step-by-Step Fix

1. Power the unit off and wait at least 60 seconds before restarting it.
2. Follow these owner-safe checks: $safeChecks
3. Tip: Note exactly when the code returns, because a code at startup often points to a different cause than a code near the end of a cycle.
4. If the same code returns immediately, stop using the unit and check the model-specific service manual or contact a qualified technician.

## When to Call Support

Call support if you see leaking water, burning smells, repeated breaker trips, gas ignition failure, damaged wiring, or a code that returns after cleaning and reset steps.

This article is general guidance and does not replace $($row.brand)'s official technical support or a licensed technician.

## FAQ

### Is $($row.brand) error $($row.code) serious?

It can be serious if the code returns quickly, the unit leaks, smells hot, trips a breaker, or fails to complete a normal cycle.

### Can I reset $($row.code) myself?

You can try a basic power reset and owner-safe checks, but do not open sealed, gas, refrigerant, or live electrical components.

### Does error $($row.code) always mean a part is bad?

No. Many error codes are caused by blocked hoses, dirty filters, poor water supply, installation issues, or temporary sensor readings.

{{< ad >}}
"@

  Set-Content -Path $path -Value ($frontMatter + $body) -Encoding utf8
  $index++
}

Write-Host "Generated $index article files from $SeedCsv."

(function () {
  const input = document.getElementById("site-search");
  const results = document.getElementById("search-results");
  const status = document.getElementById("search-status");
  if (!input || !results || !status) return;

  let index = [];

  function normalize(value) {
    return String(value || "").toLowerCase();
  }

  function escapeHtml(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function score(item, terms) {
    const title = normalize(item.title);
    const code = normalize(item.code);
    const brand = normalize(item.brand);
    const product = normalize(item.product);
    const summary = normalize(item.summary);
    const haystack = `${title} ${code} ${brand} ${product} ${summary}`;

    let total = 0;
    for (const term of terms) {
      if (!haystack.includes(term)) return 0;
      if (code === term || code.replace(/\s+/g, "") === term.replace(/\s+/g, "")) total += 60;
      if (brand === term) total += 35;
      if (title.includes(term)) total += 25;
      if (code.includes(term)) total += 25;
      if (product.includes(term)) total += 15;
      if (summary.includes(term)) total += 8;
    }
    return total;
  }

  function render(items, query) {
    if (!query) {
      results.innerHTML = "";
      status.textContent = `${index.length} published pages indexed.`;
      return;
    }

    if (!items.length) {
      results.innerHTML = '<p class="empty-state">No matching published pages yet.</p>';
      status.textContent = "0 results";
      return;
    }

    status.textContent = `${items.length} result${items.length === 1 ? "" : "s"}`;
    results.innerHTML = items.slice(0, 30).map(({ item }) => `
      <article class="search-result">
        <a href="${escapeHtml(item.url)}">
          <span class="code">${escapeHtml(item.code)}</span>
          <h2>${escapeHtml(item.title)}</h2>
          <p>${escapeHtml(item.summary)}</p>
          <span class="meta">${escapeHtml(item.brand)} / ${escapeHtml(item.product)}</span>
        </a>
      </article>
    `).join("");
  }

  function runSearch() {
    const query = input.value.trim();
    const terms = normalize(query).split(/\s+/).filter(Boolean);
    const matches = index
      .map((item) => ({ item, rank: score(item, terms) }))
      .filter((entry) => entry.rank > 0)
      .sort((a, b) => b.rank - a.rank || a.item.title.localeCompare(b.item.title));
    render(matches, query);
  }

  fetch("/index.json", { headers: { "Accept": "application/json" } })
    .then((response) => {
      if (!response.ok) throw new Error("Search index request failed");
      return response.json();
    })
    .then((data) => {
      index = Array.isArray(data) ? data : [];
      const params = new URLSearchParams(window.location.search);
      input.value = params.get("q") || "";
      runSearch();
      input.addEventListener("input", runSearch);
    })
    .catch(() => {
      status.textContent = "Search index could not be loaded.";
    });
})();

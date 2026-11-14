// Auxilio de arte: captura a saida real do TAAG. Nao integra o programa DOS.
// Uso opcional: node artes/obter-taag.cjs CAMINHO_PARA_PLAYWRIGHT_CORE
const fs = require('fs');
const path = require('path');
const { chromium } = require(process.argv[2]);
(async () => {
  const browser = await chromium.launch({ headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
    const result = {};
    for (const text of ['Moon Patrol', 'GAME', 'OVER']) {
      const font = text === 'Moon Patrol' ? 'Mini' : 'Small';
      const url = 'https://patorjk.com/software/taag/#p=display&f=' + font + '&t=' + encodeURIComponent(text);
      await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
      await page.waitForFunction(t => document.querySelector('textarea')?.value === t && document.body.innerText.includes('Copy'), text, { timeout: 60000 });
      // A arte e o texto do elemento terminal que preserva espacos.
      const candidates = await page.locator('body *').evaluateAll(es => es.filter(e => e.children.length === 0 && e.textContent.includes('\n') && /[|_/\\]/.test(e.textContent) && getComputedStyle(e).whiteSpace.startsWith('pre')).map(e => e.textContent));
      if (candidates.length !== 1) throw new Error('Inspecionar DOM do TAAG: ' + JSON.stringify(candidates));
      result[text] = { font, url, text: candidates[0] };
      console.log(text, JSON.stringify(result[text]));
      await page.screenshot({ path: path.join(__dirname, 'taag-' + text.replace(' ', '-') + '.png') });
      await page.goto('about:blank');
    }
    fs.writeFileSync(path.join(__dirname, 'taag.json'), JSON.stringify(result, null, 2) + '\n');
    console.log(JSON.stringify(result, null, 2));
  } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode = 1; });

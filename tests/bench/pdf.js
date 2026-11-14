// Print tests/bench/results/report.html to report.pdf. Requires playwright.
// Usage: node tests/bench/pdf.js [results-dir]
const path = require('path');
const { chromium } = require('playwright');
(async () => {
  const dir = path.resolve(process.argv[2] || path.join(__dirname, 'results'));
  const browser = await chromium.launch();
  const page = await browser.newPage({ colorScheme: 'light' });
  await page.goto('file://' + path.join(dir, 'report.html'));
  await page.pdf({ path: path.join(dir, 'report.pdf'), format: 'A4', printBackground: true,
    margin: { top: '14mm', bottom: '14mm', left: '12mm', right: '12mm' } });
  await browser.close();
  console.log('wrote', path.join(dir, 'report.pdf'));
})();

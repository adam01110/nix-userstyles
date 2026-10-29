const assert = require("node:assert/strict");
const fs = require("node:fs");
const postcss = require("postcss");

const [
	defaultPath,
	extendedPath,
	replacedPath,
	paletteJSON,
	lightPaletteJSON,
	originalColorsJSON,
] = process.argv.slice(2);
const palette = JSON.parse(paletteJSON);
const lightPalette = JSON.parse(lightPaletteJSON);
const originalColors = new Set(
	JSON.parse(originalColorsJSON).map((color) => color.toLowerCase()),
);
let assertions = 0;

function check(condition, message) {
	assert.ok(condition, message);
	assertions += 1;
}

function verify(path, expectedSelectors, expectedPalette) {
	const root = postcss.parse(fs.readFileSync(path, "utf8"));
	const documents = [];
	root.walkAtRules("-moz-document", (rule) => documents.push(rule));
	check(documents.length === 1, `${path}: exactly one document wrapper`);
	const document = documents[0];
	assert.deepEqual(
		document.params.split(",").map((selector) => selector.trim()),
		expectedSelectors,
	);
	assertions += 1;
	check(
		root.nodes.length === 1,
		`${path}: no rules outside the document wrapper`,
	);

	const themeRules = [];
	document.walkRules((rule) => {
		if (rule.nodes.some((node) => node.prop === "--color-background-default"))
			themeRules.push(rule);
	});
	check(
		themeRules.length === 4,
		`${path}: default, automatic, dark, and light theme rules`,
	);
	check(
		themeRules.some((rule) => rule.selector === ":root"),
		"default root palette",
	);
	check(
		themeRules.some((rule) => rule.selector === ":root[data-theme=dark]"),
		"explicit dark palette",
	);
	check(
		themeRules.some((rule) => rule.selector === ":root[data-theme=light]"),
		"explicit light palette",
	);
	check(
		themeRules.some(
			(rule) =>
				rule.parent.name === "media" &&
				rule.parent.params === "(prefers-color-scheme:dark)",
		),
		"automatic dark palette",
	);

	const expectedTokens = {
		"--ctp-base": `#${expectedPalette.base00}`,
		"--ctp-accent": `#${expectedPalette.base07}`,
		"--color-background-default": `#${expectedPalette.base00}`,
		"--color-foreground-default": `#${expectedPalette.base05}`,
		"--color-foreground-link-default": `#${expectedPalette.base07}`,
		"--color-border-focus": `#${expectedPalette.base07}`,
		"--color-ansi-red": `#${expectedPalette.base08}`,
		"--color-syntax-inserted": `#${expectedPalette.base0B}`,
		"--color-syntax-deleted": `#${expectedPalette.base08}`,
		"--color-syntax-keyword": `#${expectedPalette.base0E}`,
		"color-scheme": "dark",
	};
	for (const rule of themeRules) {
		for (const [property, value] of Object.entries(expectedTokens)) {
			check(
				rule.nodes.some(
					(node) =>
						node.prop === property && node.value === value && node.important,
				),
				`${path}: ${rule.selector} ${property}=${value} !important`,
			);
		}
	}

	let diffSelection = false;
	document.walkRules("diffs-container", (rule) => {
		diffSelection = rule.nodes.some(
			(node) =>
				node.prop === "--diffs-editor-selection-bg" &&
				node.value.includes("var(--ctp-accent)") &&
				node.important,
		);
	});
	check(diffSelection, `${path}: inherited Pierre diff selection token`);
	document.walkDecls((declaration) => {
		check(declaration.important, `${path}: ${declaration.prop} is important`);
		for (const match of declaration.value.matchAll(/#([0-9a-f]{6})\b/gi)) {
			check(
				!originalColors.has(match[1].toLowerCase()),
				`${path}: unmapped Mocha color ${match[0]}`,
			);
		}
	});
}

verify(defaultPath, ['domain("tangled.org")'], palette);
verify(
	extendedPath,
	['domain("tangled.org")', 'domain("tangled.example")'],
	palette,
);
verify(replacedPath, ['domain("tangled.example")'], lightPalette);
console.log(
	`Tangled integration: ${assertions} assertions passed across 3 builds`,
);

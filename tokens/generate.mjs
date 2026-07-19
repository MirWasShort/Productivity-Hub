#!/usr/bin/env node
/**
 * Genera i design token per i due client a partire da `tokens/tokens.json`.
 *
 *   node tokens/generate.mjs
 *
 * Produce:
 *   frontend/lib/core/theme/generated_tokens.dart
 *   webapp/src/styles/tokens.css
 *
 * I file generati non vanno modificati a mano: si cambia la sorgente e si
 * rilancia. Con `--check` non scrive nulla e fallisce se i file su disco non
 * corrispondono a quelli che genererebbe — utile in CI.
 */
import { readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const tokens = JSON.parse(readFileSync(join(root, 'tokens/tokens.json'), 'utf8'))
const checkOnly = process.argv.includes('--check')

const BANNER = 'GENERATO da tokens/generate.mjs — non modificare a mano.'

/** `#RRGGBB` → `0xFFRRGGBB`, la forma che vuole `Color` in Dart. */
function dartColor(hex) {
  return `0xFF${hex.replace('#', '').toUpperCase()}`
}

function dartFile() {
  const { spacing, radius, priority, listSwatches, fallbackColor, brand } = tokens
  // Costanti piatte, non record: Dart non consente di leggere un campo di un
  // record dentro un'espressione `const`, e i temi devono restare costanti.
  const priorityFields = (mode) =>
    ['low', 'medium', 'high']
      .flatMap((level) => {
        const name = `${mode}${level[0].toUpperCase()}${level.slice(1)}`
        return [
          `  static const ${name}Background = Color(${dartColor(priority[mode][level].background)});`,
          `  static const ${name}Foreground = Color(${dartColor(priority[mode][level].foreground)});`,
        ]
      })
      .join('\n')

  return `// ${BANNER}
// Fonte: tokens/tokens.json
import 'package:flutter/material.dart';

/// Token del design system condivisi con la webapp.
abstract final class Tokens {
  static const seed = Color(${dartColor(brand.seed)});

  // Spaziature (multipli di 4).
${Object.entries(spacing)
  .map(([name, value]) => `  static const ${name} = ${value.toFixed(1)};`)
  .join('\n')}

  // Raggi.
${Object.entries(radius)
  .map(([name, value]) => `  static const radius${name[0].toUpperCase()}${name.slice(1)} = ${value.toFixed(1)};`)
  .join('\n')}

  /// Colori preimpostati di liste e tag.
  static const listSwatches = <String>[
${listSwatches.map((hex) => `    '${hex}',`).join('\n')}
  ];

  /// Colore di ripiego quando il backend non ne manda uno valido.
  static const fallbackColor = Color(${dartColor(fallbackColor)});
}

/// Accenti di priorità, per luminosità del tema.
abstract final class PriorityTokens {
${priorityFields('light')}

${priorityFields('dark')}
}
`
}

function cssFile() {
  const { radius, scheme, priority } = tokens
  const cssVars = (values) =>
    Object.entries(values)
      .map(([name, hex]) => `  --${kebab(name)}: ${hex.toLowerCase()};`)
      .join('\n')

  const priorityVars = (mode) =>
    ['low', 'medium', 'high']
      .flatMap((level) => [
        `  --priority-${level}: ${priority[mode][level].background.toLowerCase()};`,
        `  --priority-${level}-foreground: ${priority[mode][level].foreground.toLowerCase()};`,
      ])
      .join('\n')

  return `/* ${BANNER}
   Fonte: tokens/tokens.json */

/* Scala dei raggi: sovrascrive quella di Tailwind, così \`rounded-sm/md/lg\`
   parla già la lingua del design system. */
@theme {
${Object.entries(radius)
  .map(([name, value]) => `  --radius-${name}: ${value / 16}rem;`)
  .join('\n')}
}

:root {
${cssVars(scheme.light)}

  /* Accenti di priorità (tema chiaro) */
${priorityVars('light')}
}

.dark {
${cssVars(scheme.dark)}

  /* Accenti di priorità (tema scuro) */
${priorityVars('dark')}
}
`
}

function kebab(name) {
  return name.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`)
}

const outputs = [
  { path: 'frontend/lib/core/theme/generated_tokens.dart', content: dartFile() },
  { path: 'webapp/src/styles/tokens.css', content: cssFile() },
]

let stale = false
for (const { path, content } of outputs) {
  const full = join(root, path)
  if (checkOnly) {
    const current = readFileSync(full, 'utf8')
    if (current !== content) {
      console.error(`✗ ${path} non è allineato a tokens.json`)
      stale = true
    } else {
      console.log(`✓ ${path}`)
    }
  } else {
    writeFileSync(full, content)
    console.log(`scritto ${path}`)
  }
}

if (stale) {
  process.exit(1)
}

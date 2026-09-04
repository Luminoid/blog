/**
 * Mermaid house style.
 *
 * A before_post_render filter that rewrites every {% mermaid %} block in a post so
 * the diagram starts with an %%{init}%% directive built from `mermaid_theme` in
 * _config.yml (palette and font, matching the blog's figures), and so flowcharts end
 * with the classDef lines from `mermaid_theme.flowchart_classes`. A diagram that
 * already begins with its own %%{init}%% directive is left untouched. The theme's own
 * {% mermaid %} tag then renders the rewritten block as usual. A filter is used rather
 * than re-registering the tag because Hexo loads theme and site scripts concurrently,
 * so a same-name tag registration is a race.
 */
'use strict';

const BLOCK = /(\{%\s*mermaid\s*%\}\n)([\s\S]*?)(\n[ \t]*\{%\s*endmermaid\s*%\})/g;
const FLOWCHART = /^(%%\{[^\n]*\n)?\s*(flowchart|graph)\b/;

hexo.extend.filter.register('before_post_render', data => {
  const { flowchart_classes: classes = {}, ...init } = hexo.config.mermaid_theme || {};
  const directive = Object.keys(init).length ? `%%{init: ${JSON.stringify(init)}}%%\n` : '';
  const defs = Object.entries(classes).map(([name, style]) => `classDef ${name} ${style}`).join('\n');
  if (!directive && !defs) return data;
  data.content = data.content.replace(BLOCK, (match, open, body, close) => {
    if (body.trimStart().startsWith('%%{init')) return match;
    let out = directive + body;
    if (defs && FLOWCHART.test(out)) out += `\n${defs}`;
    return open + out + close;
  });
  return data;
});

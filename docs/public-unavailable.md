# Public-v2 unavailable placements (additive consumer contract)

This adds one closed content node to [the public-v2 bridge](public-v2.md):

```ts
type Unavailable = {kind:'unavailable'; label?:string};
```

The only accepted keys are `kind` and optional `label`. Unknown and duplicate
keys are rejected, including escaped spellings of duplicate JSON keys. IDs,
targets, paths, filenames, source fields, private aliases, flags, reasons,
`href`, and arbitrary URLs are **not** part of this node. It is accepted in
root, named-section, and anonymous-section content at the original placement
position. It emits one paragraph; it does not join adjacent Markdown chunks or
introduce a new inline Markdown syntax.

## Fixed public-only destination

- Destination: **`/_unavailable/`**, including the final slash.
- Default visible label: **`[非公開]`**.
- Optional `label`: a producer-authorized, non-filename semantic public title.

The consumer cannot infer title-disclosure permission from a literal string.
The producer must resolve the reference before classifying it as private and
must omit unauthorized titles/aliases. Unknown or ambiguous references must
remain failures, not be downgraded automatically. This consumer never reads a
source note or discovers a private target.

The node neither defines a tree nor supplies a target ID, and it contributes
no containment, transclusion, or backlink target to consumer graph validation.
Existing public references still require exact public definitions, and all
existing cycle and metadata-reference checks remain in force.

## Native emission, not graph routing

The pinned Forester `6.0~dev` revision
`f8fb5f5d88923db36643cf9c20c662adff969c98` supports the native XML anchor builtin:

```forester
\p{\<html:a>[href]{/_unavailable/}{SAFE_LITERAL_LABEL}}
```

`SAFE_LITERAL_LABEL` above is illustrative: the converter emits the actual
label through `Forester_6.escape_literal`, the same escaper used for metadata.
For example, the default brackets are native verbatim literals, not wiki-link
syntax. Forester commands, braces, brackets, percent signs, TeX-looking text,
HTML-looking text, and Unicode remain visible literal label content. Entity
spellings in this semantic string are not decoded as Markdown.

The pin has no named `\link` builtin. Its native `[label](destination)` form
is a URI/graph link: publication routing can suggest a tree and strips the
trailing slash from a local route. The XML anchor builtin deliberately avoids
that behavior and preserves the exact fixed href without a missing-tree
reference or an arbitrary user-supplied URL. Native HTML acceptance checks the
actual anchor label and href, not merely emitted source syntax.

Label validation uses the existing metadata string validator: strict UTF-8,
no disallowed C0/DEL bytes, and at most 256 KiB in UTF-8 bytes. Tab, LF, and CR
are allowed as in metadata; accepted bytes are not trimmed or normalized.
Explicit empty labels remain empty strings rather than silently selecting the
default. Wrong JSON types, lone surrogates, invalid UTF-8, forbidden controls,
and oversized strings fail closed with existing generic `PF_*` codes.

## Unchanged guards and compatibility

Arbitrary Markdown `[label](/_unavailable/)`, relative paths, raw HTML anchors,
raw Forester, unresolved public links/transclusions, and assets remain subject
to the existing strict refusals. The special destination is available **only**
through the closed structured node. Extra fields remain errors even when the
label is otherwise acceptable. Code examples stay literal. Existing v2 inputs
without the new node retain their exact output bytes.

Validation finishes before creating output directories. CLI diagnostics still
contain only generic codes and counts; rejected input bytes/mtime are unchanged.
The existing `Tree_of_md.Public_forest` facade exposes this behavior without
new wiring or a legacy API change. Dependency locks are unchanged.

## Focused verification

Build the actual changed source and its CLI dependency, then run all regressions
with the pinned native renderer enabled:

```sh
dune build bin/public_main.exe test/public_forest_test.exe
PUBLIC_FOREST_TEST_FORESTER=/path/to/pinned/forester \
  dune exec test/public_forest_test.exe
```

The additional cases cover default and literal labels, closed/duplicate keys,
malformed labels, dangling targets, raw/Markdown bypass attempts, graph cycles,
actual CLI no-write refusals, and native HTML label/href preservation. Native
execution is opt-in via `PUBLIC_FOREST_TEST_FORESTER`; without that variable the
native case is not exercised. It uses wholly synthetic inputs and production
HTML, never `--dev`.

This converter does not create a 404 page, configure Workers, guarantee HTTP
404 status, approve title disclosure, copy attachments, or authorize publishing.
Those are independent producer/site responsibilities and acceptance gates.

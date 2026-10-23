# Public JPEG references in `forester-public-v2`

This is an additive, closed JSON-only consumer extension. The abstract
`Public_forest.t` and all public function signatures are unchanged, including
the `Tree_of_md` façade. Internally the validated roots **and** JPEG registry
are retained. Existing empty-registry/no-image output and unavailable nodes
keep their prior bytes and semantics. Older consumers reject the extension;
producer, consumer and site pins must be reviewed together before publication.

## Exact wire shape

```ts
type PublicImage = {
  kind: 'image'; sha256: string; alt: string;
  width?: number; height?: number;
};
type PublicJpeg = {
  sha256: string; mime: 'image/jpeg'; bytes: number;
  width: number; height: number;
};
// PublicForestNode |= PublicImage;
// PublicForest.assets: PublicJpeg[];
```

All required keys must be present. Unknown/duplicate keys, including JSON-escaped
duplicates, are rejected at every new object. Missing fields are not inferred.
Optional display fields must be omitted rather than set to null. Integers are
JSON integers, never booleans, floats (even `1.0`), strings or coerced values.

- Digests are exactly 64 lowercase ASCII hex characters (`[0-9a-f]{64}`). No
  trimming, case folding, URL decoding or repair occurs.
- Registry order is strictly ascending by exact digest; duplicate/unsorted entries
  are rejected rather than sorted. The set of image references must equal the
  registry digest set. Missing, unused or mismatched registry entries fail with
  `PF_SCHEMA`, not `PF_TARGET`; JPEGs never become tree graph vertices or edges.
- Repeated placements, including nested named/anonymous trees, may share one
  asset. Limits count unique registry entries and bytes, not placements.
- At most 128 assets; `bytes` is 1..8 MiB each and at most 32 MiB in aggregate.
  Registry intrinsic width/height are each 1..8192, with at most 32,000,000
  pixels. Optional authored **display** width/height are independently 1..8192;
  they need not equal intrinsic dimensions, and their product is not an
  intrinsic decode budget.
- `alt` is required and may be empty. It is strict UTF-8, at most 4096 encoded
  bytes, without U+0000..U+001F, U+007F..U+009F or lone surrogates. No Unicode,
  whitespace, BOM or newline normalization is performed. Local syntax markers
  `[[`, `]]`, `%%`, `#{`, `\{`, `<!--`, and backslash followed by an ASCII
  letter or `<` are refused. Other accepted punctuation, HTML-looking text and
  entities remain literal: they are not parsed as Markdown/HTML or decoded.
  Filenames/metadata are never used to synthesize alt.

Wrong shapes/types/nonpositive integers fail with `PF_SCHEMA`; exceeding byte,
count, dimension or pixel maxima fails with `PF_LIMIT`. Invalid UTF-8/JSON
(including surrogate escapes) fails with `PF_JSON`. Existing JSON 8 MiB, JSON
depth 128, scalar UTF-8 256 KiB, tree depth 32, 200,000-token and 20,000-node
limits remain in force; image placements consume the existing node budget.

## Fixed native emission, not Markdown image permission

Each image is a block-position structured content node. The consumer emits only:

```text
\p{\<html:img>[src]{/media/<sha256>.jpg}[alt]{LITERAL_ESCAPED_ALT}[width]{W}[height]{H}{}}
```

Absent display attributes are omitted individually, in width/height order.
`Forester_6.escape_literal` is applied to alt exactly once, as for literal
metadata. The src is derived only from the validated digest. This is the fixed
XML QName primitive proven against Forester `6.0~dev`, source
`f8fb5f5d88923db36643cf9c20c662adff969c98`, binary SHA-256
`c39fd87dc2fd31470bef988551dc73d3e0e1a438908a62f7891c97236ac15783`.
No named `\img`, `Ir.Image`, asset routing, raw evaluation or guessed macro
is used. Native HTML can minimize empty alt to bare `alt`; the browser attribute
value is still empty, while legacy XML emits `alt=""`.

Existing arbitrary Markdown image, relative URL, wikilink embed, raw HTML,
Forester directive, missing-target and cycle guards are unchanged. A registered
image does not authorize any such shape in an accompanying Markdown chunk.

## Consumer/caller boundary

`compile_forest` validates the tree graph before returning `.tree` bytes;
`write_forest` compiles everything before output directory creation. The
existing fresh/empty nonsymlink output rules and generic diagnostics remain.
The only written files are sorted root `<id>.tree` files, never media or a
registry sidecar. Root count is still `PF_OK <count>`.

The consumer does **not** read source photographs or JPEG bytes, resolve image
paths, copy media, normalize images, compute image hashes, inspect EXIF, decode
pixels or grant publication permission. Registry metadata is a validated claim,
not proof about bytes. The producer owns reviewed placement/alt authorization;
the caller/site must independently verify final JPEG bytes/profile/intrinsic
dimensions and close the registry, snapshot and rendered image references over
exact `media/<sha256>.jpg` files. The 16 MiB source-JPEG limit belongs to that
source loader/normalizer, not this no-image-IO consumer. Native forest assets
must remain empty for these literal references.

## Tests

`test/public_forest_test.ml` includes fixed byte emission, exact registry
closure/digests, integer/resource boundaries, UTF-8 literal alt and real CLI
no-write rejection tests. Set `PUBLIC_FOREST_TEST_FORESTER` to the independently
verified binary path to also execute separate native HTML and XML builds (no
photograph files required). Without that variable the optional native tests do
not run; a passing ordinary Dune suite alone is not native or site acceptance.

The illustrative test digest
`3b4f9dc01f8011ba0c41f67a7bb3b61d23d1a38cd28bc33c39fbca93e8578e80`
identifies an explicitly owned synthetic 16×12, 372-byte research JPEG, not real
content or a production normalization recipe. Synthetic registry-only boundary
fixtures intentionally need no image files. Publication, independent source
review, producer→site integration, browser decode, Workers and deployment are
separate gates.

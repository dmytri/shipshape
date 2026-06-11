# Assets Policy

This project uses `assets/` as the root for durable Captain/human-authored assets.

## Purpose

`assets/**` contains product, content, design, brand, media, reference data, and approved fixture-like materials that are directly authored or approved by the Captain and/or human.

Examples:

```text
assets/content/homepage.md
assets/content/emails/order-confirmation.md
assets/brand/logo.svg
assets/brand/colors.md
assets/design/wireframes/checkout.md
assets/design/mockups/empty-cart.png
assets/media/product-hero.png
assets/data/demo-catalog.json
assets/fixtures/approved-checkout-session.json
```

## Ownership

Captain and humans may create, edit, and curate `assets/**`.

Quartermaster and Crew Mates may read `assets/**`, reference it from tests/specs, and implement code that consumes it, but must not modify, rewrite, regenerate, or delete it.

## Deletion Rule

`assets/**` is not disposable implementation. The Captain must not delete assets as part of a stale-code cleanup unless:

- the human explicitly asks,
- committed specs explicitly retire the asset,
- or the asset was created by mistake in the same Captain session.

## Test Fixtures vs Assets

Fixture-like files under `assets/**` are approved durable assets. QM-owned test fixtures belong outside `assets/`, usually under `<test directory>`.

Examples:

```text
assets/fixtures/approved-checkout-session.json  # Captain/human-owned durable asset
tests/fixtures/generated-checkout-case.json     # QM-owned test fixture
```

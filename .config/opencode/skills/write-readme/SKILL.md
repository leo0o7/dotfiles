---
name: write-readme
description: Write a README for this project
---

# README Writing Skill

The goal is to create READMEs that are useful, readable, and human. Avoid generic AI-style documentation that is too polished, too dense, or full of empty claims.

A good README should quickly explain what the project is, what it does, and how someone can use or understand it. It should also leave room for deeper technical detail when the project deserves it.

## Style

Write plainly and directly.

Prefer:

- short paragraphs
- concrete details
- honest project scope
- simple section names
- project-specific explanations
- practical examples

Avoid:

- marketing language
- fake excitement
- generic template sections
- overclaiming
- long dense paragraphs
- repeating the same idea in multiple sections
- making small projects sound bigger than they are

Do not use phrases like:

- powerful
- seamless
- robust
- cutting-edge
- production-ready
- scalable
- unlocks
- leverage
- comprehensive solution

Unless the repo clearly proves a claim, do not make the claim.

## General README intent

The README should answer, in a natural order chosen for the project:

- What is this?
- Why does it exist?
- What does it currently do?
- How do I run or use it?
- What are the interesting technical decisions?
- What should I know about the project status or limitations?
- Where can I go deeper if I care?

Do not force all of these into separate sections. Use only what fits.

## Opening

Start with a short, plain description.

Good patterns:

- "A small Rust service for..."
- "A tiny set of scripts for..."
- "A learning-focused implementation of..."
- "An unofficial tool for..."
- "A small CLI that..."

The opening should not sound like a product landing page.

Bad:

- "A powerful and seamless solution for..."
- "An innovative tool designed to revolutionize..."
- "A robust and scalable platform for..."

## Scope and honesty

Add a short scope/status note when useful.

This is especially useful for:

- learning projects
- experimental projects
- unofficial tools
- incomplete projects
- projects with important limitations
- projects that intentionally avoid some features

Examples of the kind of tone:

- "This is mostly a learning project."
- "The goal is to understand the algorithm, not to replace existing libraries."
- "This is an unofficial project and may break if the upstream service changes."
- "This is intentionally small."

## Section ideas

Pick sections based on the repo. Do not use all of them by default.

Before writing, inspect the repository and decide what kind of README this project needs. Then write the README using only the sections that actually help explain this specific project.

Possible sections:

- `What this includes`
- `Usage`
- `Setup`
- `Example`
- `How it works`
- `Implementation notes`
- `Design decisions`
- `Benchmarks`
- `Output`
- `Configuration`
- `Project layout`
- `Limitations`
- `Security`
- `References`
- `Attribution`

Use section names that feel natural for the project. Avoid overly formal names unless the project needs them.

## Features / project explanation

When listing features, keep them concrete.

Good:

- `insertion into the graph`
- `k-NN search`
- `save/load support`
- `seeded construction for reproducible indexes`
- `a small benchmark runner`

Bad:

- `fast and powerful performance`
- `seamless developer experience`
- `robust architecture`

## Technical decisions

Include brief explanations of decisions when they help the reader understand the project.

Good examples:

- why a specific data structure was used
- why a project is split into certain crates/modules
- why an algorithm is approximate
- what tradeoff a parameter controls
- why something is intentionally simple

Do not turn this into a full essay unless the project is mostly educational.

## Usage

If the project can be run, include the minimal useful command.

Prefer copy-pasteable examples.

Do not invent setup steps. Inspect the repo first.

## Benchmarks

Only include benchmarks if the repo has real benchmark data.

When adding benchmarks, include enough context to make them meaningful:

- dataset
- metric
- command, if available
- important parameters
- short interpretation

Do not oversell benchmark results.

## References / attribution

Add references when the project is based on:

- a paper
- another project
- a tutorial
- a known workflow
- an algorithm
- an unofficial API

Keep attribution simple and factual.

## Final checklist

Before finalizing the README:

- Remove generic AI phrasing.
- Remove sections that do not add value.
- Make sure the first paragraph clearly explains the project.
- Make sure setup/usage is accurate.
- Make sure limitations are not hidden.
- Make sure the project is not made to sound bigger than it is.
- Keep the README easy to skim.

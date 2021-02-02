# Fish Notes :fish: `0.0.1`

<!-- vim-markdown-toc GFM -->

* [CHANGELOG](#changelog)
* [Usage](#usage)
    * [Create Note](#create-note)
* [Options](#options)
* [Disclaimer](#disclaimer)

<!-- vim-markdown-toc -->

## CHANGELOG

- Tue Feb  2 22:56:56 CET 2021
    - Remove search but keep in contrib

- Sun 19 Jul 2020 04:13:49 PM CEST
    - Add commands for searching notes
    - Add CHANGELOG to README
    - Update README with help for `new` and the new search commands

## Usage

### Create Note

```text
$ set -x FISH_NOTES_DIR ~/.local/share/fish_notes
$ notes new -T "This is a title" -t these -t are -t tags
Created new note '/home/tifa/.local/share/fish_notes/616627'
```

Your notes will be stored like this:

```
fish_notes λ tree
.
├── 146261
│   ├── body.md
│   ├── date
│   ├── tags
│   └── title
├── 188152
│   ├── body.md
│   ├── date
│   ├── tags
│   └── title
```

### Searching

This is currently a work in progress

## Options

- `FISH_NOTES_EXTENSION`: Default file extension for note content
- `FISH_NOTES_DIR`: Where notes are stored, defaults to `$XDG_DATA_DIR/fish_notes`
- `__notes_entry_template`: Template for new notes
  ```fish
  $ function __notes_entry_template; echo "foo"; end; notes new
  ```

## Disclaimer

I created this primarily for myself. It's therefore quite minimal and requires both Ripgrep and FZF, in case you want to use search. Additionally, I can't guarantee that all features work with all symbols and characters.

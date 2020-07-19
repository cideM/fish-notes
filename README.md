# Fish Notes :fish: `0.0.1`

<!-- vim-markdown-toc GFM -->

* [CHANGELOG](#changelog)
* [Usage](#usage)
    * [Create Note](#create-note)
    * [Searching](#searching)
* [Options](#options)
* [Disclaimer](#disclaimer)

<!-- vim-markdown-toc -->

## CHANGELOG

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

You can search notes by tags and by content with the `notes search_content` and `notes search_tags` commands. Both will spawn a FZF shell where you can interactively narrow down your search. **Both commands return file names, not file content**. The idea is that I don't know how you'd like to consume your notes. Maybe you want to pipe them into a pager that has syntax highlighting for certain file extensions. For example, if you stick with the default extension `.md`, you can do:

```shell
$ notes search_content | rg body | xargs bat
───────┬────────────────────────────────────────────────────────────────────────
       │ File: /data/fish_notes/987961/body.md
───────┼────────────────────────────────────────────────────────────────────────
   1   │ This is some content for a note
───────┴────────────────────────────────────────────────────────────────────────
```

Since `bat` recognizes the `.md` file extension, you'll get syntax highlighting. The `rg` call makes sure that only the note content is displayed. The possible file names that are returned are as follows:

```shell
$ notes search_content
/data/fish_notes/987961/title
/data/fish_notes/987961/date
/data/fish_notes/987961/tags
/data/fish_notes/987961/body.md
```

So doing `rg title` will only print titles, and so on.

## Options

- `FISH_NOTES_EXTENSION`: Default file extension for note content
- `FISH_NOTES_DIR`: Where notes are stored, defaults to `$XDG_DATA_DIR/fish_notes`
- `__notes_entry_template`: Template for new notes
  ```fish
  $ function __notes_entry_template; echo "foo"; end; notes new
  ```

## Disclaimer

I created this primarily for myself. It's therefore quite minimal and requires both Ripgrep and FZF, in case you want to use search. Additionally, I can't guarantee that all features work with all symbols and characters.

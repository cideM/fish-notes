# Fish Notes :fish: `0.0.1`

<!-- vim-markdown-toc GFM -->

* [CHANGELOG](#changelog)
* [Usage](#usage)
    * [Create Note](#create-note)
    * [Searching](#searching)
        * [Built-in: Tags and Title Search](#built-in-tags-and-title-search)
        * [Custom: By Date](#custom-by-date)
        * [Custom: By Content Interactively](#custom-by-content-interactively)
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
Created new note '/home/tifa/.local/share/fish_notes/2021-02-03T23:13:27+01:00'
```

Your notes will be stored like this:

```
fish_notes λ tree
.
├── 2021-02-03T23:13:27+01:00
│   ├── body.md
│   ├── date
│   ├── tags
│   └── title
├── 2021-02-02T23:13:27+01:00
│   ├── body.md
│   ├── date
│   ├── tags
│   └── title
```

### Searching

This script focuses almost entirely on creating notes, because searching notes is extremely dependent on what you're trying to accomplish.

It's likely that I'll add some search functionality to Fish Notes again, to make certain tasks easier that would otherwise require hairy scripting.

Anyway, here are some ideas for how you can search your notes!

#### Built-in: Tags and Title Search

You can search by tag(s) and title like this: `notes search -t tag1 -t tag2 -T
"Some Title"`. Multiple tags will result in the intersection of all such
results to be returned. What you get back are the folder names, so you can pipe them into other commands. Here's how to pipe the results into `less`

```shell
$ source functions/notes.fish; notes search -t agenda | xargs -I _ sh -c 'cat _/body*'
# My first note!

Content, more content
```

#### Custom: By Date

Since the folder name of your notes use ISO 8601 they are automatically sorted. If you want to only operate on notes of a certain year, just do `ls $FISH_NOTES_DIR/2021-*`. For limiting it to certain months and years, you can use bracket expansion: `ls $FISH_NOTES_DIR/{2021,2022}-{2,3}*`. This will use the cartesian product or, in simpler words, find notes for both years and both months.

#### Custom: By Content Interactively

Please see `./contrib/find_one_note.fish` for a tiny script using ripgrep and FZF to find a sinlge note Interactively.

## Options

- `FISH_NOTES_EXTENSION`: Default file extension for note content
- `FISH_NOTES_DIR`: Where notes are stored, defaults to `$XDG_DATA_DIR/fish_notes`
- `__notes_entry_template`: Template for new notes
  ```fish
  $ function __notes_entry_template; echo "foo"; end; notes new
  ```

## Disclaimer

I created this primarily for myself. It's therefore quite minimal and requires both Ripgrep and FZF, in case you want to use search. Additionally, I can't guarantee that all features work with all symbols and characters.

# Fish Notes :fish:

## Disclaimer

I created this primarily for myself. It's therefore very minimal and requires setting up your own mappings, as shown in `contrib/scripts.fish`. The only thing this little script does is let you easily add notes which are stored in a way that combines human readable text with a bit of structure for easier analysis.

## Usage

Upon running `notes` your `$EDITOR` will open. The first line is the title, the second line are tags, the third line is empty and everything from the fourth line onwards in the content of your note. The way lines are parsed is hardcoded. Respect those rules.

```text
$ set -x FISH_NOTES_DIR ~/.local/share/fish_notes
$ notes
Created new note '/home/tifa/.local/share/fish_notes/616627'
```

That's it! There's no help, no searching, no nothing. Your notes will be stored like this:

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

## Options

- `FISH_NOTES_EXTENSION`: Default file extension for note content
- `FISH_NOTES_DIR`: Where notes are stored, defaults to `$XDG_DATA_DIR/fish_notes`

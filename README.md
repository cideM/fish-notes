# Fish Notes :fish:

## Disclaimer

I created this primarily for myself. It's therefore very minimal and requires setting up your own mappings, as shown in `contrib/scripts.fish`. The only thing this little script does is let you easily add notes which are stored in a way that combines human readable text with a bit of structure for easier analysis.

## Usage

```text
$ set -x FISH_NOTES_DIR ~/.local/share/fish_notes
$ notes new -T "This is a title" -t these -t are -t tags
Created new note '/home/tifa/.local/share/fish_notes/616627'
```

That's it! There is no search or edit functionality. Check the `contrib/`
folder for ideas. Your notes will be stored like this:

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
- `__notes_entry_template`: Template for new notes
  ```fish
  $ function __notes_entry_template; echo "foo"; end; notes new
  ```

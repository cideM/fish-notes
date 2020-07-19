# Fish Notes :fish:

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

### Search Notes

You can search notes by tags and by content with the `notes search_content` and `notes search_tags` commands. Both will spawn a FZF shell where you can interactively narrow down your search.

## Options

- `FISH_NOTES_EXTENSION`: Default file extension for note content
- `FISH_NOTES_DIR`: Where notes are stored, defaults to `$XDG_DATA_DIR/fish_notes`
- `__notes_entry_template`: Template for new notes
  ```fish
  $ function __notes_entry_template; echo "foo"; end; notes new
  ```

## Disclaimer

I created this primarily for myself. It's therefore quite minimal and requires both Ripgrep and FZF, in case you want to use search. Additionally, I can't guarantee that all features work with all symbols and characters.


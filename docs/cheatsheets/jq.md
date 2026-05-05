# jq

**Purpose.** Command-line JSON processor. Filter, transform, and reshape JSON with a small functional language. Standard tool for any API/log workflow.

## 3 main use cases

### 1. Pluck fields
```
echo '{"a":1,"b":2}' | jq '.a'              # 1
curl -s api/users | jq '.[].name'           # one name per line
curl -s api/users | jq '.[] | {id, name}'   # reshape into smaller objects
```

### 2. Filter arrays
```
jq '.[] | select(.age > 30)'                # filter by condition
jq '.users | map(.email)'                   # array of emails
jq '.items | length'                        # count
jq '.[] | select(.tags[] | contains("urgent"))'  # nested filter
```

### 3. Transform shapes
```
jq '{name: .full_name, repo: .url}'                          # rename keys
jq '. | to_entries | map(.value) | add'                      # sum values
jq -s 'add' a.json b.json                                    # merge files
jq --arg env "$ENV" '.config[$env]'                          # inject shell var
```

## Trickery

- **`-r` raw output.** Strips JSON quotes from strings. Essential when piping into other tools: `jq -r '.url' | xargs curl`.
- **`-s` slurp.** Reads all input into one array. Combine with `add` to merge: `jq -s 'add' *.json`.
- **`--arg name value` / `--argjson`.** Inject shell variables safely (no interpolation issues): `jq --arg id "$ID" '.users[] | select(.id == $id)'`. Use `--argjson` for non-string values.
- **`paths(scalars)`.** Print all paths to leaf values. Great for exploring unfamiliar JSON: `jq 'paths(scalars)' < big.json | head`.
- **`group_by` + `map`.** `jq 'group_by(.team) | map({team: .[0].team, count: length})'` — SQL `GROUP BY` equivalent.
- **`reduce`.** `jq 'reduce .[] as $x (0; . + $x.amount)'` — fold over an array.
- **`@csv` / `@tsv`.** `jq -r '.[] | [.id, .name, .email] | @csv'` — convert JSON to CSV, properly escaped.
- **`gojq` if jq is too slow.** Drop-in compatible Go reimplementation, faster for huge files.

## Gotchas

- `jq` reads stdin until EOF if you forget to pipe a finite source. `jq '.foo'` alone hangs waiting for input.
- Floating-point precision: very large integers in JSON may lose precision through jq's number type. Use `tonumber` carefully on big IDs.
- Filters compose left-to-right with `|` — same character as shell pipe but different scope. Quote your filter (`jq '.a | .b'`) so the shell doesn't pipe `.b` as a command.

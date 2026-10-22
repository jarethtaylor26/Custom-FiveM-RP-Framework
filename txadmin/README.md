# Civic Framework txAdmin starter

This is a self-contained starter set of four Lua resources:

- `civic_core`: characters, persistent player data, jobs, and cash/bank balances
- `civic_inventory`: starter items, consumables, and admin item grants
- `civic_vehicles`: a small vehicle catalog, purchases, and owned-vehicle spawning
- `civic_housing`: two purchasable properties with basic enter/exit commands

## Generate the txAdmin recipe

After editing any framework resource or `server.cfg`, regenerate the embedded recipe:

```sh
python3 scripts/src/build-txadmin-recipe.py
```

`recipe.yaml` embeds the resource files and downloads the standard CFX server resources. Host the generated YAML at a public raw-file URL (for example, in a GitHub repository) and paste that URL into txAdmin's recipe URL field. txAdmin will ask for the server license key and deployment settings.

The install uses `server.cfg` to start the stock CFX essentials first, then the Civic resources in dependency order. It grants no ACE permissions by default; add an `add_ace group.admin civic.admin allow` line and assign trusted administrators in txAdmin if you want to use `/setjob` or `/giveitem`.

## Current limits

This is an extendable starting framework, not a production RP server. Character data is stored in `civic_core/data/players.json`; back it up and migrate to a database before a larger public server. Inventory use, vehicle ownership, and property ownership are deliberately small command-based systems. The sample housing uses a shared interior and needs proper routing buckets, interaction points, and property interiors for a production server.

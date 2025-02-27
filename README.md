A quick workflow I commonly use to upload UI image assets via [asphalt](https://github.com/jackTabsCode/asphalt).

This workflow expects only `.png` files.

### How to use

First copy and rename the `asphalt_template.toml` to `asphalt.toml`. Then in the new file update the user id and add an open cloud api key with asset write permissions.

Next, place the png's under the `assets` folder. Then run the lune script:

```Lua
lune run upload
```

This will upload the files to roblox with asphalt and then will generate a `.rbxm` full of image labels under the `output` folder. The name of this file is just a local timestamp.

### Why?

Nothing crazy here, just something I use pretty often that saves me a bit of time especially with click friction on windows 11 to find png sizes.
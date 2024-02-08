A quick workflow I commonly use to upload UI image assets via tarmac.

This workflow expects only `.png` files.

### How to use

Place the png's under the `assets` folder. Then run the lune script:

```Lua
lune run upload [auth_cookie]
```

This will upload the files to roblox with tarmac and then will generate a `.rbxm` full of image labels under the `output` folder. The name of this file is just a local timestamp.

### Why?

Nothing crazy here, just something I use pretty often that saves me a bit of time especially with click friction on windows 11 to find png sizes.
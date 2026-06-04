import fs from "fs";
import KEYMAPS from "./keymaps";

fs.writeFile("skhdrc.generated", KEYMAPS.join("\n"), (err) => {
  if (err) throw err;
  console.log(
    "new config saved at skhdrc.generated\n",
    "save your old config and run `mv skhdrc.generated ~/config/skhd/skhdrc` to use the new config",
  );
});

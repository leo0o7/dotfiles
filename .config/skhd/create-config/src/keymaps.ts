import {
  alt,
  altCtrl,
  altShift,
  createNormalMapping as mapNormal,
  createYabaiMapping as map,
  useNumberRow,
  useVIM,
} from "./functions";

const KEYMAPS = [];

// NOTE:
// GO TO SPACE [NUMBER] WITHOUT DISABLING SIP (FROM YABAI ISSUE #205)
function goToSpace(index: number) {
  const str =
    "index=" +
    index.toString() +
    '; eval "$(yabai -m query --spaces | jq --argjson index "${index}" -r \'(.[] | select(.index == $index).windows[0]) as $wid | if $wid then "yabai -m window --focus \\"" + ($wid | tostring) + "\\"" else "skhd --key \\"ctrl - " + (map(select(."is-native-fullscreen" == false)) | index(map(select(.index == $index))) + 1 % 10 | tostring) + "\\"" end\')"';
  return str;
}

useVIM(alt, "window --focus", KEYMAPS);
map(altShift("m"), "window --toggle zoom-fullscreen", KEYMAPS);
map(altShift("b"), "space --balance", KEYMAPS);
useVIM(altShift, "window --swap", KEYMAPS);
useVIM(altCtrl, "window --warp", KEYMAPS);
useNumberRow(altCtrl, "window --space", KEYMAPS, goToSpace);
mapNormal(altCtrl("q"), "yabai --stop-service", KEYMAPS);
mapNormal(altCtrl("s"), "yabai --start-service", KEYMAPS);
mapNormal(altCtrl("r"), "yabai --restart-service", KEYMAPS);
mapNormal(alt("="), "yabai -m space --equalize", KEYMAPS);

export default KEYMAPS;

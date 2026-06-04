export function createNormalMapping(
  keymap: string,
  commands: string[] | string,
  arr: unknown[],
) {
  !Array.isArray(commands)
    ? arr.push(`${keymap} : ${commands}`)
    : arr.push(`${keymap} : ${commands.join(" | ")}`);
}

export function createYabaiMapping(
  keymap: string,
  commands: string[] | string,
  arr: unknown[],
) {
  !Array.isArray(commands)
    ? arr.push(`${keymap} : ${createYabaiCommand(commands)}`)
    : arr.push(
        `${keymap} : ${commands.map((command) => createYabaiCommand(command)).join(" | ")}`,
      );
}
export function createYabaiCommand(cmd: string) {
  return "yabai -m " + cmd;
}

export function alt(key: string) {
  return "alt - " + (key === "=" ? "0x18" : key);
}

export function altShift(key: string) {
  return "shift + alt - " + key;
}

export function altCtrl(key: string) {
  return "ctrl + alt - " + key;
}

export const sides = { h: "west", j: "south", k: "north", l: "east" };
type keybind = (key: string) => string;
export function useVIM(
  keybind: keybind,
  command: string,
  KEYMAPS: unknown[],
  chainTo?: (key: string) => string,
) {
  if (chainTo) {
    for (const key in sides) {
      createYabaiMapping(
        keybind(key),
        `${command} ${sides[key]} | ${chainTo(key)}`,
        KEYMAPS,
      );
    }
  } else {
    for (const key in sides) {
      createYabaiMapping(keybind(key), `${command} ${sides[key]}`, KEYMAPS);
    }
  }
}
export function useNumberRow(
  keybind: keybind,
  command: string,
  KEYMAPS: unknown[],
  chainTo?: (num: number) => string,
) {
  if (chainTo) {
    for (let i = 0; i < 10; i++) {
      createYabaiMapping(
        keybind(i.toString()),
        `${command} ${i} | ${chainTo(i)}`,
        KEYMAPS,
      );
    }
  } else {
    for (let i = 0; i < 10; i++) {
      createYabaiMapping(keybind(i.toString()), `${command} ${i}`, KEYMAPS);
    }
  }
}

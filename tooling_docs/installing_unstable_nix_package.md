```markdown
# Installing Unstable Nix Packages in Devbox

This guide shows how to install packages from `nixpkgs-unstable` (or specific versions) in Devbox using local flakes.

## When to Use This

- You need a package version not available in Devbox's curated index
- You want the latest version from nixpkgs-unstable
- You need to override a package to a specific version

## Step-by-Step Guide

### 1. Create a Local Flake Directory

```bash
mkdir -p ~/.devbox-flakes/<package-name>
cd ~/.devbox-flakes/<package-name>
```

### 2. Create the Flake

Create a `flake.nix` file:

**For latest unstable version:**
```nix
{
  description = "Package from nixpkgs-unstable";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          mypackage = pkgs.packageName;
        };
      }
    );
}
```

**For specific version override:**
```nix
{
  description = "Package at specific version";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        mypackage_custom = pkgs.packageName.overrideAttrs (oldAttrs: rec {
          version = "X.Y.Z";
          src = pkgs.fetchFromGitHub {
            owner = "owner-name";
            repo = "repo-name";
            rev = "v${version}";
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        });
      in {
        packages = {
          mypackage = mypackage_custom;
        };
      }
    );
}
```

### 3. Get the Correct SHA256 Hash (if overriding version)

If you're overriding to a specific version, use a fake hash first:

```bash
sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```

Then build to get the real hash:

```bash
cd ~/your-project
devbox shell
```

The error will show:
```
got: sha256-CORRECT_HASH_HERE
```

Copy that hash and update your flake.nix.

### 4. Add to devbox.json

Add the local flake reference to your `devbox.json`:

```json
{
  "packages": {
    "path:/home/username/.devbox-flakes/<package-name>#mypackage": ""
  }
}
```

**Important:** Use absolute paths, not `~`.

### 5. Install

```bash
devbox update
devbox shell
```

### 6. Update Later

To update to newer versions from unstable:

```bash
cd ~/.devbox-flakes/<package-name>
rm flake.lock
cd ~/your-project
devbox update
```

## Real Example: Elixir 1.19.1

**Directory structure:**
```
~/.devbox-flakes/elixir/
└── flake.nix
```

**flake.nix:**
```nix
{
  description = "Elixir 1.19.1 with Erlang OTP 28";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        elixir_1_19 = pkgs.beam.packages.erlang.elixir.overrideAttrs (oldAttrs: rec {
          version = "1.19.1";
          src = pkgs.fetchFromGitHub {
            owner = "elixir-lang";
            repo = "elixir";
            rev = "v${version}";
            sha256 = "sha256-ACTUAL_HASH_HERE";
          };
        });
      in {
        packages = {
          elixir = elixir_1_19;
          erlang = pkgs.beam.interpreters.erlang;
        };
      }
    );
}
```

**devbox.json:**
```json
{
  "packages": {
    "path:/home/username/.devbox-flakes/elixir#elixir": "",
    "path:/home/username/.devbox-flakes/elixir#erlang": ""
  }
}
```

## Tips

- **Find package paths:** Check [nixpkgs source](https://github.com/NixOS/nixpkgs) or use `nix search nixpkgs#packagename`
- **BEAM packages:** Located at `pkgs.beam.packages.erlang.<package>` or `pkgs.beam.interpreters.<package>`
- **System architecture:** Common values are `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`
- **Debugging:** Add `DEVBOX_DEBUG=1` before commands for detailed errors

## Troubleshooting

**Error: "package not found"**
- Check the package path in nixpkgs
- Verify your flake.nix syntax
- Use absolute paths, not `~`

**Error: "unexpected argument"**
- Use `overrideAttrs` instead of `override` for version changes
- Check the package's builder to see what attributes it accepts

**Registry errors**
- Check `nix registry list` for conflicts
- Remove problematic entries with `nix registry remove <name>`
```

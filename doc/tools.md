# Tools

## [`checkmake`](https://github.com/mrtazz/checkmake)

_checkmake is an experimental tool for linting and checking Makefiles._

- Documentation:
  - pre-commit usage: <https://github.com/mrtazz/checkmake?tab=readme-ov-file#pre-commit-usage>
- Files:
  - `.checkmake-module.ini`
- Related tools:
  - [GNU Make](#gnu-make)
  - [`pre-commit`](#pre-commit)

## [Code Spell Checker](https://cspell.org/) (`cspell`)

_Spell checker_

- Documentation:
  - <https://github.com/streetsidesoftware/vscode-spell-checker>
- Files:
  - `cspell.config.yaml`: configuration file and dictionary
- Related tools:
  - [`pre-commit`](#pre-commit): Runs checks for this tool.
- VS Code extensions:
  - <https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker>

## [`direnv`](https://direnv.net/)

_Integrates environment management with your shell (e.g. `bash` or `zsh`)._

- Documentation:
  - Getting Started: <https://direnv.net/#getting-started>
  - Standard library: <https://direnv.net/man/direnv-stdlib.1.html>
- Files:
  - `.envrc`: loads application settings and any machine-specific settings into your environment.
  - `.envrc.local`: machine-specific settings, which are excluded from source control to avoid
    exposing secrets.
  - `.envrc.local.example`: an example of settings for various operating systems, which can be used
    as a template for creating `.envrc.local`.
- Installation:
  - Homebrew: `brew install direnv`
    **Note: Follow instructions about updating `.bashrc` or `.zshrc`**.

## [EditorConfig](https://editorconfig.org/)

_Defines basic parameters for formatting source files._

- Documentation:
  - Configuration: <https://editorconfig.org/>
  - Formal specification: <https://spec.editorconfig.org/>
- Files:
  - `.editorconfig`: configuration file
- Related tools:
  - [`pre-commit`](#pre-commit): Runs checks for this tool.

## [GNU Make](https://www.gnu.org/software/make/)

_Automates project-related tasks, such as rendering project audio._

- Documentation:
  - Makefile Style Guide: <https://style-guides.readthedocs.io/en/latest/makefile.html>
  - Manual: <https://www.gnu.org/software/make/manual/make.html>
  - Portable Makefiles: <https://www.oreilly.com/openbook/make3/book/ch07.pdf>
- Files:
  - `Makefile`

## [Markdown](https://daringfireball.net/projects/markdown/)

_File format and syntax for documentation._

- Documentation:
  - Syntax: <https://daringfireball.net/projects/markdown/syntax>
- Interactions;
  - [Mermaid](#mermaid) is embedded in some Markdown documents
  - [Markdownlint](#markdownlint-markdownlint-cli2) lints markdown sources
- VS Code extensions:
  - <https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one>

## [Markdownlint](https://github.com/DavidAnson/markdownlint-cli2) (`markdownlint-cli2`)

_Checks Markdown files for style or formatting errors._

- Documentation:
  - Rules: <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>
- Files:
  - `.markdownlint-cli2.jsonc`: configuration file
- Related tools:
  - [`pre-commit`](#pre-commit): Runs checks for this tool.
- VS Code extensions:
  - <https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint>

## [Mermaid](https://mermaid-js.github.io/mermaid)

- Documentation:
  - Customized styling directives: <https://stackoverflow.com/q/71864287/112682>
  - Syntax: <https://mermaid.js.org/intro/n00b-syntaxReference.html>
- Interactions:
  - Mermaid is embedded in some [Markdown](#markdown) documents
- VS Code extensions:
  - Markdown Preview Mermaid Support:
    <https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid>
  - Mermaid Editor:
    <https://marketplace.visualstudio.com/items?itemName=tomoyukim.vscode-mermaid-editor>

## [`pre-commit`](https://pre-commit.com/)

_A framework for managing and maintaining multi-language pre-commit hooks in Git repositories._

- Documentation:
  - Configuration file format:
    <https://pre-commit.com/index.html#adding-pre-commit-plugins-to-your-project>
  - Supported hooks: <https://pre-commit.com/hooks.html>
- Files:
  - `.pre-commit-config.yaml`: Defines hooks to run and where they come from
  - `scripts/`: Custom pre-commit scripts that fix issues when the project is on a WSL filesystem.

### Installation

- Install `pre-commit` with your favorite package manager:
  - Debian: `apt install pre-commit`
  - Homebrew: `brew install pre-commit`
- `pre-commit install`: Install Git hooks in this repository.

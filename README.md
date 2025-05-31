## Rust Project

```
-.vscode
++settings.json
-util
++.git
++src
++Cargo.lock
++Cargo.toml
-core
++project_1
+++.git
+++src
+++Cargo.lock
+++Cargo.toml

```
## Example Usage
```bash
# git clone this repository into ~/scripts/rust
# Add the following line into ~/.bashrc
source ~/scripts/rust/cargo_wrapper.sh

# Execute the following command
source ~/.bashrc


# Assume current folder is: core
# What the following command does:
# - what cargo new is supposed to do
# - add new "core/my_project/Cargo.toml" in the "rust-analyzer.linkedProject"
cargo new my_project


# What the following command does:
# - delete the core/my_project
# - remove existing "core/my_project/Cargo.toml" from the "rust-analyzer.linkedProject"
cargo delete my_project
#


```



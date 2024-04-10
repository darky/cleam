# cleam

[![Package Version](https://img.shields.io/hexpm/v/cleam)](https://hex.pm/packages/cleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cleam/)

![logo](logo.png)

Cleam for clean Gleam. Detect unused exports, i.e. public functions, tests and types, that not used in another files. 

## How to

1. Add cleam to your project as dev dependency
```sh
gleam add cleam --dev
```

2. Run check locally or on CI/CD
```sh
gleam run -m cleam
```

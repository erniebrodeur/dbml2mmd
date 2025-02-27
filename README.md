# dbml2mmd

A command-line tool to convert DBML (Database Markup Language) files to Mermaid Markdown format for database diagram visualization.

## Documentation

For full documentation, visit [https://erniebrodeur.github.io/dbml2mmd/](https://erniebrodeur.github.io/dbml2mmd/)

## Overview

dbml2mmd transforms your DBML schema definitions into Mermaid Markdown diagrams, making it easy to include your database schema diagrams in documentation, GitHub READMEs, or any platform that supports Mermaid.

## Installation

```bash
gem install dbml2mmd
```

## Usage

### Basic Usage

Convert a single DBML file to Mermaid Markdown:

```bash
dbml2mmd input.dbml
```

This will create `input.mmd` in the same directory.

### Specify Output File

```bash
dbml2mmd input.dbml -o output.mmd
```

### Process Multiple Files

```bash
dbml2mmd *.dbml
```

### Watch for Changes

```bash
dbml2mmd input.dbml --watch
```

### Help

```bash
dbml2mmd --help
```

## Example

### Input (sample.dbml)

```dbml
Table users {
  id int [pk]
  username varchar
  email varchar
  created_at timestamp
}

Table posts {
  id int [pk]
  title varchar
  body text
  user_id int [ref: > users.id]
  created_at timestamp
}
```

### Output (sample.mmd)

```
erDiagram
    users {
        int id PK
        varchar username
        varchar email
        timestamp created_at
    }
    
    posts {
        int id PK
        varchar title
        text body
        int user_id FK
        timestamp created_at
    }
    
    posts ||--o{ users : "user_id"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/erniebrodeur/dbml2mmd>.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

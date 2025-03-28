# SimpleGameServer

A Ruby on Rails server that manages turn-based game sessions. This server provides a flexible foundation for implementing various turn-based games by handling core game mechanics such as player management, session creation, and turn progression.

[![Ruby Tests](https://github.com/nickhart/simple_game_server/actions/workflows/ruby.yml/badge.svg)](https://github.com/nickhart/simple_game_server/actions/workflows/ruby.yml)
[![Dependency Status](https://img.shields.io/badge/dependencies-Dependabot-025E8C.svg)](https://github.com/nickhart/simple_game_server/pulls?q=is%3Apr+is%3Aopen+label%3Adependencies)
[![Ruby Style](https://img.shields.io/badge/Ruby%20Style-RuboCop-ruby.svg)](https://github.com/rubocop/rubocop)
[![Ruby](https://img.shields.io/badge/Ruby-3.4.2-ruby.svg)](https://www.ruby-lang.org/en/)
[![Rails](https://img.shields.io/badge/Rails-8.0.2-red.svg)](https://rubyonrails.org/)

## Features

- Create game sessions with customizable player limits
- Join existing game sessions
- Automatic turn management
- Support for 2-10 players per game
- Game state management (waiting, active, finished)
- RESTful API for game interactions

## Dependencies

This project uses Dependabot to keep dependencies up to date. Dependency update pull requests are created automatically and can be found [here](https://github.com/nickhart/simple_game_server/pulls?q=is%3Apr+is%3Aopen+label%3Adependencies).

### Main Dependencies
- Ruby 3.4.2
- Rails 8.0.2
- PostgreSQL 14+

Updates are checked weekly for:
- Ruby gems (both production and development dependencies)
- GitHub Actions workflows

## Prerequisites

- Ruby 3.2.2
- Rails 8.0.2
- PostgreSQL 14+

## Setup

1. Clone the repository:
```bash
git clone https://github.com/nickhart/simple_game_server.git
cd simple_game_server
```

2. Install dependencies:
```bash
bundle install
```

3. Configure your database:
   - Copy `.env.example` to `.env` (if not exists)
   - Update database credentials in your `.env` file:
```bash
DATABASE_USERNAME=your_username
DATABASE_PASSWORD=your_password
DATABASE_HOST=localhost
```

4. Create and setup the database:
```bash
rails db:create
rails db:migrate
```

## Running the Server

Start the Rails server:
```bash
rails server
```

The server will be available at http://localhost:3000

## Running Tests

Run the full test suite:
```bash
rails test
```

## Development Workflow

1. Create a new branch for your feature:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes and commit them:
```bash
git add .
git commit -m "Description of your changes"
```

3. Push your branch and create a pull request:
```bash
git push origin feature/your-feature-name
```

4. Wait for CI checks to pass and request review

## Branch Protection

The `main` branch is protected with the following rules:
- Direct pushes to `main` are not allowed
- Pull requests require passing tests
- Branch must be up to date with `main` before merging
- Pull request reviews are required

## Project Structure

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed information about the project's architecture and design decisions.

## API Documentation

The API documentation will be available at `/api/docs` when running the server (coming soon).

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

Please make sure to update tests as appropriate and follow the existing coding style.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

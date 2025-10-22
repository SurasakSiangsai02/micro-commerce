# Contributing to Micro Commerce

We love your input! We want to make contributing to Micro Commerce as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, track issues and feature requests, as well as accept pull requests.

## Pull Requests

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](LICENSE) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using GitHub's [issue tracker](https://github.com/SurasakSiangsai02/micro-commerce/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/SurasakSiangsai02/micro-commerce/issues/new).

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR-USERNAME/micro-commerce.git
   cd micro-commerce
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run Tests**
   ```bash
   flutter test
   ```

## Code Style

### Dart/Flutter Guidelines

- Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format your code
- Run `flutter analyze` to check for issues
- Write meaningful commit messages

### File Organization

- Place new screens in appropriate folders under `lib/screens/`
- Add new widgets to `lib/widgets/`
- Put business logic in `lib/services/`
- Add models to `lib/models/`

### Naming Conventions

- Use `snake_case` for file names
- Use `PascalCase` for class names
- Use `camelCase` for variable and function names
- Use descriptive names for variables and functions

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Coverage Report
```bash
flutter test --coverage
```

## Documentation

- Update documentation when adding new features
- Add inline code comments for complex logic
- Update the README.md if needed
- Add documentation to the `docs/` folder for major features

## Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation only changes
- `style:` Changes that do not affect the meaning of the code
- `refactor:` A code change that neither fixes a bug nor adds a feature
- `test:` Adding missing tests or correcting existing tests
- `chore:` Changes to the build process or auxiliary tools

### Examples

```
feat: add product search functionality
fix: resolve cart calculation bug
docs: update installation instructions
style: format code according to style guide
refactor: simplify authentication service
test: add unit tests for coupon service
chore: update dependencies
```

## Feature Requests

We welcome feature requests! Please:

1. Check if the feature has already been requested
2. Provide a clear description of the feature
3. Explain why this feature would be useful
4. Consider submitting a pull request if you can implement it

## Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment include:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

### Enforcement

Project maintainers are responsible for clarifying the standards of acceptable behavior and are expected to take appropriate and fair corrective action in response to any instances of unacceptable behavior.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to reach out to the maintainers:

- Create an issue for questions about the codebase
- Email: surasak.siangsai@example.com for other questions

Thank you for contributing! 🎉
# Shared Macro Package

A dbt package demonstrating how to abstract reusable macros away from your main dbt project into a separate, testable package. This approach promotes code reusability, maintainability, and enables proper testing of macro functionality.

## 📋 Table of Contents

- [Package Structure](#package-structure)
- [Package Installation](#package-installation)
- [Namespace Considerations](#namespace-considerations)
- [Integration Testing](#integration-testing)
- [Building Test Cases](#building-test-cases)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)

## 📁 Package Structure

```
shared_macro/
├── dbt_project.yml              # Package configuration
├── packages.yml                 # Package dependencies
├── macros/
│   └── column_utils/            # Organise macros based on common functionality
├── integration_tests/           # Test suite for packaged macros
│   ├── dbt_project.yml         # Test project configuration
│   ├── packages.yml            # Local package reference
│   ├── seeds/                  # Test data
│   ├── models/                 # Test models using macros
│   └── macros/                 # Custom test macros
└── README.md                   # This documentation
```

## 📦 Package Installation

### Local Development and Integration Testing

For local development and when building integration testing, the package uses a local reference:

```yaml
# integration_tests/packages.yml
packages:
  - local: ../
```

This setup allows you to:
- Test changes immediately without publishing
- Iterate quickly during development
- Validate functionality before release

### Production Installation

When ready for production use, install via Git or dbt Hub:

```yaml
# packages.yml in your main project
packages:
  - git: "https://github.com/your-org/shared-macro-package.git"
    revision: "v1.0.0"
  # OR from dbt Hub (if published)
  - package: your-org/shared_macro
    version: "1.0.0"
```

### Installation Commands

```bash
# Install packages
dbt deps

# Verify installation
dbt list --models package:shared_macro
```

## 🏷️ Namespace Considerations

### Macro Namespacing

When calling macros from packages, always use the package namespace to avoid conflicts:

```sql
-- ✅ Correct: Explicit namespace
{{ shared_macro.format_id("id") }}

-- ❌ Incorrect: No namespace (may cause conflicts or error out with an undefined error message)
{{ format_id("id") }}
```

### Package Name Configuration

The package name is defined in `dbt_project.yml`:

```yaml
name: 'shared_macro'  # This becomes the namespace
```

## 🧪 Integration Testing

### Test Project Structure

The `integration_tests/` folder contains a complete dbt project dedicated to testing the package macros. Think of this as a unit testing functionality of your packaged macro. This should cover the test cases that you know **must** pass before a macro can be released.

To run this integration test dbt project, there are two options:
1. use dbt CLI; this requires a completely separate project to be setup in the dbt Platform. While it means that there are more administrative overhead by setting up a new project, this has the benefit of ensuring dbt version alignment throughout
2. use dbt Core locally; it is highly recommended to ensure that the dbt Core used is aligned with the release track of the main project's dbt Platform to maintain compatibility. A `profiles.yml` will need to be setup locally to allow for dbt Core to work.

```
integration_tests/
├── dbt_project.yml      # Test project config
├── packages.yml         # References parent package locally
├── seeds/
│   └── customers.csv    # Test data
├── models/
│   └── staging/
│       ├── stg_customers.sql    # Model using package macros
│       └── _stg_models.yml      # Tests for the model
└── macros/
    ├── assert_column_names.sql   # Custom test macro
    └── assert_id_length.sql      # Custom test macro
```

### Running Integration Tests

```bash
# Navigate to integration tests
cd integration_tests/

# Install dependencies (including parent package)
dbt deps

# Run tests; all test cases must pass before package release
dbt build
```

## 🔨 Building Test Cases

### 1. Custom Test Macros

Create reusable test macros in `integration_tests/macros/` for custom testing.

### 2. Test Data Setup

Provide realistic test data in `seeds/` that ensures the macros can be tested thoroughly including any known edge cases.

### 3. Test Models

Create models that uses the macro

### 4. Test Definitions

Declare tests on the models to ensure macro works as expected

## 💡 Usage Examples

### In Your Main Project

After installing the package, use macros with proper namespacing:

```sql
-- models/staging/stg_customers.sql
select
    {{ shared_macro.format_id("raw_customer_id") }} as customer_id,
    {{ shared_macro.sanitise_column_name("Customer Name") }} as customer_name,
    created_at
from {{ source('raw', 'customers') }}
```

### Advanced Usage with Variables

```sql
-- Use with custom variables
select 
    {{ shared_macro.snake_case_columns(
        relation=ref("raw_data"),
        exclude=var('exclude_columns', []),
        empty_string_to_null=true
    ) }}
from {{ ref("raw_data") }}
```

## 🎯 Best Practices

### Package Development

1. **Organize by Functionality**: Group related macros in subdirectories
2. **Use Descriptive Names**: Make macro purposes clear from names
3. **Document Parameters**: Include clear parameter documentation
4. **Version Appropriately**: Use semantic versioning for releases
5. **Test Thoroughly**: Maintain comprehensive test coverage

### Macro Design

1. **Single Responsibility**: Each macro should have one clear purpose
2. **Configurable**: Use parameters for flexibility
3. **Database Agnostic**: Use adapter dispatch for cross-database compatibility
4. **Error Handling**: Include appropriate error messages and validation

### Testing Strategy

1. **Test Edge Cases**: Include boundary conditions and error scenarios
2. **Use Realistic Data**: Test with data similar to production
3. **Automate Testing**: Integrate tests into CI/CD pipelines
4. **Document Test Cases**: Explain what each test validates

### Integration Guidelines

1. **Namespace Everything**: Always use package namespaces
2. **Pin Versions**: Use specific versions in production
3. **Monitor Dependencies**: Keep track of package updates
4. **Document Usage**: Provide clear examples for consumers

---

## 🚀 Getting Started

1. **Clone or fork this repository**
2. **Navigate to `integration_tests/`**
3. **Run `dbt deps` to install dependencies**
4. **Run `dbt build` to execute tests**
5. **Modify macros and tests to fit your needs**
6. **Publish your package for team consumption**

This pattern provides a robust foundation for building and maintaining shared dbt utilities across your organization.
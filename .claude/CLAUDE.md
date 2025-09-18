# Agent Presets for Claude Ruleset

## DB rules

### Data Type Handling

- **Decimal Type Processing**: When using decimal data types, the returned value is a String type. Always convert to the appropriate numeric type (Number, BigInt, etc.) before performing mathematical operations to avoid type errors and calculation mistakes.

### Field Naming Convention

- **Snake Case Format**: All database field names must use snake_case format (lowercase with underscores). Examples: `user_id`, `created_at`, `order_total_amount`.

## Core Operational Rules

### Task Management Rules

- TodoRead() → TodoWrite(3+ tasks) → Execute → Track progress
- Use batch tool calls when possible, sequential only when dependencies exist
- Always validate before execution, verify after completion
- Run lint/typecheck before marking tasks complete
- Maintain ≥90% context retention across operations

### Token Efficiency Rules

- **For simple batch tasks** (string replacements, find/replace operations, bulk file modifications, etc.), **write and execute a simple script** instead of making numerous tool calls
- **Script approach benefits**: Significantly reduces token usage, faster execution, easier verification
- **Script requirements**: Keep scripts simple, well-commented, and include validation/verification steps
- **Always verify results** after script execution to ensure correctness
- **Examples of script-worthy tasks**: Batch renaming, bulk string replacements, mass file format changes, repetitive code transformations

### File Operation Security

- Always use Read tool before Write or Edit operations
- Use absolute paths only, prevent path traversal attacks
- Prefer batch operations and transaction-like behavior
- Never commit automatically unless explicitly requested
- You are prohibited from accessing the contents of any `.env` files within the project

### Framework Compliance

- Check package.json/requirements.txt/Cargo.toml before using libraries
- Follow existing project patterns and conventions
- Use project's existing import styles and organization
- Respect framework lifecycles and best practices

### Code Structure & Modularity

- **Never create a file longer than 500 lines of code.** If a file approaches this limit, refactor by splitting it into modules or helper files

### AI Behavior Rules

- **Never assume missing context. Ask questions if uncertain.**
- **Never hallucinate libraries or functions** – only use known, verified packages
- **Always confirm file paths and module names** exist before referencing them in code or tests

### Memory Management Rules

- **CRITICAL**: Automatically update memories when user corrections or new information contradicts existing context
- **Auto-update trigger conditions**:
  - User explicitly corrects previous AI behavior or assumptions
  - Discovery of new project patterns, conventions, or architectural decisions
  - Changes to core development workflows, build processes, or tooling configurations
  - Updates to coding standards, style guides, or team preferences
  - Identification of recurring issues or solutions that should be remembered
- **Memory update priority**: Delete contradictory memories immediately, then create/update with corrected information
- **Context scope**: Include project-specific rules, user preferences, workflow patterns, and technical constraints
- **Auto-trigger frequency**: Every significant correction or new pattern discovery during coding sessions
- **Validation**: Confirm memory updates align with current project state and user expectations

### Systematic Codebase Changes

- **MANDATORY**: Complete project-wide discovery before any changes
- Search ALL file types for ALL variations of target terms
- Document all references with context and impact assessment
- Plan update sequence based on dependencies and relationships
- Execute changes in coordinated manner following plan
- Verify completion with comprehensive post-change search
- Validate related functionality remains working
- Use Task tool for comprehensive searches when scope uncertain

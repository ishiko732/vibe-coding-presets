# Agent Presets for Claude

## Project Overview

This is an "agent-presets" repository that contains Claude Code configurations including custom output styles and specialized agents. The project structure is designed to provide reusable templates and configurations for different types of AI-assisted development workflows.

## Key Configuration Files

### Output Styles
- **critical-analyst.md**: Professional analysis mode with rigorous technical evaluation, challenge assumptions, and evidence-based responses. Use for critical code reviews and technical assessments.

### Specialized Agents
- **ui-designer.md**: UI/UX design specialist for interface improvements, animations, user experience optimization, and design system integration. Includes expertise in modern web design principles, accessibility standards, and technical implementation.

## Development Notes

- This repository serves as a template/preset collection rather than a traditional software project
- No package.json, build scripts, or testing frameworks are present as this is a configuration-only repository
- The .gitignore contains only "settings.local.json" indicating local configuration files should not be committed
- Focus on maintaining clean, well-documented configuration files that can be easily imported into other projects

## Usage Context

When working with this repository, prioritize:
1. Clear documentation of configuration purposes and use cases
2. Maintaining consistency in configuration file formats and structure
3. Adding appropriate metadata (name, description, color) to new configurations
4. Following the established pattern for output styles and agent definitions

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
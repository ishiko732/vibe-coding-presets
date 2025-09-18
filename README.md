# AI Coding Presets for Claude

This project contains intelligent agent preset configurations for Claude Code to enhance development efficiency and code quality.

## 📁 Project Structure

```text
agent-presets/
├── .claude/
│   └── CLAUDE.md          # Claude AI behavior rules and configuration
└── README.md             # Project documentation (this file)
```

## 🛠️ .claude Configuration Guide

### CLAUDE.md File Purpose

`.claude/CLAUDE.md` is the core configuration file for Claude Code that defines AI assistant behavior rules, language preferences, and development standards.

### Main Configuration Sections

#### 1. Language Configuration

- **Primary Language**: Chinese - for all user communications
- **Secondary Language**: Japanese - backup communication language
- **Code Language**: English - strictly enforced for code and comments
- **Documentation**: English - for ALL documentation files (README.md, technical docs, API docs)

#### 2. Database Rules (DB Rules)

- **Data Type Handling**: Decimal type conversion rules
- **Field Naming**: Enforced snake_case format

#### 3. Core Operational Rules

- **Task Management**: TodoWrite tool usage standards
- **Token Efficiency**: Batch operation optimization strategies
- **File Operation Security**: Path safety and transactional operations
- **Framework Compliance**: Dependency checking and pattern adherence
- **Code Structure**: 500-line file limit and modularity requirements

#### 4. AI Behavior Rules

- Never assume missing context
- Never hallucinate libraries or functions
- Always confirm file paths and module names

#### 5. Memory Management Rules

- Automatic memory update mechanisms
- Context scope management
- Validation and alignment strategies

## 🚀 How to Use

### 1. Setup Project Configuration

Apply this configuration to your project:

```bash
# Copy .claude folder to your project root
cp -r .claude /path/to/your/project/

# Or create symbolic link
ln -s /path/to/agent-presets/.claude /path/to/your/project/.claude
```

### 2. Customize Configuration

Modify `.claude/CLAUDE.md` according to your project needs:

```markdown
# Add project-specific rules

## Project Specific Rules

### Framework Configuration

- Use React 18+ with TypeScript
- Follow Material-UI design system
- Implement proper error boundaries

### Testing Requirements

- Write unit tests for all utility functions
- Integration tests for API endpoints
- E2E tests for critical user flows
```

### 3. Verify Configuration

Confirm the configuration is working:

1. Open Claude Code
2. Run any command in project root directory
3. Observe if Claude responds according to configured language and rules

## 📝 Configuration File Details

### Language Priority Settings

```markdown
## Language Configuration

### Communication Language Priority

- **Primary Language**: Chinese (中文) - Use for all communications
- **Secondary Language**: Japanese (日本語) - Use when needed
- **Tertiary Language**: English - Use only when necessary
- **Code & Comments Language**: English ONLY - Strictly enforced
- **Documentation**: English for ALL documentation files
```

### Development Standards Enforcement

```markdown
## Core Operational Rules

### Task Management Rules

- TodoRead() → TodoWrite(3+ tasks) → Execute → Track progress
- Use batch tool calls when possible
- Always validate before execution, verify after completion
```

## ⚙️ Global Configuration

Set Claude Code global preferences:

```bash
# Set notification channel
claude config set --global preferredNotifChannel terminal_bell

```

## 🔧 Troubleshooting

### Common Issues

1. **Configuration Not Applied**

   - Ensure `.claude/CLAUDE.md` exists in project root
   - Check file permissions and format

2. **Language Settings Invalid**

   - Restart Claude Code session
   - Verify CLAUDE.md language configuration syntax

3. **Rule Conflicts**
   - Check for conflicts between project and global configurations
   - Adjust rule priorities accordingly

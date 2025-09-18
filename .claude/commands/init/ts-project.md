---
allowed-tools: [Bash, Write, Read, TodoWrite, Glob, Grep]
description: 'Initialize a TypeScript project with modern tooling (pnpm, Biome, TailwindCSS). Supports web-service (Hono), simple (Vite), and Next.js projects with optional monorepo structure.'
---

# Initialize TypeScript Project

**Name:** init-ts-project
**Description:** Initialize a TypeScript project with modern tooling (pnpm, Biome, TailwindCSS)
**Color:** blue

## Command Options

Ask the user to specify the project type and name:

1. **Project Type:**

   - `web-service`: Hono-based web service with Zod validation
   - `simple`: Vite-based simple page
   - `next`: Next.js application

2. **Project Name:** The name of the project directory to create

3. **Monorepo (optional):** Whether to configure as a monorepo structure

## Implementation Steps

### Initial Setup

1. Enable corepack for pnpm: `corepack enable pnpm`
2. Create project directory and navigate to it
3. Validate that directory doesn't already exist
4. **Initialize Claude Configuration**:
   - Copy current `.claude` folder to the project directory
   - Exclude `.claude/settings.local.json` from copying
   - Skip if initializing in current directory

### Project Type Initialization

#### Web Service (Hono)

```bash
# Initialize Hono project
pnpm create hono@latest . --yes

# Install additional dependencies
pnpm add zod @hono/zod-validator
pnpm add -D @types/node

```

#### Simple Page (Vite)

```bash
# Initialize Vite with TypeScript template
pnpm create vite . --template vanilla-ts --yes
pnpm install
```

#### Next.js

```bash
# Initialize Next.js with Biome instead of ESLint (Next.js 15.5+ feature)
pnpm create next-app@latest . --yes --typescript --tailwind --app --src-dir --import-alias "@/*"

# Note: During interactive setup, choose "Biome" when prompted for linting option
# This creates optimized configurations with Next.js and React rules plus built-in formatting
```

### Monorepo Configuration (if requested)

1. Create `pnpm-workspace.yaml`:

```yaml
packages:
  - 'packages/*'
  - 'apps/*'
```

1. Create directory structure:

```text
packages/
├── main/
│   ├── src/
│   └── package.json
apps/
```

1. Move main source code to `packages/main/src/` (except for Next.js projects)

### Linting Setup (Biome)

1. Install Biome (if not already installed by create-next-app): `pnpm add -D @biomejs/biome`
2. Create or update `biome.json` configuration with Next.js optimizations:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.2.2/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": false,
    "defaultBranch": "main"
  },
  "files": {
    "ignoreUnknown": false
  },
  "formatter": {
    "enabled": true,
    "formatWithErrors": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineEnding": "lf",
    "lineWidth": 80,
    "attributePosition": "auto"
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "style": {
        "useImportType": {
          "level": "warn",
          "fix": "safe",
          "options": {
            "style": "auto"
          }
        },
        "noNonNullAssertion": "off",
        "useExponentiationOperator": "off"
      },
      "complexity": {
        "noStaticOnlyClass": "off"
      },
      "correctness": {
        "useExhaustiveDependencies": "warn"
      },
      "a11y": {
        "recommended": true
      }
    },
    "includes": ["**", "!packages/**/dist/*", "!.next/**/*"]
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "asNeeded",
      "trailingCommas": "es5"
    },
    "globals": []
  },
  "assist": {
    "enabled": true,
    "actions": {
      "source": {
        "organizeImports": "on"
      }
    }
  }
}
```

### TailwindCSS Setup (for simple and web-service)

1. Install TailwindCSS: `pnpm add -D tailwindcss postcss autoprefixer`
2. Initialize config: `npx tailwindcss init -p`
3. Configure `tailwind.config.js`:

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',
    './packages/*/src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

1. Create CSS file with Tailwind directives in appropriate src directory

### Package.json Scripts Configuration

Add the following scripts to package.json (Next.js projects will have some of these pre-configured):

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check . --fix",
    "format": "biome format --write .",
    "check": "pnpm lint && pnpm typecheck",
    "check:fix": "pnpm lint:fix && pnpm typecheck",
    "typecheck": "tsc --noEmit"
  }
}
```

### TypeScript Configuration

Create `tsconfig.json` if it doesn't exist (Next.js projects will have this pre-configured):

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "src/**/*",
    "packages/*/src/**/*",
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx"
  ],
  "exclude": ["node_modules", "dist", ".next"]
}
```

### Git Configuration

Create comprehensive `.gitignore` if it doesn't exist:

```gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Production builds
/dist/
/build/
/.next/
/out/

# Development
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/settings.json
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Storybook build outputs
.out
.storybook-out
```

### Claude Configuration Setup

If initializing in a new directory (not current directory):

1. **Initialize Claude Configuration**:
   - Claude will automatically detect and locate the current `.claude` folder
   - Copy the entire `.claude` folder to the new project directory
   - Exclude `.claude/settings.local.json` from copying
   - Preserve all agent configurations, output styles, and commands

2. **Verify Claude Configuration**:
   - Ensure `.claude/CLAUDE.md` contains project-specific rules
   - Verify agents and output-styles are properly copied
   - Confirm commands directory structure is intact

## Final Steps

1. Run `pnpm install` to install all dependencies
2. Display project structure summary
3. Show available npm scripts
4. Provide next steps for the user

## Expected Outcome

After running this command, the user will have:

- ✅ A fully configured TypeScript project
- ✅ pnpm as package manager with corepack enabled
- ✅ Biome configured for linting and formatting
- ✅ TailwindCSS ready for styling
- ✅ Proper project structure (monorepo if requested)
- ✅ All development scripts ready to use
- ✅ Type checking configured
- ✅ Git repository initialized with comprehensive .gitignore
- ✅ Claude configuration copied and ready to use (excluding local settings)

## Usage Examples

**Web Service:**

```text
User: "Initialize a web-service project called 'api-server'"
```

**Simple Page:**

```text
User: "Create a simple project named 'landing-page'"
```

**Next.js with Monorepo:**

```text
User: "Initialize a next project called 'webapp' with monorepo structure"
```

**Validation Steps:**

- Always run `pnpm check` after initialization to ensure everything is properly configured
- Verify TypeScript compilation works without errors
- Confirm linting passes with Biome

# GUID.codes Static Web App

This directory contains the static web app implementation of the GUID.codes website, built with Vite and TypeScript for deployment to Azure Static Web Apps.

## 📁 Project Structure

```
src/swa/
├── guid-site/                    # Main application directory
│   ├── src/
│   │   ├── index.ts             # TypeScript source code
│   │   └── theme.css            # Stylesheets (bundled with TypeScript)
│   ├── public/                   # Static assets (auto-copied to dist)
│   │   └── *.png, *.ico, etc.   # Favicon and icon files
│   ├── index.html               # Main page
│   ├── 404.html                 # Error page
│   ├── about.html               # About page
│   ├── staticwebapp.config.json # Azure SWA configuration
│   ├── swa-cli.config.json      # SWA CLI configuration
│   ├── vite.config.ts           # Vite build configuration
│   ├── tsconfig.json            # TypeScript configuration
│   └── package.json             # Dependencies and scripts
└── README.md                     # This file
```

## 🔧 Prerequisites

Before running this project, ensure you have the following installed:

### Required Software

1. **Node.js** (v18 or higher)
   - Download from [nodejs.org](https://nodejs.org/)
   - Verify installation: `node --version`

2. **npm** (comes with Node.js)
   - Verify installation: `npm --version`

### Optional Tools (for full development experience)

3. **Azure Static Web Apps CLI** (for local SWA simulation)
   ```bash
   npm install -g @azure/static-web-apps-cli
   ```

4. **Visual Studio Code** (recommended editor)
   - Download from [code.visualstudio.com](https://code.visualstudio.com/)
   - Recommended extensions:
     - TypeScript and JavaScript Language Features
     - Vite (for better development experience)

## 🚀 Getting Started

### 1. Navigate to the Project Directory

```bash
cd src/swa/guid-site
```

### 2. Install Dependencies

```bash
npm install
```

This will install:
- **Vite** - Fast build tool and dev server
- **TypeScript** - Type-safe JavaScript
- **Azure Static Web Apps CLI** - Local development simulation

### 3. Development Commands

#### Start Development Server
```bash
npm run dev
```
- Starts Vite development server on `http://localhost:5173`
- Hot reload enabled for instant changes
- TypeScript compilation on-the-fly
- Uses `.env.development` environment variables

#### Build for Production
```bash
npm run build
```
- Compiles TypeScript to optimized JavaScript
- Processes and optimizes all assets
- Outputs to `dist/` folder
- Uses `.env.production` environment variables
- Ready for deployment

#### Build for Development
```bash
npm run build:dev
```
- Same as `npm run build` but uses development environment variables

#### Build for Production (Explicit)
```bash
npm run build:prod
```
- Same as `npm run build` but explicitly uses production environment variables

#### Preview Production Build
```bash
npm run preview
```
- Serves the built `dist/` folder locally
- Test production build before deployment

### 4. Azure Static Web Apps Development (Optional)

#### Start SWA CLI (Full Azure SWA Simulation)
```bash
npx swa start
```
- Simulates Azure Static Web Apps environment
- Includes routing, authentication, and API simulation
- Uses configuration from `swa-cli.config.json`

## ⚙️ Environment Configuration

The application uses environment variables to configure the API URL and other settings.

### Environment Files

The project supports multiple environment files:

```
.env                    # Default values (committed)
.env.development        # Development overrides (committed)
.env.production         # Production overrides (committed)
.env.local              # Local overrides (not committed)
.env.local.example      # Local template (committed)
```

### Available Environment Variables

#### `GUID_API_URL`
- **Description**: The base URL for the GUID API
- **Default**: `https://api.guid.codes`
- **Example**: `https://api-staging.guid.codes` or `http://localhost:7071`

### Setting Environment Variables

#### For Local Development
1. Copy the example file:
   ```bash
   cp .env.local.example .env.local
   ```

2. Edit `.env.local` with your values:
   ```env
   GUID_API_URL=http://localhost:7071
   ```

#### For Different Environments
- **Development**: Edit `.env.development`
- **Production**: Edit `.env.production`
- **CI/CD**: Set environment variables in your build pipeline

#### Build-Time Configuration
You can also set environment variables when building:

```bash
# Windows (PowerShell)
$env:GUID_API_URL="https://api-staging.guid.codes"; npm run build

# Linux/macOS
GUID_API_URL="https://api-staging.guid.codes" npm run build
```

## 📦 Build Process

The project uses a modern Vite + TypeScript setup:

### Development Mode
1. **TypeScript**: Source files in `src/` are served directly by Vite
2. **Assets**: Files in `public/` are served at root path
3. **Hot Reload**: Changes reflect instantly in browser

### Production Build
1. **TypeScript Compilation**: `src/index.ts` → bundled JavaScript with content hashing
2. **Asset Processing**: `public/` contents copied to `dist/` root
3. **HTML Processing**: HTML files processed and script references updated
4. **Optimization**: Minification, tree-shaking, and compression

### Output Structure
```
dist/
├── index.html                    # Main page (with bundled script refs)
├── 404.html                      # Error page
├── about.html                    # About page
├── assets/
│   ├── main-[hash].js           # Bundled and optimized JavaScript
│   └── main-[hash].css          # Bundled and optimized CSS
└── *.png, *.ico, etc.           # Static assets
```

## 🌐 Deployment

### Azure Static Web Apps

The project is configured for Azure Static Web Apps deployment:

1. **Build Configuration**: 
   - App location: `.` (current directory)
   - Output location: `dist`
   - Build command: `npm run build`

2. **Routing**: Configured in `staticwebapp.config.json`
   - Fallback to `index.html` for SPA behavior
   - Custom 404 page handling with `404.html`

3. **GitHub Actions**: Automatic deployment on push to main branch

### Manual Deployment

To deploy manually:

1. Build the project:
   ```bash
   npm run build
   ```

2. Upload the `dist/` folder contents to your hosting provider

## 🔍 Configuration Files

### `vite.config.ts`
- Configures Vite build process
- Sets up multiple HTML entry points
- Handles TypeScript compilation

### `tsconfig.json`
- TypeScript compiler options
- `noEmit: true` - Vite handles compilation
- Strict type checking enabled

### `staticwebapp.config.json`
- Azure Static Web Apps routing rules
- Fallback navigation for single-page app behavior
- Custom 404 error page configuration

### `swa-cli.config.json`
- Local development configuration for SWA CLI
- Dev server and build command settings

## 🐛 Troubleshooting

### Common Issues

#### "Module not found" errors
- Ensure you've run `npm install`
- Check that TypeScript files are in the `src/` directory

#### Build fails
- Verify Node.js version (v18+)
- Clear cache: `rm -rf node_modules package-lock.json && npm install`

#### Assets not loading
- Check that static files are in the `public/` directory
- Verify relative paths in HTML files

#### SWA CLI issues
- Ensure the project is built: `npm run build`
- Check `swa-cli.config.json` configuration

### Getting Help

1. Check the [Vite documentation](https://vitejs.dev/)
2. Review [Azure Static Web Apps docs](https://docs.microsoft.com/en-us/azure/static-web-apps/)
3. Open an issue in the project repository

## 📝 Development Notes

- **TypeScript**: Use strict typing for better code quality
- **Assets**: Place static files in `public/` for automatic copying
- **Styling**: CSS files imported in TypeScript are bundled and minified
- **JavaScript**: Reference TypeScript source directly in HTML (`src/index.ts`)
- **Hot Reload**: Changes to TypeScript, CSS, and HTML reload automatically

## 🔄 Migration from Previous Setup

This static web app replaces the previous setup by:
- Using Vite instead of manual asset copying
- TypeScript compilation handled by Vite
- Simplified build process with modern tooling
- Better development experience with hot reload
- Optimized production builds with code splitting
# The new Guid API

Solution meant to provide new guids whenever requested.

Sure, this is also possible via the major search engines, by searching for `new guid` or something similar, but over there you need to select it in the UI before you can copy it.

This service only returns a new guid by invoking the site.

## Local Development

This project is structured as an Azure Static Web Apps application with:
- **Frontend**: Vite + TypeScript static site
- **Backend**: .NET 8 Azure Functions

### Prerequisites

- [Node.js](https://nodejs.org/) (v18.x, 20.x, or 22.x)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Azure Static Web Apps CLI](https://github.com/Azure/static-web-apps-cli)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jandev/guid-api.git
   cd guid-api
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Build the frontend**
   ```bash
   npm run build
   ```

4. **Start the development environment**
   ```bash
   ./start-dev.ps1
   ```

This will:
- Start the .NET Azure Functions API on `http://localhost:7071`
- Start the Static Web Apps CLI on `http://localhost:4280`
- Automatically proxy API calls from `/api/*` to the Functions backend

### Manual Development Setup

If you prefer to start services manually:

1. **Start the API (Terminal 1)**
   ```bash
   cd api
   func start
   ```

2. **Start the Static Web Apps CLI (Terminal 2)**
   ```bash
   npx @azure/static-web-apps-cli start
   ```

### Available Scripts

- `npm run build` - Build the frontend for production
- `npm run dev` - Start Vite development server
- `npm run preview` - Preview the production build locally
- `./start-dev.ps1` - Start both API and SWA CLI together

### Project Structure

```
├── src/                          # Frontend source files
│   ├── index.html               # Main page
│   ├── about.html               # About page
│   ├── 404.html                 # 404 error page
│   ├── index.ts                 # TypeScript application logic
│   └── theme.css                # Custom styles
├── api/                         # Azure Functions (.NET 8)
│   ├── Api.csproj
│   ├── Program.cs
│   ├── NewGuid.cs              # Main GUID generation endpoint
│   ├── Live.cs                 # Health check endpoint
│   └── host.json
├── dist/                        # Built frontend files
├── public/                      # Static assets (favicons, etc.)
├── staticwebapp.config.json     # Azure Static Web Apps configuration
├── swa-cli.config.json         # SWA CLI configuration
└── .github/workflows/swa.yml    # Deployment workflow
```

### API Endpoints

- `GET /api/newguid` - Generate a new GUID
- `GET /api/live` - Health check endpoint

### Troubleshooting

- **Node.js version issues**: Use Node.js v18.x, 20.x, or 22.x for Azure Functions Core Tools compatibility
- **API not starting**: Ensure .NET 8 SDK is installed and `func` command is available
- **Build failures**: Run `npm install` to ensure all dependencies are installed

## Invoke the API

Invoke the API without an `Accept`-header.

```
GET https://api.guid.codes/

Response content-type: text/plain
Response body:
49ccbb20-6602-49e4-a932-9b39ef6521b6
```

Invoke the API with a JSON `Accept`-header.

```
GET https://api.guid.codes/
Accept: application/json

Response content-type: application/json
Response body:
{
    "value": "d9b8750c-6742-42fb-9aa1-4510245139fb"
}
```

## Deployment

This project consists of 2 small applications.

1. Static website
2. API

Either one is deployed whenever there is a change in their respecting folders of the  `main` branch in this repository.

The static site will be deployed to an Azure Storage Account and uses the static site hosting feature.  
The API is deployed to an Azure Function App.

Both are, by default, deployed to multiple regions across the globe and an Azure Traffic Manager will make sure the site & API is used which has the best response times for the user.

For a succesful deployment, a secret needs to be added to the repository called `AZURE_DEV`. The contents of this secret should be the output of this command:

```azcli
az ad sp create-for-rbac --name "guidapi" --role owner --sdk-auth
```

Or something similar of course. The contents are used in the workflows to log in to Azure and deploy the resources.
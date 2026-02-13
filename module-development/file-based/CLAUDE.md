# CLAUDE.md - File-Based Module Development Guide

This file provides guidance for creating and developing LabKey file-based modules.

## What is a File-Based Module?

A file-based module is a LabKey module that doesn't contain any Java code. It enables custom development without compiling, letting you directly deploy and test module resources, often without restarting the server. File-based modules support:

- SQL queries and views
- Reports (R, JavaScript, HTML)
- Custom data views
- Web parts and HTML/JavaScript client-side applications
- Assay definitions
- ETL configurations
- Pipeline definitions

## Module Directory Structure

### Development/Source Layout
```
myModule/
├── module.properties          # Module configuration (REQUIRED)
├── README.md                  # Module documentation
└── resources/                 # All module resources go here
    ├── queries/               # SQL queries and query metadata
    │   └── [schema_name]/     # Organize by schema
    │       ├── [query_name].sql
    │       ├── [query_name].query.xml
    │       └── [query_name]/  # Query-specific views
    │           └── [view_name].html
    ├── reports/               # Report definitions
    │   └── schemas/
    │       └── [schema_name]/
    │           └── [query_name]/
    │               ├── [report_name].r
    │               ├── [report_name].rhtml
    │               └── [report_name].report.xml
    ├── views/                 # Custom views and web parts
    │   ├── [view_name].html
    │   └── [view_name].webpart.xml
    ├── schemas/               # Database schema definitions
    │   └── dbscripts/
    │       ├── postgresql/
    │       └── sqlserver/
    ├── web/                   # JavaScript, CSS, images
    │   └── [moduleName]/
    │       ├── [moduleName].js
    │       └── [moduleName].css
    ├── assay/                 # Assay type definitions
    ├── etls/                  # ETL configurations
    ├── folderTypes/           # Custom folder type definitions
    └── pipeline/              # Pipeline task definitions
```

### Deployed Layout
When deployed, the structure changes slightly:
- `resources/` directory contents move to root level
- `module.properties` becomes `config/module.xml`
- Compiled code (if any) goes to `lib/`

## module.properties File

This is the **required** configuration file for your module. Place it in the module root.

### Required Properties
```properties
ModuleClass: org.labkey.api.module.SimpleModule
Name: myModule
```

### Recommended Properties
```properties
ModuleClass: org.labkey.api.module.SimpleModule
Name: myModule
Label: My Custom Module
Description: A file-based module for custom queries, reports, and views.\
             Multi-line descriptions can span multiple lines using backslash continuation.
Version: 1.0.0
Author: Your Name <your.email@example.com>
Organization: Your Organization
OrganizationURL: https://example.com
License: Apache 2.0
LicenseURL: https://www.apache.org/licenses/LICENSE-2.0
Maintainer: Your Name <your.email@example.com>
RequiredServerVersion: 23.11
```
`Name` should usually be the same as the directory name, especially for file-based modules.

### Additional Properties
- **SchemaVersion**: Version number for SQL schema upgrade scripts (e.g., `1.00`)
- **ManageVersion**: Boolean (true/false) for schema version management
- **BuildType**: "Development" or "Production"
- **SupportedDatabases**: "pgsql" or "mssql" (comma-separated)
- **URL**: Homepage URL for the module

### Auto-Generated Properties (Don't Set)
These are set during build: BuildNumber, BuildOS, BuildPath, BuildTime, BuildUser, EnlistmentId, ResourcePath, SourcePath, VcsRevision, VcsURL

## Creating Web Parts

Web parts are HTML views that can be added to LabKey pages.

### Basic Web Part Structure

**File**: `resources/views/myWebPart.html`
```html
<div class="labkey-module-content">
    <h2>My Web Part</h2>
    <p>Content goes here</p>
</div>

<script type="text/javascript" nonce="<%=scriptNonce%>">
// JavaScript code here
// IMPORTANT: Always include nonce="<%=scriptNonce%>" for CSP compliance
</script>
```

**Configuration**: `resources/views/myWebPart.webpart.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<webpart xmlns="http://labkey.org/data/xml/webpart">
    <name>My Web Part</name>
    <description>Description of what this web part does</description>
    <location>body</location>
</webpart>
```

### Important: Content Security Policy (CSP)

LabKey enforces CSP, so **all inline scripts must include the nonce attribute**:
```html
<script type="text/javascript" nonce="<%=scriptNonce%>">
    // Your code here
</script>
```

Without the nonce, your inline scripts will be blocked by the browser.

### Template Variables

LabKey automatically substitutes the following variables in HTML view files (use `<%=variableName%>` syntax):

- **scriptNonce**: CSP nonce for inline scripts. **Required for all `<script>` tags** to comply with Content Security Policy.
  ```html
  <script type="text/javascript" nonce="<%=scriptNonce%>">
  ```

- **contextPath**: The web application's context path (e.g., `/labkey`). Use for building URLs to server resources.
  ```javascript
  var url = '<%=contextPath%>' + '/someResource.js';
  ```

- **containerPath**: The current container's path (e.g., `/MyProject/MyFolder`). Use for building container-specific URLs.
  ```javascript
  var containerUrl = '<%=contextPath%>' + '<%=containerPath%>';
  ```

- **wrapperDivId**: A unique ID for the wrapper div containing the view (format: `ModuleHtmlView_<uniqueID>`). Useful for scoping JavaScript or CSS to a specific view instance.
  ```javascript
  var wrapper = document.getElementById('<%=wrapperDivId%>');
  ```

- **id**: The web part's row ID (or `-1` if not rendered as a web part). Use to identify specific web part instances.
  ```javascript
  var webPartId = <%=id%>; // Note: no quotes, this is a number
  ```

- **webpartContext**: A JSON string containing configuration for the web part, including:
  - `wrapperDivId`: The wrapper div ID
  - `id`: The web part row ID
  - `properties`: An object containing the web part's custom properties (from webpart.xml configuration)
  - Any additional properties set on the web part

  ```javascript
  var config = JSON.parse('<%=webpartContext%>');
  console.log('Web part ID:', config.id);
  console.log('Properties:', config.properties);
  ```

**Note**: The entire view is automatically wrapped in a div with the `wrapperDivId`, so you don't need to create it yourself.

## Using LabKey JavaScript APIs

LabKey provides a comprehensive JavaScript API for interacting with the server.

**Complete API Reference**: For the full JavaDoc-style API documentation, see https://labkey.github.io/labkey-api-js/

### Accessing User and Container Information

User and container information is automatically rendered into the page:

```javascript
// Access current user information
console.log('User ID:', LABKEY.user.id);
console.log('Display Name:', LABKEY.user.displayName);
console.log('Email:', LABKEY.user.email);
console.log('Is Admin:', LABKEY.user.isAdmin);
console.log('Is Guest:', LABKEY.user.isGuest);

// Access current container/folder information
console.log('Container ID:', LABKEY.container.id);
console.log('Container Path:', LABKEY.container.path);
console.log('Container Name:', LABKEY.container.name);
```

### Common LABKEY JavaScript Objects

- **LABKEY.ActionURL**: Build URLs to LabKey controllers and actions
- **LABKEY.Ajax**: Make AJAX requests to LabKey APIs
- **LABKEY.Query**: Execute SQL queries and retrieve data
- **LABKEY.Security**: Access user permissions and security info
- **LABKEY.Utils**: Utility functions for common tasks

### Example: Querying Data

```javascript
LABKEY.Query.selectRows({
    schemaName: 'lists',
    queryName: 'MyList',
    success: function(data) {
        console.log('Rows:', data.rows);
    },
    failure: function(error) {
        console.error('Query failed:', error);
    }
});
```

## Creating SQL Queries

Place SQL query files in `resources/queries/[schema_name]/`.

### Basic Query

**File**: `resources/queries/core/Users.sql`
```sql
SELECT
    UserId,
    DisplayName,
    Email,
    Active
FROM core.Users
WHERE Active = TRUE
ORDER BY DisplayName
```

### Query Metadata

**File**: `resources/queries/core/Users.query.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<query xmlns="http://labkey.org/data/xml/query">
    <metadata>
        <columns>
            <column columnName="UserId">
                <description>Unique user identifier</description>
            </column>
            <column columnName="DisplayName">
                <description>User's display name</description>
            </column>
        </columns>
    </metadata>
</query>
```

## Deployment and Testing

### Location

File-based modules are deployed to:
```
<LABKEY_ROOT>/build/deploy/externalModules/[moduleName]/
```

**IMPORTANT**: Back up your module before running `gradlew cleanBuild` as the build directory may be deleted.

### Enabling the Module

1. Navigate to your target folder in LabKey
2. Go to **Folder > Management**
3. Click the **Folder Type** tab
4. Check your module's checkbox under "Modules"
5. Click **Update Folder**

### Hot Deployment

Most changes to file-based module resources don't require a server restart:
- ✅ HTML/JavaScript changes in views: No restart needed
- ✅ Query definition changes: No restart needed
- ✅ Report updates: No restart needed
- ⚠️ module.properties changes: Restart required
- ⚠️ Adding new resource types: May require restart

Simply refresh your browser to see changes.

## Best Practices

### Security
- Always use `nonce="<%=scriptNonce%>"` for inline scripts
- Escape user-supplied data before rendering in HTML
- Use LABKEY.Utils.encodeHtml() to prevent XSS
- Never expose sensitive data in client-side code

### Code Organization
- Keep JavaScript in separate files under `resources/web/[moduleName]/`
- Use meaningful names for queries, views, and reports
- Group related queries by schema
- Document your queries with .query.xml metadata files

### Performance
- Use query metadata to hide unnecessary columns
- Limit result sets with WHERE clauses
- Create database indexes for frequently queried columns
- Cache expensive queries when possible

### Maintenance
- Version your module.properties appropriately
- Document breaking changes in your README
- Test on both PostgreSQL and SQL Server if supporting both
- Keep module.properties up to date with RequiredServerVersion

## Common Patterns

### Creating a Dashboard Web Part

```html
<div class="labkey-module-content">
    <h2>My Dashboard</h2>
    <div id="dashboard-content">Loading...</div>
</div>

<script type="text/javascript" nonce="<%=scriptNonce%>">
(function() {
    // Parse web part configuration
    var config = JSON.parse('<%=webpartContext%>');
    console.log('Web part ID:', config.id);
    console.log('Custom properties:', config.properties);

    // Query data in the current container
    LABKEY.Query.selectRows({
        containerPath: '<%=containerPath%>',
        schemaName: 'core',
        queryName: 'Users',
        success: function(data) {
            var html = '<ul>';
            data.rows.forEach(function(row) {
                html += '<li>' + LABKEY.Utils.encodeHtml(row.DisplayName) + '</li>';
            });
            html += '</ul>';

            // Use wrapperDivId to scope to this specific view instance
            var wrapper = document.getElementById('<%=wrapperDivId%>');
            var contentDiv = wrapper.querySelector('#dashboard-content');
            contentDiv.innerHTML = html;
        }
    });
})();
</script>
```

### Adding Custom Button Actions

```html
<div class="labkey-module-content">
    <button id="myButton" class="labkey-button">Click Me</button>
</div>

<script type="text/javascript" nonce="<%=scriptNonce%>">
(function() {
    document.getElementById('myButton').addEventListener('click', function() {
        LABKEY.Utils.alert('Button Clicked', 'You clicked the button!');
    });
})();
</script>
```

## Documentation Resources

For more information, see:
- Simple Modules Overview: https://www.labkey.org/Documentation/wiki-page.view?name=simpleModules
- File-Based Module Tutorial: https://www.labkey.org/Documentation/wiki-page.view?name=moduleqvr
- JavaScript API Documentation: https://labkey.github.io/labkey-api-js/
- Module Directory Structures: https://www.labkey.org/Documentation/wiki-page.view?name=moduleDirectoryStructures
- Query Development: https://www.labkey.org/Documentation/wiki-page.view?name=addSQLQuery

## Quick Start Checklist

- [ ] Create module directory in `build/deploy/externalModules/`
- [ ] Add `module.properties` with required fields
- [ ] Create `resources/` directory structure
- [ ] Add at least one view or query
- [ ] Enable module in a test folder
- [ ] Test functionality in browser
- [ ] Document usage in README.md
- [ ] Back up module outside build directory

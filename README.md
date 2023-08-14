# service-alerting-prototype

## Usage
1. Create a `.env` file from `.env.sample` and populate it with
    - `OPSGENIE_API_URL`: Depends on the hosting instance, e.g. `api.eu.opsgenie.com`
    - `OPSGENIE_API_KEY`: Created from the Settings pane of the OpsGenie dashboard. Add all scopes (Read, Create and Update, Delete, Configuration Access)

2. Run 
```bash
make opsgenie
```

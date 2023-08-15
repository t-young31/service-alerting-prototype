# service-alerting-prototype

## Usage
0. Signup for an [OpsGenie](https://www.atlassian.com/software/opsgenie)
account, start the free trial then [upgrade](https://intercom.help/opsgenie/en/articles/3505298-changing-your-trial-plan)
the trial to the standard plan.

1. Create a `.env` file from `.env.sample` and populate it with
    - `OPSGENIE_API_URL`: Depends on the hosting instance, e.g. `api.eu.opsgenie.com`
    - `OPSGENIE_API_KEY`: Created from the Settings pane of the OpsGenie dashboard. Add all scopes (Read, Create and Update, Delete, Configuration Access)

2. Create a `config.yaml` file from `config.sample.yaml`

3. Run 
```bash
make opsgenie
```

3. Ensure all team members have accepted the email invitation to OpsGenie.

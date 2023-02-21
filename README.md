# The new Guid API

Solution meant to provide new guids whenever requested.

Sure, this is also possible via the major search engines, by searching for `new guid` or something similar, but over there you need to select it in the UI before you can copy it.

This service only returns a new guid by invoking the site.

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
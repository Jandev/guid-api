$storageAccount = "guidapistaticprodweu"
az storage blob service-properties update --account-name $storageAccount --static-website --index-document index.html --404-document 404.html
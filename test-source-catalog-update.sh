#!/bin/bash

# User specified shell exports
#castuser
#castpw
#castip

source cast-source-catalog.sh

catalogsFile="$scriptProcessingDir/catalogsOutput.xml"
sourceCatalogFile="$scriptProcessingDir/sourceCatalog.xml"
originalSourcesFile="$scriptProcessingDir/originalSources.xml"
uploadedResultsFile="$scriptProcessingDir/uploadedResult.xml"
parsedUploadedSourcesFile="$scriptProcessingDir/parsedUploadedSources.xml"
parsedSourcesFile="$scriptProcessingDir/parsedSources.xml"
sourcesFile="$scriptProcessingDir/sources.xml"
diffedFile="$scriptProcessingDir/diffed.xml"

loginGettingSecurityContext $castuser $castpw $castip

echo
echo "#####################################"
echo "import modified sources"
getSourceCatalogsIntoFile "$catalogsFile"
getSourceCatalogByNameFromFileToFile "fromArgs2" "$catalogsFile" "$sourceCatalogFile"
extractSourceElementsFromFileToFile "$sourceCatalogFile" "$originalSourcesFile"
uploadFile "resources/importCatalogModified.csv" "$uploadedResultsFile"
parseSourcesFromFileToFile "$uploadedResultsFile" "$parsedUploadedSourcesFile"
extractSourceElementsFromFileToFile "$parsedUploadedSourcesFile" "$parsedSourcesFile"
viewSourceDifferencesFromBaseFileFromUploadedFileToViewFile "$originalSourcesFile" "$parsedSourcesFile" "$diffedFile"
extractSourcesEntityFromFileToFile "$parsedUploadedSourcesFile" "$sourcesFile"
updateCatalogByNameFromFileWithSourcesFile "fromArgs2" "$catalogsFile" "$sourcesFile"

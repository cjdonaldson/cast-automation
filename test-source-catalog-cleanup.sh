#!/bin/bash

# User specified shell exports
#castuser
#castpw
#castip

source cast-source-catalog.sh

cleanupCatalogOutput="$scriptProcessingDir/cleanupCatalogOutput.xml"
loginGettingSecurityContext $castuser $castpw $castip

getSourceCatalogsIntoFile "$cleanupCatalogOutput"
delSourceCatalogByNameFromFile "emptyCatalogFromFile" "$cleanupCatalogOutput"
delSourceCatalogByNameFromFile "fromArgs1" "$cleanupCatalogOutput"
delSourceCatalogByNameFromFile "fromArgs2" "$cleanupCatalogOutput"

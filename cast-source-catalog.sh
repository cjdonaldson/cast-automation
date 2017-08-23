#!/bin/bash
# to extract MD,
#   sed -n '/^#start__md$/,/^#end__md$/{/^#start__md$/d; /^#end__md$/d; p; }' file.sh | sed 's/^# //'

source cast-global-setup.sh

#start__md
# ## cast-source-catalog.sh
# Provides CAST Source Catalog operations via the following:
#
#end__md

#start__md
# ---
# `getSourceCatalogsIntoFile <path-to-output-file>` <br/>
# Retrieves the currently available Source Catalogs containing name, version, description, and history information into `<path-to-output-file`. <br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; HTTP GET sourcecatalog/requestAll
#
#end__md
getSourceCatalogsIntoFile() {
  $castHttps $uriBase/sourcecatalog/requestAll -o "$1-temp"
  xmllint --format "$1-temp" > "$1"
  rm "$1-temp"
}

#start__md
# ---
# `addSourceCatalogFromFile <path-to-file>`<br/>
# Adds a new Source Catalog as specifed in the `<path-to-file>`<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; HTTP POST sourcecatalog/add<br/>
# &nbsp; &nbsp; with post data:
# * _body=urlEncoded(xml-data)
# * __Content-Type=application/xml
#
#
# examples of the file format:
# ```
# <saveSourceCatalog xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
#   <sourceCatalog name="emptyCatalogFromFile" version="1.0.0" description="just an empty catalog">
#     <sources/>
#   </sourceCatalog>
# </saveSourceCatalog>
# ```
# ```
# <saveSourceCatalog xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
#   <sourceCatalog name="emptyCatalogFromFile" version="1.0.0" description="just an empty catalog">
#     <sources>
#       <Source definition="SD" encryptionMode="FE-MPM" followDtcp="false" id="83dbf4a9-981a-4e34-82d5-3627e9c00435" name="AMC" programProvision="INTERNAL" shortName="AMC" sourceId="4100" value="NORMAL">
#         <CopyControlInformation aps="OFF" cit="OFF" emi="COPY_FREELY" rct="OFF"/>
#       </Source>
#       <Source definition="SD" encryptionMode="FE-MPM" followDtcp="false" id="691a4c0a-9eb7-4e13-ac3b-640a9e12122b" name="BET" programProvision="INTERNAL" shortName="BET" sourceId="4103" value="NORMAL">
#         <CopyControlInformation aps="OFF" cit="OFF" emi="COPY_FREELY" rct="OFF"/>
#       </Source>
#     </sources>
#   </sourceCatalog>
# </saveSourceCatalog>
# ```
#
#end__md
addSourceCatalogFromFile() {
  catalogFile="$1"
  newCatalog=$(<$catalogFile)
  $castHttps -d $xmlDataPost --data-urlencode "_body=$newCatalog" $uriBase/sourcecatalog/add
}

#start__md
# ---
# `addSourceCatalogFromArgs <name> <version> <description> <sources-xml>`<br/>
# Adds a new Source Catalog as specifed by the given values. Where `sources-xml` is
# the `<sources>` xml node as defined in `addSourceCatalogFromFile`<br/>
# This function formats an xml document as defined in `addSourceCatalogFromFile` posting to the same
# uri.
#
#end__md
addSourceCatalogFromArgs() {
  xmlSaveSourceCatalogFromArgs "$1" "$2" "$3" "$4"
  $castHttps -d $xmlDataPost --data-urlencode "_body=$xmlSaveSourceCatalog" $uriBase/sourcecatalog/add
}

#private
getCatalogIdByNameFromFile() {
  catalogId=`xmllint --xpath "string(//*[@name='$1']/@id)" "$2" | tr -d '[:space:]'`
}

#start__md
# ---
# `delSourceCatalogByNameFromFile <name> <path-to-file>`<br/>
# Deletes the specified Source Catalog by retrieving the ID for `name` from the specified file.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST sourcecatalog/delete/&lt;ID&gt;<br/>
#
#end__md
delSourceCatalogByNameFromFile() {
  getCatalogIdByNameFromFile "$1" "$2"
  $castHttps --request POST $uriBase/sourcecatalog/delete/$catalogId
}

#start__md
# ---
# `getSourceCatalogByNameFromFileToFile <name> <path-to-file> <path-to-output-file>`<br/>
# Retrieves the full detailed Source Catalog into the output file by retrieving the ID for `name` from the specified input file.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; GET sourcecatalog/request/&lt;ID&gt;<br/>
#
#end__md
getSourceCatalogByNameFromFileToFile() {
  getCatalogIdByNameFromFile "$1" "$2"
  $castHttps $uriBase/sourcecatalog/request/$catalogId -o "$3-temp"
  xmllint --format "$3-temp" > "$3"
  rm "$3-temp"
}

#start__md
# ---
# `getSourceCatalogUploadUrl`<br/>
# Retrieves a CAST assigned SOurce CAtalog upload url svaing the result in uploadUrl.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; GET sourcecatalog/getUploadUrl<br/>
#
#end__md
getSourceCatalogUploadUrl() {
  outputFile="$scriptProcessingDir/output-tmp.xml"
  $castHttps $uriBase/sourcecatalog/getUploadUrl -o "$outputFile"
  uploadUrl=`xmllint --xpath "string(/httpUrl/@value)" "$outputFile"`
  rm "$outputFile"
}

#start__md
# ---
# `uploadFile <path-to-file>`<br/>
# Uploads a file to CAST.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST &lt;cast-provided-url&gt;<br/>
# &nbsp; &nbsp; with post data:
# * Filename=&lt;filename&gt;
# * file-upload=&lt;file-contents&gt;
#
#end__md
uploadFile() {
  srcFile="$1"

  getSourceCatalogUploadUrl
  $castHttps --form file-upload=@"$srcFile" --form Filename=$srcFile $uploadUrl -o "$2-temp"
  xmllint --format "$2-temp" > "$2"
  rm "$2-temp"
}

#start__md
# ---
# `parseSourcesFromFileToFile <path-to-input-file> <path-to-output-file>`<br/>
# Parses the input Source Catalog CSV file into the specified output file as Source Catalog Sources XML.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST sourcecatalog/parseSources<br/>
# &nbsp; &nbsp; with post data:
# * requestRepositories=urlEncoded(&lt;requestRepositories/&gt;)
#
#end__md
parseSourcesFromFileToFile() {
  body=$(<$1)
  $castHttps --data-urlencode "_body=$body" -d $xmlDataPost $uriBase/sourcecatalog/parseSources -o "$2-temp"
  xmllint --xpath '/sources' "$2-temp" > "$2-result"
  rm "$2-temp"
  xmllint --format "$2-result" > "$2"
  rm "$2-result"
}

getXmlNodeIntoFile() {
  xmllint --xpath "$1" "$2" > "$3"
}

extractSourcesEntityFromFileToFile() {
  getXmlNodeIntoFile '//sources' "$1" "$2"
}

extractSourceElementsFromFileToFile() {
  getXmlNodeIntoFile '///Source' "$1" "$2"
}

#start__md
# ---
# `viewSourceDifferencesFromBaseFileFromUploadedFileToViewFile <path-to-base-file> <path-to-uploaded-file> <path-to-output-file>`<br/>
# Instructs CAST to generate a Source Catalog difference from base to uploaded.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST sourcecatalog/request/&lt;ID&gt;<br/>
# &nbsp; &nbsp; with post data:
# * __Content-Type=application/xml
# * _body=urlEncoded(
# ```
# <viewSourceDifferences xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
#       <baseSources>
#         <path-to-base-file-contents>
#       </baseSources>
#       <uploadedSources>
#         <path-to-uploaded-file-contents>
#       </uploadedSources>
#     </viewSourceDifferences>#
# ```
# )
#
#end__md
viewSourceDifferencesFromBaseFileFromUploadedFileToViewFile() {
  read -r -d '' body <<-ENDOFMESSAGE
    <viewSourceDifferences xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
      <baseSources>
        $(<$1)
      </baseSources>
      <uploadedSources>
        $(<$2)
      </uploadedSources>
    </viewSourceDifferences>
ENDOFMESSAGE
  #formData="-d __Content-Type=application/xml -d __Accept=*/*"
  $castHttps --data-urlencode "_body=$body" -d $xmlDataPost $uriBase/sourcecatalog/viewSourceDifferences -o "$3-temp"
  xmllint --format "$3-temp" > "$3"
  rm "$3-temp"
}

getSourceCatalogDetailsByNameFromFileContainingSources() {
  getSourceCatalogDetailsByNameFromFile "$1" "$2"
  sources=`xmllint --xpath "//*[@name='$1']/sources" "$2"`
}

getSourceCatalogDetailsByNameFromFile() {
  catalogId=`xmllint --xpath "string(//*[@name='$1']/@id)" "$2" | tr -d '[:space:]'`
  version=`xmllint --xpath "string(//*[@name='$1']/@version)" "$2" | tr -d '[:space:]'`
  description=`xmllint --xpath "string(//*[@name='$1']/@description)" "$2" | tr -d '[:space:]'`
}

#start__md
# ---
# `updateCatalogByNameFromFileWithSourcesFile <name> <path-to-catalog-file> <path-to-sources-file>`<br/>
# Updates the Source Catalog specified by name with new data - name, version, description, sources - by retrieving the ID for `name` from the specified catalog file.
# sources file is the  &lt;sources&gt;...&lt;sources&gt; xml format.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST sourcecatalog/update<br/>
# &nbsp; &nbsp; with post data:
# * __Content-Type=application/xml
# * _body=urlEncoded( addSourceCatalogFromFile xml format data )
#
#end__md
updateCatalogByNameFromFileWithSourcesFile() {
  getSourceCatalogDetailsByNameFromFile "$1" "$2"
  xmlSaveSourceCatalogFromArgsWithId "$1" "$version" "$description" "$catalogId" "$(<$3)"
  $castHttps -d $xmlDataPost --data-urlencode "_body=$xmlSaveSourceCatalog" $uriBase/sourcecatalog/update
}

#start__md
# ---
# `getRepositoryToFile <path-to-file>`<br/>
# Retrieves all CAST repositories in the specified file.
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; GET repositories/repositoryManagement.form<br/>
# &nbsp; &nbsp; with post data:
# * requestRepositories=urlEncoded(&lt;requestRepositories/&gt;)
#
#end__md
getRepositoryToFile() {
  $castHttps --data-urlencode "requestRepositories=<requestRepositories/>" $uriBase/repositories/repositoryManagement.form > $1-temp
  xmllint --format $1-temp > $1
  rm $1-temp
}

#start__md
# ---
# `waitForProgressMonitorToCompleteFromFile <path-to-progress-file>`<br/>
# Blocks script execution until the progress meter specified in `path-to-progress-file` completes.
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST repositories/repositoryProgressMonitor/&lt;ID&gt;<br/>
#
#end__md
waitForProgressMonitorToCompleteFromFile() {
  progressFile="$scriptProcessingDir/progressFile.xml"
  getProgressMonitorDetailsFromFile "$1"
  echo "progress $monitorPercentDone"
  while [ "$monitorComplete" == "false" ]; do
    echo "progress $monitorPercentDone"
    $castHttps $uriBase/repositories/repositoryProgressMonitor/$monitorId -o "$progressFile"
    getProgressMonitorDetailsFromFile "$progressFile"
  done
}

#start__md
# ---
# `publishCatalogByNameFromFileToRepositoryByNameFromFile <name> <path-to-sources-file> <repo-name> <path-to-repos-file>`<br/>
# Publishes the specified Source Catalog to the specified repository using the `path-to-?-file`s to retrieve required post information.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST sourcecatalog/request/publish<br/>
# &nbsp; &nbsp; with post data:
# * id=&lt;source-catalog-id&gt;
# * repositoryPath=&lt;cast-repo-path&gt;
# * label=&lt;repo-description&gt;
# * providerType=com.ccadllc.firebird.cast.sourcecatalog
#
#end__md
publishCatalogByNameFromFileToRepositoryByNameFromFile() {
  getCatalogIdByNameFromFile "$1" "$2"
  publishCatalogByIdToRepositoryByNameFromFile "$catalogId" "$3" "$4"
}

publishCatalogByIdToRepositoryByNameFromFile() {
  publishedResultFile="$scriptProcessingDir/publishedResult.xml"
  getRepositoryLocationByNameFromFile "$2" "$3"
  getRepositoryDescriptionByNameFromFile "$2" "$3"
  $castHttps -d "id=$1" -d "repositoryPath=$repositoryLocation" --data-urlencode "label=$repositoryDescription" -d "providerType=com.ccadllc.firebird.cast.sourcecatalog" $uriBase/repositories/publish -o "$publishedResultFile"
  waitForProgressMonitorToCompleteFromFile "$publishedResultFile"
}

#start__md
# ---
# `editSourceCatalogByNameFromFileWithNewVersion <name> <path-to-input-file> <version>`<br/>
# Transistions the named catalog in input file from Published to Edit with the new version without changing the sources.<br/>
# Provides CAST Source Catalog operations via the following:<br/>
# &nbsp; &nbsp; POST sourcecatalog/update<br/>
# &nbsp; &nbsp; with post data:
# * _body=urlEncoded(xml-data)
# * __Content-Type=application/xml
#
#end__md
editSourceCatalogByNameFromFileWithNewVersion() {
  sourceCatalogFile="$scriptProcessingDir/sourceCatalog.xml"
  getSourceCatalogByNameFromFileToFile "$1" "$2" "$sourceCatalogFile"
  getSourceCatalogDetailsByNameFromFileContainingSources "$1" "$sourceCatalogFile"
  xmlSaveSourceCatalogFromArgsWithId "$1" "$3" "$description" "$catalogId" "$sources"
  $castHttps -d $xmlDataPost --data-urlencode "_body=$xmlSaveSourceCatalog" $uriBase/sourcecatalog/update
}



#### PRIVATE functions

xmlSaveSourceCatalogFromArgs() {
  xmlSaveSourceCatalogFromArgsWithId "$1" "$2" "$3" "" "$4"
}

xmlSaveSourceCatalogFromArgsWithId() {
  name="$1"
  version="$2"
  desc="$3"
  if [ -z "$4" ]; then
    id=""
  else
    id="id=\"$4\""
  fi
  sources="$5"

  read -r -d '' xmlSaveSourceCatalog <<-ENDOFMESSAGE
    <saveSourceCatalog xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
      <sourceCatalog name="$name" version="$version" description="$desc" $id>
        $sources
      </sourceCatalog>
    </saveSourceCatalog>
ENDOFMESSAGE
}

getRepositoryLocationByNameFromFile() {
  repositoryLocation=`xmllint --xpath "string(//*[@name='$1']/@location)" $2`
}

getRepositoryDescriptionByNameFromFile() {
  repositoryDescription=`xmllint --xpath "string(//*[@name='$1']/@description)" $2`
}

getProgressMonitorDetailsFromFile() {
  monitorId=`xmllint --xpath "string(//@id)" $1`
  monitorCanceled=`xmllint --xpath "string(//@canceled)" $1`
  monitorPercentDone=`xmllint --xpath "string(//@percentDone)" $1`
  monitorComplete=`xmllint --xpath "string(//@complete)" $1`
}

getOneTimeToken() {
  outputFile="$scriptProcessingDir/output-tmp.xml"
  $castHttps --request POST $uriBase/security/createOneTimeToken.form -o "$outputFile"
  oneTimeToken=`xmllint --xpath "string(/success/@oneTimeId)" "$outputFile" | tr -d '[:space:]'`
  rm "$outputFile"
}


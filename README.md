
# CAST Automation
CAST supports basic authentication which allows for simpler scripting operations.


 ## cast-global-setup.sh
 cast-global-setup.sh is to be sourced from each CAST functional script and not from the test script.
 And defines communication global variables.

 The following global variables need to be defined prior to sourcing the respective CAST functional script either via shell __export__s
 or script __set__s in the test script
 * castuser  The CAST user name to be used
 * castpw    The password for CAST user
 * castip    The ip address of the CAST to be automated


 which define castHttps and uriBase variables that can be used like:

 &nbsp;&nbsp; `$castHttps <options> $uriBase/<uriTarget>`

 `$scriptProcessingDir` variable provides a location for operational result storage and work area.
 Prepend to file names.

 ## cast-source-catalog.sh
 Provides CAST Source Catalog operations via the following:

 ---
 `getSourceCatalogsIntoFile <path-to-output-file>` <br/>
 Retrieves the currently available Source Catalogs containing name, version, description, and history information into `<path-to-output-file`. <br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; HTTP GET sourcecatalog/requestAll

 ---
 `addSourceCatalogFromFile <path-to-file>`<br/>
 Adds a new Source Catalog as specifed in the `<path-to-file>`<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; HTTP POST sourcecatalog/add<br/>
 &nbsp; &nbsp; with post data:
 * _body=urlEncoded(xml-data)
 * __Content-Type=application/xml


 examples of the file format:
 ```
 <saveSourceCatalog xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
   <sourceCatalog name="emptyCatalogFromFile" version="1.0.0" description="just an empty catalog">
     <sources/>
   </sourceCatalog>
 </saveSourceCatalog>
 ```
 ```
 <saveSourceCatalog xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
   <sourceCatalog name="emptyCatalogFromFile" version="1.0.0" description="just an empty catalog">
     <sources>
       <Source definition="SD" encryptionMode="FE-MPM" followDtcp="false" id="83dbf4a9-981a-4e34-82d5-3627e9c00435" name="AMC" programProvision="INTERNAL" shortName="AMC" sourceId="4100" value="NORMAL">
         <CopyControlInformation aps="OFF" cit="OFF" emi="COPY_FREELY" rct="OFF"/>
       </Source>
       <Source definition="SD" encryptionMode="FE-MPM" followDtcp="false" id="691a4c0a-9eb7-4e13-ac3b-640a9e12122b" name="BET" programProvision="INTERNAL" shortName="BET" sourceId="4103" value="NORMAL">
         <CopyControlInformation aps="OFF" cit="OFF" emi="COPY_FREELY" rct="OFF"/>
       </Source>
     </sources>
   </sourceCatalog>
 </saveSourceCatalog>
 ```

 ---
 `addSourceCatalogFromArgs <name> <version> <description> <sources-xml>`<br/>
 Adds a new Source Catalog as specifed by the given values. Where `sources-xml` is
 the `<sources>` xml node as defined in `addSourceCatalogFromFile`<br/>
 This function formats an xml document as defined in `addSourceCatalogFromFile` posting to the same
 uri.

 ---
 `delSourceCatalogByNameFromFile <name> <path-to-file>`<br/>
 Deletes the specified Source Catalog by retrieving the ID for `name` from the specified file.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST sourcecatalog/delete/&lt;ID&gt;<br/>

 ---
 `getSourceCatalogByNameFromFileToFile <name> <path-to-file> <path-to-output-file>`<br/>
 Retrieves the full detailed Source Catalog into the output file by retrieving the ID for `name` from the specified input file.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; GET sourcecatalog/request/&lt;ID&gt;<br/>

 ---
 `getSourceCatalogUploadUrl`<br/>
 Retrieves a CAST assigned SOurce CAtalog upload url svaing the result in uploadUrl.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; GET sourcecatalog/getUploadUrl<br/>

 ---
 `uploadFile <path-to-file>`<br/>
 Uploads a file to CAST.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST &lt;cast-provided-url&gt;<br/>
 &nbsp; &nbsp; with post data:
 * Filename=&lt;filename&gt;
 * file-upload=&lt;file-contents&gt;

 ---
 `parseSourcesFromFileToFile <path-to-input-file> <path-to-output-file>`<br/>
 Parses the input Source Catalog CSV file into the specified output file as Source Catalog Sources XML.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST sourcecatalog/parseSources<br/>
 &nbsp; &nbsp; with post data:
 * requestRepositories=urlEncoded(&lt;requestRepositories/&gt;)

 ---
 `viewSourceDifferencesFromBaseFileFromUploadedFileToViewFile <path-to-base-file> <path-to-uploaded-file> <path-to-output-file>`<br/>
 Instructs CAST to generate a Source Catalog difference from base to uploaded.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST sourcecatalog/request/&lt;ID&gt;<br/>
 &nbsp; &nbsp; with post data:
 * __Content-Type=application/xml
 * _body=urlEncoded(
 ```
 <viewSourceDifferences xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
       <baseSources>
         <path-to-base-file-contents>
       </baseSources>
       <uploadedSources>
         <path-to-uploaded-file-contents>
       </uploadedSources>
     </viewSourceDifferences>#
 ```
 )

 ---
 `updateCatalogByNameFromFileWithSourcesFile <name> <path-to-catalog-file> <path-to-sources-file>`<br/>
 Updates the Source Catalog specified by name with new data - name, version, description, sources - by retrieving the ID for `name` from the specified catalog file.
 sources file is the  &lt;sources&gt;...&lt;sources&gt; xml format.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST sourcecatalog/update<br/>
 &nbsp; &nbsp; with post data:
 * __Content-Type=application/xml
 * _body=urlEncoded( addSourceCatalogFromFile xml format data )

 ---
 `getRepositoryToFile <path-to-file>`<br/>
 Retrieves all CAST repositories in the specified file.
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; GET repositories/repositoryManagement.form<br/>
 &nbsp; &nbsp; with post data:
 * requestRepositories=urlEncoded(&lt;requestRepositories/&gt;)

 ---
 `waitForProgressMonitorToCompleteFromFile <path-to-progress-file>`<br/>
 Blocks script execution until the progress meter specified in `path-to-progress-file` completes.
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST repositories/repositoryProgressMonitor/&lt;ID&gt;<br/>

 ---
 `publishCatalogByNameFromFileToRepositoryByNameFromFile <name> <path-to-sources-file> <repo-name> <path-to-repos-file>`<br/>
 Publishes the specified Source Catalog to the specified repository using the `path-to-?-file`s to retrieve required post information.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST sourcecatalog/request/publish<br/>
 &nbsp; &nbsp; with post data:
 * id=&lt;source-catalog-id&gt;
 * repositoryPath=&lt;cast-repo-path&gt;
 * label=&lt;repo-description&gt;
 * providerType=com.ccadllc.firebird.cast.sourcecatalog

 ---
 `editSourceCatalogByNameFromFileWithNewVersion <name> <path-to-input-file> <version>`<br/>
 Transistions the named catalog in input file from Published to Edit with the new version without changing the sources.<br/>
 Provides CAST Source Catalog operations via the following:<br/>
 &nbsp; &nbsp; POST sourcecatalog/update<br/>
 &nbsp; &nbsp; with post data:
 * _body=urlEncoded(xml-data)
 * __Content-Type=application/xml


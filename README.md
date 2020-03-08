X12 to JSON to DB Processor using Trace Transformer, Fuse 7.5, and Syndesis
====================================

This project demonstrates consuming a large X12 batch file and splitting it into multiple JSON transaction messages.  From there, we consume the multiple JSON messages of a queue and insert them as records into a database.

![](images/MAS.png "X12 to JSON to DB Flow")

## Prerequisites

- VSCode 1.4+
- OpenShift 4.2+
- Trace Transformer 7.4.6
- Fuse 7.5 Image Streams (template found [here](https://raw.githubusercontent.com/jboss-fuse/application-templates/master/fis-image-streams.json))

Firstly, start by downloading the registy key from [here](https://access.redhat.com/terms-based-registry/).  You will need a redhat.com login for this.  Create a new Registry Service Account for your OpenShift environment and import it using the following command:

```
oc project openshift
oc create -f blah-secret.yaml
oc secrets link default <pull_secret_name> --for=pull
oc secrets link builder <pull_secret_name>
```

Secondly, we need to update the Fuse image streams to Fuse 7.5:

```
export BASEURL=https://raw.githubusercontent.com/jboss-fuse/application-templates/master/fis-image-streams.json
oc apply -n openshift -f ${BASEURL}
```

Lastly, request an evaluation license from [Trace Financial](https://www.tracefinancial.com/contact-us).  For the purpose of this example, Transformer version 3.7.4 is assumed.  Once the Transformer tooling has been downloaded, please execute the following steps to copy the required files to your local Maven repository:

1. Copy <transformer-install-dir>\runtime\3.7.4\maven\transformer-runtime-skinny-3.7.4.jar to a temp directory

2. Copy <transformer-install-dir>\runtime\3.7.4\maven\transformer-runtime-skinny-3.7.4.pom to a temp directory

3. Copy <transformer-install-dir>\runtime\3.7.4\currency-lib to a temp directory

4. Generate a Trace runtime license JAR file and copy to a temp directory

5. Execute the following commands via the CLI to install the prerequisite JAR files in your local Maven repostiory:

```
mvn install:install-file -DgroupId=com.tracegroup.transformer -DartifactId=transformer-runtime-skinny -Dversion=3.7.4 -Dpackaging=pom -Dfile=transformer-runtime-skinny-3.7.4.pom.xml

mvn install:install-file -DgroupId=com.tracegroup.transformer -DartifactId=currencylib -Dversion=1.0.12 -Dfile=currencylib-1.0.12.jar -Dpackaging=jar

mvn install:install-file -DgroupId=com.tracegroup.transformer -DartifactId=RedHat.16122019.1.lic -Dversion=1.0.0 -Dfile=RedHat.16122019.1.lic.jar -Dpackaging=jar
```

5. Install the Trace Transformer sample project to your local Maven repository by executing the following command:

```
mvn install:install-file -DgroupId=com.tracefinancial.amadeus -DartifactId=amadeus -Dversion=1.0.0 -Dfile=amadeus-1.0.0.jar -Dpackaging=jar
```

## Deployment

This project can be deployed using the following method:

* On an Openshift 4.2+ environment using Fuse 7.5.

## Openshift Deployment

First, create a new OpenShift project called *rest-process-manager*

```
oc new-project rest-process-manager --description="Fuse REST Process Manager Demo" --display-name="REST Process Manager"
```

Execute the following command which will execute the *openshift* profile that executes the `clean fabric8:deploy` maven goal:

```
mvn -Popenshift
```

The fabric8 maven plugin will perform the following actions:

* Compiles and packages the Java artifact
* Creates the OpenShift API objects
* Starts a Source to Image (S2I) binary build using the previously packaged artifact
* Deploys the application using binary streams

## Expose the route via 3scale

As default, 3scale is installed and configured with SmartDiscovery enabled.  As a result, we need to expose our Fuse (Camel) RESTful service using 3scale.  Once the container is deployed, open 3scale and discover the new Fuse integration by clicking on *New API* and selecting *Import from OpenShift*.  

Enter the details for the new route as shown below:

![](images/3scale-integration-one.png "3scale Integration")

For the client test portion, be sure to setup an Application Plan, Publish then assign it to your Developer user.  This way, an API Key will be generated.  This is what the Client Test screen should look like:

![](images/client-test.png "Client Test")

## Swagger UI

A [Swagger User Interface](http://swagger.io/swagger-ui/) is available within the rest-process-manager application to view and invoke the available services.  Click the above route location (link), and append `/swagger-ui.html` when the page opens.  This should display the below Swagger interface:

The raw swagger definition can also be found at the context path `/camel-rest-3scale/api-doc`.  The swagger UI request window is illustrated by the following:

![](images/swagger-request.png "Swagger Request")

Finally, the response screen is below:

![](images/swagger-response.png "Swagger Response")

## Command Line Testing

Using a command line, execute the following to query the definition service

```
curl -X GET \
  'https://rest-process-manager-3scale-apicast-staging.apps.open.redhat.com:443/camel-rest-3scale/consumer-searchapi-web/subscribersearch?first=eddy&last=reagan&user_key=<enter 3scale userkey>' \
  -H 'Accept: */*' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Authorization: Bearer <insert auth token from above>'
```

A successful response will output the following

```json
{"networks": [{
   "networkId": "1000",
   "packages":    [
            {
         "name": "Signature",
```
...

```
INSERT INTO transaction_details (CommonAccessReference,MessageFunction,RecordLocator,TravellerSurname,FlightNumber,DepartureAirportCode,DepartureDateTime,ArrivalAirportCode,ArrivalDateTime,SpecialRequirementsType,SpecialRequirementsDetails) VALUES (:#CommonAccessReference,:#MessageFunction,:#RecordLocator,:#TravellerSurname,:#FlightNumber,:#DepartureAirportCode,:#DepartureDateTime,:#ArrivalAirportCode,:#ArrivalDateTime,:#SpecialRequirementsType,:#SpecialRequirementsDetails)
```
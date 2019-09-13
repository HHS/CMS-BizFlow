# HHS CMS BizFlow HR Tracking System
## (a.k.a. NEIL - Networking people with Enterprise systems & Information Link)

## System Components

* **database** : Database scripts for BIZFLOW schema and HHS_CMS_HR schema
* **deploy** : Deployment script, packaging script
* **java** : Custom-developed Java module
* **process** : Process definition, user group, BizCove/View/Menu
* **report** : Report export
* **ui** : UI form
* **webapps** : Web application, including BizFlow web solution, WebMaker runtime directory

## Java Module Build Instruction

### CMS PDF Module
CMS PDF module is used to generate PDF document attachment in BizFlow work item handler.  It is built using Java.  Apache ANT build script is used to generate the JAR file.  The module requires dependent library files and configuration files.  It will be deployed to WebMaker server directory.

#### Pre-requisite:
* JDK 1.7
* Apache Ant 1.9.x or later

#### Build Steps
1. Open command line interface, and change directory to the cmspdf module directory.

	cd java/cmspdf

1. Using a text editor, modify `cmspdf.properties` file in the cmspdf directory for the JDK location in the build machine.

	jdk.home.1.7=<full_path_to_jdk_1.7_home>

1. Run ANT script.

	ant -f cmspdf.xml

1. Capture the generated jar file.

	out/artifacts/lib/cmspdf.jar

1. Deploy the jar file onto the target tomcat location.

	<tomcat_dir>/webapps/bizflowwebmaker/WEB-INT/lib/

#### Static Files for the Initial Deployment
The following instructions are to deploy the dependent library files and configuration files for the cmspdf module.  They should be copied onto the target tomcat location along with the freshly built cmspdf.jar file.

Normally, the library files and configuration files will only need to be deployed once per environment.  Any subsequent code change to the module will require the rebuild and redeploy of the cmspdf.jar file only under normal circumstances.  If there is library change or configuration change, you need to refresh the changed files using the following steps.

1. Create PDF_Configuration directory onto the target tomcat location.

		mkdir <tomcat_dir>/webapps/bizflowwebmaker/WEB-INF/PDF_Configuration/

1. Copy the generated configuration files to the target location.
	* From (source repository):
		* out/artifacts/conf/*
	* To (target environment):
		* <tomcat_dir>/webapps/bizflowwebmaker/WEB-INF/PDF_Configuration/

1. Copy the generated configuration files to the target location.
	* From (source repository):
		* out/artifacts/conf/HWSessionFactory.properties
		* out/artifacts/conf/log4j.properties
	* To (target environment):
		* <tomcat_dir>/webapps/bizflowwebmaker/WEB-INF/classes/

1. Copy the library files to the target location.
	* From (source repository):
		* lib/activation-1.1.jar
		* lib/bcmail-jdk15on-1.54.jar
		* lib/bcpkix-jdk15on-1.54.jar
		* lib/bcprov-jdk15on-1.54.jar
		* lib/commons-collections-3.2.1-LICENSE.txt
		* lib/commons-collections-3.2.1.jar
		* lib/commons-logging-1.2.jar
		* lib/fontbox-2.0.4.jar
		* lib/hsfrmwk.jar
		* lib/hwjo.jar
		* lib/hwjsp.jar
		* lib/mail-1.4.jar
		* lib/pdfbox-2.0.4.jar
		* lib/pdfbox-app-2.0.4-sources.jar
		* lib/pdfbox-app-2.0.4.jar
		* lib/pdfbox-debugger-2.0.4.jar
		* lib/pdfbox-tools-2.0.4.jar
		* lib/rijndael-api.jar

	* To (target environment):
		* <tomcat_dir>/webapps/bizflowwebmaker/WEB-INF/lib/

	Note: WebMaker server contains the following libraries, which will be duplicate.  In such case, exclude those from cmspdf module.
		activation.jar
		commons-logging-1.1.1.jar
		mail.jar


## UI Module Packaging Instruction
UI modules are captured from DEV environment's web application directory, using ANT build file.  

The ANT build file will package the UI modules in a zip file.  Especially for WebMaker runtime files, the script will capture configuration files separately per environment, which will be deployed to the target environment appropriately by the deployment script later on.  The script also appends timestamp to the JavaScript and CSS file references in the web application files so that the web browser cache is forced to be refreshed at the first time loading after the new deployment.

### Pre-requisite on DEV Server:
* JDK/JRE 1.7
* Apache Ant 1.9.x or later
* Administrator (or sudo) access to DEV server machine
* UI modules are deployed and tested in DEV server, and ready for promotion to higher environments (e.g. QA and PROD)
	* WebMaker form runtime files
	* cmspdf files
	* BizFlow solution files

### Packaging Steps
1. Login to DEV server machine with an administrator (or sudo) account. 

1. In the command line prompt, create a work directory where files will be generated, and change directory to it.

	For example:

		mkdir -p work/deploy
		cd work/deploy

1. Copy UI packaging script to the deployment directory.
	
	* From (source repository):
		* deploy/build.xml
	* To (target environment):
		* <DEV_server_dir>/work/deploy/

1. Using a text editor, modify the following property value in the `build.xml` file for tomcat web application directory setting.  Specify the full path to the tomcat directory.

		<property name="webserver.dir" value="full_path_to_tomcat_directory" />
	

1. In the command line prompt, run ANT.  The following will execute the default target, which will generate a zip file.

		ant

1. Capture the generated zip file.  The packaging script will create the intermediate directories and generate the UI runtime zip file with timestamp suffix.  

	For example:

		<DEV_server_dir>/work/deploy/deployment/ui/runtime_20180201_132525.zip



## UI Module Deployment Instruction
UI modules are deployed to the higher environments (e.g. QA, PROD) using shell scripts.  

The deployment script will stop tomcat service, copy runtime files to tomcat web application directory, and start tomcat service.

1. Login to higher environment server machine with an administrator account. (Or, sudo to administrator account)

1. In the command line prompt, create a work directory where the deployment package file will be placed, and change directory to it.

	For example:

		mkdir -p work/deploy/baseline/ui
		cd work/deploy

1. Copy UI deployment script to the deployment directory.
	
	* From (source repository):
		* deploy/deploy_ui_qa.sh
	* To (target environment):
		* <DEV_server_dir>/work/deploy/

1. Using a text editor, modify the following property value in the build.xml for tomcat web application directory setting.  Specify the full path to the tomcat directory.

		DIR_DEPLOY=<full_path_to_deploy_baseline_directory_above>
		DIR_TOMCAT=<full_path_to_tomcat_directory>

1. In the command line prompt, make the UI deployment script mode executable.

	For example:

		chomod 744 deploy_ui_qa.sh

1. Copy UI deployment package file to the UI deployment directory.
	
	For example:

	* From (source repository):
		* runtime_20180201_132525.zip
	* To (target environment):
		* <DEV_server_dir>/work/deploy/baseline/ui

1. In the command line prompt, extract the UI runtime zip file.  If there is previous extract of runtime files, remove it before fresh extract.

	For example:

		cd baseline/ui
		rm -rf runtime
		unzip runtime_20180201_132525.zip

1. In the command line prompt, change directory back to the deployment directory, and run the deployment script.

	For example:

		cd <DEV_server_dir>/work/deploy
		./deploy_ui_qa.sh -nodebug

	Note: The deployment script has "-nodebug" option for real deployment action.  If you run the script without the option, it will try to test directory setting without actually deploying any file.  This is a precautionary measure to prevent accidental overwriting of the target application files.  In order to run the deployment script in "DEBUG" mode, i.e. without "-nodebug" option, a dummy script should be placed in the deployment directory.  Make sure the dummy script mode is executable.

	For example:
	* From (source repository):
		* deploy/script1.sh
	* To (target environment):
		* <DEV_server_dir>/work/deploy/
```
	chomod 744 script1.sh 
```

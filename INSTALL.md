INSTALLATION
===

Basic Instructions
---
The distribution has three subdirectories: `editor` (the Flex based KEfED editor), `reasoning` (the PowerLoom based reasoner) and `server` (the web application server). 

To get up and running quickly:

1. `cd editor`
2. `ant` - this builds the editor (look below for bug fixes if the system does not run). 
3. `cp dist/blazeds.war ../server/webapps/` - puts the built web app in the correct server subdirectory
4. `cd ../server`
5. `ant`
6. `java -jar dist/installers/install-BioScholarServer-1.0.4.jar`
	- Follow the instructions in the installer
7. `open BioScholarServer.app` - will run the launcher but will fail after a short period of time. 
	- It is better to copy the `*.war` files into a Tomcat container and run the web application from there. 
	- We will be incorporating features of this BioScholar implementation in future releases but we will not be supporting this version going forward.

Bug fixes
---

- You will need an installed version of Adobe's `Flex 4.6` for this current distribution.  
- This code was written for `Flex 3.5`. Building the system under for `Flex 4.x` with `ant`, will encounter an error: 

```
The class not found in jar file: mxmlc.jar
```

To fix this, simply copy the you will need to copy the `flex_ant/lib/flexTasks.jar` file from the Flex 4 SDK distribution to Ant's lib directory ({ant_root}/lib) replacing the existing `flexTasks.jar`. 

- Make sure you have `launch4j` installed with a version greater than 3.1.
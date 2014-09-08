BioScholar System
===

The 'BioScholar' system was first described in our BMC Bioinformatics paper ([Russ et al. 2011](http://www.biomedcentral.com/1471-2105/12/351)) as the first full implementation of a KEfED model. ('KEfED' stands for 'Knowledge Engineering from Experimental Design' and is our approach to represent experimental observations with little or no additional domain-specific interpretation). **BioScholar** itself, is intended to be an experimental knowledge management system curated from the scientific literature and specifically targeted to support early-stage biomedical researchers (graduate students and postdocs) in facing the very first research challenge that they face: making sense of the very large amount of existing knowledge in the literature.

Installing the BioScholar System source code.
---

This is a slightly involved process, since there are several dependencies that need to be installed in order using Maven.  

### Prerequisites 

#### For execution only

* Maven (version 3+)
* Git (naturally)

#### For development

* Recommend use of the Spring Tool Suite as a development environment 
* Client development is based on Flex (which is problematic since Adobe is no longer developing this language). We have not yet migrated to the open source version from Apache but are using Adobe Flex 4.5.1. This is due to maintaining stability for our established code base going forward.  

### Installing the submodules

Note that in the current installation process we skip unit tests. This is less than ideal but reflects the 'alpha' nature of the current development version. 

1. build the parent projects 
  * (*these provide version numbers and maven respositories for upload*)  
  2. `cd bmkeg-parent`; `mvn -DskipTests clean install`
  3. `cd bmkeg-as-parent`; `mvn -DskipTests clean install`
1. build the `vpdmf-bioscholar` project (*this generates a mysql database with local java and actionscript libraries for the systems data model using the `VPDMf` system*)  
  2. `cd vpdmf-bioscholar`; `mvn -DskipTests clean install`
1.  

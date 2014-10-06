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
* MySQL version 5+
* Java 7
* Flex 4.5.1

### Installing the project

Note that in the current installation process we skip unit tests. This is less than ideal but reflects the 'alpha' nature of the current development version. Note that this process may take a long time. 

```
1. git clone --recursive https://github.com/BMKEG/bioscholarProject/
2. cd bioscholarProject
3. mvn -DskipTests clean install
```

> **IMPORTANT** Due to licensing restrictions of a subcomponent library, this build will currently **fail** with the `kefedClientComponent` submodule. We are working to switch out the offending library as a priority and will present a fully open source version as soon as possible. 


### Running the project
```
1. cd bioscholar
3. mvn jetty:start
```




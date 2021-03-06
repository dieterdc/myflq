#MyFLq version 1.0 
[My Forensic Loci queries]

Open source, straightforward analysis tool for forensic DNA samples.

The tool expects a loci csv-file (similar to [loci.csv](https://github.com/beukueb/myflq/blob/master/src/loci/myflqpaper_loci.csv)), a validated-allele csv-file for all the included loci  (similar to [alleles.csv](https://github.com/beukueb/myflq/blob/master/src/alleles/myflqpaper_alleles.csv)) and a fast[a/q] datafile, whereupon the datafile's profile is extracted. To download the loci.csv and alleles.csv files, right-click the 'RAW' button and choose 'save as...'. These files can be opened using a regular text editor such as 'Textpad' (Windows) or 'gedit' (Linux).

The datafile can be a single-individual-source or multiple-individual-source sample. Profile results depend on both csv files. Loci.csv will determine the number of loci that will be analyzed; alleles.csv will determine the region of interest [ROI] of those loci.

## Options for running MyFLq
### From the Github repo
Initial setup:

    git clone https://github.com/beukueb/myflq.git
    cd myflq/src/MyFLsite/
    python3 manage.py syncdb

For the above to work all dependencies need to be installed, and a MySQL database needs to be prepared. Detailed instructions are in src/MyFLsite/documentation.

To start the webapp:

    sudo systemctl start rabbitmq
    celery -A MyFLsite worker -l info &
    python3 manage.py runserver 0.0.0.0:8000


### As a Docker container
Another option is, after installing [Docker](https://www.docker.io/), to pull and start the MyFLq container on your server with the following command:

    sudo docker run -p 0.0.0.0:80:8000 -i -t --entrypoint webapp beukueb/myflq

If you want the webapp to run on another port than the standard webport 80, change that in the commandline.

MyFLq will then run as a local web application on the indicated port.

### Illumina BaseSpace
MyFLq is also accessible directly from the Illumina BaseSpace environment.

#### Custom loci.csv and alleles.csv
When custom loci.csv and alleles.csv are required on BaseSpace, one can submit them on [MyFLhub](https://github.com/beukueb/myflq) (MyFLq repo on Github) with a pull request (ask a bioinformatician to help if you don't know how). The program will then be rebuild, and your files will be available to select within 24 hours.

If you do not want those files to be public, you can copy paste them into the respective textbox in the input form. In this case pay close attention to the format of your *.csv files. There should not be any whitespace, unless at the end of a line or within a commented line. The easiest way to achieve this is to open your .csv file in a standard text editor of your choice (e.g. 'Textpad' in Windows or 'gedit' in Linux), to select (CTRL+A) and copy (CTRL+C) its entire contents and to paste them (CTRL+V) in the allocated text field on BaseSpace MyFLq (see 'Choose input settings' below).

When choosing to use custom loci and alleles input files, you have to make sure that both files contain information for the same loci/alleles. That is, the alleles.csv file needs to contain only allele information for every locus specified in the loci.csv file and vice versa. If this is not the case, an error will be generated. 

In the future it will be possible to upload files (e.g. small csv's) to your BaseSpace projects. At that time you will be able to select personal files.

##Workflow on BaseSpace MyFLq
To start the app on BaseSpace simply launch it, which will direct you to the input form.

###Choose input settings

- Choose a sensible name or leave the default with date/time
- Select loci set.  
  The options are links to loci.csv-files that have been shared by users on [MyFLhub](htt\
ps://github.com/beukueb/myflq). You can also copy paste your custom file in the textbox.
- Select allele database.  
  These are instead links to the alleles.csv-files. You can copy paste your custom file in the textbox.
- Sample: select the fastq (or fasta?) file for analysis.  
  The fastq can be either single-end or paired-end and should be available on BaseSpace.
- Save results to: the project where your results will be saved.
- General options for analysis:
 - *Threshold*  
   Unique reads with an abundance lower than this value (in %), are discarded. It is reported in the locus stats how many reads were discarded in this way.
 - *Preview*  
   Analyzing very big fastq's can take a considerable amount of time. If you want a quick preview, select a random percentage of the file to analyze. For low values (2-10%), this will give you a quick analysis of the profile. If at this point all alleles indicate a clear single contributor and have at least 1000 reads per locus, it is probably not necessary to do an analysis on the full file.
- Alignment options  
  Different types of alignments occur during the process of analysis. With these options you can influence the processing.
 - *Primer buffer*  
   The number of bases at the end of the primer that will not be used for assigning the reads to loci. Choosing a higher buffer therefore means the locus assignment could be slightly less specific, but more reads will get assigned. Is there a recommended maximum setting?
 - *Stutter buffer*  
   The stutters of the smallest allele for a locus are normally not in the database, and could have a negative-length ROI. Default value of this buffer is 1 to accomodate that. This allows all stutters to be seen as flanking out is performed with a flank 1 repeat unit smaller.
 - *Flankout*  
   If you see a large amount of negative reads (where do you see these?) in the analysis, or a high abundant unique read with very poor flanks, turn this feature off. The analysis will then be done between the primers. Previously unknown alleles can be discovered this way.
 - *Homopolymers compressed*  
   Long homopolymers in the flanks could stutter during PCR. This option annotates flanks of loci that were possibly affected by this.
 - *Flankout by alignment*  
   If this option is activated, flanks are removed with our alignment algorithm, instead of the k-mer based flexible flanking.

After selecting options, launch analysis.

###Review results.
When the analysis is done, BaseSpace will have automatically made a report with all the results. This report can be found in the project folder in which your results were saved.  

The report primarily shows the visual profile. Initially it shows the overview of all analyzed loci. 

Functionality:

- On the X-axis (with the loci names), you can zoom in and move the axis to go over all the loci.
- Putting the mouse on an allele candidate bar, shows all information for that candidate. Clicking on a bar from an allele candidate that has an abundance higher than the threshold, will deselect it from the profile. Sequence aberrations can be removed by doing so.
- Selecting 'Absolute length' in the settings, will reorganize the graph. All allele candidates will now be plotted within each locus proportionate to their sequence length.
- Pushing 'Make profile' generates a table in a new window that contains only the allele candidates that were present with an abundance higher than the threshold and were not manually deselected from the profile.

Suggested steps:

- Set the threshold to a level appropriate for the sample noise.
- Inspect each red allele (unknown in the database), that is still higher in abundance than the threshold. If the abundance is not far removed from the threshold and the stats indicate poor quality, deselect them from the profile.
- In case it is known to be a single contributor sample, closely inspect all sequences from loci that have more than 2 alleles.

###Make profile and save it locally
- After reviewing all loci, click "Make profile".
- A new browser window will open with all the alleles in the profile. Save it locally by selecting 'Save as...' form your browser's 'File' menu.
  (For now it is not possible to save it in your project, so choose a filename that refers to the project/result.) 
- If there is a locus with more than two alleles, it is indicated that based on the threshold this profile derives from a multi-contributor sample. If there is maximum two alleles per locus, the probability of that profile can be retrieved from the [ENFSI STRbase](http://strbase.org/) site.

###Test files
Click [here](https://cloud-hoth.illumina.com/s/6nsamiEr4SNk) to get access to a project with forensic samples that can be used to try out MyFLq.
  
##More information
- Original paper: [My-Forensic-Loci-queries (MyFLq) framework for analysis of forensic STR data generated by massive parallel sequencing](http://dx.doi.org/10.1016/j.fsigen.2013.10.012)

# Counting Sheep PSG

EEGLAB-compatible sleep scoring, signl processing and event marking

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.  

## Prerequisites

Mac, PC and Linux compatible.  
Designed for use with EEGLAB 2019 or later (https://eeglab.org) on Matlab R2019a.  
For use on continuous EEGLAB datasets (*.set).  

Works best if recording includes (in the EEG.event structure):  
* Recording start time event (at first data point)
* Lights Off and Lights On events

## Installing

Simply unzip 'countingSheepPSG' and add to Matlab path.  
Alternatively, unzip and move folder to '~/eeglab/plugins/' directory for EEGLAB GUI integration.  

## Usage

### Supported Data Formats:

* EEGLAB Datasets
* European Data Format (EDF)
* Brain Products

### Sleep Scoring Keyboard Shortcuts:

* 0 - Wake
* 1 - NREM 1
* 2 - NREM 2
* 3 - SWS
* 4 - REM
* . - Unscored

### Event Marking Mode:

* Single point events can be created using single-click
* Events with a duration can be created using single-click (start) + shift-click (end)
* Single-click existing event to select for Delete
* Note: keyboard shortcuts do not work in event marking mode

### Signal processing (using built-in EEGlab functions)

* downsampling
* filtering
* re-refenrencing
* channel edit

### Automatic Event Detection:

* Automatic movement artifact detection
* Automatic spindle detection (using EEGlab 'detect_spindles' plugin)
* Automatic slow wave detection (using EEGlab 'PAA' plugin)
    
## Authors

Sleep Well & Stuart Fogel.  
School of Psychology, University of Ottawa, Canada.  
uOttawa Sleep Research Laboratory.  

A revision of sleepSMG. sleepSMG originally developed by:  
Stephanie Greer and Jared Saletin.  
Walker Lab, UC Berekeley, 2011.  
https://sleepsmg.sourceforge.net  
https://www.jaredsaletin.org/hume  

## Contact 

https://socialsciences.uottawa.ca/sleep-lab/  
https://www.sleepwellpsg.com  
sfogel@uottawa.ca  

## License

Copyright (C) Stuart Fogel & Sleep Well, 2022.  
See the GNU General Public License v3.0 for more details.

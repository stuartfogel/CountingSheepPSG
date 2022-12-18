# Counting Sheep PSG

EEGlab-compatible sleep scoring and event marking

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

## Prerequisites

Mac, PC and Linux compatible.  
Designed for use with EEGlab 2019 or later (https://eeglab.org) on Matlab R2019a.  
For use on continuous eeglab datasets (*.set).  

Works best if recording includes (in the EEG.event structure):  
* Recording start time event (at first data point)
* Lights Off and Lights On events

## Installing

Simply unzip 'countingSheepPSG' and add to Matlab path.

## Usage

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
Note: keyboard shortcuts do not work in event marking mode
    
## Authors

Sleep Well & Stuart Fogel.  
Stuart Fogel.  
School of Psychology, University of Ottawa, Canada.  
uOttawa Sleep Research Laboratory.  

A revision of sleepSMG. sleepSMG originally developed by:  
Stephanie Greer and Jared Saletin.  
Walker Lab, UC Berekeley, 2011.  
https://sleepsmg.sourceforge.net  

https://www.jaredsaletin.org/hume  

## Contact 

https://socialsciences.uottawa.ca/sleep-lab/  

sfogel@uottawa.ca  

https://www.sleepwellpsg.com  

## License

Copyright (C) Sleep Well, 2022.  
See the GNU General Public License v3.0 for more details.

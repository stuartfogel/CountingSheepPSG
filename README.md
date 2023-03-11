# Counting Sheep PSG

EEGLAB-compatible manual sleep stage scoring, signal processing and event marking for polysomnographic (PSG) data

![screenshot](https://user-images.githubusercontent.com/8634128/219664342-3e338ef9-6ed1-4884-b0b8-6aa0997209c1.jpg)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.  

## Prerequisites

Mac, PC and Linux compatible.  
Designed for use with EEGLAB 2020 or later (https://eeglab.org) on Matlab R2020b or later.  
For use on continuous EEGLAB datasets (*.set).  

Works best if recording includes (in the EEG.event structure):  
* Recording start time event (at first data point)
* Lights Off and Lights On events

## Installing

Simply unzip 'countingSheepPSG' and add to Matlab path.  
Alternatively, unzip and move folder to '~/eeglab/plugins/' directory for EEGLAB GUI integration.  

## Usage

* Customize display montage in:
* ~/montages/sleep_montage_default.m (rename and save to new file)
* Loads an EEGlab PSG dataset for signal preprocessing and annnotation

### Supported Data Formats:

* EEGLAB Datasets (default)
* European Data Format (EDF)
* Brain Products Format (VHDR)

### Sleep Scoring Keyboard Shortcuts:

* 0 - Wake
* 1 - NREM 1
* 2 - NREM 2
* 3 - SWS
* 4 - REM
* . - Unscored
* backspace/delete - delete seelcted event(s)

### Event Marking Mode:

* Single-point events can be created using single mouse click
* Events with a duration can be created using mouse click-and-drag
* Enable 'all channels' mode to mark events without a channel
* Single-click existing event to select/deselect for delete/merge

### Signal processing (using built-in EEGlab functions)

* interpolate bad channels
* downsampling
* filtering
* re-referencing
* channel edit (beta)

### Automatic Event Detection:

* Automatic movement artifact detection
* Automatic spindle detection (using EEGlab 'detect_spindles' plugin)
* Automatic slow wave detection (using EEGlab 'PAA' plugin)
* Automatic rapid eye movement detection (coming soon...)
    
## Authors

Stuart Fogel & Sleep Well.  
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
See the GNU General Public License v3.0 for more information.

This file is part of 'Counting Sheep PSG'.
See https://github.com/stuartfogel/CountingSheepPSG for details.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above author, license,
copyright notice, this list of conditions, and the following disclaimer.

2. Redistributions in binary form must reproduce the above author, license,
copyright notice, this list of conditions, and the following disclaimer in 
the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Counting Sheep PSG is intended for research purposes only. Any commercial 
or medical use of this software and source code is strictly prohibited.
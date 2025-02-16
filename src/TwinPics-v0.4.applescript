use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use script "Dialog Toolkit Plus" version "1.1.3"
use script "PrefsStorageLib" version "1.1.0"

-- Initialize default values
prepare storage for domain "com.dityan.twinpics" default values {variationSelected:"B&W / Color", selectedPreset:"", TwinPicsOn:false, VariantType:"", viewSelection:"A", TwinPickeywords:"Twin"}

property variationTypes : {"Flat Raw", "B&W / Color", "Preset"}
property TwinPickeywords : {}
property presetList : {}

-- Load saved values
set variationSelected to value for key "variationSelected"
set selectedPreset to value for key "selectedPreset"
set TwinPicsOn to value for key "TwinPicsOn"
set VariantTypes to {"new variant", "clone variant"}
set viewSelection to value for key "viewSelection"
set VariantType to value for key "VariantType"
set TwinPickeywords to value for key "TwinPickeywords"

-- Convert TwinPickeyword list to comma-separated string for display
set keywordsString to my listToString(TwinPickeywords, ", ")

tell application "Capture One"
	set presetList to available styles
end tell

set windowTitle to "..:: TwinPics - settings ::.."
set accViewWidth to 320
set spacer to 10
set theTop to spacer

set {theButtons, minWidth} to create buttons {"Cancel", "SAVE"} default button 2 given «class btns»:2
if minWidth > accViewWidth then set accViewWidth to minWidth -- make sure buttons fit

-- Create dialog window
set {createdByLabel, theTop} to create label "* created by yan senez - 2024 - v 0.4 - www.dityan.com *" bottom (0) max width accViewWidth control size small size aligns center aligned without bold type
set {theRule2, theTop} to create rule (theTop + spacer) rule width accViewWidth
set {keywords_Field, keywords_Label, theTop} to create top labeled field keywordsString bottom (theTop + spacer) field width accViewWidth label text "Keyword tag (separate with commas):" left inset 0 without accepts linebreak and tab
set {theMatrixViewValue, theTop} to create matrix {"A", "B", "A&B"} left inset 0 bottom (theTop + spacer) max width accViewWidth initial choice viewSelection without arranged vertically
set {ViewerLabel, theTop} to create label "Twin selected in the viewer:" bottom (theTop + spacer) max width accViewWidth aligns left aligned without bold type
set {PresetPopup, PresetList_Label, theTop} to create labeled popup presetList bottom (theTop + spacer) popup width accViewWidth / 2 + 50 max width accViewWidth / 2 label text "Choose preset :" popup left 0 left inset 0 initial choice selectedPreset
set {theMatrixValue, theTop} to create matrix variationTypes left inset 0 bottom (theTop + spacer) max width accViewWidth initial choice variationSelected without arranged vertically
set {theMatrixLabel, theTop} to create label "Twin adjustments : " bottom (theTop + spacer) max width accViewWidth aligns left aligned without bold type
set {theMatrixValue2, theTop} to create matrix VariantTypes left inset 0 bottom (theTop + spacer) max width accViewWidth initial choice VariantType without arranged vertically
set {VariantTypeLabel, theTop} to create label "Twin Type : " bottom (theTop + spacer) max width accViewWidth aligns left aligned without bold type

set {theRule1, theTop} to create rule (theTop + spacer) rule width accViewWidth
if TwinPicsOn is true then
	set {TwinPicsOnCheckbox, unusedTop, newWidth} to create checkbox "ON" bottom (theTop + spacer) max width accViewWidth / 4 - 10 left inset 0 with initial state
else
	set {TwinPicsOnCheckbox, unusedTop, newWidth} to create checkbox "ON" bottom (theTop + spacer) max width accViewWidth / 4 - 10 left inset 0 without initial state
end if
set {boldLabel, theTop} to create label "-:| TwinPics |:-" bottom theTop + 10 max width accViewWidth control size large size aligns right aligned with bold type

set allControls to {keywords_Field, keywords_Label, theMatrixViewValue, ViewerLabel, theMatrixLabel, VariantTypeLabel, theMatrixValue, TwinPicsOnCheckbox, theRule2, createdByLabel, PresetPopup, PresetList_Label, theMatrixValue2, boldLabel, theRule1}
set {buttonName, controlsResults} to display enhanced window windowTitle acc view width accViewWidth acc view height theTop acc view controls allControls buttons theButtons with align cancel button

if buttonName is "SAVE" then
	try
		set variationSelected to item 7 of controlsResults
		set selectedPreset to item 11 of controlsResults
		set TwinPicsOn to item 8 of controlsResults
		set VariantType to item 13 of controlsResults
		set viewSelection to item 3 of controlsResults
		set keywordsString to item 1 of controlsResults
		
		-- Convert keywords string to list
		set TwinPickeywords to my stringToList(keywordsString, ",")
	on error errMsg number errNum
		display dialog "Error getting values from controlsResults: " & errMsg
	end try
	
	-- Save values to storage
	assign value variationSelected to key "variationSelected"
	assign value selectedPreset to key "selectedPreset"
	assign value TwinPicsOn to key "TwinPicsOn"
	assign value VariantType to key "VariantType"
	assign value viewSelection to key "viewSelection"
	assign value TwinPickeywords to key "TwinPickeywords"
	
	-- Handle background script
	if TwinPicsOn is true then
		try
			-- Define Background Scripts directory
			set destinationFolder to (POSIX path of (path to library folder from user domain)) & "Scripts/Capture One Scripts/Background Scripts/"
			-- Create directory if it doesn't exist
			do shell script "mkdir -p " & quoted form of destinationFolder
			
			-- Create the background script content
			set backgroundScript to "use AppleScript version \"2.4\"
use scripting additions
use script \"PrefsStorageLib\" version \"1.1.0\"

prepare storage for domain \"com.dityan.twinpics\"

on CO_CaptureDone(rawFilePath)
    prepare storage for domain \"com.dityan.twinpics\"
    set TwinPicsOn to value for key \"TwinPicsOn\"
    if TwinPicsOn is true then
        createVariant(rawFilePath)
    end if
end CO_CaptureDone

on createVariant(rawFilePath)
    prepare storage for domain \"com.dityan.twinpics\"
    set {variationSelected, selectedPreset, TwinPicsOn, viewSelection, VariantType, TwinPickeywords} to ¬
        {value for key \"variationSelected\", value for key \"selectedPreset\", value for key \"TwinPicsOn\", ¬
            value for key \"viewSelection\", value for key \"VariantType\", value for key \"TwinPickeywords\"}
    
    tell application \"Capture One\"
        set theImage to (first image whose path is rawFilePath)
        
        if VariantType is \"new variant\" then
            set twinpic to add variant of theImage without additive select
        else if VariantType is \"clone variant\" then
            set twinpic to clone variant of first variant of theImage without additive select
        end if
        
        set {theAvariant, theBvariant} to {variant 1 of theImage, variant 2 of theImage}
        
        deselect current document variants (variants)
        if viewSelection is \"A&B\" then
            select current document variants {theAvariant, theBvariant}
        else if viewSelection is \"B\" then
            select current document variants {theBvariant}
        else if viewSelection is \"A\" then
            select current document variants {theAvariant}
        end if
        
        if variationSelected is \"B&W / Color\" then
            set BWBoolean to black and white of adjustments of theAvariant
            set black and white of adjustments of theBvariant to not BWBoolean
        else if variationSelected is \"Flat Raw\" then
            set theCrop to crop of theAvariant
            reset adjustments of theBvariant
            if VariantType is not \"new variant\" then
                set crop of theBvariant to theCrop
            end if
        else if variationSelected is \"Preset\" then
            tell theBvariant
                apply style current layer named selectedPreset
            end tell
        end if
        
        set selectedVariants to (get selected variants)
        
        repeat with picWord in TwinPickeywords
            tell current document
                if exists keyword picWord then
                    set TwinPicKeyword to keyword picWord
                else
                    tell item 1 of selectedVariants to set TwinPicKeyword to make new keyword with properties {name:picWord}
                end if
                try
                    apply keyword TwinPicKeyword to selectedVariants
                end try
            end tell
        end repeat
        
    end tell
end createVariant"
			
			-- Write the background script file
			set destinationPath to destinationFolder & "TwinPicsOnBackground.applescript"
			do shell script "echo " & quoted form of backgroundScript & " > " & quoted form of destinationPath
			
		on error errMsg number errNum
			display dialog "Error creating background script: " & errMsg
		end try
	else
		try
			-- Remove background script if TwinPics is turned off
			set destinationFolder to (POSIX path of (path to library folder from user domain)) & "Scripts/Capture One Scripts/Background Scripts/"
			set destinationPath to destinationFolder & "TwinPicsOnBackground.applescript"
			do shell script "rm -f " & quoted form of destinationPath
		on error errMsg number errNum
			display dialog "Error removing background script: " & errMsg
		end try
	end if
end if

-- Helper functions for string/list conversion
on listToString(theList, delimiter)
	set {TID, text item delimiters} to {text item delimiters, delimiter}
	set theString to theList as text
	set text item delimiters to TID
	return theString
end listToString

on stringToList(theString, delimiter)
	set {TID, text item delimiters} to {text item delimiters, delimiter}
	set theList to text items of theString
	set text item delimiters to TID
	return theList
end stringToList

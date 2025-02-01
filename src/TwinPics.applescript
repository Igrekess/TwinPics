use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use script "Dialog Toolkit Plus" version "1.1.3"
use script "PrefsStorageLib" version "1.1.0"

-- Initialiser les valeurs par défaut
prepare storage for domain "com.yse.twinpics" default values {variationSelected:"B&W / Color", selectedPreset:"", TwinPicsOn:false, VariantType:"", viewSelection:"A", TwinPickeywords:"Twin"}

property variationTypes : {"Flat Raw", "B&W / Color", "Preset"}
property TwinPickeywords : {}
property presetList : {}

-- Charger les valeurs enregistrées
set variationSelected to value for key "variationSelected"
set selectedPreset to value for key "selectedPreset"
set TwinPicsOn to value for key "TwinPicsOn"
set VariantTypes to {"new variant", "clone variant"}
set viewSelection to value for key "viewSelection"
set VariantType to value for key "VariantType"
set TwinPickeywords to value for key "TwinPickeywords"

-- Convertir la liste de TwinPickeyword en une chaîne de mots-clés séparés par des virgules pour l'affichage
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
-- Créer la fenêtre de dialogue
set {createdByLabel, theTop} to create label "* created by yan senez - 2024 - v 0.2 - www.dityse.com *" bottom (0) max width accViewWidth control size small size aligns center aligned without bold type
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
		
		-- Convertir la chaîne de mots-clés en liste
		set TwinPickeywords to my stringToList(keywordsString, ",")
	on error errMsg number errNum
		display dialog "Erreur lors de l'obtention des valeurs dans controlsResults : " & errMsg
	end try
	
	-- Enregistrement des valeurs dans le stockage si SAVE
	assign value variationSelected to key "variationSelected"
	assign value selectedPreset to key "selectedPreset"
	assign value TwinPicsOn to key "TwinPicsOn"
	assign value VariantType to key "VariantType"
	assign value viewSelection to key "viewSelection"
	assign value TwinPickeywords to key "TwinPickeywords"
	
	-- Gestion de twinPicsOnBackground :
	-- Si TwinPics est activé, copier le script twinPicsOnBackground dans le répertoire Background.
	-- Sinon, le supprimer.
	--
	-- Remarque : Adaptez "destinationFolder" à l'emplacement du répertoire Background utilisé par Capture One.
	if TwinPicsOn is true then
		try
			-- Récupérer le chemin du bundle de TwinPics
			set bundlePath to (path to me) as text
			-- On suppose que le script twinPicsOnBackground est rangé dans le dossier "Contents:Resources:" du bundle
			set sourceFilePath to bundlePath & "Contents:Resources:TwinPicsOnBackground.applescript"
			set sourcePath to POSIX path of sourceFilePath
			
			-- Définir le répertoire Background dans ~/Library/Scripts/Capture One Scripts/Background Scripts/
			set destinationFolder to (POSIX path of (path to library folder from user domain)) & "Scripts/Capture One Scripts/Background Scripts/"
			set destinationPath to destinationFolder & "TwinPicsOnBackground.applescript"
			
			-- Copier le script dans le répertoire Background
			do shell script "cp -f " & quoted form of sourcePath & " " & quoted form of destinationPath
		on error errMsg number errNum
			display dialog "Erreur lors de la copie de twinPicsOnBackground dans le répertoire Background: " & errMsg
		end try
	else
		try
			-- Définir le répertoire Background dans ~/Library/Scripts/Capture One Scripts/Background Scripts/
			set destinationFolder to (POSIX path of (path to library folder from user domain)) & "Scripts/Capture One Scripts/Background Scripts/"
			set destinationPath to destinationFolder & "TwinPicsOnBackground.applescript"
			
			-- Supprimer le script du répertoire Background
			do shell script "rm -f " & quoted form of destinationPath
		on error errMsg number errNum
			display dialog "Erreur lors de la suppression de twinPicsOnBackground du répertoire Background: " & errMsg
		end try
	end if
	
	-- (Optionnel) Vous pouvez ajouter ici un retour ou une confirmation.
end if

-- Fonction pour convertir une liste en chaîne de texte avec des virgules
on listToString(theList, delimiter)
	set {TID, text item delimiters} to {text item delimiters, delimiter}
	set theString to theList as text
	set text item delimiters to TID
	return theString
end listToString

-- Fonction pour convertir une chaîne de texte en liste en utilisant une virgule comme séparateur
on stringToList(theString, delimiter)
	set {TID, text item delimiters} to {text item delimiters, delimiter}
	set theList to text items of theString
	set text item delimiters to TID
	return theList
end stringToList

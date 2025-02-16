--
--	Created by: Yan Senez
--	Created on: 04/11/2024
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use script "PrefsStorageLib" version "1.1.0"

prepare storage for domain "com.dityan.twinpics"
set variationSelected to value for key "variationSelected"
set selectedPreset to value for key "selectedPreset"
set TwinPicsOn to value for key "TwinPicsOn"
set variationSelected to value for key "variationSelected"
set TwinPickeywords to value for key "TwinPickeywords"
--set TwinPickeywords to {}

repeat with kwords in TwinPickeywords
	log kwords
end repeat


on CO_CaptureDone(rawFilePath)
	prepare storage for domain "com.dityan.twinpics"
	set variationSelected to value for key "variationSelected"
	set selectedPreset to value for key "selectedPreset"
	set TwinPicsOn to value for key "TwinPicsOn"
	if TwinPicsOn is true then
		createVariant(rawFilePath)
	end if
end CO_CaptureDone

on createVariant(rawFilePath)
	prepare storage for domain "com.yse.twinpics"
	set {variationSelected, selectedPreset, TwinPicsOn, viewSelection, VariantType, TwinPickeywords} to ¬
		{value for key "variationSelected", value for key "selectedPreset", value for key "TwinPicsOn", ¬
			value for key "viewSelection", value for key "VariantType", value for key "TwinPickeywords"}
	
	tell application "Capture One"
		set theImage to (first image whose path is rawFilePath)
		
		-- Création de la variante
		if VariantType is "new variant" then
			set twinpic to add variant of theImage without additive select
		else if VariantType is "clone variant" then
			set twinpic to clone variant of first variant of theImage without additive select
		end if
		
		-- Gestion des références aux variantes
		set {theAvariant, theBvariant} to {variant 1 of theImage, variant 2 of theImage}
		
		-- Gestion de la sélection
		deselect current document variants (variants)
		if viewSelection is "A&B" then
			select current document variants {theAvariant, theBvariant}
		else if viewSelection is "B" then
			select current document variants {theBvariant}
		else if viewSelection is "A" then
			select current document variants {theAvariant}
		end if
		
		-- Application des ajustements
		if variationSelected is "B&W / Color" then
			set BWBoolean to black and white of adjustments of theAvariant
			set black and white of adjustments of theBvariant to not BWBoolean
		else if variationSelected is "Flat Raw" then
			set theCrop to crop of theAvariant
			reset adjustments of theBvariant
			if VariantType is not "new variant" then
				set crop of theBvariant to theCrop
			end if
		else if variationSelected is "Preset" then
			tell theBvariant
				apply style current layer named selectedPreset
			end tell
		end if
		
		-- Obtenir la liste des variantes sélectionnées
		set selectedVariants to (get selected variants)
		
		repeat with picWord in TwinPickeywords
			log "Applying keyword :" & picWord
			
			-- Récupérer ou créer le mot-clé
			tell current document
				if exists keyword picWord then
					set TwinPicKeyword to keyword picWord
				else
					-- Créer le mot-clé dans la première variante sélectionnée
					tell item 1 of selectedVariants to set TwinPicKeyword to make new keyword with properties {name:picWord}
				end if
				-- Appliquer le mot-clé à toutes les variantes sélectionnées
				try
					apply keyword TwinPicKeyword to selectedVariants
				end try
			end tell
		end repeat
		
	end tell
end createVariant



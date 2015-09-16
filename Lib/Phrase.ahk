; Licensed under The MIT License (MIT), see: http://opensource.org/licenses/MIT
; Copyright (c) 2015 Nicolas Schneider
; Version: 1.0, Date: 09.09.2015
class Phrase {

	static DEFAULT_KEY_BEGIN := "{"
	static DEFAULT_KEY_END := "}"
	parts := Object()
	keys := Object()
	template := ""
	keyBegin := Phrase.DEFAULT_KEY_BEGIN
	keyEnd := Phrase.DEFAULT_KEY_END

	; When you want to use custom delimiters, provide an array with two entries.
	; Each must be a single character, the first one is the key begin character,
	; the second one the key end character.
	from(template, delimiters = "") {
		return new Phrase(template, delimiters)
	}

	__New(template, delimiters = "") {
		this.template := template
		if (template == "") {
			throw Exception("EmptyTemplate")
		}
		if (delimiters != "" && !isObject(delimiters)) {
			if (StrLen(delimiters) != 2) {
				throw Exception("IllegalKeyDelimiters", -1, "Delimiters must be a string of length 2!")
			}
			StringSplit, delims, delimiters
			delimiters := [delims1, delims2]
		}
		if (isObject(delimiters)) {
			if (delimiters.MaxIndex() != 2) {
				throw Exception("IllegalKeyDelimiters", -1, "Delimiters must be an array of length 2!")
			}
			if (StrLen(delimiters[1]) != 1) {
				throw Exception("IllegalKeyDelimiters", -1, "First delimiter must be a single character!")
			}
			if (StrLen(delimiters[2]) != 1) {
				throw Exception("IllegalKeyDelimiters", -1, "Second delimiter must be a single character!")
			}
			if (delimiters[1] == delimiters[2]) {
				throw Exception("IllegalKeyDelimiters", -1, "Key begin and key end must not be the same character!")
			}
			this.keyBegin := delimiters[1]
			this.keyEnd := delimiters[2]
		}
		this.parse()
	}

	put(key, value) {
		if (!this.keys.hasKey(key)) {
			throw Exception("KeyNotFound", -1, "Key """ . key . """ not found in template: " . this.template)
		}
		this.keys[key].value := value
		return this
	}

	putAll(map) {
		for key, value in map {
			this.put(key, value)
		}
		return this
	}

	format() {
		string := ""
		for index, part in this.parts {
			if (part.isKey()) {
				if (part.value = "") {
					throw Exception("KeyNotSet", -1, "Key """ . part.keyId . """ not set")
				}
				string .= part.value
			} else {
				if (part.length) {
					string .= SubStr(this.template, part.offset, part.length)
				} else {
					string .= SubStr(this.template, part.offset)
				}
			}
		}
		return string
	}

	class Part {
		isKey() {
			return false
		}
	}

	class Text extends Phrase.Part {
		offset := 0
		length := 0
		
		__New(offset, length) {
			this.offset := offset
			this.length := length
		}
	}

	class Key extends Phrase.Part {
		keyId := ""

		__New(keyId) {
			this.keyId := keyId
		}

		isKey() {
			return true
		}
	}

	parse() {
		static CODE_LOWER_A := asc("a"), CODE_LOWER_Z := asc("z"), CODE_UNDERSCORE = asc("_")
		parts := Object()
		keys := Object()
		keyBegin := this.keyBegin
		keyEnd := this.keyEnd

		; Add an additional space character to the end of the template to have the parsing loop
		; run one more time at the end in order to find the last keyEnd character.
		template := this.template . " "

		lookAhead := ""
		isParsingKey := false
		partStart := 1
		Loop, Parse, template
		{
			char := lookAhead
			lookAhead := A_LoopField
			if (isParsingKey) {
				if (char == keyEnd) {
					; We have found the end of a key.
					isParsingKey := false
					length := A_Index - partStart - 1
					if (length == 0) {
						throw Exception("EmptyKey", -1, "Empty key at position " . A_Index-1)
					}

					; Check if there is already a key with keyId.
					; If it is, just insert it again in the parts list.
					; Otherwise, create a new key and add it to the parts and keys.
					keyId := SubStr(template, partStart, length)
					if (keys.hasKey(keyId)) {
						parts.insert(keys[keyId])
					} else {
						key := new Phrase.Key(keyId)
						parts.insert(key)
						keys[key.keyId] := key
					}
					partStart := A_Index
					continue
				}

				; Check that the current character is allowed inside a key.
				charCode := asc(char)
				if ((charCode < CODE_LOWER_A || charCode > CODE_LOWER_Z) && (charCode != CODE_UNDERSCORE)) {
					keyId := SubStr(template, partStart, A_Index - partStart - 1)
					throw Exception("IllegalKeyCharacter", -1, "Illegal character """ . char . """ in key """ . keyId . """ at position " . A_Index-1)
				}
				continue
			}

			if (char == keyBegin) {
				if (lookAhead == keyBegin) {
					; Found an escaped keyBegin. Add a new text part that includes the first keyBegin.
					if (A_Index - partStart - 1 > 0) {
						; Insert a new text part if its length is greater than 0.
						parts.insert(new Phrase.Text(partStart, A_Index - partStart - 1))
					}
					partStart := A_Index
					; Reset 'lookAhead' to have the next iteration have an empty 'char', effectively
					; skipping over the detection of keyBegin.
					lookAhead := ""
				} else {
					; Found the beginning of a new key.
					if (A_Index - partStart - 1 > 0) {
						; Insert a new text part if its length is greater than 0.
						parts.insert(new Phrase.Text(partStart, A_Index - partStart - 1))
					}
					isParsingKey := true
					partStart := A_Index
				}
				continue
			}
		}

		if (isParsingKey) {
			; Key is not complete.
			keyId := SubStr(template, partStart)
			throw Exception("UnescapedKeyBegin" ,-1, "Unescaped """ . keyBegin . """ at position " . A_Index-1)
		} else {
			; Copy the remaining text.
			parts.insert(new Phrase.Text(partStart, ""))
		}

		this.parts := parts
		this.keys := keys
	}

}

class Phrase {

	static KEY_BEGIN := "{"
	static KEY_END := "}"
	parts := Object()
	keys := Object()
	template := ""

	from(template) {
		return new Phrase(template)
	}

	__New(template) {
		this.template := template
		if (template == "") {
			throw Exception("Empty Template!")
		}
		this.parse()
	}

	put(key, value) {
		if (!this.keys.hasKey(key)) {
			throw Exception("Key """ . key . """ not found in template: " this.template)
		}
		this.keys[key].value := value
		return this
	}

	format() {
		string := ""
		for index, part in this.parts {
			if (part.isKey()) {
				if (part.value = "") {
					throw Exception("Key """ . part.keyId . """ not set!")
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

		; Add an additional space character to the end of the template to have the parsing loop
		; run one more time at the end in order to find the last KEY_END character.
		template := this.template . " "

		lookAhead := ""
		isParsingKey := false
		partStart := 1
		Loop, Parse, template
		{
			char := lookAhead
			lookAhead := A_LoopField
			if (isParsingKey) {
				if (char == Phrase.KEY_END) {
					; We have found the end of a key.
					isParsingKey := false
					length := A_Index - partStart - 1
					if (length == 0) {
						throw Exception("Empty Key!")
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
					throw Exception("illegal character """ . char . """ in key """ . keyId . """ at position " . A_Index-1)
				}
				continue
			}

			if (char == Phrase.KEY_BEGIN) {
				if (lookAhead == Phrase.KEY_BEGIN) {
					; Found an escaped KEY_BEGIN. Add a new text part that includes the first KEY_BEGIN.
					parts.insert(new Phrase.Text(partStart, A_Index - partStart - 1))
					partStart := A_Index
					; Reset 'lookAhead' to have the next iteration have an empty 'char', effectively
					; skipping over the detection of KEY_BEGIN.
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
			if (char == Phrase.KEY_END) {
				if (lookAhead == Phrase.KEY_END) {
					; Found an escaped KEY_END. Add a new text part that includes the first KEY_END.
					parts.insert(new Phrase.Text(partStart, A_Index - partStart - 1))
					partStart := A_Index
					; Reset 'lookAhead' to have the next iteration have an empty 'char', effectively
					; skipping over the detection of KEY_END.
					lookAhead := ""
				} else {
					throw Exception("Not escaped closing brace!")
				}
				continue
			}
		}

		if (isParsingKey) {
			; Key is not complete.
			keyId := SubStr(template, partStart)
			throw Exception("no matching closing brace found for key """ . keyId . """ starting at position " . partStart)
		} else {
			; Copy the remaining text.
			parts.insert(new Phrase.Text(partStart, ""))
		}

		this.parts := parts
		this.keys := keys
	}

}

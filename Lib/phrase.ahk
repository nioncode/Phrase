
class Phrase {

	parts := Object()
	keys := Object()
	template := ""

	from(template) {
		return new Phrase(template)
	}

	__New(template) {
		this.template := template
		parsingResult := new Phrase.Parser(this.template).parse()
		this.parts := parsingResult.parts
		this.keys := parsingResult.keys
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
			if (part.value = "" && part.isKey()) {
				throw Exception("Key """ . part.keyId . """ not set!")
			}
			string .= part.value
		}
		return string
	}

	class Part {
		value := ""

		isKey() {
			return false
		}
	}

	class Text extends Phrase.Part {
		__New(text) {
			this.value := text
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

	class Parser {
		static KEY_BEGIN := "{"
		static KEY_END := "}"
		template := ""
		templateLength := 0
		currentIndex := -1

		__New(template) {
			this.template := template
			this.templateLength := StrLen(template)
		}

		parse() {
			parts := Object()
			keys := Object()
			this.currentIndex := 1
			while (!this.atEnd()) {
				char := this.currentChar()
				if (char == Phrase.Parser.KEY_BEGIN && this.lookAhead() != Phrase.Parser.KEY_BEGIN) {
					keyId := this.consumeKey()
					if (keys.hasKey(keyId)) {
						; If we already have found the same key before, do not
						; create it again, just add it to the parts once more.
						parts.insert(keys[keyId])
						continue
					}
					key := new Phrase.Key(keyId)
					parts.insert(key)
					keys[key.keyId] := key
					continue
				}
				parts.insert(new Phrase.Text(this.consumeText()))
			}
			return {"parts": parts, "keys": keys}
		}

		/**
		 * @brief Consumes a single character.
		*/
		consume() {
			this.currentIndex++
		}

		/**
		 * @brief Consumes a key.
		 * @return the identifier of the key, i.e. everything between the key delimiters.
		*/
		consumeKey() {
			keyId := ""
			startingPosition := this.currentIndex

			; Consume the KEY_BEGIN char.
			this.consume()
			while (true) {
				if (this.atEnd()) {
					throw Exception("no matching closing brace found for key """ . keyId . """ starting at position " . startingPosition)
				}
				char := this.currentChar()
				if (char == Phrase.Parser.KEY_END) {
					this.consume()
					break
				}
				if (!this.isAllowedKeyCharacter()) {
					throw Exception("illegal character """ . char . """ in key """ . keyId . """ at position " . this.currentIndex)
				}
				keyId .= char
				this.consume()
			}
			if (StrLen(keyId) = 0) {
				throw Exception("key at position " . startingPosition . " is empty")
			}
			return keyId
		}

		/**
		 * @brief Returns whether the current character is allowed inside a key identifier.
		*/
		isAllowedKeyCharacter() {
			static CODE_LOWER_A := asc("a"), CODE_LOWER_Z := asc("z"), CODE_UNDERSCORE = asc("_")
			charCode := asc(this.currentChar())
			return (charCode >= CODE_LOWER_A && charCode <= CODE_LOWER_Z) || (charCode == CODE_UNDERSCORE)
		}

		/**
		 * @brief Consumes everything until a new key identifier is found.
		 * @return the text that was consumed.
		*/
		consumeText() {
			text := ""
			while (!this.atEnd()) {
				char := this.currentChar()
				if (char == Phrase.Parser.KEY_BEGIN) {
					if (this.lookAhead() == Phrase.Parser.KEY_BEGIN) {
						; The KEY_BEGIN character was escaped.
						; Add it to the text only once, but consume two
						; characters, the KEY_BEGIN and its escaping char.
						text .= char
						this.consume()
						this.consume()
						continue
					} else {
						; We reached the beginning of a new key.
						break
					}
				}
				if (char == Phrase.Parser.KEY_END) {
					if (this.lookAhead() == Phrase.Parser.KEY_END) {
						; The KEY_END character was escaped.
						; Add it to the text only once, but consume two
						; characters, the KEY_END and its escaping char.
						text .= char
						this.consume()
						this.consume()
						continue
					} else {
						throw Exception("no matching opening brace found for closing brace at position " . this.currentIndex)
						break
					}
				}
				; Add every non special character to the text and consume it.
				text .= char
				this.consume()
			}
			if (StrLen(text) = 0) {
				throw Exception("text at position " . this.currentIndex . " is empty")
			}
			return text
		}

		/**
		 * @brief Returns the character at the current position.
		*/
		currentChar() {
			return SubStr(this.template, this.currentIndex, 1)
		}

		/**
		 * @brief Returns the next character.
		*/
		lookAhead() {
			return SubStr(this.template, this.currentIndex+1, 1)
		}

		/**
		 * @brief Returns whether we are at the end of the template, i.e. all characters have been consumed.
		*/
		atEnd() {
			return this.currentIndex > this.templateLength
		}

	}

}

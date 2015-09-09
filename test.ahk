#Include <Yunit\Yunit>
#Include <Yunit\Window>
#Include <Yunit\StdOut>
#Include <Phrase>
#NoEnv

Yunit.Use(YunitStdOut, YunitWindow).Test(StringPhraseTestSuite, StringTestSuite)

class StringPhraseTestSuite {

	Empty() {
		this.ExpectedException := Exception("EmptyTemplate")
		template := ""
		Phrase.from(template).format()
	}

	Plaintext() {
		template := "hello world"
		expectation := "hello world"
		assertStringEquals(expectation, Phrase.from(template).format())
	}

	OneKeyAtEnd() {
		template := "hello {name}"
		expectation := "hello someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	OneKeyAtBeginning() {
		template := "{name} is here"
		expectation := "someone is here"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	OneKeyInMiddle() {
		template := "is it {name}?"
		expectation := "is it someone?"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	TwoKeys() {
		template := "hello {first} {second}"
		expectation := "hello some one"
		assertStringEquals(expectation, Phrase.from(template).put("first", "some").put("second", "one").format())
	}

	EmptyKey() {
		this.ExpectedException := Exception("EmptyKey")
		template := "{}"
		Phrase.from(template).format()
	}

	EmptyKeyAtBeginning() {
		this.ExpectedException := Exception("EmptyKey")
		template := "hello {}"
		Phrase.from(template).format()
	}

	EmptyKeyAtEnd() {
		this.ExpectedException := Exception("EmptyKey")
		template := "{} is gone"
		Phrase.from(template).format()
	}

	EmptyKeyInMiddle() {
		this.ExpectedException := Exception("EmptyKey")
		template := "hello {} foo"
		Phrase.from(template).format()
	}

	MissingKey() {
		this.ExpectedException := Exception("KeyNotSet")
		template := "hello {name}"
		Phrase.from(template).format()
	}

	EscapingAtBeginning() {
		template := "{{hello mr. {name}"
		expectation := "{hello mr. someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	EscapingAtEnd() {
		template := "hello mr. {name}{{"
		expectation := "hello mr. someone{"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	EscapingInMiddle() {
		template := "hello {{mr. {name}"
		expectation := "hello {mr. someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	EscapingNotNecessaryForKeyEndChar() {
		template := "hello mr.} {name}"
		expectation := "hello mr.} someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	IllegalKeyCharacter() {
		keyId := "na|me"
		this.ExpectedException := Exception("IllegalKeyCharacter")
		template := "hello {" . keyId . "}"
		Phrase.from(template).put(keyId, "foo").format()
	}

	KeysInsideBraces() {
		template := "Something or {{{name}} is inside {{}"
		expectation := "Something or {someone} is inside {}"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

}

assertStringEquals(expected, actual) {
	if (expected != actual) {
		throw Exception("Expected: " . expected . ", Got: " . actual)
	}
}

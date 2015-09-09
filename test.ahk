﻿#Include <Yunit\Yunit>
#Include <Yunit\Window>
#Include <Yunit\StdOut>
#Include <phrase>
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

	EscapingBegin() {
		template := "hello {{mr. {name}"
		expectation := "hello {mr. someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	EscapingEnd() {
        template := "hello mr.}} {name}"
		expectation := "hello mr.} someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	EscapingBeginEnd() {
		template := "hello {{mr.}} {name}"
		expectation := "hello {mr.} someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	IllegalKeyCharacter() {
		keyId := "na|me"
		this.ExpectedException := Exception("IllegalKeyCharacter")
		template := "hello {" . keyId . "}"
		Phrase.from(template).put(keyId, "foo").format()
	}

}

assertStringEquals(expected, actual) {
	if (expected != actual) {
		throw Exception("Expected: " . expected . ", Got: " . actual)
	}
}

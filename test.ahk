#Include <Yunit\Yunit>
#Include <Yunit\Window>
#Include <Yunit\StdOut>
#Include <phrase>
#NoEnv

Yunit.Use(YunitStdOut, YunitWindow).Test(StringPhraseTestSuite, StringTestSuite)

class StringPhraseTestSuite {

	Plaintext() {
		template := "hello world"
		expectation := "hello world"
		assertStringEquals(expectation, Phrase.from(template).format())
	}

	OneKey() {
		template := "hello {name}"
		expectation := "hello someone"
		assertStringEquals(expectation, Phrase.from(template).put("name", "someone").format())
	}

	MissingKey() {
		this.ExpectedException := Exception("Key ""name"" not set!")
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

}

assertStringEquals(expected, actual) {
	if (expected != actual) {
		throw Exception("Expected: " . expected . ", Got: " . actual)
	}
}

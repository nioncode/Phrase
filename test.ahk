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
		YUnit.assert(expectation == Phrase.from(template).format())
	}

	OneKey() {
		template := "hello {name}"
		expectation := "hello someone"
		YUnit.assert(expectation == Phrase.from(template).put("name", "someone").format())
	}

	MissingKey() {
        this.ExpectedException := Exception("Key ""name"" not set!")
		template := "hello {name}"
		Phrase.from(template).format()
	}

}

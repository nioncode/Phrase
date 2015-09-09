# Phrase - AutoHotkey string formatting
Phrase is based on the Android library with the [same name](https://github.com/square/phrase/).

It makes it easy to format a string that contains readable markup code instead of hard to read positional arguments like the default [AutoHotkey Format command](http://ahkscript.org/docs/commands/Format.htm).

# Usage

    #Include <Phrase>
    template := "Hello {name}, you are {age} years old."
    MsgBox % Phrase.from(template)
                   .put("name", "Mr. X")
                   .put("age", 42)
                   .format()

will display

> Hello Mr. X, you are 42 years old.

# Install
Copy *Phrase.ahk* from the *Lib* folder to your library. See also: [#Include](http://ahkscript.org/docs/commands/_Include.htm) and [Library folders](http://ahkscript.org/docs/Functions.htm#lib).

# Syntax
Create a new Phrase object from a template by using `Phrase.from(template)`.
<br>
Then, add values for all keys in the template by calling `put(key, value)` on the phrase object.
<br>
To get the formatted string, call `format()`.

Phrase supports a fluent interface, which makes it possible to chain method calls together:

    p := Phrase.from("Hello {name}!")
    p.put("name", "someone")
    string := p.format()

is equal to

    string := Phrase.from("Hello {name}!").put("name", "someone").format()

## Keys
Everything between `{}` is treated as the *key identifier*, which can be used in a call to `put(key, value)` to dynamically replace the key with a value that can be determined at runtime.

Phrase only allows lowercase a-z and the underscore character to be used inside a key identifier.

To insert a literal `{` into the text, type it twice.
This is not necessary for the closing brace.
<br>
Keys can also be inside escaped `{` environments:

    MsgBox % Phrase.from("Hey {{{key} is inside braces}!").put("key", "my key").format()

will produce

> Hey {my key is inside braces}!

# Exceptions
Phrase conforms to the Fail-Fast principle.
That means as soon as an error is detected, an Exception will be thrown.

Every Exception has a 'Message' that identifies the error and optionally an 'Extra' field that has more details about the error, like the name of the key that was not found or the exact position in the template that caused the parsing to fail. See also: [AutoHotkey Exception Object](http://ahkscript.org/docs/commands/Throw.htm#Exception)).

Raised Exceptions:

  - EmptyTemplate: When the template to be formatted is empty.
  - KeyNotFound: When  `put(key, value)` is called with a *key* that was not found in the template.
  - KeyNotSet: When `format()` is called before every key has been assigned a value with `put(key, value)`.
  - EmptyKey: When the template contains an empty key, i.e. `{}` is used.
  - IllegalKeyCharacter: When a key identifier contains an invalid character.
  - UnescapedKeyBegin: When a `{` was not correctly escaped or the end of a key was not found.

# Tests
Phrase uses [Uberi's YUnit library](https://github.com/Uberi/Yunit) to perform unit tests.
<br>
You must have this library in your library in order to be able to run *tests.ahk*.

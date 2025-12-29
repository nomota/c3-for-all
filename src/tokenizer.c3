// lib/std/core/tokenizer.c3
/*
  a generic string tokenizer

  Tokenizer {StringType} tokenizer; // StringType = String | ZString | DString | WString
  tokenizer.init(str_of_same_type, delimiters=" \t\r\n");
  List {TokenType} tokens; // TokenType = String | Char16[](only for WString)
  while (try token = tokenizer.next()) {
     tokens.push(token);
  }
*/

module std::core::string::tokenizerx;
faultdef NO_MORE_TOKEN; // placed here because generic module doesn't allow faultdef

module std::core::string::tokenizer {StrType};

struct Tokenizer {
    StrType buffer @if(StrType != DString);
    char[] buffer @if(StrType == DString);
    Char16[] delimiters @if(StrType == WString);
    char[] delimiters @if(StrType != WString);
    usz index;
}

macro void Tokenizer.init(&self, buffer, String delimiters=" \t\r\n")
{
    $if StrType == String || StrType == ZString || StrType == WString:
        self.buffer = buffer;
    $endif

    $if StrType == DString:
        self.buffer = buffer.str_view();
    $endif

    $if StrType == WString:
        self.delimiters = delimiters.to_utf16(tmem)!!;
    $endif

    $if StrType != WString:
        self.delimiters = (char[])delimiters;
    $endif

    self.index = 0;
}

fn bool Tokenizer.is_end(&self) 
{
      $if StrType == String || StrType == DString: 
        if (self.index >= self.buffer.len) return true;
    $endif

    $if StrType == ZString:
        if (self.buffer[self.index] == '\0') return true;
    $endif

    $if StrType == WString:
        if (self.buffer[self.index] == (Char16)'\0') return true;
    $endif

    return false;
}

fn bool Tokenizer.is_delim(&self) 
{
    $if StrType != WString:
        char c = self.buffer[self.index];
    $endif
 
    $if StrType == WString:
        Char16 c = self.buffer[self.index];
    $endif

    foreach (d: self.delimiters) {
        if (c == d) return true;
    }

    return false;
}

macro Tokenizer.next(&self) // returns String? or Char16[]?
{
    while (true) {
        if (self.is_end()) break;
        if (! self.is_delim()) break;
        self.index += 1;  
    }

    if (self.is_end()) {
        return tokenizerx::NO_MORE_TOKEN?;
    }

    usz start = self.index;

    bool added = false;
    while (true) {
        if (self.is_end()) break;
        if (self.is_delim()) break;
        self.index += 1;
        added = true; 
    }

    usz end = self.index;
    if (added) end -= 1;

    $if StrType == WString: 
        return self.buffer[start .. end];
    $endif

    $if StrType != WString: 
        return (String)self.buffer[start .. end];
    $endif
}

// CUT HERE --------------------------
module test_main;

import std::io;
import std::core::string::tokenizer;
import std::collections;

fn void test_String() // @test
{
    String s = " Hello, World ! ";
    Tokenizer {String} tok;
    tok.init(s, " ,");
    List {String} list;
    while (try t = tok.next()) {
        list.push(t);
    }
    String[] expected = {"Hello", "World", "!"};
    foreach(i, item: list) {
        assert(expected[i] == item);
   }
}

fn void test_ZString() // @test
{
    ZString s = " Hello , World !  ";
    Tokenizer {ZString} tok;
    tok.init(s," ,");
    List {String} list;
    while (try t = tok.next()) {
        list.push(t);
    }
    String[] expected = {"Hello", "World", "!"};
    foreach(i, item: list) {
        assert(expected[i] == item);
   }
}

fn void test_DString() // @test
{
    DString s = dstring::new(tmem, " Hello, World ! ");
    Tokenizer {DString} tok;
    tok.init(s, " ,");
    List {String} list;
    while (try t = tok.next()) {
        list.push(t);
    }
    String[] expected = {"Hello", "World", "!"};
    foreach(i, item: list) {
        assert(expected[i] == item);
   }
}

macro Char16[] utf8_char16(String s)
{
    return s.to_utf16(tmem)!!;
}

fn bool equals(Char16[] a, String b) 
{
    Char16* b16 = tmalloc(b.len*Char16.sizeof);
    conv::utf8to16_unsafe(b, b16)!!;

    if (a.len != ((WString)b16).len()) return false;
   
    for (usz i = 0; i < a.len; i++) {
        if (a[i] != b16[i]) return false;
    }

    return true;
}

fn void test_WString() // @test
{
    String s_utf8 = "♡ Hello , 세상 !  ";
    Char16[] s_char16 = utf8_char16(s_utf8);
    WString s = (WString) s_char16;
    Tokenizer {WString} tok;
    tok.init(s,"♡ ,");
    List {Char16[]} list;
    while (try t = tok.next()) {
        list.push(t);
    }
    String[] expected = {"Hello", "세상", "!"};
    foreach(i, item: list) {
        io::printn(item);
        assert(equals(item, expected[i]));
   }
}

fn void main()
{
    test_String();
    test_ZString();
    test_DString();
    test_WString();
}

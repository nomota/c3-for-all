// lib/std/core/tokenizer.c3
/*
  a String tokenizer

  Tokenizer tokenizer;
  tokenizer.init(str, delimiters=" \t\r\n");
  List{String} tokens;
  while (try token = tokenizer.next()) {
     tokens.push(token);
  }
*/

module std::core::string::tokenizer;

faultdef NO_MORE_TOKEN;

struct Tokenizer {
    String buffer;
    char[] delimiters;
    usz index;
}

fn void Tokenizer.init(&self, String buffer, String delimiters=" \t\r\n")
{
    self.buffer = buffer;
    self.delimiters = delimiters;
    self.index = 0;
}

fn bool Tokenizer.is_end(&self) 
{
      if (self.index >= self.buffer.len) return true;

    return false;
}

fn bool Tokenizer.is_delim(&self) 
{
    char c = self.buffer[self.index];

    foreach (d: self.delimiters) {
        if (c == d) return true;
    }

    return false;
}

fn String Tokenizer.next(&self)
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

    return (String)self.buffer[start .. end];
}

// CUT HERE --------------------------
module test_main;

import std::io;
import std::core::string::tokenizer;
import std::collections;

fn void test_String() // @test
{
    String str = " Hello, World ! ";
    Tokenizer tokenizer;
    tokenizer.init(str, " ,");
    List {String} tokens;
    while (try token = tokenizer.next()) {
        tokens.push(token);
    }
    String[] expected = {"Hello", "World", "!"};
    foreach(i, token: tokens) {
        assert(expected[i] == token);
   }
}

fn void main()
{
    test_String();
}
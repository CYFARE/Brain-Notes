# Regex Cheatsheet

| Description                                      | Command                                           |
|--------------------------------------------------|---------------------------------------------------|
| Find all lines starting with # comments          | `^#.*\n`                                          |
| All words starting with specific character       | `P[\w]+`                                          |
| Find all email addresses in a document           | `[\w\-\.]+@([\w-]+\.)+[\w\-]{2,4}`                |
| Find all links in html                           | `<a[^>]*\bhref=["'](https?://\S+)["'][^>]*>`      |
| Full dates in document                           | `[\d]{1,2} [ADFJMNOS]\w* [\d]{4}`                 |
| Match all lines containing a word                | `[\s\S].(WORD).*[\s\S]`                           |
| Match everything before the word including the word itself | `^(.*?WORD) ?`                             |
| Match IP addresses                                   | `\b(?:\d{1,3}\.){3}\d{1,3}\b`                     |
| Match domain names                                   | `([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}`    |
| Match dates in YYYY-MM-DD format                     | `\b\d{4}-\d{2}-\d{2}\b`                           |
| Match credit card numbers                            | `\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b`      |
| Match phone numbers (various formats)                | `\b\d{3}[-\.\s]?\d{3}[-\.\s]?\d{4}\b`             |
| Match URLs                                           | `https?:\/\/\S+`                                  |
| Match hashtags in a sentence                         | `#\w+`                                            |
| Match mentions (usernames) in a sentence            | `@\w+`                                            |
| Match email addresses                                | `[\w\.\-]+@[\w\.\-]+\.\w+`                       |
| Match HTML tags                                      | `<[^>]+>`                                        |
| Match HTML comments                                  | `<!--[\s\S]*?-->`                                |
| Match hexadecimal color codes                        | `#[0-9a-fA-F]{6}`                                |
| Match MAC addresses                                  | `([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})`       |
| Match social security numbers (SSN)                  | `\d{3}-\d{2}-\d{4}`                              |
| Match ZIP codes                                      | `\b\d{5}(?:-\d{4})?\b`                           |
| Match alphanumeric strings                           | `\w+`                                            |
| Match only alphabetic strings                        | `[A-Za-z]+`                                      |
| Match only numeric strings                           | `\d+`                                            |
| Match UUIDs (Universally Unique Identifiers)         | `[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}` |
| Match positive integers                              | `\b[1-9]\d*\b`                                   |
| Match negative integers                              | `-\b[1-9]\d*\b`                                  |
| Match floating-point numbers (decimal)               | `\b[+-]?(\d+\.\d*|\.\d+)([eE][+-]?\d+)?\b`      |
| Match multiline comments in code                    | `\/\*(.|[\r\n])*?\*\/`                           |
| Match single-line comments in code                  | `\/\/.*`                                         |
| Match HTML tags with attributes                      | `<[^>]+>` with optional attributes               |
| Match quoted strings (single or double quotes)      | `["'][^"']*["']`                                 |
| Match IPv6 addresses                                 | `[0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){7}`        |
| Match XML tags                                       | `<[^>]+>`                                        |
| Match positive or negative currency amounts         | `[-+]?\$\d+(?:,\d{3})*(?:\.\d{2})?`              |
| Match 5-digit words (e.g., PIN)                      | `\b[A-Za-z]{5}\b`                                |
| Match Markdown headers                               | `^\s*#\s+.+`                                     |
| Match Markdown lists (bulleted/numbered)            | `^\s*[-*]\s+.+` or `^\s*\d+\.\s+.+`              |
| Match Markdown links                                 | `\[[^\]]+\]\([^\)]+\)`                           |
| Match XML comments                                  | `<!--[\s\S]*?-->`                                |
| Match hexadecimal numbers                           | `\b0[xX][0-9A-Fa-f]+\b`                         |
| Match Roman numerals                                | `\bM{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\b` |
| Match US Social Security Numbers (SSN)              | `\d{3}-\d{2}-\d{4}`                              |
| Match credit card expiration dates (MM/YY)          | `^(0[1-9]|1[0-2])\/?([2-9]\d)$`                 |
| Match Markdown images                               | `!\[[^\]]+\]\([^\)]+\)`                          |
| Match quoted email addresses                        | `["'][\w\.\-]+@[\w\.\-]+\.\w+["']`               |
| Match Markdown code blocks                          | <code>````[\s\S]+?````</code> or <code>    [\s\S]+</code>               |
| Match hexadecimal RGB color codes                   | `#[0-9a-fA-F]{6}`                                |
| Match US phone numbers (various formats)            | `\b(?:\(\d{3}\)|\d{3})(?:[-\s.]?)\d{3}(?:[-\s.]?)\d{4}\b` |
| Match British postcodes (various formats)           | `([A-Z][A-HJ-Y]?[0-9][A-Z0-9]?[0-9][ABD-HJLNP-UW-Z]{2})|GIR 0AA` |
| Match Markdown inline code                          | <code>\`[^\`]+\`</code>                             |
| Match Markdown blockquotes                          | `^\s*>\s+.+`                                     |
| Match XML opening tags                              | `<[^/][^>]+>`                                    |
| Match XML closing tags                              | `<\/[^>]+>`                                      |
| Match hashtags in a string                          | `\B#(\w+)`                                       |
| Match Markdown emphasis (`*italic*` and `**bold**`) | `\b\*{1,2}[^*]+\*{1,2}\b`                        |
| Match HTML attributes                               | `[\w-]+=["'][^"']*["']`                          |
| Match Python function definitions                  | `def\s+\w+\s*\(`                                 |
| Match SQL SELECT statements                         | `\bSELECT\b.+?\bFROM\b`                         |
| Match JavaScript function declarations             | `\bfunction\b\s+\w+\s*\(`                       |
| Match JSON strings                                  | `"(?:\\.|[^"])*"`                                |
| Match XML opening and closing tags                  | `<\/?[^>]+>`                                    |
| Match Markdown horizontal rules                    | `^\s*[-*_]{3,}\s*$`                              |
| Match JavaScript variable assignments              | `\b\w+\s*=\s*.*?;`                              |
| Match XML self-closing tags                         | `<[^/][^>]+\/>`                                  |


## Lookup Table
| Name | Symbol | Pure Regex |
| --- | --- | --- |
| Caret | ^ | ^ |
| Digit | \d | [0-9] |
| Not Digit | \D | ```[^\d]``` |
| Word | \w | [a-zA-z0-9] |
| Not Word | \W | ```[^\w]```|
| Whitespace | \s | [\f\n\r\t\v] |
| Not Whitespace | \S | ```[^\s]``` |


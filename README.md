# sf2

Haxe library that adds support for reading SF2 soundfont files. It follows the structure of the [Haxe format library](https://github.com/HaxeFoundation/format).

## Usage

```haxe
var soundfontBytes:Bytes = File.getBytes("path/to/your/soundfont.sf2");
var soundfont:SF2 = new Reader(new BytesInput(soundfontBytes)).read();
```

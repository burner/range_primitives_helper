# Range Primitives Helper

Range primitives like `isInputRange` are used in many places in D code.
When the usage of those primitives leads to a compile error, because e.g. the
passed type is not an InputRange, the error messages are often not very helpful.
This is especially true, if range primitives are used as function constraints
for function overloading.

For example:
```dlang
void fun(T)(T t) if(isInputRange!T && !isRandomAccessRange!T) {
}

void fun(T)(T t) if(isRandomAccessRange!T) {
}
```

This is at least annoying, and avoidable at best.
This library **Range Primitives Helper** helps making this less annoying.

## Usage

```dlang
import range_primitives_helper;

enum string result = isInputRangeErrorFormatter!(T);
```

If the passed type `T` is an InputRange the `enum string result` will read

```dlang
T.stringof ~ " is an InputRange"
```

if `T` is not an InputRange the string will list which criteria of the
InputRange concept is not fulfilled by `T`;

But this is only half the work.
The other part is a bit of a refactoring effort.
Instead of having to template functions that use function constraints to do the
overload resolution, a better approach is to have what I would call a
*dispatch function* like this.

```dlang
import range_primitives_helper;

void fun(T)(T t) {
	static if(isRandomAccessRange!T) {
		funRAR(t);
	} else static if(isInputRange!T) {
		funIR(t);
	} else {
		static assert(false, "'fun' expected 'T' = "
			~ T.stringof ~ " either to be
			~ an InputRange or"
			~ " a RandomAccessRange but\n"
			~ isInputRangeErrorFormatter!(T)
			~ "\n"
			~ isRandomAccessRangeErrorFormatter!(T));
	}
}

private void funIR(T)(T t) {
}

private void funRAR(T)(T t) {
}
```

Calling `fun` with an `int` for example results in, IMO very nice, error message

```sh
SOURCE_LOCATION: Error: static assert:  "
'fun' expected 'T' = 'int' either to be an InputRange or a RandomAccessRange but
int is not an InputRange because:
	the property 'empty' does not exist
	and the property 'front' does not exist
	and the function 'popFront' does not exist
int is not an RandomAccessRange because
	the property 'empty' does not exist
	and the property 'front' does not exist
	and the function 'popFront' does not exist
	and the property 'save' does not exist
	and int must not be an autodecodable string but should be an aggregate type
	and int must allow for array indexing, aka. [] access"
```

## Primitives

The are primitives for:

| Type | std.range | range\_primitives\_helper |
| ---- | --------- | ----------------------- |
| InputRange | isInputRange | isInputRangeErrorFormatter |
| BidirectionalRange | isBidirectionalRange | isBidirectionalRangeErrorFormatter |
| ForwardRange | isForwardRange | isForwardRangeErrorFormatter |
| RandomAccessRange | isRandomAccessRange | isRandomAccessRangeErrorFormatter |
| OutputRange | isOutputRange | isOutputRangeErrorFormatter |

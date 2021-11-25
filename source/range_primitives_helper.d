module range_primitives_helper;

import std.algorithm.iteration : map, filter, joiner;
import std.algorithm.searching : any;
import std.conv : to;
import std.array;
import std.range;
import std.traits;

@safe:

/**
* This function produces a descriptive message why `R` is not an InputRange.
* If `R` is an InputRange the returned string will say so.
*/
string isInputRangeErrorFormatter(R)() pure {
	static if(is(typeof(R.init) == R)) {
		string ret = R.stringof ~ " is not an InputRange because:\n\t";

		Test[] tests =
				[ isValidEmpty!R()
				, isFrontValid!R()
				, isPopFrontValid!R()
				];

		auto msg = tests
			.filter!(t => t.failed)
			.map!(t => t.message)
			.joiner("\n\tand ")
			.to!string();

		bool failed = tests.map!(t => t.failed).any();

		return failed
			? ret ~ msg
			: R.stringof ~ " is an InputRange";
	} else {
		return R.stringof ~ " can not be tested as " ~ R.stringof ~ ".init"
			~ " does not construct a compileable " ~ R.stringof;
	}
}

/// ditto
unittest {
	struct Foo {}
	enum msg = isInputRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an InputRange because:
	the property 'empty' does not exist
	and the property 'front' does not exist
	and the function 'popFront' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isInputRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		int empty;
	}
	enum msg = isInputRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an InputRange because:
	the property 'empty' is not of type 'bool' but 'int'
	and the property 'front' does not exist
	and the function 'popFront' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isInputRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		void front();
	}
	enum msg = isInputRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an InputRange because:
	the property 'front' does not return a non 'void' value
	and the function 'popFront' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isInputRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
	}
	enum msg = isInputRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an InputRange because:
	the function 'popFront' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isInputRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
		void popFront();
	}
	enum msg = isInputRangeErrorFormatter!(Foo);
	enum exp =`Foo is an InputRange`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isInputRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/**
* This function produces a descriptive message why `R` is not a ForwardRange.
* If `R` is an ForwardRange the returned string will say so.
*/
string isForwardRangeErrorFormatter(R)() pure nothrow {
	static if(is(typeof(R.init) == R)) {
		bool failed = false;
		string ret = R.stringof ~ " is not an ForwardRange because";

		enum ev = isEmptyValid!R();
		failed |= ev.failed;
		ret ~= ev.message;

		enum fv = isFrontValid!R();
		failed |= fv.failed;
		ret ~= fv.message;

		enum pv = isPopFrontValid!R();
		failed |= pv.failed;
		ret ~= pv.message;

		enum sv = isSaveValid!R();
		failed |= sv.failed;
		ret ~= sv.message;

		return failed
			? ret
			: R.stringof ~ " is an ForwardRange";
	} else {
		return R.stringof ~ " can not be tested as " ~ R.stringof ~ ".init"
			~ " does not construct a compileable " ~ R.stringof;
	}
}

/+
/// ditto
unittest {
	struct Foo {}
	enum msg = isForwardRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an ForwardRange because
	the property 'empty' does not exist
	the property 'front' does not exist
	the function 'popFront' does not exist
	the property 'save' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isForwardRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		int empty;
	}
	enum msg = isForwardRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an ForwardRange because
	the property 'empty' does not return a 'bool' but a 'int'
	the property 'front' does not exist
	the function 'popFront' does not exist
	the property 'save' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isForwardRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		void front();
	}
	enum msg = isForwardRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an ForwardRange because
	the property 'front' does not return a non 'void' value
	the function 'popFront' does not exist
	the property 'save' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isForwardRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
	}
	enum msg = isForwardRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an ForwardRange because
	the function 'popFront' does not exist
	the property 'save' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isForwardRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
		void popFront();
	}
	enum msg = isForwardRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an ForwardRange because
	the property 'save' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isForwardRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
		void popFront();
		int save;
	}
	enum msg = isForwardRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an ForwardRange because
	the property 'save' does not return a 'Foo' but a 'int'`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isForwardRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
		void popFront();
		Foo save() { return this; }
	}
	enum msg = isForwardRangeErrorFormatter!(Foo);
	enum exp =`Foo is an ForwardRange`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isForwardRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}
+/

/**
* This function produces a descriptive message why `R` is not an BidirectionalRange.
* If `R` is an BidirectionalRange the returned string will say so.
*/
string isBidirectionalRangeErrorFormatter(R)() pure nothrow {
	static if(is(typeof(R.init) == R)) {
		bool failed = false;
		string ret = R.stringof ~ " is not an BidirectionalRange because";

		enum ev = isEmptyValid!R();
		failed |= ev.failed;
		ret ~= ev.message;

		enum fv = isFrontValid!R();
		failed |= fv.failed;
		ret ~= fv.message;

		enum pv = isPopFrontValid!R();
		failed |= pv.failed;
		ret ~= pv.message;

		enum bv = isBackValid!R();
		failed |= bv.failed;
		ret ~= bv.message;

		return failed
			? ret
			: R.stringof ~ " is an BidirectionalRange";
	} else {
		return R.stringof ~ " can not be tested as " ~ R.stringof ~ ".init"
			~ " does not construct a compileable " ~ R.stringof;
	}
}

/+
/// ditto
unittest {
	struct Foo {}
	enum msg = isBidirectionalRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an BidirectionalRange because
	the property 'empty' does not exist
	the property 'front' does not exist
	the function 'popFront' does not exist
	the property 'back' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isBidirectionalRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		int empty;
	}
	enum msg = isBidirectionalRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an BidirectionalRange because
	the property 'empty' does not return a 'bool' but a 'int'
	the property 'front' does not exist
	the function 'popFront' does not exist
	the property 'back' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isBidirectionalRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		void front();
	}
	enum msg = isBidirectionalRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an BidirectionalRange because
	the property 'front' does not return a non 'void' value
	the function 'popFront' does not exist
	the property 'back' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isBidirectionalRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
	}
	enum msg = isBidirectionalRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an BidirectionalRange because
	the function 'popFront' does not exist
	the property 'back' does not exist`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isBidirectionalRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
		void popFront();
		float back();
	}
	enum msg = isBidirectionalRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an BidirectionalRange because
	the property 'back' does return a 'float' which is not equal to the type of 'front' which is 'int'`;
	static assert(msg == exp, "\n" ~ msg ~ "\n" ~ exp);
	string msg2 = isBidirectionalRangeErrorFormatter!(Foo);
	assert(msg2 == exp, "\n" ~ msg ~ "\n" ~ exp);
}
+/

/**
* This function produces a descriptive message why `R` is not an RandomAccessRange.
* If `R` is an RandomAccessRange the returned string will say so.
*/
string isRandomAccessRangeErrorFormatter(R)() pure nothrow {
	static if(is(typeof(R.init) == R)) {
		bool failed = false;
		string ret = R.stringof ~ " is not an RandomAccessRange because";

		enum ev = isEmptyValid!R();
		failed |= ev.failed;
		ret ~= ev.message;

		enum fv = isFrontValid!R();
		failed |= fv.failed;
		ret ~= fv.message;

		enum pv = isPopFrontValid!R();
		failed |= pv.failed;
		ret ~= pv.message;

		static if(!isAutodecodableString!R || isAggregateType!R) {
			failed = true;
			ret ~= "\n\t" ~ R.stringof ~ " must not be an autodecodable string"
				~ " but should be an aggregate type";
		}

		enum sv = isSaveValid!R();
		failed |= sv.failed;
		ret ~= sv.message;

		static if(!(isBidirectionalRange!R || !isInfinite!R)) {
			failed = true;
			ret ~= "\n\t'" ~ R.stringof ~ ".empty' must either be 'enum bool = "
				~ "true' or 'ReturnType!(" ~ R.stringof ~ ".back)' must be equal"
				~ " to 'ReturnType!(" ~ R.stringof ~ ".front)'";
		}

		static if(!(hasLength!R || !isInfinite!R)) {
			failed = true;
			ret ~= "\n\t'" ~ R.stringof ~ ".empty' must either be 'enum bool = "
				~ "true' or '" ~ R.stringof ~ ".length' must be of type 'size_t'";
		}

		static if(!is(typeof(lvalueOf!R[1]))) {
			failed = true;
			ret ~= "\n\t" ~ R.stringof ~ " must allow for array indexing, aka."
				~ " [] access";
		}

		static if(is(typeof(lvalueOf!R[1]))
				&& !is(typeof(lvalueOf!R[1]) == ElementType!R))
		{
			failed = true;
			ret ~= "\n\t" ~ R.stringof ~ "[1] is of type '"
				~ typeof(lvalueOf!R[1]) ~ "' but must be equal to '"
				~ R.stringof ~ ".front' which is '" ~ ElementType!(R).stringof
				~ "'";
		}

		static if(!(isInfinite!R
				|| !is(typeof(lvalueOf!R[$ - 1]))
				|| is(typeof(lvalueOf!R[$ - 1]) == ElementType!R)))
		{
			failed = true;
			ret ~= "\n\t" ~ R.stringof ~ ".empty must either be 'enum bool = "
				~ "true' or " ~ R.stringof ~ "[$ - 1] must be of the same type "
				~ "as " ~ R.stringof ~ ".front which is '" ~ ElementType!R
				~ "'";
		}

		return failed
			? ret
			: R.stringof ~ " is an RandomAccessRange";
	} else {
		return R.stringof ~ " can not be tested as " ~ R.stringof ~ ".init"
			~ " does not construct a compileable " ~ R.stringof;
	}
}

/+
/// ditto
unittest {
	struct Foo {}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	the property 'empty' does not exist
	the property 'front' does not exist
	the function 'popFront' does not exist
	Foo must not be an autodecodable string but should be an aggregate type
	the property 'save' does not exist
	Foo must allow for array indexing, aka. [] access`;
	static assert(msg == exp, "\n" ~ msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, "\n" ~ msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		int empty;
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp = `Foo is not an RandomAccessRange because
	the property 'empty' does not return a 'bool' but a 'int'
	the property 'front' does not exist
	the function 'popFront' does not exist
	Foo must not be an autodecodable string but should be an aggregate type
	the property 'save' does not exist
	Foo must allow for array indexing, aka. [] access`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		void front();
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	the property 'front' does not return a non 'void' value
	the function 'popFront' does not exist
	Foo must not be an autodecodable string but should be an aggregate type
	the property 'save' does not exist
	'Foo.empty' must either be 'enum bool = true' or 'ReturnType!(Foo.back)' must be equal to 'ReturnType!(Foo.front)'
	'Foo.empty' must either be 'enum bool = true' or 'Foo.length' must be of type 'size_t'
	Foo must allow for array indexing, aka. [] access`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	the function 'popFront' does not exist
	Foo must not be an autodecodable string but should be an aggregate type
	the property 'save' does not exist
	'Foo.empty' must either be 'enum bool = true' or 'ReturnType!(Foo.back)' must be equal to 'ReturnType!(Foo.front)'
	'Foo.empty' must either be 'enum bool = true' or 'Foo.length' must be of type 'size_t'
	Foo must allow for array indexing, aka. [] access`;
	static assert(msg == exp, msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		bool empty;
		int front();
		void popFront();
		float back();
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	Foo must not be an autodecodable string but should be an aggregate type
	the property 'save' does not exist
	'Foo.empty' must either be 'enum bool = true' or 'ReturnType!(Foo.back)' must be equal to 'ReturnType!(Foo.front)'
	'Foo.empty' must either be 'enum bool = true' or 'Foo.length' must be of type 'size_t'
	Foo must allow for array indexing, aka. [] access`;
	static assert(msg == exp, "\n" ~ msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, "\n" ~ msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		enum empty = true;
		int front();
		void popFront();
		float back();
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	Foo must not be an autodecodable string but should be an aggregate type
	the property 'save' does not exist
	'Foo.empty' must either be 'enum bool = true' or 'ReturnType!(Foo.back)' must be equal to 'ReturnType!(Foo.front)'
	'Foo.empty' must either be 'enum bool = true' or 'Foo.length' must be of type 'size_t'
	Foo must allow for array indexing, aka. [] access`;
	static assert(msg == exp, "\n" ~ msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, "\n" ~ msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		enum empty = true;
		int front();
		void popFront();
		float back();
		Foo save() { return this; }
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	Foo must not be an autodecodable string but should be an aggregate type
	'Foo.empty' must either be 'enum bool = true' or 'ReturnType!(Foo.back)' must be equal to 'ReturnType!(Foo.front)'
	'Foo.empty' must either be 'enum bool = true' or 'Foo.length' must be of type 'size_t'
	Foo must allow for array indexing, aka. [] access`;
	static assert(msg == exp, "\n" ~ msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, "\n" ~ msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		enum empty = true;
		int front();
		void popFront();
		float back();
		Foo save() { return this; }
		int opIndex(size_t idx) { return 0; }
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	Foo must not be an autodecodable string but should be an aggregate type
	'Foo.empty' must either be 'enum bool = true' or 'ReturnType!(Foo.back)' must be equal to 'ReturnType!(Foo.front)'
	'Foo.empty' must either be 'enum bool = true' or 'Foo.length' must be of type 'size_t'`;
	static assert(msg == exp, "\n" ~ msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, "\n" ~ msg ~ "\n" ~ exp);
}

/// ditto
unittest {
	struct Foo {
		enum empty = true;
		int front();
		void popFront();
		float back();
		Foo save() { return this; }
		int opIndex(size_t idx) { return 0; }
		size_t length() { return 0; }
	}
	enum msg = isRandomAccessRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an RandomAccessRange because
	Foo must not be an autodecodable string but should be an aggregate type`;
	static assert(msg == exp, "\n" ~ msg ~ "\n" ~ exp);
	string msg2 = isRandomAccessRangeErrorFormatter!(Foo);
	assert(msg2 == exp, "\n" ~ msg ~ "\n" ~ exp);
}
+/

private:

struct Test {
	bool failed;
	string message;
}

//
// isFrontValid
//
Test isFrontValid(R)() {
	enum hasFront = is(typeof((return ref R r) => r.front));
	static if(hasFront) {
		alias RTfront = ReturnType!((R r) => r.front);
		enum hasFrontIsVoid = is(RTfront == void);
		static if(hasFrontIsVoid) {
			return Test(true
				, "the property 'front' does not return a non 'void' "
				~ "value");
		} else {
			return Test(false, "");
		}
	} else {
		return Test(true, "the property 'front' does not exist");
	}
}

unittest {
	struct Foo{}
	enum Test a = isFrontValid!Foo();
	static assert(a.failed);
	static assert(a.message == "the property 'front' does not exist"
			, a.message);
}

unittest {
	struct Foo{
		int front;
	}
	enum Test a = isFrontValid!Foo();
	static assert(!a.failed);
	static assert(a.message.empty, a.message);
}

//
// isBackValid
//
Test isBackValid(R)() {
	enum hasBack = is(typeof((return ref R r) => r.back));
	static if(hasBack) {
		alias RTback = ReturnType!((R r) => r.back);
		enum hasBackIsEqualToFront = is(RTback == ElementType!R);
		static if(!hasBackIsEqualToFront) {
			return Test(true
				, "the property 'back' does return a '" ~ RTback.stringof
				~ "' which is not equal to the type of 'front' which is '"
				~ ElementType!(R).stringof ~ "'");
		} else {
			return Test(false, "");
		}
	} else {
		return Test(true, "the property 'back' does not exist");
	}
}

unittest {
	struct Foo{}
	enum Test a = isBackValid!Foo();
	static assert(a.failed);
	static assert(a.message == "the property 'back' does not exist"
			, a.message);
}

unittest {
	struct Foo{
		int back;
	}
	enum Test a = isBackValid!Foo();
	static assert(a.failed);
	static assert(a.message == "the property 'back' does return a 'int' which is not equal to the type of 'front' which is 'void'"
			, a.message);
}

unittest {
	struct Foo{
		int back;
		double front;
	}
	enum Test a = isBackValid!Foo();
	static assert(a.failed);
	static assert(a.message == "the property 'back' does return a 'int' which is not equal to the type of 'front' which is 'double'"
			, a.message);
}

unittest {
	struct Foo{
		int back;
		int front;
	}
	enum Test a = isBackValid!Foo();
	static assert(!a.failed);
	static assert(a.message.empty, a.message);
}

//
// isPopFrontValid
//
Test isPopFrontValid(R)() {
	enum hasPopFront = is(typeof((R r) => r.popFront));
	static if(!hasPopFront) {
		return Test(true, "the function 'popFront' does not exist");
	} else {
		return Test(false, "");
	}
}

unittest {
	struct Foo{}
	enum Test a = isPopFrontValid!Foo();
	static assert(a.failed);
	static assert(a.message == "the function 'popFront' does not exist"
			, a.message);
}

unittest {
	struct Foo{
		void popFront();
	}
	enum Test a = isPopFrontValid!Foo();
	static assert(!a.failed);
	static assert(a.message.empty);
}

//
// isSaveValid
//
Test isSaveValid(R)() {
	enum hasSave = is(typeof((R r) => r.save));
	static if(hasSave) {
		alias RTsave = ReturnType!((R r) => r.save);
		enum isSaveR = is(RTsave == R);
		static if(!isSaveR) {
			return Test(true,
			"the property 'save' does not return a '" ~ R.stringof
				~ "' but a '" ~ RTsave.stringof ~ "'");
		} else {
			return Test(false, "");
		}
	} else {
		return Test(true, "the property 'save' does not exist");
	}
}

unittest {
	struct Foo{}
	enum Test a = isSaveValid!Foo();
	static assert(a.failed);
	static assert(a.message == "the property 'save' does not exist");
}

unittest {
	struct Foo{
		int save;
	}
	enum Test a = isSaveValid!Foo();
	static assert(a.failed);
	static assert(a.message == "the property 'save' does not return a 'Foo'"
			~ " but a 'int'");
}

//
// isValidEmpty
//
Test isValidEmpty(R)() {
	enum hasEmpty = __traits(hasMember, R, "empty");
	static if(hasEmpty) {
		static if (__traits(compiles, { enum e = R.empty; })) {
			enum bool b = R.empty;
			static if(b) {
				return Test(R.empty == false, "");
			} else {
				return Test(true, "the enum 'empty' must not be 'false'");
			}
		} else if(is(typeof(__traits(getMember, R, "empty")) == bool)) {
			return Test(false, "");
		} else {
			return Test(true, "the property 'empty' is not of type 'bool' but '"
					~ typeof(R.empty).stringof ~ "'");
		}
	} else {
		return Test(true, "the property 'empty' does not exist");
	}
}

unittest {
	struct Foo {}
	enum Test a = isValidEmpty!Foo();
	static assert(a.failed);
	static assert(a.message == "the property 'empty' does not exist"
			, a.message);
}

unittest {
	struct Foo {
		int empty;
	}
	enum Test a = isValidEmpty!Foo();
	static assert(a.failed);
	static assert(a.message ==
			"the property 'empty' is not of type 'bool' but 'int'"
			, a.message);
}

unittest {
	struct Foo {
		enum bool empty = false;
	}
	enum Test a = isValidEmpty!Foo();
	static assert(a.failed);
	static assert(a.message == "the enum 'empty' must not be 'false'"
			, a.message);
}

unittest {
	struct Foo {
		bool empty;
	}
	enum Test a = isValidEmpty!Foo();
	static assert(!a.failed);
	static assert(a.message.empty);
}

unittest {
	struct Foo {
		enum bool empty = true;
	}
	enum Test a = isValidEmpty!Foo();
	static assert(!a.failed, a.message);
	static assert(a.message.empty);
}

//
// isValidBoolEnum
//
Test isValidBoolEnum(R)() {
	static if (__traits(compiles, { enum e = R.empty; })) {
		enum bool b = R.empty;
		static if(b) {
			return Test(R.empty == false, "");
		} else {
			return Test(true, "the enum 'empty = true' must not be 'false'");
		}
	} else {
		return Test(true, "the enum 'empty = true' does not exist");
	}
}

unittest {
	struct Foo {}
	enum Test a = isValidBoolEnum!Foo();
	static assert(a.failed);
	static assert(a.message == "the enum 'empty = true' does not exist"
			, a.message);
}

unittest {
	struct Foo {
		int empty;
	}
	enum Test a = isValidBoolEnum!Foo();
	static assert(a.failed);
	static assert(a.message == "the enum 'empty = true' does not exist"
			, a.message);
}

unittest {
	struct Foo {
		enum bool empty = false;
	}
	enum Test a = isValidBoolEnum!Foo();
	static assert(a.failed);
	static assert(a.message == "the enum 'empty = true' must not be 'false'"
			, a.message);
}

unittest {
	struct Foo {
		bool empty;
	}
	enum Test a = isValidBoolEnum!Foo();
	static assert(a.failed);
	static assert(a.message == "the enum 'empty = true' does not exist"
			, a.message);
}

unittest {
	struct Foo {
		enum bool empty = true;
	}
	enum Test a = isValidBoolEnum!Foo();
	static assert(!a.failed, a.message);
	static assert(a.message.empty);
}

//
// isValidOpIndex
//
Test isValidOpIndex(R)() {
	static if(!is(typeof(lvalueOf!R[1]))) {
		return Test(true, "[] aka. opIndex not possible");
	} else static if(is(typeof(lvalueOf!R[1]))
			&& !is(typeof(lvalueOf!R[1]) == ElementType!R))
	{
		return Test(true
			, R.stringof ~ "[idx] is of type '"
			~ typeof(lvalueOf!R[1]).stringof ~ "' but must be equal to '"
			~ R.stringof ~ ".front' which is '" ~ ElementType!(R).stringof
			~ "'");
	} else {
		return Test(false, "");
	}
}

unittest {
	struct Foo {}
	enum Test a = isValidOpIndex!Foo();
	static assert(a.failed);
	static assert(a.message == "[] aka. opIndex not possible", a.message);
}

unittest {
	struct Foo {
		int opIndex(size_t i) { assert(false); }
	}
	enum Test a = isValidOpIndex!Foo();
	static assert(a.failed);
	static assert(a.message == "Foo[idx] is of type 'int' but must be equal to 'Foo.front' which is 'void'");
}

unittest {
	struct Foo {
		double front;
		int opIndex(size_t i) { assert(false); }
	}
	enum Test a = isValidOpIndex!Foo();
	static assert(a.failed);
	static assert(a.message == "Foo[idx] is of type 'int' but must be equal to 'Foo.front' which is 'double'");
}

unittest {
	struct Foo {
		int front;
		int opIndex(size_t i) { assert(false); }
	}
	enum Test a = isValidOpIndex!Foo();
	static assert(!a.failed);
	static assert(a.message);
}

//
// hasValidLength
//
Test hasValidLength(R)() {
	static if(hasLength!R) {
		return Test(false, "");
	} else {
		return Test(true, "property 'size_t length' is not defined");
	}
}

unittest {
	struct Foo {}
	enum Test a = hasValidLength!Foo();
	static assert(a.failed);
	static assert(a.message == "property 'size_t length' is not defined"
			, a.message);
}

unittest {
	struct Foo {
		double length;
	}
	enum Test a = hasValidLength!Foo();
	static assert(a.failed);
	static assert(a.message == "property 'size_t length' is not defined"
			, a.message);
}

unittest {
	struct Foo {
		size_t length;
	}
	enum Test a = hasValidLength!Foo();
	static assert(!a.failed);
	static assert(a.message.empty);
}

module range_primitives_helper;

import std.array;
import std.range : ElementType, hasLength, isBidirectionalRange, isInfinite;
import std.traits : ReturnType, isAutodecodableString, isAggregateType
		, lvalueOf;

@safe:

/**
* This function produces a descriptive message why `R` is not an InputRange.
* If `R` is an InputRange the returned string will say so.
*/
string isInputRangeErrorFormatter(R)() pure nothrow {
	static if(is(typeof(R.init) == R)) {
		bool failed = false;
		string ret = R.stringof ~ " is not an InputRange because";

		enum ev = isEmptyValid!R();
		failed |= ev.failed;
		ret ~= ev.message;

		enum fv = isFrontValid!R();
		failed |= fv.failed;
		ret ~= fv.message;

		enum pv = isPopFrontValid!R();
		failed |= pv.failed;
		ret ~= pv.message;

		return failed
			? ret
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
	enum exp =`Foo is not an InputRange because
	the property 'empty' does not exist
	the property 'front' does not exist
	the function 'popFront' does not exist`;
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
	enum exp =`Foo is not an InputRange because
	the property 'empty' does not return a 'bool' but a 'int'
	the property 'front' does not exist
	the function 'popFront' does not exist`;
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
	enum exp =`Foo is not an InputRange because
	the property 'front' does not return a non 'void' value
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
	}
	enum msg = isInputRangeErrorFormatter!(Foo);
	enum exp =`Foo is not an InputRange because
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

private:

struct Test {
	bool failed;
	string message;
}

Test isEmptyValid(R)() {
	enum hasEmpty = __traits(hasMember, R, "empty");
	static if(hasEmpty) {
		alias RTempty = ReturnType!((R r) => r.empty);
		enum hasEmptyIsBool = is(RTempty == bool);
		static if(!hasEmptyIsBool) {
			return Test(true,
			"\n\tthe property 'empty' does not return a 'bool' but "
				~ "a '" ~ RTempty.stringof ~ "'");
		} else {
			return Test(false, "");
		}
	} else {
		return Test(true, "\n\tthe property 'empty' does not exist");
	}
}

Test isFrontValid(R)() {
	enum hasFront = is(typeof((return ref R r) => r.front));
	static if(hasFront) {
		alias RTfront = ReturnType!((R r) => r.front);
		enum hasFrontIsVoid = is(RTfront == void);
		static if(hasFrontIsVoid) {
			return Test(true
				, "\n\tthe property 'front' does not return a non 'void' "
				~ "value");
		} else {
			return Test(false, "");
		}
	} else {
		return Test(true, "\n\tthe property 'front' does not exist");
	}
}

Test isBackValid(R)() {
	enum hasBack = is(typeof((return ref R r) => r.back));
	static if(hasBack) {
		alias RTback = ReturnType!((R r) => r.back);
		enum hasBackIsEqualToFront = is(RTback == ElementType!R);
		static if(!hasBackIsEqualToFront) {
			return Test(true
				, "\n\tthe property 'back' does return a '" ~ RTback.stringof
				~ "' which is not equal to the type of 'front' which is '"
				~ ElementType!(R).stringof ~ "'");
		} else {
			return Test(false, "");
		}
	} else {
		return Test(true, "\n\tthe property 'back' does not exist");
	}
}

Test isPopFrontValid(R)() {
	enum hasPopFront = is(typeof((R r) => r.popFront));
	static if(!hasPopFront) {
		return Test(true, "\n\tthe function 'popFront' does not exist");
	} else {
		return Test(false, "");
	}
}

Test isSaveValid(R)() {
	enum hasSave = is(typeof((R r) => r.save));
	static if(hasSave) {
		alias RTsave = ReturnType!((R r) => r.save);
		enum isSaveR = is(RTsave == R);
		static if(!isSaveR) {
			return Test(true,
			"\n\tthe property 'save' does not return a '" ~ R.stringof
				~ "' but a '" ~ RTsave.stringof ~ "'");
		} else {
			return Test(false, "");
		}
	} else {
		return Test(true, "\n\tthe property 'save' does not exist");
	}
}

Test isValidBoolEnum(R)() {
	enum hasEmpty = __traits(hasMember, R, "empty");
	static if(hasEmpty) {
		static if (isInputRange!R && __traits(compiles, { enum e = R.empty; })) {
			enum bool b = R.empty;
			static if(b) {
				return Test(R.empty, "");
			} else {
				return Test(true, "The enum " ~ R.stringof ~ ".empty must not "
						~ "false");
			}
		} else {
			return Test(true, R.stringof ~ ".empty is not an enum of type bool");
		}
	}
}

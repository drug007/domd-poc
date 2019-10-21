module meta;

// check if the member is property
private template isProperty(alias aggregate, string member)
{
	static if (__traits(compiles, isSomeFunction!(__traits(getMember, aggregate, member))))
	{
		static if (isSomeFunction!(__traits(getMember, aggregate, member)))
			enum bool isProperty = (functionAttributes!(__traits(getMember, aggregate, member)) & FunctionAttribute.property) != 0;
		else
			enum bool isProperty = false;
	}
	else
		enum bool isProperty = false;
}

private bool privateOrPackage()(string protection)
{
	return protection == "private" || protection == "package";
}

// check if the member is readable/writeble?
private enum isReadableAndWritable(alias aggregate, string member) = __traits(compiles, __traits(getMember, aggregate, member) = __traits(getMember, aggregate, member));
private enum isPublic(alias aggregate, string member) = !__traits(getProtection, __traits(getMember, aggregate, member)).privateOrPackage;

private template isField(alias aggregate, string member)
{
	enum bool isField = __traits(compiles, __traits(getMember, aggregate, member).offsetof);
}

// check if the member is readable
private enum bool isReadable(alias aggregate, string member) =
	__traits(compiles, { static fun(T)(auto ref T t) {} fun(__traits(getMember, aggregate, member)); });

// This trait defines what members should be processed -
// public members that are either readable and writable or getter properties
private template Processable(alias value, string member)
{
	static if (!isPublic!(value, member))
		enum Processable = false;
	else
		enum Processable = isReadable!(value, member); // any readable is good
}

private template FieldsAndProperties(alias value)
{
	import std.meta : ApplyLeft, AliasSeq, Filter;

	alias T = typeof(value);
	alias isProperty = ApplyLeft!(.isProperty, value);
	alias isField = ApplyLeft!(.isField, value);
	alias FieldsAndProperties = AliasSeq!(Filter!(isField, getAllMembers!T), Filter!(isProperty, getAllMembers!T));
}

private template getAllMembersImpl(T)
{
	static if (__traits(getAliasThis, T).length)
		alias getAllMembersImpl = AliasSeq!(getAllMembersImpl!(typeof(__traits(getMember, T.init, __traits(getAliasThis, T)))), Erase!(__traits(getAliasThis, T)[0], __traits(allMembers, T)));
	else
		alias getAllMembersImpl = __traits(allMembers, T);
}

import std.meta : Reverse, NoDuplicates;
private alias getAllMembers(T) = Reverse!(NoDuplicates!(Reverse!(getAllMembersImpl!T)));

/// returns alias sequence, members of which are members of value
/// that should be processed
template ProcessableMembers(alias a)
{
	import std.traits : isType;
	import std.meta : ApplyLeft, Filter;

	static if (isType!a)
		a value;
	else
		alias value = a;
	alias AllMembers = FieldsAndProperties!value;
	alias isProper = ApplyLeft!(Processable, value);
	alias ProcessableMembers = Filter!(isProper, AllMembers);
}
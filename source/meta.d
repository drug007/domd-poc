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

private template isField(alias aggregate, string member)
{
    enum bool isField = __traits(compiles, __traits(getMember, aggregate, member).offsetof);
}

private template FieldsAndProperties(alias value)
{
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

private alias getAllMembers(T) = Reverse!(NoDuplicates!(Reverse!(getAllMembersImpl!T)));

/// returns alias sequence, members of which are members of value
/// that should be processed
template ProcessableMembers(alias value)
{
	import std.meta : ApplyLeft, Filter;
	alias AllMembers = FieldsAndProperties!value;
	alias isProper = ApplyLeft!(Serializable, value);
	alias SerializableMembers = Filter!(isProper, AllMembers);
}
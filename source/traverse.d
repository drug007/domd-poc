module traverse;

import std.traits : isDynamicArray, isIntegral, isFloatingPoint, isBoolean, isSomeString;

enum isLeaf(T) = is(T == enum) || isIntegral!T || isFloatingPoint!T || isBoolean!T || isSomeString!T;
enum isNode(T) = is(T == struct) || isDynamicArray!T;
alias Identity(alias A) = A;

auto traverseImpl(alias leaf, alias nodeEnter, alias nodeLeave, Ctx, Data)(ref Ctx ctx, ref Data data)
{
	static if (isLeaf!(Data))
	{
		leaf(ctx, data);
	}
	else static if (isNode!(Data))
	{
		static if (is(typeof(ctx.nestingLevel) == long)) ctx.nestingLevel++;
		nodeEnter(ctx, data);

		static if (is(Data == struct))
		{
			import std.traits : isType;
			foreach(memberName; __traits(allMembers, (Data)))
				static if (!isType!(__traits(getMember, data, memberName)))
					traverseImpl!(leaf, nodeEnter, nodeLeave)(ctx, __traits(getMember, data, memberName));
		}
		else static if (isDynamicArray!(Data))
		{
			foreach(member; data)
				traverseImpl!(leaf, nodeEnter, nodeLeave)(ctx, member);
		}

		nodeLeave(ctx, data);
		static if (is(typeof(ctx.nestingLevel) == long)) ctx.nestingLevel--;
	}
	else
		static assert(0);
}

/// there are childs having no corresponding dom nodes
/// so we need ability to count child count using data only
/// without dom
auto childCount(Data)(Data data)
{
	import meta;

	static if (isNode!(Data))
	{
		static if (is(Data == struct))
		{
			return ProcessableMembers!Data.length;
		}
		else static if (isDynamicArray!(Data))
		{
			return data.length;
		}
		else
			static assert(0);
	}
	else
		return 0;
}

auto traverseImpl(alias leaf, alias nodeEnter, alias nodeLeave, Ctx, Data, Model)(ref Ctx ctx, ref Data data, ref Model model)
{
	static if (isLeaf!(Data))
	{
		leaf(ctx, data, model);
	}
	else static if (isNode!(Data))
	{
		import std.array : front, popFront;

		// Put on stack the current state of context before entering the next node
		// to restore it after leaving it
		auto old = ctx.area;
		ctx.nestingLevel++;
		nodeEnter(ctx, data, model);

		static if (is(Data == struct))
		{
			import std.traits : isType;
			auto childs = model.child.length ? model.child : [model];

			foreach(memberName; __traits(allMembers, Data))
			{
				ctx.area.x = ctx.xWidgetRange[$-1].front[0];
				ctx.area.w = ctx.xWidgetRange[$-1].front[1];
				ctx.area.y = ctx.yWidgetRange[$-1].front[0];
				ctx.area.h = ctx.yWidgetRange[$-1].front[1];

				alias member = Identity!(__traits(getMember, data, memberName));
				static if (!isType!member)
				{
					traverseImpl!(leaf, nodeEnter, nodeLeave)(ctx, mixin("data."~memberName), childs.front);
					model.child.length ? childs.popFront : {};
					ctx.xWidgetRange[$-1].popFront;
					ctx.yWidgetRange[$-1].popFront;
				}
			}
		}
		else static if (isDynamicArray!(Data))
		{
			foreach(member; data)
				traverseImpl!(leaf, nodeEnter, nodeLeave)(ctx, member, model);
		}
		ctx.area = old;

		nodeLeave(ctx, data, model);
		ctx.nestingLevel--;
	}
	else
		static assert(0);
}
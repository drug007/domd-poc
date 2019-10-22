module walker;

import common;

struct WidgetRange
{
	float x, delta, xend;

	invariant
	{
		import std.math, std.conv;

		assert(x >= 0, x.text);
		assert(xend.isNaN || xend >= 0);
		assert(!x.isNaN);
		assert(!delta.isNaN);
	}

	@disable this();

	this(float start, float marginBorderPadding, float range, size_t childCount)
	{
		x = start + marginBorderPadding;
		// x SHALL NOT BE greater than the widget size
		if (x > start + range)
		{
			x = start + range;
			delta = 0;
			xend = x;
			return;
		}

		if (childCount)
		{
			delta = (range - 2*marginBorderPadding)/childCount;
			xend = x+range - marginBorderPadding;
		}
		else
		{
			delta = (range - 2*marginBorderPadding);
			xend = float.nan;
		}
	}

	bool empty() const
	{
		return x >= xend;
	}

	auto front()
	{
		import std.typecons : tuple;
		return tuple(x, delta);
	}

	void popFront()
	{
		import std.math : isNaN;
		x += xend.isNaN ? 0 : delta;
	}
}

struct Walker
{
	WorkArea area;
	auto direction = Direction.row;
	auto alignment = Alignment.stretch;
	auto justification = Justification.around;

	WidgetRange[] xWidgetRange, yWidgetRange;

	auto wrapping = false;
	int nestingLevel;

	// for debug output in console
	string indentPrefix;

	import std.stdio;
	import traverse;

	@disable this();

	this(int w, int h)
	{
		area.x = area.y = 0;
		area.w = w;
		area.h = h;
		area.margin = 10;
		area.padding = 10;

		direction = Direction.column;
		alignment = Alignment.stretch;
		justification = Justification.around;
		wrapping = false;
	}

	auto render(Data, Dom)(Data data, Dom dom)
	{
		assert(dom);
		import std.math : isNaN;

		// defaulting
		if (area.margin.isNaN)
			area.margin = 0;
		if (area.padding.isNaN)
			area.padding = 0;

		traverseImpl!(leaf, nodeEnter, nodeLeave)(this, data, dom);
	}

	static auto leaf(Data, Dom)(ref typeof(this) ctx, Data data, Dom dom)
	{
		with(ctx)
		{
			writeln(indentPrefix, data);
			writeln(indentPrefix, ctx.area.w, "x", ctx.area.h);
			writeln(indentPrefix, dom.attributes.direction);
			if (!dom.attributes.direction.isNull)
				direction = dom.attributes.direction.get;
			if (!dom.attributes.margin.isNull)
				area.margin = dom.attributes.margin.get;
			if (!dom.attributes.padding.isNull)
				area.padding = dom.attributes.padding.get;
		}
	}

	static auto nodeEnter(Data, Dom)(ref typeof(this) ctx, Data data, Dom dom)
	{
		with(ctx)
		{
			writeln(indentPrefix, data);
			// writeln(indentPrefix, ctx.area.x, ", ", ctx.area.y, " ", ctx.area.w, "x", ctx.area.h);
			writeln(indentPrefix, ctx.area.margin);

			if (!dom.attributes.direction.isNull)
				direction = dom.attributes.direction.get;
			if (!dom.attributes.margin.isNull)
				area.margin = dom.attributes.margin.get;
			if (!dom.attributes.padding.isNull)
				area.padding = dom.attributes.padding.get;

			import std.math : isNaN;
			assert(!area.margin.isNaN);
			final switch (direction)
			{
				case Direction.row:
					xWidgetRange ~= WidgetRange(area.x, area.margin + area.padding, area.w, childCount(data));
					yWidgetRange ~= WidgetRange(area.y, area.margin + area.padding, area.h, 0);
					break;
				case Direction.rowReverse:
					assert(0, "not implemented");
					// break;
				case Direction.column:
					xWidgetRange ~= WidgetRange(area.x, area.margin + area.padding, area.w, 0);
					yWidgetRange ~= WidgetRange(area.y, area.margin + area.padding, area.h, childCount(data));
					break;
				case Direction.columnReverse:
					assert(0, "not implemented");
					// break;
			}

			indentPrefix ~= "\t";
		}
	}

	static auto nodeLeave(Data, Dom)(ref typeof(this) ctx, Data data, Dom dom)
	{
		ctx.indentPrefix = ctx.indentPrefix[0..$-1];
		ctx.xWidgetRange  = ctx.xWidgetRange [0..$-1];
		ctx.yWidgetRange  = ctx.yWidgetRange [0..$-1];
	}
}

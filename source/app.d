module app;

import std.typecons : Flag, Yes, No;
import renderer : render;

void singleItem(Flag!"runTest" runTest = Yes.runTest)
{
	import std.stdio;
	import std.array : front;
	import common : makeDom, DomNode, printDom, Direction, Margin, Padding;

	@(Direction.column)
	@Margin(20)
	@Padding(30)
	static struct Data
	{
	}

	Data data;
	auto root = makeDom(data);

	import walker : Walker;

	auto walker = Walker(640, 480);
	walker.render(data, root);

	walker.cmd_buf.render("single");

	if (!runTest)
		return;
}

void itemInColumn(Flag!"runTest" runTest = Yes.runTest)
{
	import std.stdio;
	import std.array : front;
	import common : makeDom, DomNode, printDom, Direction;
	import walker : Walker;

	@(Direction.column)
	static struct Data
	{
		string item0 = "item0", item1 = "item1", item2 = "item2", item3 = "item3";
	}

	Data data;
	auto root = makeDom(data);

	auto walker = Walker(640, 480);
	walker.render(data, root);

	walker.cmd_buf.render("itemInColumn");

	if (!runTest)
		return;
}

void itemInRow(Flag!"runTest" runTest = Yes.runTest)
{
	import std.stdio;
	import std.array : front;
	import common : makeDom, DomNode, printDom, Direction;
	import walker : Walker;

	static struct Data
	{
		string item0 = "item0", item1 = "item1", item2 = "item2", item3 = "item3";
	}

	Data data;

	auto root = makeDom(data);
	root.attributes.direction = Direction.row;
	root.attributes.margin = 20;
	root.attributes.padding = 30;
	auto walker = Walker(640, 480);
	walker.render(data, root);

	walker.cmd_buf.render("itemInRow");

	if (!runTest)
		return;
}

void complexCase(Flag!"runTest" runTest = Yes.runTest)
{
	import std.stdio;
	import std.array : front;
	import common : makeDom, DomNode, printDom, Direction, Margin, Padding;

	@(Direction.column)
	static struct Data
	{
		@Margin(0)
		@Padding(0)
		struct Child0
		{
			string item = "some long text";
		}

		Child0 child0;

		@(Direction.row)
		struct Child1
		{
			@(Direction.column)
			@(Margin(20))
			struct Panel0
			{
				struct Image
				{

				}

				Image image;

				struct Text
				{

				}

				Text text;
			}

			Panel0 panel0;

			@(Direction.column)
			struct Panel1
			{
				struct Text
				{

				}

				Text text;

				@(Direction.row)
				@Margin(5)
				@Padding(5)
				struct Panel
				{
					string ok = "ok", cancel = "cancel";
				}

				Panel panel;
			}

			Panel1 panel1;
		}

		Child1 child1;
	}

	Data data;

	import walker : Walker;
	import common : Direction, Alignment, Justification;
	auto walker = Walker(640, 480);
	walker.render(data, makeDom(data));

	walker.cmd_buf.render("complexCase");

	if (!runTest)
		return;
}

void main()
{
	singleItem(Yes.runTest);
	itemInRow(No.runTest);
	itemInColumn(No.runTest);
	complexCase(No.runTest);
}
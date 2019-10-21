module app;

import std.typecons : Flag, Yes, No;
import renderer : render;

void singleItem(Flag!"runTest" runTest = Yes.runTest)
{
	import std.stdio;
	import std.array : front;
	import common : makeDom, DomNode, printDom, Direction, Margin, Padding;

	@(Direction.column)
	@Margin(200)
	@Padding(300)
	static struct Data
	{
	}

	Data data;
	auto root = makeDom(data);

	import walker : Walker;

	auto walker = Walker(640, 480);
	walker.render(data, root);

	walker.renderlog.render("single");

	if (!runTest)
		return;

	import std.algorithm : each;
	import std.array : popFront;
	import common;

	auto log = walker.renderlog;
	log.each!writeln;

	assert(log.front.name == "Data");
	assert(log.front.area == WorkArea(0, 0, 640, 480, 200, 300));
	assert(log.front.direction == Direction.column);
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

	walker.renderlog.render("itemInColumn");

	if (!runTest)
		return;

	import std.array : popFront;
	import common;

	auto log = walker.renderlog;

	assert(log.front.name == "root");
	assert(log.front.area == WorkArea(0, 0, 640, 480, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item0");
	assert(log.front.area == WorkArea(10, 10, 620, 115, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item1");
	assert(log.front.area == WorkArea(10, 125, 620, 115, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item2");
	assert(log.front.area == WorkArea(10, 240, 620, 115, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item3");
	assert(log.front.area == WorkArea(10, 355, 620, 115, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;
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

	walker.renderlog.render("itemInRow");

	if (!runTest)
		return;

	import std.array : popFront;
	import common;

	auto log = walker.renderlog;

	assert(log.front.name == "root");
	assert(log.front.area == WorkArea(0, 0, 640, 480, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item0");
	assert(log.front.area == WorkArea(10, 10, 155, 460, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item1");
	assert(log.front.area == WorkArea(165, 10, 155, 460, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item2");
	assert(log.front.area == WorkArea(320, 10, 155, 460, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.item3");
	assert(log.front.area == WorkArea(475, 10, 155, 460, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;
}

void complexCase(Flag!"runTest" runTest = Yes.runTest)
{
	import std.stdio;
	import std.array : front;
	import common : makeDom, DomNode, printDom, Direction, Margin;

	@(Direction.column)
	static struct Data
	{
		struct Child0
		{

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
				struct Panel
				{
					struct Ok
					{

					}

					Ok ok;

					struct Cancel
					{

					}

					Cancel cancel;
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

	walker.renderlog.render("complexCase");

	if (!runTest)
		return;

	import std.array : popFront;
	import common;

	auto log = walker.renderlog;
	assert(log.front.name == "root");
	assert(log.front.area == WorkArea(0, 0, 640, 480, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child0");
	assert(log.front.area == WorkArea(10, 10, 620, 230, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1");
	assert(log.front.area == WorkArea(10, 240, 620, 230, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel0");
	assert(log.front.area == WorkArea(20, 250, 300, 210, 20));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel0.image");
	assert(log.front.area == WorkArea(40, 270, 260, 85, 20));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel0.text");
	assert(log.front.area == WorkArea(40, 355, 260, 85, 20));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel1");
	assert(log.front.area == WorkArea(320, 250, 300, 210, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel1.text");
	assert(log.front.area == WorkArea(330, 260, 280, 95, 10));
	assert(log.front.direction == Direction.column);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel1.panel");
	assert(log.front.area == WorkArea(330, 355, 280, 95, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel1.panel.ok");
	assert(log.front.area == WorkArea(340, 365, 130, 75, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;

	assert(log.front.name == "root.child1.panel1.panel.cancel");
	assert(log.front.area == WorkArea(470, 365, 130, 75, 10));
	assert(log.front.direction == Direction.row);
	log.popFront;
	log.popFront;
}

void main()
{
	singleItem(Yes.runTest);
	itemInRow(No.runTest);
	itemInColumn(No.runTest);
	complexCase(No.runTest);
}
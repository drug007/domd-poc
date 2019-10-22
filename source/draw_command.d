module draw_command;

import taggedalgebraic : TaggedAlgebraic;

import common : Rect, Color;

struct SetViewport
{
	float w, h;
}

struct DrawRect
{
	Rect  r;
	Color c;
	bool  filled;

	this()(auto ref Rect r, auto ref Color c, bool filled = false)
	{
		this.r = r;
		this.c = c;
		this.filled = filled;
	}
}

struct DrawText
{
	float x, y;
	string str;

	this(float x, float y, string str)
	{
		this.x = x;
		this.y = y;
		this.str = str;
	}
}

union AllCommands
{
	SetViewport set_viewport;
	DrawRect    draw_rect;
	DrawText    draw_text;
}

alias DrawCommand = TaggedAlgebraic!AllCommands;
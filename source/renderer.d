module renderer;

import printed.canvas : IRenderingContext2D;
import draw_command : DrawCommand;

private void renderTo(DrawCommand[] cmd_buf, IRenderingContext2D ctx)
{
	import printed.canvas;
	with (ctx)
	{
		float k;
		foreach(rs; cmd_buf)
		{
			final switch (rs.kind)
			{
				case DrawCommand.Kind.set_viewport:
					k = pageWidth / cmd_buf[0].w;
					lineWidth(k);
				break;
				case DrawCommand.Kind.draw_rect:
					import std.math : isNaN;
					import std.exception : enforce;

					if (rs.r.w < 1 || rs.r.h < 1)
						break;
					enforce(!k.isNaN);
					with(rs.r)
					{
						if (rs.filled)
						{
							fillStyle = brush(rs.c.r, rs.c.g, rs.c.b, rs.c.a);
							fillRect(x*k, y*k, w*k, h*k);
							fill;
						}
						strokeStyle = brush(rs.c.r, rs.c.g, rs.c.b, rs.c.a);
						beginPath(x*k, y*k);
						lineTo((x+w)*k, y*k);
						lineTo((x+w)*k, (y+h)*k);
						lineTo(x*k, (y+h)*k);
						lineTo(x*k, y*k);
						closePath;
						stroke;
					}
				break;
				case DrawCommand.Kind.draw_text:
					assert(0);
			}
		}
	}
}

void render(DrawCommand[] cmd_buf, string filename)
{
	import std.typecons : Tuple, tuple;
	import std.file;
	import printed.canvas : PDFDocument, HTMLDocument, SVGDocument;
	
	{
		auto pdf = new PDFDocument (210, 297);
		cmd_buf.renderTo(pdf);
		std.file.write(filename ~ ".pdf", pdf.bytes);
	}
	
	{
		auto svg = new SVGDocument (210, 297);
		cmd_buf.renderTo(svg);
		std.file.write(filename ~ ".svg", svg.bytes);
	}
	
	{
		auto html = new HTMLDocument (210, 297);
		cmd_buf.renderTo(html);
		std.file.write(filename ~ ".html", html.bytes);
	}
}